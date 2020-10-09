#!/bin/bash

# Task 1: Create a utility virtual machine

gcloud beta compute --project=qwiklabs-gcp-02-a48b7442b31b instances create my-utility-vm  \
    --zone=us-central1-c --machine-type=n1-standard-1 \ 
    --subnet=default --no-address --maintenance-policy=MIGRATE \
    --service-account=1021017000827-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --image=debian-10-buster-v20200910 --image-project=debian-cloud \ 
    --boot-disk-size=10GB --boot-disk-type=pd-standard \
    --boot-disk-device-name=my-utility-vm --no-shielded-secure-boot \ 
    --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

# Task 2: Create a Windows virtual machine

gcloud beta compute --project=qwiklabs-gcp-02-a48b7442b31b instances create windows-2016 \
    --zone=europe-west2-a --machine-type=n1-standard-2 --subnet=default \
    --network-tier=PREMIUM --maintenance-policy=MIGRATE \
    --service-account=1021017000827-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --tags=http-server,https-server --image=windows-server-2016-dc-core-v20200908 \
    --image-project=windows-cloud --boot-disk-size=100GB --boot-disk-type=pd-ssd \
    --boot-disk-device-name=windows-2016 --no-shielded-secure-boot --shielded-vtpm \
    --shielded-integrity-monitoring --reservation-affinity=any

# Create firewall rule to allow http traffic to the vm
gcloud compute --project=qwiklabs-gcp-02-a48b7442b31b firewall-rules create default-allow-http \
    --direction=INGRESS --priority=1000 --network=default \
    --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

# Create firewall rule to allow https traffic to the vm
gcloud compute --project=qwiklabs-gcp-02-a48b7442b31b firewall-rules create default-allow-https \
    --direction=INGRESS --priority=1000 --network=default \
    --action=ALLOW --rules=tcp:443 \
    --source-ranges=0.0.0.0/0 --target-tags=https-server

# PJGId)O?0eSrNo8
# Task 3: Create a custom virtual machine

gcloud beta compute --project=qwiklabs-gcp-02-a48b7442b31b instances create my-custom-vm \
    --zone=us-west1-b --machine-type=custom-6-32768 --subnet=default \
    --network-tier=PREMIUM --maintenance-policy=MIGRATE \
    --service-account=1021017000827-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --image=debian-10-buster-v20200910 --image-project=debian-cloud \
    --boot-disk-size=10GB --boot-disk-type=pd-standard \
    --boot-disk-device-name=my-custom-vm --no-shielded-secure-boot \
    --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

# Task 4: Connect via SSH to your custom VM
gcloud compute ssh my-custom-vm --zone us-west1-b --tunnel-through-iap

# To see information about unused and used memory and swap space on your custom VM:
free

# To see details about the RAM installed on your VM:
sudo dmidecode -t 17

# To verify the number of processors:
nproc

# To see details about the CPUs installed on your VM:
lscpu

# To exit the SSH terminal:
exit

