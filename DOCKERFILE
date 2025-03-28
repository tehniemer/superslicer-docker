# Use jlesage base image for GUI applications
FROM jlesage/baseimage-gui:debian-11

# Set metadata
LABEL authors="Jesse Niemand - tehniemer"
LABEL description="Docker container for SuperSlicer using jlesage/baseimage-gui."

# Set environment variables
ENV APP_NAME="SuperSlicer"

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxcb-xinerama0 \
    libxkbcommon-x11-0 \
    libxrandr2 \
    libglu1-mesa \
    libpangoxft-1.0-0 \
    libgtk-3-0 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Download and install SuperSlicer
RUN mkdir -p /opt/superslicer && \
    wget -qO- $(curl -s https://api.github.com/repos/supermerill/SuperSlicer/releases/latest | jq -r '.assets[] | select(.name | test("linux64_[0-9]+\\.tar\\.zip$")) | .browser_download_url') | tar -xJ -C /opt/superslicer

# Set up application execution
RUN ln -s /opt/superslicer/SuperSlicer /usr/bin/superslicer

# Copy the start script.
COPY startapp.sh /startapp.sh

# Set the name of the application.
RUN set-cont-env APP_NAME "SuperSlicer"

# Expose GUI ports (default VNC port)
EXPOSE 5800 5900

# Define volumes for persistent storage
VOLUME ["/config", "/storage"]

# Set workdir to the application folder
WORKDIR /opt/superslicer

# Define entrypoint
ENTRYPOINT ["/init"]
