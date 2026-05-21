# UltraVNC Password Decryptor

A PowerShell script to decrypt passwords stored by [UltraVNC](https://www.uvnc.com/) in its
configuration files (e.g. `ultravnc.ini`).

## Background

UltraVNC encrypts passwords using DES with a hardcoded key. This script reverses that process
to recover the plaintext password from the hex-encoded ciphertext found in the config file.

## Requirements

- Windows PowerShell 5.1 **or** PowerShell 7+
- No external dependencies — uses built-in .NET cryptography classes

## Usage

Run the script and paste in the encrypted password when prompted:

```powershell
.\UltraVNC-Decrypt.ps1

Type in the encrypted password: 3B87CDF66850B1AE00
The password is: mypassword
```

### Where to find the encrypted password

Open `ultravnc.ini` (typically located at `C:\Program Files\uvnc bvba\UltraVNC\ultravnc.ini`)
and look for:

```ini
[ultravnc]
passwd=3B87CDF66850B1AE00
passwd2=...
```

Copy the value after `passwd=` and paste it into the prompt.

## Functions

| Function | Description |
|---|---|
| `Decrypt-Password` | Decrypts a hex-encoded UltraVNC password string |
| `Encrypt-Password` | Encrypts a plaintext password into UltraVNC's format |
| `Create-DES` | Initialises the DES cipher with UltraVNC's hardcoded key |

## Security Notice

UltraVNC's password encryption is **not secure**. It uses a static, publicly known DES key.
Anyone with read access to `ultravnc.ini` can trivially recover the password. Consider:

- Restricting file permissions on `ultravnc.ini`
- Using VPN or SSH tunnelling instead of relying on VNC's built-in auth
- Switching to a VNC implementation with stronger authentication
