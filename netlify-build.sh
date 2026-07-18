#!/usr/bin/env bash
# Script de build para Netlify. Ver netlify.toml.
set -euo pipefail

# Fallan temprano y con mensaje claro si faltan las variables en el panel.
: "${SUPABASE_URL:?Falta configurar SUPABASE_URL en Netlify (Site settings > Environment variables)}"
: "${SUPABASE_ANON_KEY:?Falta configurar SUPABASE_ANON_KEY en Netlify (Site settings > Environment variables)}"

FLUTTER_VERSION="${FLUTTER_VERSION:-3.44.6}"
FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Descargando Flutter $FLUTTER_VERSION..."
  git clone https://github.com/flutter/flutter.git \
    --depth 1 --branch "$FLUTTER_VERSION" "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get

# pubspec.yaml declara `.env` como asset obligatorio, pero ese archivo no se
# versiona (tiene credenciales). Se regenera aca desde el entorno de Netlify
# para que el build no falle por asset faltante.
cat > .env <<EOF
SUPABASE_URL=${SUPABASE_URL}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
EOF

flutter build web --release \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"
