FROM ghcr.io/cirruslabs/flutter:3.32.7

# Set working directory
WORKDIR /app

# Copy pubspec files first (for caching)
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy rest of the code
COPY . .

# Build the web app
RUN flutter build web

# Serve the web app
CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080"]