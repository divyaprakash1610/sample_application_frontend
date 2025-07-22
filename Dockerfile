# Use Flutter's official Docker image
FROM cirrusci/flutter:stable

# Set working directory
WORKDIR /app

# Copy your code
COPY . .

# Build the web app
RUN flutter build web

# Serve the web app
EXPOSE 8080
CMD ["python3", "-m", "http.server", "8080", "--directory", "build/web"]
