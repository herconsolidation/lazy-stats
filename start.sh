#!/bin/bash

# Start Xvfb in the background
Xvfb :99 -screen 0 1024x768x24 &

# Start MetaTrader 5 in the background
wine "C:\Program Files\MetaTrader 5\terminal64.exe" &

# Start the Streamlit application
streamlit run main.py --server.port 8501 --server.enableCORS false --server.enableXsrfProtection false
