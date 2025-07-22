
# Use a Flutter base image that supports web builds
FROM ghcr.io/cirruslabs/flutter:3.22.1

# Set the working directory
WORKDIR /app

# Copy all project files
COPY . .

# Get dependencies
RUN flutter pub get

# Build the web app
RUN flutter build web

# Use a simple HTTP server to serve the app
RUN apt-get update && apt-get install -y python3

# Expose the port
EXPOSE 8080

# Start the web server
CMD ["python3", "-m", "http.server", "8080", "--directory", "build/web"]
