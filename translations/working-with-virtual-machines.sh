#!/bin/bash

# We would set up a game application—a Minecraft server.
# The Minecraft server software will run on a Compute Engine instance.

# You use an n1-standard-1 machine type that includes a 10-GB boot disk, 1 virtual CPU (vCPU), 
# and 3.75 GB of RAM. This machine type runs Debian Linux by default.

# To make sure there is plenty of room for the Minecraft server's world data,
# you also attach a high-performance 50-GB persistent solid-state drive (SSD) to the instance.
# This dedicated Minecraft server can support up to 50 players.

# setting up some environment variables
export INSTANCE_NAME=mc-server
export INSTANCE_ZONE=us-central1-a
export INSTANCE_EXTERNAL_IP_ADDRESS=<IP Adress goes here>
export MY_REGION=us-central1
export MY_BUCKET_NAME=<Enter your unique bucket name here>

# Task 1: Create the VM
# We Define a VM using some advanced options

gcloud beta compute --project=qwiklabs-gcp-01-baebd99db37a instances create mc-server \
    --zone=$INSTANCE_ZONE --machine-type=e2-medium --subnet=default \
    --address=$INSTANCE_EXTERNAL_IP_ADDRESS --network-tier=PREMIUM --maintenance-policy=MIGRATE \
    --service-account=664214757259-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/trace.append,https://www.googleapis.com/auth/devstorage.read_write \
    --tags=minecraft-server --image=debian-9-stretch-v20200910 --image-project=debian-cloud \
    --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=mc-server \
    --create-disk=mode=rw,size=50,type=projects/qwiklabs-gcp-01-baebd99db37a/zones/us-central1-a/diskTypes/pd-ssd,name=minecraft-disk,device-name=minecraft-disk \
    --reservation-affinity=any
    # --disk=name=minecraft-disk,device-name=minecraft-disk,mode=rw,boot=no \
    

# Task 2: Prepare the data disk
# Create a directory and format and mount the disk

# SSH into the instance, to open a terminal and connect.
gcloud compute ssh $INSTANCE_NAME --zone $INSTANCE_ZONE --tunnel-through-iap

# To create a directory that serves as the mount point for the data disk:
sudo mkdir -p /home/minecraft

# We format the disk:
sudo mkfs.ext4 -F -E lazy_itable_init=0,\
    lazy_journal_init=0,discard \
    /dev/disk/by-id/google-minecraft-disk

# To mount the disk:
sudo mount -o discard,defaults /dev/disk/by-id/google-minecraft-disk /home/minecraft

# Task 3: Install and run the application

# The Minecraft server runs on top of the Java Virtual Machine (JVM), 
# so it requires the Java Runtime Environment (JRE) to run. 
# Because the server doesn't need a graphical user interface, you use the headless version of the JRE. 
# This reduces the JRE's resource usage on the machine, which helps ensure that the 
# Minecraft server has enough room to expand its own resource usage if needed.

# Install the Java Runtime Environment (JRE) and the Minecraft server
# First we update the Debian repositories on the VM
sudo apt-get update

# Install headless JRE
sudo apt-get install -y default-jre-headless

# Navigate to the directory where the persistent disk is mounted:
cd /home/minecraft

# Install wget, If prompted to continue, type Y
sudo apt-get install wget

# Download the current Minecraft server JAR file (1.11.2 JAR):
sudo wget https://launcher.mojang.com/v1/objects/d0d0fe2b1dc6ab4c65554cb734270872b72dadd6/server.jar

# Initialize the Minecraft server
sudo java -Xmx1024M -Xms1024M -jar server.jar nogui

# To edit the EULA, Change the last line of the file from eula=false to eula=true
# At this point we could use the sed command, but let's nano it.
sudo nano eula.txt

# Create a virtual terminal screen to start the Minecraft server
# If you start the Minecraft server again now, it is tied to the life of your SSH session.
# that is, if you close your SSH terminal, the server is also terminated. 
# To avoid this issue, you can use screen, an application that allows you to create
# a virtual terminal that can be "detached," becoming a background process, 
# or "reattached," becoming a foreground process. When a virtual terminal is detached to the background,
# it will run whether you are logged in or not.

