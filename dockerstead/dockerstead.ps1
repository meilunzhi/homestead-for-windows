param(
    [Parameter(Position=0)] [string] $Command = "help",
    [Parameter(Position=1, ValueFromRemainingArguments=$true)] [string[]] $Arguments
)
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Compose = @("compose", "--project-directory", $Root, "-f", (Join-Path $Root "docker-compose.yaml"))
$EnvFile = Join-Path $Root ".env"
if (Test-Path $EnvFile) { $Compose += @("--env-file", $EnvFile) }
switch ($Command.ToLowerInvariant()) {
    "up" { & docker @Compose up -d @Arguments }
    "down" { & docker @Compose down @Arguments }
    "build" { & docker @Compose build @Arguments }
    "restart" { & docker @Compose down; & docker @Compose up -d }
    "ps" { & docker @Compose ps }
    "status" { & docker @Compose ps }
    "logs" { & docker @Compose logs -f @Arguments }
    "config" { & docker @Compose config }
    "shell" { $Service = if ($Arguments.Count) { $Arguments[0] } else { "php83" }; & docker @Compose exec $Service sh }
    "composer" { $Service = if ($Arguments.Count) { $Arguments[0] } else { "php83" }; $Rest = if ($Arguments.Count -gt 1) { $Arguments[1..($Arguments.Count-1)] } else { @() }; & docker @Compose exec $Service composer @Rest }
    "mysql" { & docker @Compose exec mysql mysql -uhomestead -psecret homestead }
    "redis" { & docker @Compose exec redis redis-cli }
    default { Write-Host "Usage: .\dockerstead.ps1 {up|down|build|restart|ps|logs|config|shell|composer|mysql|redis}"; Write-Host "PHP services: php74..php85, frankenphp82..frankenphp85" }
}
