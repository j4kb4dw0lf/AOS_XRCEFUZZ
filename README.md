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
* `patched_files/`: Contains the patched files used to produce (`.patch`) files. 
* `unpatched_files/`: Contains the unpatched versions of the patched files.
* `build.sh`: File used to build the contanier.
* `run_container.sh`: File used to run the contanier produced to easily start fuzzing campaigns.

## Getting Started (Building the Fuzzing Environment)

The recommended way to set up the environment is using the provided Dockerfile. This ensures all dependencies and tools are correctly installed and configured.

1. **Prerequisites:** Ensure you have Docker installed on your system.
2. **Clone this repository:**

    ```bash
    git clone https://github.com/j4kb4dw0lf/AOS_XRCEFUZZ.git
    cd AOS_XRCEFUZZ
    ```

3. **Build the Docker Image:** Navigate into the cloned repository directory and build the Docker image using the provided `Dockerfile` via the `build.sh` file. This process will install dependencies, clone the Micro-XRCE-DDS-client and Micro-XRCE-DDS-agent and AFLnet repositories, and set up the environment as defined in the Dockerfile.

    ```bash
    chomd +x build.sh
    ./build.sh
    ```

    This might take some time depending on your internet connection and system performance.
4. **Run a Container:** Once the image is built, you can launch a container from it using the script.

    ```bash
    ./run_container.sh
    ```

    You are now inside the fuzzing environment container. The Micro-XRCE-DDS and AFLnet sources, along with other tools, will be available in the `/app` directory as defined in the Dockerfile.

## The scripts inside the repository, their usage and purpose

#### Bash scripts

* `aflnet_pcap_pipeline.sh <port> <capture_duration_seconds>`

This script deals with the entire pipeline related to **capturing traffic** towards the agent and **generating seed files for fuzzing campaigns**, the port to be set is the one the agent has been opened on, the capture duration my influence the completeness of the seeds, "15" (seconds) was found to be a great value for capture time during our attempts.

* `generate_patches.sh`

Script used to statically **generate `.patch` files** for the agent and aflnet, it takes no inputs and works directly using the directories `unpatched_files` and `patched_files` putting the patches inside the directory `patches`.

* `patch_agent.sh`

Script used to **apply** our proposed **patches** to the agent and rebuild it with them incorporated.

* `replay_packet.sh <port> <packet1.raw> [<packet2.raw> ...]`

This script can be used to **replay** retrieved **packets** that generate crashes or to check whetere a specific packet corpus is reached by the agent and generate errors or not. The port to specify is the one the agent has been opened on, the entire or relative packets path is then to be specified. all the packets will be sent from the same port using UDP.

* `runall_clients.sh  <agent_port> <timeout_seconds>`

Script used to **run** most of the **client examples** provided by eprosima in the Micro-XRCE-DDS repository, the port to be specified is the one the agent was opened on, the clients are run in parallel for `timeout_seconds` and will flush all their output to `/dev/null`

* `run_fuzzying_campaign.sh <agent_port> <output_dir> <capture_time> [campaign_time] [verbosity]`

This script deals with the **entire fuzzing pipeline**, launches the agent instance on port `agent_port`, `runall_clients.sh` and `aflnet_pcap_pipeline.sh`, then relaunches the agent for the fuzzing and AFLNET itself, using the seeds generated for the campaign. The fuzzing campaign will be protraied for `campaign_time`, while `verbosity` refers to the verbosity of the agent logger. both agent and fuzzer are run inside tmux to ensure readability, all results of the campaign are saved inside `output_dir`.

* `unpatch_agent.sh`

Script used to **remove** our proposed **patches** from the agent and rebuild it without them.

* `time_capsule.sh [workon|latest]`

Script that when used either takes back the agent repo to the commit we worked on `workon` or takes it to the head of the main branch `latest` and afterwards rebuilds the agent.
**Please notice all patches applied to agent by the script `patch_agent.sh` are only supposed to work in the commit we worked on, by using the time capsule script the patches to the bugs will be the ones implemented by eprosima itself.**

#### Python scripts

* `extract_raws.py <input.pcap> <server_port> <output_dir>`

This python script is used to **extract `.raw` files form the `.pcap` files** generated from tcpdump, this script is used by `aflnet_pcap_pipeline.sh` to generate seed files for AFLNET. all the flows directed to `server_port` are separated and analyzed to be then put inside `output_dir` as `.raw` files.

* `gen_crash.py`

This python script is used to **generate `.raw` files** contaning packets using a bytearray contaning the packet bytes retrieved either from the agent log or from gdb by dumping memory, both the name and the bytes are to be modified inside the script itself.

* `send_udp.py <port> <base64_packet1> [<base64_packet2> ...]`

This script **sends to the specified port** all the base64 encoding of the `.raw` **packets** it is provided, using UDP, this script is used in the script `replay_packets.sh`.
