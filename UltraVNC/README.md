# UltraVNC Password Decryptor

Decrypt passwords stored by [UltraVNC](https://www.uvnc.com/) in its configuration files (e.g. `ultravnc.ini`).
Available as a PowerShell script for Windows and a Bash script for Linux.

## Background

UltraVNC encrypts passwords using DES with a hardcoded key.
The decryptors in this directory reverse this process to recover the plaintext password from the hex-encoded ciphertext found in the config file.

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

Open `ultravnc.ini` (typically located at `C:\Program Files\uvnc bvba\UltraVNC\ultravnc.ini`) and look for:

```ini
[ultravnc]
passwd=CAE376F9DBF1474978
passwd2=...
```

Copy the value after `passwd=` and paste it into the prompt.

## Functions

| Function | Description |
|---|---|
| `Decrypt-Password` / `decrypt_password` | Decrypts a hex-encoded UltraVNC password string |
| `Encrypt-Password` / `encrypt_password` | Encrypts a plaintext password into UltraVNC's format |
| `Create-DES` (PowerShell only) | Initializes the DES cipher with UltraVNC's hardcoded key |

## Security Notice

UltraVNC's password encryption is **not secure**.
It uses a static, publicly known DES key, meaning anyone with read access to `ultravnc.ini` can trivially recover the plaintext password.
This is not a flaw that can be patched by choosing a stronger password — the algorithm itself is broken by design.

Consider the following mitigations:

- **Prefer modern remote access protocols over VNC where possible.** RDP (with Network Level Authentication), solutions like Windows Admin Center, or modern remote access tools offer significantly stronger authentication and encryption than UltraVNC, and support modern auth standards such as mutual TLS and SSO/SAML. Reserve VNC only for cases where no alternative exists.
- **Restrict file permissions on `ultravnc.ini`** so that only administrators can read it. On Windows, review the ACL via `icacls "C:\Program Files\uvnc bvba\UltraVNC\ultravnc.ini"`.
- **Audit who has access to `ultravnc.ini`** and any system that may store copies of it. Never place `ultravnc.ini` on widely readable network shares (SMB, NFS, etc.) or include it in unencrypted backups.
- **Use a unique password per machine and never reuse VNC passwords elsewhere.** If you reuse the same VNC password across multiple hosts or other services, a single compromised machine exposes all of them. Treat each host as an independent security boundary and use different passwords across all hosts, services, and users to reduce the blast radius of a breach.
- **Never expose VNC directly to the Internet.** Place it behind a VPN or SSH tunnel so that the VNC port (default `5900`) is never reachable from untrusted networks. Ideally, restrict access to dedicated management network segments.
- **Rotate VNC passwords regularly** and immediately after any suspected compromise or staff offboarding.
