#!/bin/bash
# ============================================================
# MultiAI Hub - Build & Deploy Scripts
# ============================================================

set -e

FLUTTER_CMD="flutter"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🚀 MultiAI Hub - Build & Deploy"
echo "================================"
echo "Project: $PROJECT_DIR"
echo ""

# ============================================================
# Function: Build Android APK (for testing)
# ============================================================
build_apk() {
    echo "📦 Building Android APK..."
    cd "$PROJECT_DIR"
    $FLUTTER_CMD pub get
    $FLUTTER_CMD build apk --release
    echo "✅ APK built: build/app/outputs/flutter-apk/app-release.apk"
    ls -lh build/app/outputs/flutter-apk/app-release.apk
}

# ============================================================
# Function: Build Android App Bundle (for Play Store)
# ============================================================
build_aab() {
    echo "📦 Building Android App Bundle (AAB)..."
    cd "$PROJECT_DIR"
    $FLUTTER_CMD pub get
    $FLUTTER_CMD build appbundle --release
    echo "✅ AAB built: build/app/outputs/bundle/release/app-release.aab"
    ls -lh build/app/outputs/bundle/release/app-release.aab
    echo ""
    echo "📋 To upload to Play Store:"
    echo "   1. Go to https://play.google.com/console"
    echo "   2. Create a new app"
    echo "   3. Go to Production → Create new release"
    echo "   4. Upload the .aab file"
}

# ============================================================
# Function: Build iOS (requires macOS + Xcode)
# ============================================================
build_ios() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo "❌ iOS builds require macOS with Xcode"
        echo "   Options:"
        echo "   - Use a Mac (or VM/Hackintosh)"
        echo "   - Use GitHub Actions (macos-latest runner)"
        echo "   - Use Codemagic CI (cloud Mac)"
        return 1
    fi

    echo "🍎 Building iOS..."
    cd "$PROJECT_DIR"
    $FLUTTER_CMD pub get
    $FLUTTER_CMD build ios --release
    echo "✅ iOS built"
    echo ""
    echo "📋 To upload to App Store:"
    echo "   1. Open ios/Runner.xcworkspace in Xcode"
    echo "   2. Set your Apple ID team"
    echo "   3. Product → Archive → Distribute App"
}

# ============================================================
# Function: Build Web (deploy anywhere)
# ============================================================
build_web() {
    echo "🌐 Building Web..."
    cd "$PROJECT_DIR"
    $FLUTTER_CMD pub get
    $FLUTTER_CMD build web --release
    echo "✅ Web built: build/web/"
    echo ""
    echo "📋 Deploy options:"
    echo "   • Firebase:  firebase deploy"
    echo "   • Vercel:    vercel --prod build/web"
    echo "   • Netlify:   netlify deploy --dir=build/web"
    echo "   • GitHub Pages: copy build/web/ to docs/"
}

# ============================================================
# Function: Deploy to Firebase Hosting
# ============================================================
deploy_firebase() {
    echo "🔥 Deploying to Firebase Hosting..."
    cd "$PROJECT_DIR"
    build_web

    if ! command -v firebase &> /dev/null; then
        echo "Installing Firebase CLI..."
        npm install -g firebase-tools
    fi

    echo "Make sure you've run: firebase login && firebase init hosting"
    firebase deploy --only hosting
    echo "✅ Deployed to Firebase!"
}

# ============================================================
# Function: Deploy to GitHub Releases
# ============================================================
deploy_github() {
    echo "🐙 Creating GitHub Release..."
    cd "$PROJECT_DIR"

    # Get version from pubspec
    VERSION=$(grep 'version:' pubspec.yaml | head -1 | awk -F: '{print $2}' | tr -d ' ')

    # Build all artifacts
    build_aab
    build_web

    # Create release
    if command -v gh &> /dev/null; then
        gh release create "v$VERSION" \
            build/app/outputs/bundle/release/app-release.aab \
            --title "MultiAI Hub v$VERSION" \
            --notes "Release v$VERSION of MultiAI Hub"
        echo "✅ GitHub release created!"
    else
        echo "⚠️  Install GitHub CLI: https://cli.github.com"
    fi
}

# ============================================================
# Function: Generate signing key for Play Store
# ============================================================
generate_keystore() {
    echo "🔑 Generating Android signing keystore..."
    echo ""
    echo "⚠️  IMPORTANT: Keep this file SAFE! You need it for ALL future updates."
    echo ""

    KEYSTORE_DIR="$PROJECT_DIR/android/app/keystore"
    mkdir -p "$KEYSTORE_DIR"

    read -p "Enter your app name [MultiAIHub]: " APP_NAME
    APP_NAME=${APP_NAME:-MultiAIHub}

    keytool -genkey -v \
        -keystore "$KEYSTORE_DIR/$APP_NAME.jks" \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -alias "$APP_NAME"

    echo ""
    echo "✅ Keystore created: $KEYSTORE_DIR/$APP_NAME.jks"
    echo ""
    echo "Add this to android/key.properties:"
    echo "   storePassword=<your-password>"
    echo "   keyPassword=<your-password>"
    echo "   keyAlias=$APP_NAME"
    echo "   storeFile=keystore/$APP_NAME.jks"
}

# ============================================================
# Main Menu
# ============================================================
case "${1:-menu}" in
    apk)         build_apk ;;
    aab)         build_aab ;;
    ios)         build_ios ;;
    web)         build_web ;;
    firebase)    deploy_firebase ;;
    github)      deploy_github ;;
    keystore)    generate_keystore ;;
    all)         build_aab; build_ios; build_web ;;
    menu|"")
        echo "Usage: ./deploy.sh <command>"
        echo ""
        echo "Commands:"
        echo "  apk        Build Android APK (testing)"
        echo "  aab        Build Android App Bundle (Play Store)"
        echo "  ios        Build iOS (requires macOS)"
        echo "  web        Build Web"
        echo "  firebase   Deploy Web to Firebase Hosting"
        echo "  github     Create GitHub Release"
        echo "  keystore   Generate Android signing key"
        echo "  all        Build all platforms"
        ;;
    *)
        echo "❌ Unknown command: $1"
        ;;
esac
