#!/bin/bash

# Check the user is root or not
if [ $(whoami) != "root" ]; then
    echo "login as a root user.";
    exit 0;
fi

# Set the installation directory
INSTALL_DIR="/usr/lib/jvm"

# Download the latest java -Part 1
wget -q https://www.oracle.com/java/technologies/downloads -O /tmp/trial 2> /dev/null

if [ $? -ne 0 ]; then
	echo "error code 1";
fi

grep -P 'linux-x64_bin.tar.gz' /tmp/trial -m 1 > /tmp/test
link=$(sed -n 's/.*href="\([^"]*\).*/\1/p' /tmp/test)

# link=https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz

NEW_VERSION=$(echo "$link" | grep -o "jdk-.*" | sed 's/_linux-x64_bin.tar.gz//' | grep -o '[0-9]\+');

# Check if the current version is the latest version or not

if command -v java >/dev/null; then
	CURRENT_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')

	if [ "$CURRENT_VERSION" = "$NEW_VERSION" ]; then
		echo "The newest java version is already installed in the system";
		exit 0
	fi
fi

# Download the latest java -Part 2
wget --header "Cookie: oraclelicense=accept-securebackup-cookie" --show-progress -q $link  -O /tmp/jdk.tar.gz

# Extract the JDK archive file to the installation directory
mkdir -p $INSTALL_DIR
tar -zxf /tmp/jdk.tar.gz -C $INSTALL_DIR

NEW_VERSION=$(ls -t $INSTALL_DIR | head -n 1)

# Set the default Java version

update-alternatives --install /usr/bin/java java "$INSTALL_DIR/$NEW_VERSION/bin/java" 1
update-alternatives --install /usr/bin/javac javac "$INSTALL_DIR/$NEW_VERSION/bin/javac" 1
update-alternatives --install /usr/bin/jar jar "$INSTALL_DIR/$NEW_VERSION/bin/jar" 1

# Set the JAVA_HOME environment variable
echo "export JAVA_HOME=$INSTALL_DIR/jdk*" >> ~/.bashrc
echo "export PATH=$JAVA_HOME/bin:$PATH" >> ~/.bashrc

# Clean up
rm /tmp/jdk.tar.gz /tmp/test /tmp/trial
