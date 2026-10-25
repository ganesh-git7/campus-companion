#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.44.0"
FLUTTER_HOME="${HOME}/flutter-sdk"

git clone --depth 1 --branch "$FLUTTER_VERSION" \
  https://github.com/flutter/flutter.git "$FLUTTER_HOME"

export PATH="$FLUTTER_HOME/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release

test -f build/web/index.html