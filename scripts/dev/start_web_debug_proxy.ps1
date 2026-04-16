param(
  [string]$ProxyUrl = 'http://127.0.0.1:7890',
  [ValidateSet('auto', 'node', 'powershell')]
  [string]$FetchMode = 'powershell',
  [int]$Port = 8787,
  [string]$TargetOrigin = 'https://www.freeimages.com',
  [string]$AllowOrigin = '*',
  [switch]$NoProxy
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Resolve-Path (Join-Path $scriptDir '..\..')
$proxyScriptPath = Join-Path $projectRoot 'scripts\dev\freeimages_proxy_server.mjs'

if (-not (Test-Path -LiteralPath $proxyScriptPath)) {
  throw "Proxy script not found: $proxyScriptPath"
}

$env:UPSTREAM_FETCH_MODE = $FetchMode
$env:PORT = "$Port"
$env:TARGET_ORIGIN = $TargetOrigin
$env:ALLOW_ORIGIN = $AllowOrigin

if ($NoProxy) {
  Remove-Item Env:HTTP_PROXY -ErrorAction SilentlyContinue
  Remove-Item Env:HTTPS_PROXY -ErrorAction SilentlyContinue
  Write-Host '[web-debug-proxy] Upstream proxy disabled. Running in direct mode.'
} else {
  $env:HTTP_PROXY = $ProxyUrl
  $env:HTTPS_PROXY = $ProxyUrl
  Write-Host "[web-debug-proxy] Upstream proxy set to: $ProxyUrl"
}

Write-Host "[web-debug-proxy] UPSTREAM_FETCH_MODE=$($env:UPSTREAM_FETCH_MODE)"
Write-Host "[web-debug-proxy] PORT=$($env:PORT)"
Write-Host "[web-debug-proxy] TARGET_ORIGIN=$($env:TARGET_ORIGIN)"
Write-Host '[web-debug-proxy] Starting proxy server...'

node $proxyScriptPath
