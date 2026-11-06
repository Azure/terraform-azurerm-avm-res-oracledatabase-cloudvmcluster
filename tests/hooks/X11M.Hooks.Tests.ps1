param(
    [Parameter(Mandatory)]
    [string] $FixtureRoot
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $FixtureRoot -PathType Container) -or
    @(Get-ChildItem -LiteralPath $FixtureRoot -Force).Count -ne 0) {
    throw 'FixtureRoot must be an existing, empty directory.'
}

$example = Join-Path $PSScriptRoot '..\..\examples\X11M'
Copy-Item -LiteralPath (Join-Path $example 'pre.ps1'), (Join-Path $example 'post.ps1') -Destination $FixtureRoot
$pre = Join-Path $FixtureRoot 'pre.ps1'
$post = Join-Path $FixtureRoot 'post.ps1'
$envPath = Join-Path $FixtureRoot '.env'
$statePath = Join-Path $FixtureRoot '.avm-ssh-fixture'
$previous = [Environment]::GetEnvironmentVariable('TF_VAR_ssh_public_keys')

try {
    [Environment]::SetEnvironmentVariable('TF_VAR_ssh_public_keys', $null)
    & $pre
    $value = Get-Content -LiteralPath $envPath -Raw
    if ($value -notmatch 'TF_VAR_ssh_public_keys=\["ssh-rsa ([A-Za-z0-9+/=]+)"\]') {
        throw 'Fallback did not produce an SSH RSA public key.'
    }
    $wire = [Convert]::FromBase64String($Matches[1])
    $stream = [System.IO.MemoryStream]::new($wire)
    try {
        $parts = @()
        for ($i = 0; $i -lt 3; $i++) {
            $lengthBytes = [byte[]]::new(4)
            $stream.ReadExactly($lengthBytes, 0, 4)
            $length = [Net.IPAddress]::NetworkToHostOrder([BitConverter]::ToInt32($lengthBytes))
            if ($length -lt 1 -or $length -gt 1024) { throw 'Invalid SSH key field length.' }
            $bytes = [byte[]]::new($length)
            $stream.ReadExactly($bytes, 0, $length)
            $parts += ,$bytes
        }
        if ([Text.Encoding]::ASCII.GetString($parts[0]) -ne 'ssh-rsa' -or
            $parts[2].Length -lt 256 -or $stream.Position -ne $stream.Length) {
            throw 'Invalid SSH RSA public key.'
        }
    }
    finally {
        $stream.Dispose()
    }
    if ($IsWindows) {
        foreach ($path in @($envPath, $statePath)) {
            $attributes = [System.IO.File]::GetAttributes($path)
            [System.IO.File]::SetAttributes($path, $attributes -bor [System.IO.FileAttributes]::Hidden)
        }
    }
    & $post
    if ((Test-Path -LiteralPath $envPath) -or (Test-Path -LiteralPath $statePath)) {
        throw 'Fallback files were not cleaned up.'
    }

    $original = [Text.Encoding]::UTF8.GetBytes('OTHER_VALUE=original')
    [System.IO.File]::WriteAllBytes($envPath, $original)
    & $pre
    & $post
    if (-not [System.Linq.Enumerable]::SequenceEqual([byte[]][System.IO.File]::ReadAllBytes($envPath), $original)) {
        throw 'An existing .env file was not preserved byte-for-byte.'
    }

    [System.IO.File]::WriteAllBytes($envPath, [byte[]]@())
    & $pre
    & $post
    if (-not (Test-Path -LiteralPath $envPath) -or (Get-Item -LiteralPath $envPath).Length -ne 0) {
        throw 'An existing empty .env file was not preserved.'
    }

    [System.IO.File]::WriteAllBytes($envPath, $original)
    [Environment]::SetEnvironmentVariable('TF_VAR_ssh_public_keys', '["caller"]')
    & $pre
    & $post
    if (Test-Path -LiteralPath $statePath) { throw 'Environment input was overwritten.' }
    if (-not [System.Linq.Enumerable]::SequenceEqual([byte[]][System.IO.File]::ReadAllBytes($envPath), $original)) {
        throw 'Environment input changed .env.'
    }

    [Environment]::SetEnvironmentVariable('TF_VAR_ssh_public_keys', $null)
    $caller = "export TF_VAR_ssh_public_keys=[`"caller`"]`nOTHER_VALUE=original`n"
    [System.IO.File]::WriteAllText($envPath, $caller, [System.Text.UTF8Encoding]::new($true))
    $callerBytes = [System.IO.File]::ReadAllBytes($envPath)
    & $pre
    & $post
    if ((Test-Path -LiteralPath $statePath) -or
        -not [System.Linq.Enumerable]::SequenceEqual([byte[]][System.IO.File]::ReadAllBytes($envPath), $callerBytes)) {
        throw '.env input was overwritten.'
    }

    [System.IO.File]::WriteAllBytes($envPath, $original)
    & $pre
    [System.IO.File]::AppendAllText($envPath, 'caller edit')
    $changed = [System.IO.File]::ReadAllBytes($envPath)
    $cleanupFailed = $false
    try { & $post } catch { $cleanupFailed = $true }
    if (-not $cleanupFailed -or
        -not [System.Linq.Enumerable]::SequenceEqual([byte[]][System.IO.File]::ReadAllBytes($envPath), $changed)) {
        throw 'Cleanup did not preserve a concurrently modified .env file.'
    }

    'X11M hook fallback, precedence, key format, and cleanup checks passed.'
}
finally {
    [Environment]::SetEnvironmentVariable('TF_VAR_ssh_public_keys', $previous)
    Remove-Item -LiteralPath $pre, $post, $envPath, $statePath -Force -ErrorAction SilentlyContinue
}
