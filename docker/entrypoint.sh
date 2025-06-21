#!/bin/sh

echo "[INFO] Importing LDAP root CA..."
keytool -import -noprompt \
  -trustcacerts \
  -alias labs-wmi-rootCA \
  -file /tmp/ldap-cert.pem \
  -keystore "$JAVA_HOME/lib/security/cacerts" \
  -storepass changeit

echo "[INFO] Starting Spring Boot application..."

exec su-exec appuser java -jar /app/app.jar