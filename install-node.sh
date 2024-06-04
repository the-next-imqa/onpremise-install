#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "usage: $0 [12|18]"
    echo "  12      install node 12"
    echo "  18      install node 18"
    exit 1
fi

ARG=$1

if [ "$ARG" -eq 12 ]; then
    NODE_PACKAGE="node-v12.22.12-linux-x64.tar.xz"
elif [ "$ARG" -eq 18 ]; then
    NODE_PACKAGE="node-v18.20.3-linux-x64.tar.xz"
else
    echo "Node version is not 12 or 18. Exiting..."
    exit 1
fi

NODE_DIR="$HOME/.node/$ARG"

if [ -d "$NODE_DIR" ]; then
    echo "Directory $NODE_DIR already exists. Skipping creation."
else
    echo "Directory $NODE_DIR does not exist. Creating..."
    mkdir -p "$NODE_DIR"
fi

if [ -f "$NODE_PACKAGE" ]; then
    echo "Extracting $NODE_PACKAGE..."
    tar -xJvf "$NODE_PACKAGE" --strip-components 1 -C "$NODE_DIR"
    echo "Extraction completed."
    export PATH=$NODE_DIR/bin:$PATH
    sudo ln -sf "$NODE_DIR/bin/node" /usr/local/bin/node
    sudo ln -sf "$NODE_DIR/bin/npm" /usr/local/bin/npm
    echo "Installation of Node $ARG completed."
else
    echo "Node package file $NODE_PACKAGE not found."
    exit 1
fi