#!/bin/bash

# Add path to encrypted file with the list of users and the decryption key
ENCRYPTED_FILE="credentials.enc"
DECRYPTION_KEY="adminuser"

# Log the script execution
logger "Script $0 executed"

# Function to decrypt credentials
decrypt_credentials() {
    # Check for the encrypted file
    if [ ! -f "${ENCRYPTED_FILE}" ]; then
        echo "Error: Encrypted credentials file '${ENCRYPTED_FILE}' not found."
        exit 1
    fi

    # Decrypt the file
    DECRYPTED_CREDENTIALS=$(openssl enc -aes-256-cbc -pbkdf2 -d -in "${ENCRYPTED_FILE}" -k "${DECRYPTION_KEY}")
    if [ $? -ne 0 ]; then
        echo "Error: Failed to decrypt credentials file."
        exit 1
    fi

    # Store credentials in an array
    read -d '' -r -a USER_CREDENTIALS <<< "${DECRYPTED_CREDENTIALS}"
}

# Function to create a user
create_user() {
    local username="$1"
    local hashed_pass="$2"

    # Check if user already exists
    if id "${username}" &>/dev/null; then
        echo "User '${username}' already exists."
    else
        # Create the user
        echo "Creating user '${username}'..."
        sudo useradd -m -s /bin/bash -p "${hashed_pass}" "${username}" &>/dev/null
        if [ $? -ne 0 ]; then
            echo "Error: Failed to create user '${username}'."
            exit 1
        fi
	# Log 
        logger "User '${username}' created by $(whoami) using root privileges"
    fi
}

# Function to install Java JDK as the new user
install_jdk() {
    local username="$1"
    local userpass="$2"

    # Defining JDK version and build
    JDK_VERSION="17"
    JDK_BUILD="17.0.12"
    INSTALL_DIR="/home/${username}/java_${JDK_VERSION}" # Directory to install Java JDK
    DOWNLOAD_URL="https://download.oracle.com/java/${JDK_VERSION}/archive/jdk-${JDK_BUILD}_linux-x64_bin.tar.gz"  # Building the download URL

    echo "Switching to '${username}' user..."
    echo "${userpass}" | su - "${username}" -c "
        if [ ! -d \"$INSTALL_DIR\" ]; then
            echo -e '\nCreating installation directory at $INSTALL_DIR...'
            mkdir -p \"$INSTALL_DIR\"
        fi

        if [ -x \"$INSTALL_DIR/bin/java\" ]; then
            echo -e '\nJDK is already installed.'
            exit 0
        fi

        echo 'Downloading JDK $JDK_VERSION ($JDK_BUILD)...'
        wget -q --show-progress -O \"$INSTALL_DIR/jdk.tar.gz\" \"$DOWNLOAD_URL\"
        if [ $? -ne 0 ]; then
            echo 'Error: Failed to download JDK.'
            exit 1
        fi

        echo 'Extracting JDK...'
        tar -xzf \"$INSTALL_DIR/jdk.tar.gz\" -C \"$INSTALL_DIR\" --strip-components=1
        if [ $? -ne 0 ]; then
            echo 'Error: Failed to extract JDK.'
            exit 1
        fi
        rm \"$INSTALL_DIR/jdk.tar.gz\"

        if ! grep -q 'JAVA_HOME=$INSTALL_DIR' ~/.bashrc; then
            echo 'Setting up environment variables...'
            echo 'export JAVA_HOME=$INSTALL_DIR' >> ~/.bashrc
            echo 'export PATH=\$JAVA_HOME/bin:\$PATH' >> ~/.bashrc
        fi

        echo 'Applying environment variables...'
        source ~/.bashrc

        echo 'Verifying JDK installation...'
        java -version
    "
}

# Function to install Apache Tomcat as the new user
install_tomcat() {
    local username="$1"
    local userpass="$2"

    # Define Tomcat version
    TOMCAT_VERSION="10"  # Change to the latest version as needed
    TOMCAT_BUILD="10.1.34"  # Change to the latest version as needed
    INSTALL_DIR="/home/${username}/tomcat_${TOMCAT_VERSION}"  # Directory to install Tomcat
    DOWNLOAD_URL="https://dlcdn.apache.org/tomcat/tomcat-${TOMCAT_VERSION}/v${TOMCAT_BUILD}/bin/apache-tomcat-${TOMCAT_BUILD}.tar.gz"

    echo "Switching to '${username}' user..."
    echo "${userpass}" | su - "${username}" -c "
        # Create installation directory if it doesn't exist
        if [ ! -d \"$INSTALL_DIR\" ]; then
            echo -e '\nCreating installation directory at $INSTALL_DIR...'
            mkdir -p \"$INSTALL_DIR\"
        fi

        # Check if Tomcat is already installed
        if [ -x \"$INSTALL_DIR/bin/catalina.sh\" ]; then
            echo -e '\nTomcat is already installed.'
            exit 0
        fi

        echo 'Downloading Apache Tomcat $TOMCAT_VERSION...'
        # Download Tomcat package
        wget -q --show-progress -O \"$INSTALL_DIR/tomcat.tar.gz\" \"$DOWNLOAD_URL\"
        if [ $? -ne 0 ]; then
            echo 'Error: Failed to download Apache Tomcat.'
            exit 1
        fi

        echo 'Extracting Apache Tomcat...'
        # Extract the downloaded package
        tar -xzf \"$INSTALL_DIR/tomcat.tar.gz\" -C \"$INSTALL_DIR\" --strip-components=1
        if [ $? -ne 0 ]; then
            echo 'Error: Failed to extract Apache Tomcat.'
            exit 1
        fi
        # Remove the tar.gz file after extraction
        rm \"$INSTALL_DIR/tomcat.tar.gz\"

        # Set up environment variables if not already set
        if ! grep -q 'CATALINA_HOME=$INSTALL_DIR' ~/.bashrc; then
            echo 'Setting up environment variables...'
            echo 'export CATALINA_HOME=$INSTALL_DIR' >> ~/.bashrc
            echo 'export PATH=\$CATALINA_HOME/bin:\$PATH' >> ~/.bashrc
        fi

        echo 'Applying environment variables...'
        # Load the new environment variables
        source ~/.bashrc

        echo 'Verifying Tomcat installation...'
        # Verify installation by running the version command
        \"$INSTALL_DIR/bin/version.sh\"
    "
}


# Main script execution
decrypt_credentials

# Loop on the array of users
for credential in "${USER_CREDENTIALS[@]}"; do 
    USERNAME=$(echo "${credential}" | cut -d '=' -f1)
    USERPASS=$(echo "${credential}" | cut -d '=' -f2)
    HashedPASS=$(openssl passwd -6 "${USERPASS}")

    create_user "${USERNAME}" "${HashedPASS}"
    install_jdk "${USERNAME}" "${USERPASS}"
    install_tomcat "${USERNAME}" "${USERPASS}"
done
