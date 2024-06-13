#!/bin/bash
sudo apt update && sudo apt install -y nano curl git python3 python3-pip

# Prompt for the kaapana branch name to build
read -p "Enter the kaapana branch to clone: " branch_name
export branch_name

git clone -b $branch_name https://github.com/kaapana/kaapana.git

python3 -m pip install -r kaapana/build-scripts/requirements.txt

sudo snap install docker --classic --channel=latest/stable
sudo groupadd docker
sudo usermod -aG docker $USER

sudo snap install helm --classic --channel=latest/stable
helm plugin install https://github.com/instrumenta/helm-kubeval

# Prompt for the registry username
read -p "Enter your registry username: " REGISTRY_USER

# Prompt for the registry password without echoing input
read -s -p "Enter your registry password: " REGISTRY_PW
echo # Move to a new line

# Prompt for the registry organization
read -s -p "Enter your registry password: " REGISTRY_ORG
echo # Move to a new line

# Export the entered values as environment variables
export REGISTRY_USER
export REGISTRY_PW
export REGISTRY_ORG

cat > kaapana/build-scripts/build-config.yaml <<EOL

http_proxy: "" # put the proxy here if needed
default_registry: "registry.hub.docker.com/${REGISTRY_ORG}" # registry url incl. project Gitlab template: "registry.<gitlab-url>/<group/user>/<project>"
registry_username: "" # container registry username
registry_password: "" # container registry password
container_engine: "docker" # docker or podman
enable_build_kit: false # Should be false for now: Docker BuildKit: https://docs.docker.com/develop/develop-images/build_enhancements/
log_level: "INFO" # DEBUG, INFO, WARNING or ERROR
build_only: false # charts and containers will only be build and not pushed to the registry
create_offline_installation: false # Advanced feature - whether to create a docker dump from which the platform can be deployed offline (file-size ~50GB)
push_to_microk8s: false # Advanced feature - inject container directly into microk8s after build
exit_on_error: true  # stop immediately if an issue occurs
enable_linting: true # should be true - checks deployment validity
skip_push_no_changes: false # Advanced feature - should be false usually
platform_filter: "kaapana-admin-chart" # comma seperated platform-chart-names
external_source_dirs: "" # comma seperated paths
build_ignore_patterns: "" # comma seperated list of directory paths or files that should be ignored
parallel_processes: 2 # parallel process count for container build + push
include_credentials: false # Whether to include the used registry credentials into the deploy-platform script
enable_image_stats: false # Whether to enable container image size statistics (build/image_stats.json)
vulnerability_scan: false # Whether containers should be checked for vulnerabilities during build.
vulnerability_severity_level: "CRITICAL,HIGH" # Filter by severity of findings. CRITICAL, HIGH, MEDIUM, LOW, UNKNOWN. All -> ""
configuration_check: false # Wheter the Charts, deployments, dockerfiles etc. should be checked for configuration errors.
configuration_check_severity_level: "CRITICAL,HIGH" # Filter by severity of findings. CRITICAL, HIGH, MEDIUM, LOW, UNKNOWN. All -> ""
create_sboms: false # Create Software Bill of Materials (SBOMs) for the built containers.
EOL

./kaapana/build-scripts/start_build.py 
