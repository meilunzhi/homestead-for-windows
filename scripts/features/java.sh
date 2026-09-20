#!/usr/bin/env bash

set -e

if ! dpkg -s openjdk-17-jdk >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y openjdk-17-jdk
fi

JAVA_HOME_PATH="/usr/lib/jvm/java-17-openjdk-amd64"

if [ -x "${JAVA_HOME_PATH}/bin/java" ]; then
    sudo update-alternatives --set java "${JAVA_HOME_PATH}/bin/java"
    sudo update-alternatives --set javac "${JAVA_HOME_PATH}/bin/javac"

    sudo tee /etc/profile.d/java17.sh >/dev/null <<EOF
export JAVA_HOME=${JAVA_HOME_PATH}
export PATH="\$JAVA_HOME/bin:\$PATH"
EOF
fi

java -version
javac -version
