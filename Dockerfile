# Base image with GUI support
FROM jlesage/baseimage-gui:debian-11

# Set environment variables for GUI
ENV APP_NAME="SuperSlicer"

# Install required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget unzip \
    libgtk-3-0 libxcb-shm0 libxcb-xfixes0 \
    libgl1-mesa-glx libxkbcommon-x11-0 libatk1.0-0 \
    libatk-bridge2.0-0 libcairo2 libpango-1.0-0 \
    libpangocairo-1.0-0 libgdk-pixbuf2.0-0 \
    libglib2.0-0 libgtk-3-0 libharfbuzz0b \
    libx11-6 && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt/superslicer

# Download and install the latest SuperSlicer release
RUN LATEST_URL=$(curl -s https://api.github.com/repos/supermerill/SuperSlicer/releases/latest | \
    grep "browser_download_url.*linux-x64.*\.zip" | cut -d '"' -f 4) && \
    wget -O superslicer.zip "$LATEST_URL" && \
    unzip superslicer.zip -d /opt/superslicer && \
    rm superslicer.zip

# Set execution permissions
RUN chmod +x /opt/superslicer/SuperSlicer

# Create startup script
RUN echo '#!/bin/sh\nexec /opt/superslicer/SuperSlicer' > /startapp.sh && \
    chmod +x /startapp.sh

# Define container startup command
CMD ["/startapp.sh"]
