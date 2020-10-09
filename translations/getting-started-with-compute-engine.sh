# setting up some environment variables
export VM_INSTANCE_ONE=my-vm-1
export VM_INSTANCE_TWO=my-vm-2
export VM_INSTANCE_ONE_ZONE=us-central1-a
export MY_REGION=us-central1
export MY_SELECTED_ZONE=us-central1-c

# Task 1: Create a virtual machine using the GCP Console

# Creates a VM Instance
gcloud beta compute --project=$DEVSHELL_PROJECT_ID instances create my-vm-3 \
    --zone=$VM_INSTANCE_ONE_ZONE --machine-type=e2-medium \
    --subnet=default --network-tier=PREMIUM \
    --maintenance-policy=MIGRATE \
    --service-account=853061025177-compute@developer.gserviceaccount.com \
    --tags=http-server --image=debian-9-stretch-v20200902 \
    --image-project=debian-cloud --boot-disk-size=10GB \
    --boot-disk-type=pd-standard --boot-disk-device-name=my-vm-1 \
    --reservation-affinity=any

gcloud compute --project=$DEVSHELL_PROJECT_ID firewall-rules create default-allow-http \
    --direction=INGRESS --priority=1000 \
    --network=default --action=ALLOW \
    --rules=tcp:80 --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

# Task 2: Create a virtual machine using the gcloud command line

# To display a list of all the zones in a region
gcloud compute zones list | grep $MY_REGION

# To set your default zone, enter the command below followed by the zone you chose.
gcloud config set compute/zone $MY_SELECTED_ZONE

# To create a VM instance called my-vm-2 in that zone
gcloud compute instances create "my-vm-2" \
    --machine-type "n1-standard-1" \
    --image-project "debian-cloud" \
    --image "debian-9-stretch-v20190213" \
    --subnet "default"

# Task 3: Connect between VM instances

# To SSH into my-vm-2 instance
gcloud compute ssh $VM_INSTANCE_TWO

# Use the ping command to confirm that my-vm-2 can reach my-vm-1 over the network:
ping -c 5 $VM_INSTANCE_ONE

# Use the ssh command to open a command prompt on my-vm-1:
gcloud compute ssh $VM_INSTANCE_ONE

# install the Nginx web server:
sudo apt-get install nginx-light -y

# Use sed command edit and add a custom message to the home page of the web server:
sudo sed -i -e '/<h1>/a\<p>Hi From Clevmania</p>' /var/www/html/index.nginx-debian.html

# Confirm that the web server is serving your new page. At the command prompt on my-vm-1, execute this command:
curl http://localhost/ 

# To exit the command prompt on my-vm-1, execute this command:
exit

# To confirm that my-vm-2 can reach the web server on my-vm-1, at the command prompt on my-vm-2, execute this command:
curl http://my-vm-1/

# Copy the External IP address for my-vm-1
# Now, paste the ip address into the address bar of a new browser tab
gcloud compute instances list --zone=$VM_INSTANCE_ONE_ZONE