# To install screen
sudo apt-get install -y screen

# To start your Minecraft server in a screen virtual terminal, (Use the -S flag to name your terminal mcs)
sudo screen -S mcs java -Xmx1024M -Xms1024M -jar server.jar nogui

# Detach from the screen and close your SSH session by pressing Ctrl+A, Ctrl+D.
# The terminal continues to run in the background.

# To reattach the terminal:
sudo screen -r mcs

# NOTE: You can always exit the screen terminal by pressing Ctrl+A, Ctrl+D.


# Task 4: Allow client traffic
# The server has an external static IP address, but it cannot receive traffic because there is no firewall rule in place. 
# Minecraft server uses TCP port 25565 by default. So we need to configure a firewall rule to allow these connections.

# Create a firewall rule
gcloud compute --project=qwiklabs-gcp-01-baebd99db37a \
    firewall-rules create minecraft-rule \
    --direction=INGRESS --priority=1000 \
    --network=default --action=ALLOW --rules=tcp:25565 \
    --source-ranges=0.0.0.0/0 --target-tags=minecraft-server

# Task 5: Schedule regular backups
# Backing up your application data is a common activity. 
# In this case, you configure the system to back up Minecraft world data to Cloud Storage.

# Create a Cloud Storage bucket
gsutil mb gs://$MY_BUCKET_NAME-minecraft-backup

# Create a backup script
# Navigate to your home directory:
cd /home/minecraft

# Now we create the script
sudo nano /home/minecraft/backup.sh

# Copy and paste the following script into the file:

#!/bin/bash
screen -r mcs -X stuff '/save-all\n/save-off\n'
/usr/bin/gsutil cp -R ${BASH_SOURCE%/*}/world gs://${YOUR_BUCKET_NAME}-minecraft-backup/$(date "+%Y%m%d-%H%M%S")-world
screen -r mcs -X stuff '/save-on\n'

# Press Ctrl+O, ENTER to save the file, and press Ctrl+X to exit nano.
# Make the script executable:
sudo chmod 755 /home/minecraft/backup.sh

# Test the backup script and schedule a cron job
. /home/minecraft/backup.sh

#  open the cron table for editing:
sudo crontab -e

# When you are prompted to select an editor, type the number corresponding to nano, and press ENTER.
# At the bottom of the cron table, paste the following line:
# That line instructs cron to run backups every 4 hours.
0 */4 * * * /home/minecraft/backup.sh
# Press Ctrl+O, ENTER to save the cron table, and press Ctrl+X to exit nano.

# This creates about 300 backups a month in Cloud Storage, so you will want to regularly delete them to avoid charges.
# Cloud Storage offers the Object Lifecycle Management feature to set a Time to Live (TTL) for objects,
# archive older versions of objects, or "downgrade" storage classes of objects to help manage costs.

# Task 6: Server maintenance
# Connect via SSH to the server, stop it and shut down the VM
sudo screen -r -X stuff '/stop\n'

# Automate server maintenance with startup and shutdown scripts
# Instead of following the manual process to mount the persistent disk and launch the server application in a screen,
# you can use metadata scripts to create a startup script and a shutdown script to do this for you.

# From the console, click the instance name, click Edit
# Navigate to Custom metadata and specify the following:

# Key	                Value
# startup-script-url	url-to-your-custom-startup-script.sh
# shutdown-script-url	url-to-your-custom-shutdownn-script.sh

# For sample script check these out: You can have these scripts in cloud storage.
# Sample start-up script

#!/bin/bash
# mount /dev/disk/by-id/google-minecraft-disk /home/minecraft
# cd /home/minecraft
# sudo screen -S mcs java -Xmx1024M -Xms1024M -jar server.jar nogui

# Sample shutdown script

#!/bin/bash
# sudo screen -r -X stuff '/stop\n'
