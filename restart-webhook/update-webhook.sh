#!/bin/bash

set -e

REPO="Project-UniCloud/uc-docker"
API_URL="https://api.github.com/repos/$REPO/releases/latest"

echo "Pobieram najnowszy tag release z GitHub..."

VERSION=$(curl -s $API_URL | grep '"tag_name":' | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$VERSION" ]; then
  echo "Nie udało się pobrać wersji z GitHub!"
  exit 1
fi

echo "Najnowszy tag release: $VERSION"

BASE_URL="https://github.com/$REPO/releases/download/$VERSION"
INSTALL_DIR="/usr/local/bin"

TMP_DIR=$(mktemp -d)
echo "Pobieram pliki z release do $TMP_DIR..."

curl -L -o "$TMP_DIR/webhook-restart" "$BASE_URL/webhook-restart"
curl -L -o "$TMP_DIR/webhook-restart.sha256" "$BASE_URL/webhook-restart.sha256"

echo "Weryfikuję sumę kontrolną..."
(cd "$TMP_DIR" && sha256sum -c webhook-restart.sha256) || {
  echo "Błąd: suma kontrolna nie pasuje!"
  rm -rf "$TMP_DIR"
  exit 1
}

echo "Kopiuję plik do $INSTALL_DIR (wymaga sudo)..."
sudo mv "$TMP_DIR/webhook-restart" "$INSTALL_DIR/webhook-restart"
sudo chmod +x "$INSTALL_DIR/webhook-restart"

rm -rf "$TMP_DIR"

echo "Restartuję usługę systemd webhook-restart..."

sudo systemctl daemon-reload
sudo systemctl enable webhook-restart
sudo systemctl restart webhook-restart
sudo systemctl status webhook-restart --no-pager

echo "Webhook-restart został uruchomiony i jest gotowy."
