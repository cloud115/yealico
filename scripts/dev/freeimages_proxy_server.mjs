import http from 'node:http';

const port = Number.parseInt(process.env.PORT ?? '8787', 10);
const targetOrigin = process.env.TARGET_ORIGIN ?? 'https://www.freeimages.com';
const allowOrigin = process.env.ALLOW_ORIGIN ?? '*';

const hopByHopHeaders = new Set([
  'connection',
  'keep-alive',
  'proxy-authenticate',
  'proxy-authorization',
  'te',
  'trailers',
  'transfer-encoding',
  'upgrade',
]);

function setCorsHeaders(res) {
  res.setHeader('Access-Control-Allow-Origin', allowOrigin);
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'Content-Type,Accept,Accept-Language,Cache-Control,Pragma',
  );
}

function copyResponseHeaders(upstream, req, res) {
  for (const [key, value] of upstream.headers.entries()) {
    const lower = key.toLowerCase();
    if (hopByHopHeaders.has(lower)) {
      continue;
    }
    if (lower === 'content-encoding') {
      continue;
    }
    if (lower === 'content-length') {
      continue;
    }
    if (lower === 'location') {
      try {
        const redirectUrl = new URL(value, targetOrigin);
        const target = new URL(targetOrigin);
        if (redirectUrl.origin === target.origin) {
          const localOrigin = `http://${req.headers.host}`;
          const localRedirect = new URL(
            `${redirectUrl.pathname}${redirectUrl.search}${redirectUrl.hash}`,
            localOrigin,
          );
          res.setHeader('Location', localRedirect.toString());
          continue;
        }
      } catch {
        // Ignore rewrite failures and keep original header.
      }
    }
    res.setHeader(key, value);
  }
}

function buildUpstreamHeaders(req) {
  const headers = new Headers();
  const incoming = req.headers;
  if (typeof incoming.accept === 'string' && incoming.accept) {
    headers.set('accept', incoming.accept);
  }
  if (
    typeof incoming['accept-language'] === 'string' &&
    incoming['accept-language']
  ) {
    headers.set('accept-language', incoming['accept-language']);
  }
  if (typeof incoming['cache-control'] === 'string' && incoming['cache-control']) {
    headers.set('cache-control', incoming['cache-control']);
  }
  if (typeof incoming.pragma === 'string' && incoming.pragma) {
    headers.set('pragma', incoming.pragma);
  }
  headers.set(
    'user-agent',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
  );
  headers.set('referer', `${targetOrigin}/`);
  return headers;
}

const server = http.createServer(async (req, res) => {
  setCorsHeaders(res);

  if (req.method === 'OPTIONS') {
    res.statusCode = 204;
    res.end();
    return;
  }

  if (req.url === '/health') {
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    res.end(
      JSON.stringify({
        ok: true,
        targetOrigin,
      }),
    );
    return;
  }

  if (req.method !== 'GET') {
    res.statusCode = 405;
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    res.end(JSON.stringify({ error: 'Only GET is supported.' }));
    return;
  }

  try {
    const incomingUrl = new URL(req.url ?? '/', `http://${req.headers.host}`);
    const targetUrl = new URL(
      `${incomingUrl.pathname}${incomingUrl.search}`,
      targetOrigin,
    );

    const upstream = await fetch(targetUrl, {
      method: 'GET',
      headers: buildUpstreamHeaders(req),
      redirect: 'follow',
    });
    const body = Buffer.from(await upstream.arrayBuffer());

    res.statusCode = upstream.status;
    copyResponseHeaders(upstream, req, res);
    res.setHeader('Content-Length', String(body.length));
    res.end(body);
  } catch (error) {
    res.statusCode = 502;
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    res.end(
      JSON.stringify({
        error: 'Proxy request failed.',
        message: error instanceof Error ? error.message : String(error),
      }),
    );
  }
});

server.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`FreeImages dev proxy running at http://localhost:${port}`);
  // eslint-disable-next-line no-console
  console.log(`Target origin: ${targetOrigin}`);
});
