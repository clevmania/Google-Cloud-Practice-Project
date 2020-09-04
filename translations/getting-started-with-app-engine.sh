#!/bin/bash

# Task 1: Initialize App Engine

# Initialize your App Engine app with your project and choose its region:
gcloud app create --project=$DEVSHELL_PROJECT_ID

# Clone the source code repository for a sample application:
git clone https://github.com/GoogleCloudPlatform/python-docs-samples

# Navigate to the hello_world directory:
cd python-docs-samples/appengine/standard_python3/hello_world

# Task 2: Run Hello World application locally

# Execute the following command to download and update the packages list.
sudo apt-get update

# Set up a virtual environment in which you will run your application. 
# Python virtual environments are used to isolate package installations from the system.
sudo apt-get install virtualenv

# If prompted [Y/n], press Y and then Enter.
virtualenv -p python3 venv 

# Activate the virtual environment.
source venv/bin/Activate

# Navigate to your project directory and install dependencies.
pip install -r requirements.txt

# Run the application
python main.py

# Task 3: Deploy and run Hello World on App Engine

# Navigate to the source directory
cd ~/python-docs-samples/appengine/standard_python3/hello_world

# Deploy your Hello World application
# If prompted "Do you want to continue (Y/n)?", press Y and then Enter.
gcloud app deploy

# Launch your browser to view the app at http://YOUR_PROJECT_ID.appspot.com
gcloud app browse


# Task 4: Disable the application

# App Engine offers no option to Undeploy an application. After an application is deployed,
# it remains deployed, although you could instead replace the application 
# with a simple page that says something like "not in service."




