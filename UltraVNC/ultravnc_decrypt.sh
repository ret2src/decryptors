#!/usr/bin/env bash

# UltraVNC Password Decryptor (Bash)
# Requires: openssl 3.x with legacy provider, xxd

KEY="E84AD660C4721AE0"

decrypt_password() {
  local encrypted="$1"
  local hex="${encrypted:0:$((${#encrypted} - 2))}"
  hex="${hex^^}"
  printf '%s' "$hex" |
    xxd -r -p |
    openssl enc -des-ecb -d -nosalt -nopad -K "$KEY" \
      -provider legacy -provider default 2>/dev/null |
    tr -d '\000'
}

encrypt_password() {
  local plain="$1"
  local padded
  padded=$(printf '%-8.8s' "$plain" | tr ' ' '\000')
  printf '%s' "$padded" |
    openssl enc -des-ecb -e -nosalt -nopad -K "$KEY" \
      -provider legacy -provider default 2>/dev/null |
    xxd -p |
    tr '[:lower:]' '[:upper:]' |
    tr -d '\n'
  echo "00"
}

main() {
  printf "Type in the encrypted password: "
  read -r password
  if [[ -n "$password" ]]; then
    decrypted=$(decrypt_password "$password")
    echo "The password is: ${decrypted}"
  fi
  printf "Press enter to exit."
  read -r
}

main
