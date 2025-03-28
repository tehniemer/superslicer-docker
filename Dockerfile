# Use jlesage base image for GUI applications
FROM jlesage/baseimage-gui:debian-11

# Set environment variables
ENV APP_NAME="SuperSlicer"

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget xz-utils unzip jq \
    libgtk-3-0 libxcb-shm0 libxcb-xfixes0 \
    libgl1-mesa-glx libxkbcommon-x11-0 libatk1.0-0 \
    libatk-bridge2.0-0 libcairo2 libpango-1.0-0 \
    libpangocairo-1.0-0 libgdk-pixbuf2.0-0 \
    libglib2.0-0 libgtk-3-0 libharfbuzz0b \
    libx11-6 && \
    rm -rf /var/lib/apt/lists/*

# Set workdir to the application folder
WORKDIR /opt/superslicer
ADD get_latest_superslicer_release.sh /opt/superslicer

# Download and install SuperSlicer
RUN mkdir -p /opt/superslicer && \
    chmod +x /opt/superslicer/get_latest_superslicer_release.sh && \
    latestSlic3r=$(/opt/superslicer/get_latest_superslicer_release.sh url) && \
    slic3rReleaseName=$(/opt/superslicer/get_latest_superslicer_release.sh name) && \
    curl -sSL ${latestSlic3r} > ${slic3rReleaseName} && \
    rm -f /opt/superslicer/releaseInfo.json && \
    mkdir -p /opt/superslicer/superslicer-dist && \
    tar -xzf ${slic3rReleaseName} -C /opt/superslicer/superslicer-dist --strip-components 1 && \
    rm -f /opt/superslicer/${slic3rReleaseName} && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoclean && \
    chmod -R 777 /opt/superslicer/ && \
    groupadd superslicer && \
    useradd -g superslicer --create-home --home-dir /home/superslicer superslicer && \
    mkdir -p /configs && \
    mkdir -p /prints && \
    chown -R superslicer:superslicer /opt/superslicer/ /home/superslicer/ /prints/ /configs/ && \
    locale-gen en_US && \
    mkdir /configs/.local && \
    mkdir -p /configs/.config && \
    ln -s /configs/.config/ /home/superslicer/ && \
    mkdir -p /home/superslicer/.config && \
    # We can now set the Download directory for Firefox and other browsers. 
    # We can also add /prints/ to the file explorer bookmarks for easy access.
    echo "XDG_DOWNLOAD_DIR=\"/prints/\"" >> /home/superslicer/.config/user-dirs.dirs && \
    echo "file:///prints prints" >> /home/superslicer/.gtk-bookmarks 

# Set up application execution
RUN ln -s /opt/superslicer/SuperSlicer /usr/bin/superslicer

# Define the startup command
RUN mkdir -p /config && \
    echo "/usr/bin/superslicer" > /config/startapp.sh && \
    chmod +x /config/startapp.sh

# Set application startup script
ENV APP_EXEC="/config/startapp.sh"

# Expose GUI ports (default VNC port)
EXPOSE 5800 5900

# Define volumes for persistent storage
VOLUME ["/config", "/prints"]

# Define entrypoint
ENTRYPOINT ["/init"]
