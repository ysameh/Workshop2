#!/bin/bash


NAGIOS_VERSION="4.5.1"
INSTALL_PATH="$HOME/nagios"
SOURCE_DIR="/tmp/nagios-${NAGIOS_VERSION}"


if [ -x "$INSTALL_PATH/bin/nagios" ]; then
    echo -e '\nNagios is already installed.'
    exit 0
fi

# Download Nagios source if not already downloaded
if [ ! -f "/tmp/nagios-${NAGIOS_VERSION}.tar.gz" ]; then
    echo "Downloading Nagios..."
    wget -q --show-progress -O "/tmp/nagios-${NAGIOS_VERSION}.tar.gz" \
    "https://assets.nagios.com/downloads/nagioscore/releases/nagios-${NAGIOS_VERSION}.tar.gz"
fi

# Extract source
echo "Extracting Nagios..."
rm -rf "$SOURCE_DIR"
tar -xzf "/tmp/nagios-${NAGIOS_VERSION}.tar.gz" -C /tmp

# Compile and install
echo "Compiling and installing Nagios..."
cd "$SOURCE_DIR"
./configure --prefix="$INSTALL_PATH" --with-nagios-user="$USER" --with-nagios-group="$USER" --with-httpd-conf=/etc/httpd/conf.d  &>/dev/null

#make -j$(nproc) &>/dev/null  # Using parallel jobs
make all &>/dev/null
make install &>/dev/null
make install-commandmode &>/dev/null
make install-init &>/dev/null
make install-config &>/dev/null
make install-webconf &>/dev/null
make install-daemoninit &>/dev/null


# Configure Nagios
#echo "Configuring Nagios..."
#cp "$SOURCE_DIR"/sample-config/nagios.cfg "$INSTALL_PATH"/etc/nagios.cfg
echo "Installing Nagios plugins"

cd /tmp
wget -q --show-progress https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz
tar -xzf nagios-plugins-2.3.3.tar.gz
cd nagios-plugins-2.3.3

./configure --prefix="$INSTALL_PATH" --with-nagios-user="$USER" --with-nagios-group="$USER" &>/dev/null

#make -j$(nproc) &>/dev/null  # Using parallel jobs 
make install &>/dev/null

#Setting Nagios home enviroment variable
if ! grep -q "NAGIOS_HOME=${INSTALL_DIR}" "$HOME/.bashrc"; then
    echo "export NAGIOS_HOME=${INSTALL_PATH}" >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
fi




# Start Nagios
#echo "Starting Nagios..."
nohup "$INSTALL_PATH/bin/nagios" "$INSTALL_PATH/etc/nagios.cfg" &



echo "Nagios installation completed successfully!"
