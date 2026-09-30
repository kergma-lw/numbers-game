#!/usr/bin/env bash
set -euo pipefail

if command -v flutter >/dev/null 2>&1; then
  flutter_bin="$(command -v flutter)"
elif [[ -x "${HOME}/.local/flutter/bin/flutter" ]]; then
  flutter_bin="${HOME}/.local/flutter/bin/flutter"
else
  printf '%s\n' "Flutter was not found in PATH or at ~/.local/flutter/bin/flutter." >&2
  exit 127
fi

exec "${flutter_bin}" test
