# Use a Python base image
FROM python:3.9-slim-buster

# Set working directory
WORKDIR /app

# Install Oracle Instant Client (adjust version and URL as needed)
# This is a general example, you might need to adapt it based on your Oracle client version and OS.
# For production, consider using a pre-built image with Oracle Instant Client or building it more robustly.
RUN apt-get update && apt-get install -y libaio1 \
    && rm -rf /var/lib/apt/lists/*

# Download and install Oracle Instant Client Basic and SDK packages
# You might need to adjust the download URLs based on the specific version you want.
# These URLs are examples and might change.
RUN mkdir -p /opt/oracle \
    && wget -q https://download.oracle.com/otn_software/linux/instantclient/2113000/instantclient-basic-linux.x64-21.13.0.0.0dbru.zip \
    && unzip instantclient-basic-linux.x64-21.13.0.0.0dbru.zip -d /opt/oracle \
    && wget -q https://download.oracle.com/otn_software/linux/instantclient/2113000/instantclient-sdk-linux.x64-21.13.0.0.0dbru.zip \
    && unzip instantclient-sdk-linux.x64-21.13.0.0.0dbru.zip -d /opt/oracle \
    && rm instantclient-basic-linux.x64-21.13.0.0.0dbru.zip instantclient-sdk-linux.x64-21.13.0.0.0dbru.zip \
    && ln -s /opt/oracle/instantclient_21_13 /opt/oracle/instantclient

ENV LD_LIBRARY_PATH=/opt/oracle/instantclient:$LD_LIBRARY_PATH
ENV TNS_ADMIN=/opt/oracle/instantclient/network/admin

# Copy requirements file and install Python dependencies
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ .

# Expose the port the app runs on
EXPOSE 5000

# Command to run the application
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "main:app"]
