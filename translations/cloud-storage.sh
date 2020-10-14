#!/bin/bash

#set up environment variables
export BUCKET_NAME =cloud-storage-4c85975d4c28

#Create a Cloud Storage bucket
gsutil mb gs://$BUCKET_NAME

# Run the following command to download a sample file 
# (this sample file is a publicly available Hadoop documentation HTML file):

curl \
http://hadoop.apache.org/docs/current/\
hadoop-project-dist/hadoop-common/\
ClusterSetup.html > setup.html

# make copies of the file
cp setup.html setup2.html
cp setup.html setup3.html

# Task 2: Access control lists (ACLs)
# Run the following command to copy the first file to the bucket:
gsutil cp setup.html gs://$BUCKET_NAME/

# To get the default access list that's been assigned to setup.html,
# run the following command:
gsutil acl get gs://$BUCKET_NAME/setup.html  > acl.txt
cat acl.txt

# To set the access list to private and verify the results,
# run the following commands:
gsutil acl set private gs://$BUCKET_NAME/setup.html
gsutil acl get gs://$BUCKET_NAME/setup.html  > acl2.txt
cat acl2.txt

# To update the access list to make the file publicly readable,
# run the following commands:
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/setup.html
gsutil acl get gs://$BUCKET_NAME/setup.html  > acl3.txt
cat acl3.txt

# Examine the file in the Cloud Console
# Click On BUCKET_NAME
# Verify that for file setup.html, Public access has a Public link available.

# Delete the local file and copy back from Cloud Storage
# Delete the setup file
rm setup.html

# You can verify the file is deleted
ls

# To copy the file from the bucket again
gsutil cp gs://$BUCKET_NAME/setup.html setup.html

# Task 3: Customer-supplied encryption keys (CSEK)
# Generate a CSEK key
# For the next step, you need an AES-256 base-64 key.
python3 -c 'import base64; import os; print(base64.encodebytes(os.urandom(32)))'

# Copy the value of the generated key 
# excluding b' and \n' from the command output. Key should be in form of:
# b't8VRBKbhW5/47lq9XHWxa6GpMcNYiFcrX7Yy3Cz/L+Q=\n'

# Modify the boto file
# The encryption controls are contained in a gsutil configuration file named .boto.
ls -al
nano .boto

# If the .boto file is empty, close the nano editor with Ctrl+X 
# and generate a new .boto file using the gsutil config -n command. 
# Then, try opening the file again with the above commands.

# If the .boto file is still empty, you might have to locate it using the gsutil version -l command.

# Locate the line with "#encryption_key="
# Uncomment the line by removing the # character, 
# and paste the key you generated earlier at the end.

# Press Ctrl+O, ENTER to save the boto file, and then press Ctrl+X to exit nano.

# Upload the remaining setup files (encrypted) and verify in the Cloud Console
gsutil cp setup2.html gs://$BUCKET_NAME/
gsutil cp setup3.html gs://$BUCKET_NAME/

# Return to the Cloud Console, click to open your bucket
# Veridy both setup2.html and setup3.html files show that they are customer-encrypted.

# Delete local files, copy new files, and verify encryption
rm setup*

# To copy the files from the bucket again:
gsutil cp gs://$BUCKET_NAME/setup* ./

# cat the encrypted files to see whether they made it back:
cat setup.html
cat setup2.html
cat setup3.html

# Task 4: Rotate CSEK keys
# Open the .boto file
nano .boto

# Comment out the current encryption_key line by adding the # character to the beginning of the line.
# Uncomment decryption_key1 by removing the # character, 
# and copy the current key from the encryption_key line to the decryption_key1 line.
# Press Ctrl+O, ENTER to save the boto file, and then press Ctrl+X to exit nano.

# Note: In practice, you would delete the old CSEK key from the encryption_key line.

# Generate another CSEK key and add to the boto file
python3 -c 'import base64; import os; print(base64.encodebytes(os.urandom(32)))'

# Copy the value of the generated key excluding b' and \n' from the command output.
# Open the .boto file
nano .boto

# Uncomment encryption and paste the new key value for encryption_key=.
# Press Ctrl+O, ENTER to save the boto file, and then press Ctrl+X to exit nano.

