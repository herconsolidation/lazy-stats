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
    python3-pip \
    git \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Enable multi-arch and install wine32
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y wine32

# Configure Wine and ensure prefix is updated
RUN winecfg -v=win7 && wineboot -u

# Create a directory for the MT5 installer and copy it
WORKDIR /app
COPY mt5setup.exe .

# Install MetaTrader 5 with a timeout and verbose output
RUN xvfb-run --auto-servernum --server-args="-screen 0 1024x768x24" timeout 300 wine mt5setup.exe /auto

# --- DEBUGGING STEP (TEMPORARY) ---
# List contents of the Wine prefix to find where MT5 installed
RUN ls -R /opt/mt5_wine/drive_c/
# --- END DEBUGGING STEP ---

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy your Streamlit application code
COPY . .

# Expose the port Streamlit runs on
EXPOSE 8501

# This command will be automatically executed by Render
CMD Xvfb :99 -screen 0 1024x768x24 & \
    wine "C:\Program Files\MetaTrader 5\terminal64.exe" & \
    streamlit run main.py --server.port 8501 --server.enableCORS false --server.enableXsrfProtection false
