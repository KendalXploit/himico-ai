#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "========================================"
echo "   HIMICO AI DevContainer Installer"
echo "========================================"

mkdir -p .devcontainer

cat > .devcontainer/devcontainer.json << 'EOF'
{
  "name": "HIMICO AI Flutter Dev",
  "build": {
    "dockerfile": "Dockerfile"
  },
  "remoteUser": "vscode",
  "postCreateCommand": "bash .devcontainer/postCreate.sh",
  "customizations": {
    "vscode": {
      "extensions": [
        "Dart-Code.flutter",
        "Dart-Code.dart-code",
        "ms-vscode.vscode-json",
        "GitHub.copilot",
        "GitHub.copilot-chat"
      ]
    }
  }
}
EOF

cat > .devcontainer/Dockerfile << 'EOF'
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
curl \
wget \
git \
zip \
unzip \
xz-utils \
openjdk-17-jdk \
clang \
cmake \
ninja-build \
pkg-config \
libgtk-3-dev \
libglu1-mesa \
ca-certificates \
sudo \
&& rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git /opt/flutter

ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:\${PATH}"

ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk

RUN mkdir -p \$ANDROID_HOME/cmdline-tools

RUN wget https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip -O sdk.zip && \
unzip sdk.zip && \
rm sdk.zip && \
mkdir -p \$ANDROID_HOME/cmdline-tools/latest && \
mv cmdline-tools/* \$ANDROID_HOME/cmdline-tools/latest/

ENV PATH="\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\${PATH}"

RUN yes | sdkmanager --licenses || true

RUN sdkmanager \
"platform-tools" \
"platforms;android-35" \
"build-tools;35.0.0" || true

RUN flutter config --android-sdk \$ANDROID_HOME || true

RUN flutter doctor || true
EOF

cat > .devcontainer/postCreate.sh << 'EOF'
#!/bin/bash

echo "========================================"
echo " HIMICO AI Development Environment"
echo "========================================"

flutter --version

flutter doctor -v

flutter pub get
EOF

chmod +x .devcontainer/postCreate.sh

echo ""
echo "✅ DevContainer berhasil dibuat!"
echo ""
echo "Selanjutnya jalankan:"
echo ""
echo "git add ."
echo "git commit -m \"Add DevContainer\""
echo "git push"
echo ""