# Rewrite the key for file 1 and comment out the old decrypt key
# When a file is encrypted, rewriting the file decrypts it using the decryption_key1 that you previously set,
# and encrypts the file with the new encryption_key.

# You are rewriting the key for setup2.html, but not for setup3.html, 
# so that you can see what happens if you don't rotate the keys properly.
gsutil rewrite -k gs://$BUCKET_NAME_1/setup2.html

# Open the .boto file
nano .boto

# Comment out the current decryption_key1 line by adding the # character back in.
# Press Ctrl+O, ENTER to save the boto file, and then press Ctrl+X to exit nano.

# Download setup 2 and setup3
gsutil cp  gs://$BUCKET_NAME/setup2.html recover2.html

gsutil cp  gs://$BUCKET_NAME/setup3.html recover3.html

# What happened? setup3.html was not rewritten with the new key, so it can no longer be decrypted, and the copy will fail.
# You have successfully rotated the CSEK keys.

# Task 5: Enable lifecycle management
# View the current lifecycle policy for the bucket
gsutil lifecycle get gs://$BUCKET_NAME

# There is no lifecycle configuration. So we create one in the next steps.

# Create a JSON lifecycle policy file
# Create a file named life.json,
nano life.json

# Paste the following:
# These instructions tell Cloud Storage to delete the object after 31 days.
{
  "rule":
  [
    {
      "action": {"type": "Delete"},
      "condition": {"age": 31}
    }
  ]
}

# Press Ctrl+O, ENTER to save the file, and then press Ctrl+X to exit nano.

# Set the policy and verify
# To set the policy
gsutil lifecycle set life.json gs://$BUCKET_NAME

# To verify the policy
gsutil lifecycle get gs://$BUCKET_NAME

# Task 6: Enable versioning
# View the versioning status for the bucket and enable versioning
# Notice - The Suspended policy means that it is not enabled.
gsutil versioning get gs://$BUCKET_NAME

# To enable versioning
gsutil versioning set on gs://$BUCKET_NAME

# To verify that versioning was enabled
gsutil versioning get gs://$BUCKET_NAME

# Create several versions of the sample file in the bucket
ls -al setup.html

# Open the setup file
nano setup.html

# Delete any a few lines from setup.html to change the size of the file.
# Exit nano

# Copy the file to the bucket with the -v versioning option:
gsutil cp -v setup.html gs://$BUCKET_NAME

# Open the setup file
nano setup.html

# Delete any a few lines from setup.html to change the size of the file.
# Exit nano

# Copy the file to the bucket with the -v versioning option:
gsutil cp -v setup.html gs://$BUCKET_NAME

# List all versions of the file
gsutil ls -a gs://$BUCKET_NAME/setup.html

# Highlight and copy the name of the oldest version of the file (the first listed),
# referred to as [VERSION_NAME] in the next step.
# Make sure to copy the full path of the file, starting with gs://

# Store the version value in the environment variable [VERSION_NAME].
export VERSION_NAME=<Enter VERSION name here>

# Download the oldest, original version of the file and verify recovery
gsutil cp $VERSION_NAME recovered.txt

# To verify recovery
ls -al setup.html

ls -al recovered.txt

# You have recovered the original file from the backup version.
# Notice that the original is bigger than the current version because you deleted lines.

# Task 7: Synchronize a directory to a bucket
# Make a nested directory and sync with a bucket

# Make a nested directory structure so that you can examine what happens when it is recursively copied to a bucket.
mkdir firstlevel
mkdir ./firstlevel/secondlevel
cp setup.html firstlevel
cp setup.html firstlevel/secondlevel

# To sync the firstlevel directory on the VM with your bucket,
gsutil rsync -r ./firstlevel gs://$BUCKET_NAME/firstlevel

# Examine the results

# In the Cloud Console, on the Navigation menu, click Storage > Browser.

# Click [BUCKET_NAME]. Notice the subfolders in the bucket.
# Click on /firstlevel and then on /secondlevel.

# Compare what you see in the Cloud Console with the results of the following command:
gsutil ls -r gs://$BUCKET_NAME/firstlevel

# Exit Cloud Shell:
exit