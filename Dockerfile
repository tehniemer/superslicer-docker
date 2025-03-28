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
WORKDIR /slic3r

ADD get_latest_superslicer_release.sh /slic3r

# Download and install the latest SuperSlicer release
RUN mkdir -p /slic3r/slic3r-dist \
  && chmod +x /slic3r/get_latest_superslicer_release.sh \
  && latestSlic3r=$(/slic3r/get_latest_superslicer_release.sh url) \
  && slic3rReleaseName=$(/slic3r/get_latest_superslicer_release.sh name) \
  && curl -sSL ${latestSlic3r} > ${slic3rReleaseName} \
  && rm -f /slic3r/releaseInfo.json \
  && mkdir -p /slic3r/slic3r-dist \
  && tar -xzf ${slic3rReleaseName} -C /slic3r/slic3r-dist --strip-components 1 \
  && rm -f /slic3r/${slic3rReleaseName} \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get autoclean \
  && chmod -R 777 /slic3r/ \
  && groupadd slic3r \
  && useradd -g slic3r --create-home --home-dir /home/slic3r slic3r \
  && mkdir -p /slic3r \
  && mkdir -p /configs \
  && mkdir -p /prints/ \
  && chown -R slic3r:slic3r /slic3r/ /home/slic3r/ /prints/ /configs/ \
  && locale-gen en_US \
  && mkdir /configs/.local \
  && mkdir -p /configs/.config/ \
  && ln -s /configs/.config/ /home/slic3r/ \
  && mkdir -p /home/slic3r/.config/ \
  # We can now set the Download directory for Firefox and other browsers. 
  # We can also add /prints/ to the file explorer bookmarks for easy access.
  && echo "XDG_DOWNLOAD_DIR=\"/prints/\"" >> /home/slic3r/.config/user-dirs.dirs \
  && echo "file:///prints prints" >> /home/slic3r/.gtk-bookmarks 

# Set execution permissions
RUN chmod +x /slic3r*

# Create startup script
RUN echo '#!/bin/sh\nexec /opt/superslicer/SuperSlicer' > /startapp.sh && \
    chmod +x /startapp.sh

VOLUME /configs/
VOLUME /prints/

# Define container startup command
CMD ["/startapp.sh"]
