# Use jlesage base image for GUI applications
FROM jlesage/baseimage-gui:ubuntu-22.04

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
    mkdir -p /config && \
    mkdir -p /prints && \
    chown -R superslicer:superslicer /opt/superslicer/ /home/superslicer/ /prints/ /config/ && \
    mkdir /config/.local && \
    mkdir -p /config/.config && \
    ln -s /config/.config/ /home/superslicer/ && \
    mkdir -p /home/superslicer/.config && \
    # We can now set the Download directory for Firefox and other browsers. 
    # We can also add /prints/ to the file explorer bookmarks for easy access.
    echo "XDG_DOWNLOAD_DIR=\"/prints/\"" >> /home/superslicer/.config/user-dirs.dirs && \
    echo "file:///prints prints" >> /home/superslicer/.gtk-bookmarks 

# Set up application execution
RUN ln -s /opt/superslicer/superslicer /usr/bin/superslicer

# Copy the start script.
COPY startapp.sh /startapp.sh

# Set the name of the application.
RUN set-cont-env APP_NAME "SuperSlicer"
