# XRCE_FUZZ: Fuzzing the Micro-XRCE-DDS Agent

This repository contains all resources developed as part of the project for the course **Advanced Operating Systems** at **Politecnico di Milano** in the academic year **2024/2025** by **Jacopo Viganò, Lorenzo Della Matera**.

## Project Goal

The objective of this project was to apply fuzzing techniques to the **eProsima Micro-XRCE-DDS protocol**, with a specific focus on identifying potential vulnerabilities and crashes within the **Micro-XRCE-DDS Agent**. Given the increasing adoption of DDS and XRCE-DDS in the automotive environment.

## Repository Contents

This repository serves as a central hub for all artifacts produced during the project. You will find:

* `Dockerfile`: A comprehensive Dockerfile to build a containerized environment ready for deploying fuzzing campaigns against the Micro-XRCE-DDS Agent. This includes necessary dependencies, cloning and setting up the target software, and integrating the fuzzing tool AFLNET.
* `scripts/`: A collection of custom scripts developed to automate various tasks, such as:
    * Setting up the fuzzing environment within the container.
    * Launching the Micro-XRCE-DDS Agent instrumented for fuzzing.
    * Starting fuzzing campaigns.
    * Applying patches.
* `patches/`: Contains patch files (`.patch`) generated to fix specific crashes or vulnerabilities discovered during fuzzing. These patches can be applied and removed via scripts to the original Micro-XRCE-DDS Agent source code. patches to integrate the Micro-XRCE-DDS protocol to AFLNET and to use AFL++ to recompile tje agent are also found here.
* `crash_packets/`: Contains the packets identified as sources of crashes within the agent, useful to reproduce the crashes also outside of the fuzzing environment.
* `patched-files/`: Contains the patched files used to produce (`.patch`) files. 
* `unpatched-files/`: Contains the unpatched versions of the patched files.
* `build.sh`: File used to build the contanier.
* `run-container.sh`: File used to run the contanier produced to easily start fuzzing campaigns.


## Getting Started (Building the Fuzzing Environment)

The recommended way to set up the environment is using the provided Dockerfile. This ensures all dependencies and tools are correctly installed and configured.

1.  **Prerequisites:** Ensure you have Docker installed on your system.
2.  **Clone this repository:**
    ```bash
    git clone https://github.com/j4kb4dw0lf/AOS_XRCEFUZZ.git
    cd AOS_XRCEFUZZ
    ```
3.  **Build the Docker Image:** Navigate into the cloned repository directory and build the Docker image using the provided `Dockerfile` via the `build.sh` file. This process will install dependencies, clone the Micro-XRCE-DDS-client and Micro-XRCE-DDS-agent and AFLnet repositories, and set up the environment as defined in the Dockerfile.
    ```bash
    chomd +x build.sh
    ./build.sh
    ```
    This might take some time depending on your internet connection and system performance.
4.  **Run a Container:** Once the image is built, you can launch a container from it using the same script.
    ```bash
    ./build.sh
    ```
    You are now inside the fuzzing environment container. The Micro-XRCE-DDS and AFLnet sources, along with other tools, will be available in the `/app` directory as defined in the Dockerfile.

## Running Fuzzing Campaigns

In order to run fuzzing campaigns, all it takes is running the script `run_fuzzying_campaign.sh` that relying on various other scripts collects the seeds for the fuzzing, launches the agent and also the fuzzer.

### Applying And Removing Patches

Using the two script `unpatch_agent.sh` and `patch_agent.sh` the agent can be patched and unpatched using the `.patch` files and said executable is rebuilt to apply the changes.
