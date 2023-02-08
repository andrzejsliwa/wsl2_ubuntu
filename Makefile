all: rvm docker java git

.PHONY: bootstrap rvm

bootstrap:
	sudo apt update
	sudo apt upgrade
	sudo echo "[boot]" > /etc/wsl.conf
	sudo echo "systemd=true" >> /etc/wsl.conf
	sudo apt install -y software-properties-common
	wsl.exe --shutdown

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

docker: ## Install Docker
	sudo apt-get install ca-certificates curl gnupg lsb-release	
	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	echo \
  		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
		$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	sudo docker run hello-world
	sudo curl -L https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose

java: ## Install Java & Gradle
	sudo apt-get -y install openjdk-17-jdk openjdk-17-jre unzip
	wget https://services.gradle.org/distributions/gradle-7.6-bin.zip -P /tmp
	sudo unzip -d /opt/gradle /tmp/gradle-7.6-bin.zip
	sudo ln -s /opt/gradle/gradle-7.6 /opt/gradle/latest
	echo 'export JAVA_HOME=$$(dirname $$(dirname $$(readlink -f $$(which javac))))' >> ~/.bashrc
	echo 'export PATH=/opt/gradle/gradle-7.6/bin:$PATH' >> ~/.bashrc

define print_help
	grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(1) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36mmake %-20s\033[0m%s\n", $$1, $$2}'
endef

help:
	@printf "\033[36mHelp: \033[0m\n"
	@$(foreach file, $(MAKEFILE_LIST), $(call print_help, $(file));)

$(V).SILENT:
