$ErrorActionPreference = 'Stop'

$envPath = Join-Path $PSScriptRoot '.env'
$statePath = Join-Path $PSScriptRoot '.avm-ssh-fixture'
if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) {
    return
}

$state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
$fixture = [Convert]::FromBase64String($state.Fixture)
if (-not (Test-Path -LiteralPath $envPath -PathType Leaf)) {
    if ($state.Existed) {
        throw 'The X11M .env file was removed; SSH fixture cleanup was not performed.'
    }
    Remove-Item -LiteralPath $statePath -Force
    return
}

$envStream = [System.IO.File]::Open($envPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
try {
    if ($envStream.Length -lt $state.Length -or $envStream.Length -gt ($state.Length + $fixture.Length)) {
        throw 'The X11M .env file changed; SSH fixture cleanup was not performed.'
    }
    $original = [byte[]]::new($state.Length)
    $envStream.ReadExactly($original, 0, $original.Length)
    $hash = [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($original))
    if ($hash -ne $state.Hash) {
        throw 'The X11M .env file changed; SSH fixture cleanup was not performed.'
    }
    $suffix = [byte[]]::new($envStream.Length - $state.Length)
    $envStream.ReadExactly($suffix, 0, $suffix.Length)
    for ($i = 0; $i -lt $suffix.Length; $i++) {
        if ($suffix[$i] -ne $fixture[$i]) {
            throw 'The X11M .env file changed; SSH fixture cleanup was not performed.'
        }
    }
    $envStream.SetLength($state.Length)
}
finally {
    $envStream.Dispose()
}

if (-not $state.Existed) {
    Remove-Item -LiteralPath $envPath -Force
}
Remove-Item -LiteralPath $statePath -Force
