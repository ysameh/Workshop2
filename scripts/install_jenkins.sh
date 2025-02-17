#! /bin/bash


install_jenkins(){

    # Define default variables
    Jenkins_Version="2"   # Add desired Jenkins version
    Jenkins_Build="2.495" # Add desired Jenkins build
    Install_Dir="$HOME/jenkins_${Jenkins_Version}" # Directory path to install java
    Download_URL="https://get.jenkins.io/war/${Jenkins_Build}/jenkins.war" # Constructing the downlad URL
    
    # Check if installation directory already exist and create it if doesn't exist
    if [ -d "${Install_Dir}" ]; then
	echo "Installation directory already exists."
    else
	echo "Creating installation directory at $Install_Dir"
	mkdir -p "${Install_Dir}"
    fi

    # Check if Jenkins already installed
    if [ -f "${Install_Dir}/jenkins.war" ]; then
	echo "Jenkins already installed"
#	echo 'Starting Jenkins...'
#	echo "java -Dhudson.util.ProcessTree.disable=true -jar ${INSTALL_DIR}/jenkins.war"
	exit 0
    fi

    # Download Jenkins
    echo "Downloading Jenkins ${Jenkins_Version} (${Jenkins_Build})..."
    wget -q --show-progress -O "${Install_Dir}/jenkins.war" "${Download_URL}"
    if [ $? -ne 0 ]; then # Checking for failed download
	echo "Error: Failed to download Jenkins"
	exit 1
    fi

    # Setting environment variables
    if ! grep -q "JENKINS_HOME=${Install_Dir}" "$HOME/.bashrc"; then
	echo "Setting up environment variables..."
	echo "export JENKINS_HOME=${Install_Dir}" >> "$HOME/.bashrc"
    else
	echo "Environment variables already set"
    fi

    # Apply environment changes
    echo "Applying environment changes..."
    source "$HOME/.bashrc"

 #  echo 'Jenkins installation complete. To start Jenkins, run:'
 #  echo "java -Dhudson.util.ProcessTree.disable=true -jar ${INSTALL_DIR}/jenkins.war"
}

install_jenkins










