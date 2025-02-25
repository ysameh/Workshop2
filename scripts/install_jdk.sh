#!/bin/bash



# Function to install Java JDK as the new user
install_jdk() {
  

    # Defining JDK version and build
    JDK_VERSION="17"
    JDK_BUILD="17.0.12"
    INSTALL_DIR="$HOME/java_${JDK_VERSION}" # Directory to install Java JDK
    DOWNLOAD_URL="https://download.oracle.com/java/${JDK_VERSION}/archive/jdk-${JDK_BUILD}_linux-x64_bin.tar.gz"  # Building the download URL

    
    
    if [ ! -d "${INSTALL_DIR}" ]; then
        echo "Creating installation directory at $INSTALL_DIR..."
        mkdir -p "${INSTALL_DIR}"
    fi

    if [ -x "${INSTALL_DIR}/bin/java" ]; then
        echo -e '\nJDK is already installed.'
        exit 0
    fi

    echo "Downloading JDK $JDK_VERSION ($JDK_BUILD)..."
    wget -q --show-progress -O "$INSTALL_DIR/jdk.tar.gz" "$DOWNLOAD_URL"
    if [ $? -ne 0 ]; then
        echo 'Error: Failed to download JDK.'
        exit 1
    fi

    echo 'Extracting JDK...'
    tar -xzf "$INSTALL_DIR/jdk.tar.gz" -C "$INSTALL_DIR" --strip-components=1
    if [ $? -ne 0 ]; then
        echo 'Error: Failed to extract JDK.'
        exit 1
    fi
    rm "$INSTALL_DIR/jdk.tar.gz"
    
    if ! grep -q "JAVA_HOME=$INSTALL_DIR" ~/.bashrc; then
        echo 'Setting up environment variables...'
        echo "export JAVA_HOME=$INSTALL_DIR" >> ~/.bashrc
        echo "export PATH=$JAVA_HOME/bin:$PATH" >> ~/.bashrc
    fi
    
    echo 'Applying environment variables...'
    source ~/.bashrc

    echo 'Verifying JDK installation...'
    java -version
    
}

install_jdk
