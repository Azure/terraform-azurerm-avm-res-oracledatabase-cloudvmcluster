$ErrorActionPreference = 'Stop'

$envPath = Join-Path $PSScriptRoot '.env'
$statePath = Join-Path $PSScriptRoot '.avm-ssh-fixture'
if (Test-Path -LiteralPath $statePath) {
    throw 'An earlier X11M SSH fixture requires cleanup before the example can run.'
}

$existed = Test-Path -LiteralPath $envPath -PathType Leaf
[byte[]] $original = @()
if ($existed) {
    $original = [System.IO.File]::ReadAllBytes($envPath)
}
$text = [System.Text.UTF8Encoding]::new($false, $true).GetString($original).TrimStart([char]0xFEFF)
if ($null -ne [Environment]::GetEnvironmentVariable('TF_VAR_ssh_public_keys') -or
    $text -cmatch '(?m)^[ \t]*(?:export [ \t]*)?TF_VAR_ssh_public_keys[ \t]*=') {
    return
}

$rsa = [System.Security.Cryptography.RSA]::Create(2048)
try {
    $key = $rsa.ExportParameters($false)
}
finally {
    $rsa.Dispose()
}

$wire = [System.IO.MemoryStream]::new()
try {
    foreach ($part in @(
            [System.Text.Encoding]::ASCII.GetBytes('ssh-rsa'),
            $key.Exponent,
            $key.Modulus
        )) {
        [byte[]] $bytes = $part
        if ($bytes[0] -band 0x80) {
            $bytes = [byte[]]@(0) + $bytes
        }
        $length = [BitConverter]::GetBytes([Net.IPAddress]::HostToNetworkOrder([int]$bytes.Length))
        $wire.Write($length, 0, $length.Length)
        $wire.Write($bytes, 0, $bytes.Length)
    }
    $publicKey = 'ssh-rsa ' + [Convert]::ToBase64String($wire.ToArray())
}
finally {
    $wire.Dispose()
}

$fixture = [System.Text.Encoding]::UTF8.GetBytes("`nTF_VAR_ssh_public_keys=[`"$publicKey`"]`n")
$originalHash = [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($original))
$state = @{
    Existed = $existed
    Length  = $original.Length
    Hash    = $originalHash
    Fixture = [Convert]::ToBase64String($fixture)
} | ConvertTo-Json -Compress
$stateStream = [System.IO.File]::Open($statePath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
try {
    $stateBytes = [System.Text.Encoding]::UTF8.GetBytes($state)
    $stateStream.Write($stateBytes, 0, $stateBytes.Length)
}
finally {
    $stateStream.Dispose()
}

$envStream = [System.IO.File]::Open($envPath, [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
try {
    if ($envStream.Length -ne $original.Length) {
        throw 'The X11M .env file changed while preparing the SSH fixture.'
    }
    $currentHash = [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($envStream))
    if ($currentHash -ne $originalHash) {
        throw 'The X11M .env file changed while preparing the SSH fixture.'
    }
    $envStream.Position = $envStream.Length
    $envStream.Write($fixture, 0, $fixture.Length)
}
finally {
    $envStream.Dispose()
}
