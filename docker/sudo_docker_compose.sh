# Purpose: Start and manage a specific Docker Compose project from a YAML file.
#
# Syntax: sudo docker compose -f <file_name>.yml -p <project_name> up -d
#
# Arguments:
#   -f <file_name>.yml : Specifies the YAML file to use.
#   -p <project_name>  : Sets a custom project name. This is crucial for Portainer to
#                        recognize it as a separate "stack."
#   up                 : Builds, recreates, and starts the containers.
#   -d                 : Runs the containers in detached mode (in the background).

# Example 1: Starts a Portainer stack using 'portainer.yml' and names the project 'portainer-service'.
sudo docker compose -f docker-compose-cyber-sentinel.yml -p cyber-sentinel-service up -d

# Example 2: Starts a Pi-Alert stack using 'pi_alert.yml' and names the project 'pialert-service'.
sudo docker compose -f pi_alert.yml -p pialert-service up -d

# Example 3: Starts a Firefox stack using 'firefox.yml' and names the project 'firefox-service'.
sudo docker compose -f docker-compose-portainer.yml -p portainer-service up -d

# Example 4: Starts a Samba stack using 'samba.yml' and names the project 'samba-service'.
sudo docker compose -f samba.yml -p samba-service up -d


#########################################################################################################

# Purpose: Update the Pi-hole container to the latest version.
#
# Step 1: Pull the latest Pi-hole image from the Docker Hub registry.
# This ensures that you have the most recent version of the image locally before
# recreating the container.
#
# Syntax: sudo docker compose pull <service_name>
# Arguments:
#   pull              : Pulls the latest image for the specified service.
#   pihole            : The name of the service to pull the image for.
sudo docker compose pull pihole

# Step 2: Recreate the Pi-hole container using the newly pulled image.
# This stops and removes the old container and starts a new one with the updated image,
# while keeping your volumes and configurations intact.
#
# Syntax: sudo docker compose up -d --force-recreate <service_name>
# Arguments:
#   up                : Starts the containers.
#   -d                : Runs in detached mode.
#   --force-recreate  : Forces the container to be recreated, even if the configuration
#                       hasn't changed.
#   pihole            : The name of the service to update.
sudo docker compose up -d --force-recreate pihole


#########################################################################################################
#Purpose: Build and run the VirusTotal scanner after changing the .env file.
#Step 1: Build the container image with the new configuration, ignoring cache.
#This command is crucial after changing the .env file. It forces Docker to rebuild
#the image, which includes copying the new .env file into the container.

sudo docker compose -f firefox.yml -p firefox-service build --no-cache

sudo docker compose -f firefox.yml -p firefox-service up -d --force-recreate

sudo docker stop librewolf
sudo docker rm librewolf
udo docker rmi lscr.io/linuxserver/librewolf:latest


#Step 2: Run the scanner from the newly built image.
#After the image is built, this command runs the scanner, passing the IP addresses
#to your script. The container will perform its task and then be removed (--rm).

sudo docker compose -f virus_total.yml -p virus_total-service run --rm virustotal_scanner python main.py 129.134.31.12
