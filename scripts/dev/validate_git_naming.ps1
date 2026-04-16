param(
  [ValidateSet('branch', 'tag', 'all')]
  [string]$Type = 'all',
  [string]$Name,
  [switch]$AllowTaskBranch,
  [string]$PrdVersion
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$branchPatterns = @(
  '^main$',
  '^release/v\d+\.\d+\.\d+$',
  '^feat/prd-\d+\.\d+\.\d+/main$',
  '^(fix|hotfix|docs|chore|refactor|test)/[a-z0-9]+(?:-[a-z0-9]+)*$'
)

$taskBranchPattern = '^feat/prd-\d+\.\d+\.\d+/t\d{2}-[a-z0-9]+(?:-[a-z0-9]+)*$'
$tagPattern = '^v\d+\.\d+\.\d+(-(alpha|beta|rc)\.\d+)?$'

function Test-ByPatterns {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Value,
    [Parameter(Mandatory = $true)]
    [string[]]$Patterns
  )

  foreach ($pattern in $Patterns) {
    if ($Value -match $pattern) {
      return $true
    }
  }

  return $false
}

function Get-CurrentPrdVersionFromBranch {
  $branchName = (git rev-parse --abbrev-ref HEAD).Trim()

  if ($branchName -match '^feat/prd-(\d+\.\d+\.\d+)/(main|t\d{2}-[a-z0-9]+(?:-[a-z0-9]+)*)$') {
    return $Matches[1]
  }

  if ($branchName -match '^release/v(\d+\.\d+\.\d+)$') {
    return $Matches[1]
  }

  return $null
}

function Get-TagBaseVersion {
  param([string]$TagName)

  if ($TagName -match '^v(\d+\.\d+\.\d+)(-(alpha|beta|rc)\.\d+)?$') {
    return $Matches[1]
  }

  return $null
}

function Validate-Branch {
  param([string]$BranchName)

  if (-not $BranchName) {
    $BranchName = (git rev-parse --abbrev-ref HEAD).Trim()
  }

  if ($BranchName -match $taskBranchPattern) {
    if ($AllowTaskBranch) {
      Write-Host "[PASS] 任务分支名合法（已启用 -AllowTaskBranch）：$BranchName"
      return $true
    }

    Write-Host "[FAIL] 当前为任务分支：$BranchName"
    Write-Host '根据仓库规范，任务分支仅允许在“多 agent + git worktree 并行执行”场景使用。'
    Write-Host '如确认是该场景，请重新执行并加上参数：-AllowTaskBranch'
    return $false
  }

  if (Test-ByPatterns -Value $BranchName -Patterns $branchPatterns) {
    Write-Host "[PASS] 分支名合法：$BranchName"
    return $true
  }

  Write-Host "[FAIL] 分支名不符合规范：$BranchName"
  Write-Host '允许格式：'
  Write-Host '  1) main'
  Write-Host '  2) release/v<major>.<minor>.<patch>'
  Write-Host '  3) feat/prd-<version>/main'
  Write-Host '  4) fix|hotfix|docs|chore|refactor|test/<slug>'
  Write-Host '  5) feat/prd-<version>/t<nn>-<slug>（仅多 agent + worktree 场景）'
  return $false
}

function Validate-Tag {
  param(
    [string]$TagName,
    [string]$ExpectedPrdVersion
  )

  if (-not $TagName) {
    throw '校验 tag 时必须通过 -Name 传入标签名。'
  }

  if ($TagName -notmatch $tagPattern) {
    Write-Host "[FAIL] 标签名不符合规范：$TagName"
    Write-Host '允许格式：v<major>.<minor>.<patch> 或 v<major>.<minor>.<patch>-rc.<n>|-beta.<n>|-alpha.<n>'
    return $false
  }

  $baseVersion = Get-TagBaseVersion -TagName $TagName
  if ($ExpectedPrdVersion -and $baseVersion -ne $ExpectedPrdVersion) {
    Write-Host "[FAIL] 标签版本与 PRD 版本不一致：$TagName"
    Write-Host "  - 期望 PRD 版本：$ExpectedPrdVersion"
    Write-Host "  - 标签主版本：$baseVersion"
    return $false
  }

  if ($ExpectedPrdVersion) {
    Write-Host "[PASS] 标签名合法且与 PRD 版本一致：$TagName"
  }
  else {
    Write-Host "[PASS] 标签名合法：$TagName"
  }

  return $true
}

$ok = $true

switch ($Type) {
  'branch' {
    $ok = Validate-Branch -BranchName $Name
  }
  'tag' {
    $expectedPrdVersion = $PrdVersion
    if (-not $expectedPrdVersion) {
      $expectedPrdVersion = Get-CurrentPrdVersionFromBranch
      if ($expectedPrdVersion) {
        Write-Host "[INFO] 未显式传入 -PrdVersion，已从当前分支推断 PRD 版本：$expectedPrdVersion"
      }
      else {
        Write-Host '[WARN] 未能推断 PRD 版本，本次仅执行标签格式校验。'
      }
    }

    $ok = Validate-Tag -TagName $Name -ExpectedPrdVersion $expectedPrdVersion
  }
  'all' {
    if (-not (Validate-Branch -BranchName $null)) {
      $ok = $false
    }

    $tags = git tag --list
    foreach ($tag in $tags) {
      $trimmed = $tag.Trim()
      if (-not $trimmed) {
        continue
      }

      if (-not (Validate-Tag -TagName $trimmed -ExpectedPrdVersion $PrdVersion)) {
        $ok = $false
      }
    }

    if (-not $PrdVersion) {
      Write-Host '[INFO] all 模式默认对历史标签仅做格式校验；如需校验与 PRD 版本一致，请显式传入 -PrdVersion。'
    }
  }
}

if (-not $ok) {
  exit 1
}

exit 0
