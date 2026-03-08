#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# Enable debugging by setting DEBUG=true in environment
: "${DEBUG:=false}"
if [ "${DEBUG}" = "true" ]; then
  set -x
fi

# Require a URL parameter
if [ $# -lt 1 ]; then
  echo "Usage: $(basename $0) <url>" >&2
  exit 64
fi

url="$1"

exit_code=0
uname_s="$(uname -s)"

if [ -z "${DISPLAY:-}" ] && [ "$uname_s" = "Linux" ]; then
  echo "Headless environment detected (no DISPLAY). Cannot launch browser." >&2
  exit 1
fi

# 1. Use custom browser (via BROWSER environment variable)
if [ -n "${BROWSER:-}" ]; then
  echo "Using custom browser: ${BROWSER}"

  if command -v "${BROWSER}" >/dev/null 2>&1 || [ -x "${BROWSER}" ]; then
    "${BROWSER}" "${url}" >/dev/null 2>&1 &
    exit_code=$?

    if [ ${exit_code} -eq 0 ]; then
      exit 0
    fi
  else
    echo "Custom browser "${BROWSER}" not found." >&2
  fi

  echo "Custom browser failed. Trying fallbacks..." >&2
fi

# 2. OS-specific default tools
case "${uname_s}" in
Linux*)
  # Check for xdg-open (standard)
  if command -v xdg-open &> /dev/null; then
    xdg-open "$url" >/dev/null 2>&1 &
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
      exit 0;
    fi
  fi

  # Fallback to common Linux browsers
  browsers=(firefox chromium chrome brave)
  for browser in "${browsers[@]}"; do
    if command -v "${browser}" &> /dev/null; then
      "${browser}" "${url}" >/dev/null 2>&1 &
        
      exit 0
    fi
  done
  ;;
Darwin*)
  # macOS: Use open command
  if command -v open &> /dev/null; then
    open "${url}" >/dev/null 2>&1 &
    exit_code=$?
    
    if [ ${exit_code} -eq 0 ]; then
        exit 0
    fi
  fi
  ;;
CYGWIN*|MINGW*|MSYS*)
  # Windows: Use cmd.exe start
  if command -v cmd.exe &> /dev/null; then
    cmd.exe /c start "" "${url}" >/dev/null 2>&1 &
    exit_code=$?
    
    if [ ${exit_code} -eq 0 ]; then
        exit 0
    fi
  fi
  ;;
esac

# 3. All fallbacks failed
echo "Failed to launch any browser." >&2
exit 1
