# ==========================================
# STAGE 1: Compile the Flutter Web Application
# ==========================================
FROM ubuntu:24.04 AS builder

# Install system dependencies needed by Flutter
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Clone the stable Flutter SDK branch
RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter

# Add Flutter execution path to the system environment
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run doctor to pre-download development binaries
RUN flutter doctor

# Set up our application working directory
WORKDIR /app

# Copy the project configuration files first (for efficient Docker layer caching)
COPY pubspec.yaml ./

# Download project dependencies
RUN flutter pub get

# Copy the entire project codebase into the container
COPY . .

# Compile the final production web assets
RUN flutter build web --release --base-href "/path-pilot/"

# ==========================================
# STAGE 2: Serve the Compiled Assets using Nginx
# ==========================================
FROM nginx:alpine

# Copy the compiled HTML/JS/CSS from Stage 1 into the Nginx web root directory
COPY --from=builder /app/build/web /usr/share/nginx/html

# Expose Port 80 for public web traffic routing
EXPOSE 80

# Launch the Nginx web server in the foreground
CMD ["nginx", "-g", "daemon off;"]