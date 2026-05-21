function Create-DES {
    $des = [System.Security.Cryptography.DES]::Create()
    $des.Key = [byte[]](0xE8, 0x4A, 0xD6, 0x60, 0xC4, 0x72, 0x1A, 0xE0)
    $des.IV  = [byte[]](0xE8, 0x4A, 0xD6, 0x60, 0xC4, 0x72, 0x1A, 0xE0)
    $des.Mode    = [System.Security.Cryptography.CipherMode]::ECB
    $des.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
    return $des
}

function ByteArrayToHex([byte[]]$bytes) {
    $sb = New-Object System.Text.StringBuilder
    foreach ($b in $bytes) {
        $sb.Append($b.ToString("X2")) | Out-Null
    }
    return $sb.ToString()
}

function HexToByteArray([string]$hex) {
    if ($hex.Length % 2 -ne 0) {
        throw "The binary key cannot have an odd number of digits"
    }
    $bytes = New-Object byte[] ($hex.Length / 2)
    for ($i = 0; $i -lt $hex.Length; $i += 2) {
        $bytes[$i / 2] = [Convert]::ToByte($hex.Substring($i, 2), 16)
    }
    return $bytes
}

function Encrypt-Password([string]$plainPassword) {
    $des = Create-DES
    $encryptor = $des.CreateEncryptor()

    $plainPassword = $plainPassword + "`u{fffd}`u{fffd}`u{fffd}`u{fffd}`u{fffd}`u{fffd}`u{fffd}`u{fffd}"
    if ($plainPassword.Length -gt 8) { $plainPassword = $plainPassword.Substring(0, 8) }

    $data           = [System.Text.Encoding]::ASCII.GetBytes($plainPassword)
    $encryptedBytes = $encryptor.TransformFinalBlock($data, 0, $data.Length)

    return (ByteArrayToHex $encryptedBytes) + "00"
}

function Decrypt-Password([string]$encryptedPassword) {
    $des = Create-DES
    $decryptor = $des.CreateDecryptor()

    $hex            = $encryptedPassword.Substring(0, $encryptedPassword.Length - 2)
    $data           = HexToByteArray $hex
    $decryptedBytes = $decryptor.TransformFinalBlock($data, 0, $data.Length)

    return [System.Text.Encoding]::ASCII.GetString($decryptedBytes)
}

# --- Main ---
Write-Host "Type in the encrypted password: " -NoNewline
$input = Read-Host
if ($input) {
    Write-Host ("The password is: " + (Decrypt-Password $input))
}
Write-Host "Press enter to exit." -NoNewline
Read-Host
