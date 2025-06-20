# Enroot and SLURM Testing on LRZ AI Systems

This repository contains scripts for testing and debugging containerized workflows using Enroot and the SLURM scheduler on the Leibniz Supercomputing Centre (LRZ) AI Systems.

## Project Overview

The primary goal of this repository is to provide tools to diagnose configuration issues and verify Enroot functionality across different compute partitions. It is designed to be a general resource for ensuring containerized environments run smoothly on the LRZ HPC infrastructure.

## Key Scripts

* `enroot_diagnostic.sbatch`: A general-purpose diagnostic script to test and debug Enroot container setups on the LRZ compute partitions. This is useful for identifying permission or configuration issues before running a full workload.

## How to Run a Job

Jobs are submitted to the SLURM workload manager.

1.  **Modify the job script**: Open the desired `.sbatch` file (e.g., `enroot_diagnostic.sbatch`) and edit the partition, reservation, and job name as needed.
2.  **Submit the job**:
    ```bash
    sbatch enroot_diagnostic.sbatch
    ```
3.  **Check the logs**: Output and error logs will be saved in the `./logs/` directory.

## Environment

This project is designed to run within the LRZ AI Systems environment, which utilizes:

* **SLURM**: For job scheduling and resource management.
* **Enroot**: For containerized software environments.
* **NVIDIA GPUs**: Jobs are configured to run on partitions like `lrz-v100x2` or `lrz-hgx-h100-94x4`.

