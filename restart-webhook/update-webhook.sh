#!/bin/bash

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

echo "Pobieram pliki z release..."

curl -L -o "$INSTALL_DIR/webhook-restart" "$BASE_URL/webhook-restart"
curl -L -o "$INSTALL_DIR/webhook-restart.sha256" "$BASE_URL/webhook-restart.sha256"

echo "Weryfikuję sumę kontrolną..."

cd $INSTALL_DIR
sha256sum -c webhook-restart.sha256

if [ $? -ne 0 ]; then
  echo "Błąd: suma kontrolna nie pasuje!"
  exit 1
fi

chmod +x webhook-restart

echo "Uruchamiam webhook-restart..."

pkill webhook-restart || true

nohup ./webhook-restart > /var/log/webhook-restart.log 2>&1 &

echo "Webhook-restart został uruchomiony."
