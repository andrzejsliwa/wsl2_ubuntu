all: bootstrap rvm docker java git

.PHONY: bootstrap rvm

DOCKER_DIR=/mnt/wsl/shared-docker

bootstrap:
	sudo apt update
	sudo apt install -y software-properties-common

git: ## Install git & gh
	sudo apt install -y git gh
	git config --global user.name "Andrzej Śliwa"
	git config --global user.email "andrzej.sliwa@gmail.com"
	git config --global init.defaultBranch "main"

rvm: ## Install RVM
	sudo apt-add-repository -y ppa:rael-gc/rvm
	sudo apt-get update
	sudo apt-get -y install rvm
	sudo usermod -a -G rvm ${USER}
	echo 'source "/etc/profile.d/rvm.sh"' >> ~/.bashrc
	@echo "Run 'wsl —shutdown' inside of PowerShell to restart WSL & propagate permissions"

docker: ## Install Docker
	sudo apt install -y --no-install-recommends apt-transport-https ca-certificates curl gnupg2 lsb-release
	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	echo \
  		"deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  		`lsb_release -cs` stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get -y update
	sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	mkdir -pm o=,ug=rwx "$(DOCKER_DIR)"
	sudo chgrp docker "$(DOCKER_DIR)"
	sudo mkdir -p /etc/docker
	sudo touch /etc/docker/deamon.json
	echo '{"hosts": ["unix:///mnt/wsl/shared-docker/docker.sock"]}' | sudo tee -a /etc/docker/daemon.json
	echo 'DOCKER_SOCK="/mnt/wsl/shared-docker/docker.sock"' | sudo tee -a ~/.bashrc
	echo 'test -S "$$DOCKER_SOCK" && export' | sudo tee -a  ~/.bashrc
	echo "%docker ALL=(ALL) NOPASSWD: /usr/bin/dockerd" | sudo tee -a /etc/sudoers
	sudo curl -L https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	sudo cp profile.d/docker.sh /etc/profile.d/docker.sh
	echo 'source "/etc/profile.d/docker.sh"' >> ~/.bashrc

java:
	sudo apt-get -y install openjdk-17-jdk openjdk-17-jre unzip
	wget https://services.gradle.org/distributions/gradle-7.6-bin.zip -P /tmp
	sudo unzip -d /opt/gradle /tmp/gradle-7.6-bin.zip
	sudo ln -s /opt/gradle/gradle-7.6 /opt/gradle/latest
	sudo cp profile.d/java.sh /etc/profile.d/java.sh
	echo 'source "/etc/profile.d/java.sh"' >> ~/.bashrc

define print_help
	grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(1) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36mmake %-20s\033[0m%s\n", $$1, $$2}'
endef

help:
	@printf "\033[36mHelp: \033[0m\n"
	@$(foreach file, $(MAKEFILE_LIST), $(call print_help, $(file));)

$(V).SILENT: