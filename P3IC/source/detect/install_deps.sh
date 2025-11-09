#!/usr/bin/env bash
set -euo pipefail

# Simple installer for Debian/Ubuntu systems to install system and python deps
# Usage:
#   sudo ./install_deps.sh        # installs apt packages and creates venv
#   ./install_deps.sh --user      # installs python packages into user site (does not use venv)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

USE_USER_PIP=0
if [ "${1-}" = "--user" ]; then
  USE_USER_PIP=1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This installer assumes a Debian/Ubuntu system with apt-get."
  echo "Install packages listed in apt-packages.txt manually for your distro."
  exit 1
fi

echo "Updating apt and installing required packages (may ask for sudo)..."
sudo apt-get update
sudo xargs -a apt-packages.txt apt-get install -y

if [ "$USE_USER_PIP" -eq 1 ]; then
  echo "Installing Python packages into user site (pip --user)..."
  python3 -m pip install --upgrade pip
  python3 -m pip install --user -r requirements.txt
  echo "Python packages installed (user)."
  exit 0
fi

echo "Creating virtualenv .venv and installing Python requirements there..."
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo "Done. To use the environment run:"
echo "  source $SCRIPT_DIR/.venv/bin/activate"
echo "Then run the program, e.g.:"
echo "  export OMP_NUM_THREADS=4"
echo "  ./build/detect <imagen>"
