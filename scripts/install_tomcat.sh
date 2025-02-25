#!/bin/bash

install_tomcat() {
    
    # Define Tomcat version
    TOMCAT_VERSION="10"  # Change to the latest version as needed
    TOMCAT_BUILD="10.1.36"  # Change to the latest version as needed
    INSTALL_DIR="${HOME}/tomcat_${TOMCAT_VERSION}"  # Directory to install Tomcat
    DOWNLOAD_URL="https://dlcdn.apache.org/tomcat/tomcat-${TOMCAT_VERSION}/v${TOMCAT_BUILD}/bin/apache-tomcat-${TOMCAT_BUILD}.tar.gz"

    
        # Create installation directory if it doesn't exist
    if [ ! -d "${INSTALL_DIR}" ]; then
        echo "Creating installation directory at ${INSTALL_DIR} ..."
        mkdir -p "${INSTALL_DIR}"
    fi

    # Check if Tomcat is already installed
    if [ -x "${INSTALL_DIR}/bin/catalina.sh" ]; then
        echo -e '\nTomcat is already installed.'
        exit 0
    fi

    echo "Downloading Apache Tomcat ${TOMCAT_VERSION}..."
    # Download Tomcat package
    wget -q --show-progress -O "${INSTALL_DIR}/tomcat.tar.gz" "${DOWNLOAD_URL}"
    if [ $? -ne 0 ]; then
        echo 'Error: Failed to download Apache Tomcat.'
        exit 1
    fi
    
    echo 'Extracting Apache Tomcat...'
    # Extract the downloaded package
    tar -xzf "${INSTALL_DIR}/tomcat.tar.gz" -C "${INSTALL_DIR}" --strip-components=1
    if [ $? -ne 0 ]; then
        echo 'Error: Failed to extract Apache Tomcat.'
        exit 1
    fi
    # Remove the tar.gz file after extraction
    rm "${INSTALL_DIR}/tomcat.tar.gz"

    # Set up environment variables if not already set
    if ! grep -q "CATALINA_HOME=${INSTALL_DIR}" "$HOME/.bashrc"; then
        echo 'Setting up environment variables...'
        echo "export CATALINA_HOME=${INSTALL_DIR}" >> "$HOME/.bashrc"
        echo 'export PATH=$CATALINA_HOME/bin:$PATH' >> "$HOME/.bashrc"
    fi

    echo 'Applying environment variables...'
    # Load the new environment variables
    source "$HOME/.bashrc"

    echo 'Verifying Tomcat installation...'
    # Verify installation by running the version command
    "${INSTALL_DIR}/bin/version.sh"
    
}

install_tomcat 
