# Use an appropriate base image
FROM ubuntu:latest

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y rclone curl net-tools iputils-ping

# Copy your script into the container
COPY synopcloud-rclone-backup.sh /usr/local/bin/synopcloud-rclone-backup.sh
COPY rclone.conf /root/.config/rclone/rclone.conf

# Ensure the script is executable
RUN chmod +x /usr/local/bin/synopcloud-rclone-backup.sh

# Set the entrypoint to run the script
ENTRYPOINT ["/usr/local/bin/synopcloud-rclone-backup.sh"]
