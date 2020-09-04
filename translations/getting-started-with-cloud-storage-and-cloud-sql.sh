#!/bin/bash

# Task 3: Create a Cloud Storage bucket using the gsutil command line
export LOCATION=US
export PROJECT_ID=qwiklabs-gcp-02-c1a4c8f171ec
export PROJECT_REGION=us-central1
export PROJECT_ZONE=us-central1-a

gsutil mb -l $LOCATION gs://$DEVSHELL_PROJECT_ID

gsutil cp gs://cloud-training/gcpfci/my-excellent-blog.png my-excellent-blog.png

gsutil cp my-excellent-blog.png gs://$DEVSHELL_PROJECT_ID/my-excellent-blog.png

gsutil acl ch -u allUsers:R gs://$DEVSHELL_PROJECT_ID/my-excellent-blog.png

# To create a VM instance named my-vm-2
gcloud compute instances create "my-vm-2" \
    --machine-type "n1-standard-1" \
    --image-project "debian-cloud" \
    --image "debian-9-stretch-v20190213" \
    --subnet "default"

gcloud compute instances list --filter="status=terminated" \
    --format="value(format(
        'gcloud compute instances delete {} --zone={} --quiet;', name, zone))" | bash


gsutil mb gs:// who killed you