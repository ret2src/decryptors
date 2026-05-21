# UltraVNC Password Decryptor

Decrypt passwords stored by [UltraVNC](https://www.uvnc.com/) in its configuration files (e.g. `ultravnc.ini`). Available as a PowerShell script for Windows and a Bash script for Linux.

## Background

UltraVNC encrypts passwords using DES with a hardcoded key. The decryptors in this directory reverse this process to recover the plaintext password from the hex-encoded ciphertext found in the config file.

## Files

| File | Platform |
|---|---|
| `UltraVNC-Decrypt.ps1` | Windows (PowerShell) |
| `ultravnc_decrypt.sh` | Linux (Bash) |

## Requirements

### UltraVNC-Decrypt.ps1
- Windows PowerShell 5.1 **or** PowerShell 7+
- No external dependencies — uses built-in .NET cryptography classes

### ultravnc_decrypt.sh
- `openssl` with the **legacy provider** enabled (required for DES support in OpenSSL 3.x)
- `xxd`

On Debian/Ubuntu, install the legacy provider if needed:

```bash
sudo apt install openssl-legacy-provider
```    

Then verify it is available:

```bash
openssl list -providers
```

## Usage

### Windows

```powershell
.\UltraVNC-Decrypt.ps1
```

| Function | Description |
|---|---|
| `Decrypt-Password` / `decrypt_password` | Decrypts a hex-encoded UltraVNC password string |
| `Encrypt-Password` / `encrypt_password` | Encrypts a plaintext password into UltraVNC's format |
| `Create-DES` | (PowerShell only) Initialises the DES cipher with UltraVNC's hardcoded key |

### Linux

```bash
chmod +x ultravnc_decrypt.sh
./ultravnc_decrypt.sh
```

Both scripts will prompt you interactively:

```text
Type in the encrypted password: CAE376F9DBF1474978
The password is: remote12
```

### Where to find the encrypted password

Open `ultravnc.ini` (typically located at `C:\Program Files\uvnc bvba\UltraVNC\ultravnc.ini`)
and look for:

```ini
[ultravnc]
passwd=CAE376F9DBF1474978
passwd2=...
```

Copy the value after `passwd=` and paste it into the prompt.

## Security Notice

UltraVNC's password encryption is **not secure**. It uses a static, publicly known DES key.
Anyone with read access to `ultravnc.ini` can trivially recover the password. Consider:

- Restricting file permissions on `ultravnc.ini`
- Using VPN or SSH tunnelling instead of relying on VNC's built-in auth
- Switching to a VNC implementation with stronger authentication
