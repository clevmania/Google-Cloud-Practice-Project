# Task 1: Confirm that needed APIs are enabled

# List Available APIs
gcloud services list --available

# Enable Kubernetes Engine API 
gcloud services enable container.googleapis.com  

# Enable Container Registry API 
gcloud services enable containerregistry.googleapis.com


# Task 2: Start a Kubernetes Engine cluster
export MY_ZONE=us-central1-a
export CLUSTER_NAME=webfrontend

# Start a Kubernetes cluster managed by Kubernetes Engine.
# Name the cluster webfrontend and configure it to run 2 nodes:
gcloud container clusters create $CLUSTER_NAME --zone $MY_ZONE --num-nodes 2

# After the cluster is created, 
# check your installed version of Kubernetes using the kubectl version command:
kubectl version

# Task 4: Run and deploy a container

# View the pod running the nginx container:
kubectl get pods

# Expose the nginx container to the Internet:
kubectl expose deployment nginx --port 80 --type LoadBalancer

# View the new service
# Note: It may take a few seconds before the External-IP field is populated for your service. 
# This is normal. Just re-run the kubectl get services command every few seconds until the field is populated.
kubectl get services

# Scale up the number of pods running on your service:
kubectl scale deployment nginx --replicas 3

# Confirm Kubernetes has updated the number of pods
kubectl get pods

# Confirm that your external IP address has not changed:
kubectl get services


