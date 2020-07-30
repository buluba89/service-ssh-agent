#!/usr/bin/env bash

wait_file() {
  local file="$1"; shift
  local wait_seconds="${1:-10}"; shift # 10 seconds as default timeout

  until test $((wait_seconds--)) -eq 0 -o -e "$file" ; do sleep 1; done

  ((++wait_seconds))
}

chmod 700 ${SSH_DIR}
chmod 600 ${SSH_DIR}/* >/dev/null 2>&1 || true
chmod 644 ${SSH_DIR}/*.pub >/dev/null 2>&1 || true

wait_file $SSH_AUTH_SOCK

for filename in "$SSH_DIR"/*; do
  extension="${filename##*.}"
  if [ "$extension" == "pub" ] || [ "$extension" == "pass" ]; then
    continue
  fi
  PASS=""
  if [[ -f "$filename.pass" ]]; then
    PASS=$(cat "$filename.pass")
  fi
  export PASS
  echo "Adding key: $filename"
  SSH_ASKPASS=/usr/local/bin/ssh_give_pass.sh ssh-add "$filename" <<< "$PASS"

done