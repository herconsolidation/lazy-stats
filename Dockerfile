# Use a base image with Ubuntu and Python pre-installed
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV WINEPREFIX=/opt/mt5_wine
ENV DISPLAY=:99

# Install necessary packages: Wine, Xvfb, and other dependencies
RUN apt-get update && apt-get install -y \
    wine \
    wine64 \
    winetricks \
    xvfb \
    x11vnc \
    python3-pip \
    git \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Configure Wine
RUN winecfg -v=win7

# Create a directory for the MT5 installer and copy it
WORKDIR /app
COPY mt5setup.exe .

# Install MetaTrader 5
RUN wine mt5setup.exe /S

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy your Streamlit application code
COPY . .

# Copy the start script and make it executable
COPY start.sh .
RUN chmod +x ./start.sh

# Expose the port Streamlit runs on
EXPOSE 8501

# The start command is now in start.sh, which will be executed by Render's Start Command
