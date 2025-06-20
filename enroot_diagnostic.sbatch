#!/bin/bash
#SBATCH --gres=gpu:1
#SBATCH --time=00:10:00

# --- Log file configuration ---
# The script will now place output (.out) and error (.err) files
# into a 'logs' subdirectory. The filenames are derived from the job name (%x).
# To change the log name, edit the --job-name directive for the partition you are testing.
# Note: These logs will be OVERWRITTEN on subsequent runs with the same job name.
#
#SBATCH -o logs/%x.out
#SBATCH -e logs/%x.err


# --- Partition, Reservation, and Job Name Block (EDIT FOR YOUR USE) ---
#
# === OPTION 1: Default Partition (lrz-v100x2) ===
#
# #SBATCH -p lrz-v100x2
# #SBATCH --job-name=diag_lrz-v100x2

#SBATCH -p lrz-hgx-a100-80x4
#SBATCH --job-name=diag_lrz-hgx-a100-80x4

#
# === OPTION 2: Special Reservation (lrz-hgx-h100-94x4) ===
# To use the special 'test_inference' reservation:
# 1. Comment out the two lines in OPTION 1 above.
# 2. Uncomment the three lines below.
#
# #SBATCH -p lrz-hgx-h100-94x4
# #SBATCH --reservation=test_inference
# #SBATCH --job-name=diag_lrz-hgx-h100-94x4
#
# --- END Partition and Reservation Block ---


# This script is a general-purpose tool to diagnose Enroot configuration and
# permission issues on the LRZ AI Systems. It performs the following checks:
# 1. Creates the log directory.
# 2. Prints user and environment information.
# 3. Checks permissions of key directories.
# 4. Attempts a minimal, clean test of the Enroot workflow.

# --- Step 1: Ensure log directory exists ---
mkdir -p ./logs

echo "================================================="
echo "=== USER AND ENVIRONMENT INFORMATION          ==="
echo "================================================="
echo "Date: $(date)"
echo "Running on node: $(hostname)"
echo "User: $(whoami)"
echo "User ID: $(id)"
echo "Current Directory: $(pwd)"
echo ""
echo "--- SLURM Environment Variables ---"
env | grep SLURM
echo ""
echo "--- Enroot Environment Variables (if any are set) ---"
env | grep ENROOT
echo ""

echo "================================================="
echo "=== FILE SYSTEM PERMISSIONS CHECK             ==="
echo "================================================="
echo "Checking permissions for relevant directories..."
echo ""
echo "Home Directory (\$HOME):"
ls -ld $HOME
echo ""
echo "Current Working Directory (.):"
ls -ld .
echo ""
# The /raid directory seems to be causing issues. Let's check it.
echo "Checking /raid directory (if it exists):"
if [ -d "/raid" ]; then
    ls -ld /raid
else
    echo "/raid directory does not exist."
fi
echo ""
# /tmp is another common location for temporary files.
echo "Checking /tmp directory:"
ls -ld /tmp
echo ""


echo "================================================="
echo "=== MINIMAL ENROOT WORKFLOW TEST              ==="
echo "================================================="
# We will use the tiny 'alpine' image for a quick and clean test.
# This avoids any issues related to your specific tf-ready.sqsh image.
IMAGE_URI="docker://alpine"
CONTAINER_NAME="enroot-diag-test"

# --- Step 3.1: Import a standard container image ---
echo "--> Attempting to import '${IMAGE_URI}'..."
enroot import ${IMAGE_URI}
if [ $? -ne 0 ]; then
    echo "## ERROR: Failed to import image. Check permissions for cache path. ##"
    exit 1
fi
echo "--> Image import successful."
echo ""
ls -l alpine.sqsh
echo ""

# --- Step 3.2: Create a container from the image ---
echo "--> Attempting to create container '${CONTAINER_NAME}'..."
enroot create --name ${CONTAINER_NAME} alpine.sqsh
if [ $? -ne 0 ]; then
    echo "## ERROR: Failed to create container. This is where the permission error likely occurs. ##"
    echo "## Check the ENROOT_DATA_PATH location and its permissions. ##"
    exit 1
fi
echo "--> Container creation successful."
echo ""

# --- Step 3.3: Start the container and run a simple command ---
echo "--> Attempting to start container and run 'whoami'..."
enroot start ${CONTAINER_NAME} whoami
if [ $? -ne 0 ]; then
    echo "## ERROR: Failed to start the container. ##"
    exit 1
fi
echo "--> Container start successful."
echo ""


# --- Step 3.4: Clean up created artifacts ---
echo "--> Cleaning up..."
enroot remove -f ${CONTAINER_NAME}
rm -f alpine.sqsh
echo "--> Cleanup complete."
echo ""


echo "================================================="
echo "=== DIAGNOSTIC SCRIPT COMPLETED SUCCESSFULLY  ==="
echo "================================================="
echo "If this script completes without errors, your basic Enroot setup is working."
echo "The issue is likely with your specific container image or the script you are running inside it."
echo "If it fails, the error message should point to the problematic step (import or create)."

