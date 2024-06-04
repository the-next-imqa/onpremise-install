#!/usr/bin/sh

NODE_DIR=~/.node

if [ -d "$NODE_DIR" ]; then
  echo "Directory $NODE_DIR already exists. Skipping creation."
else
  echo "Directory $NODE_DIR does not exist. Creating..."
  mkdir -p "$NODE_DIR"
fi

tar -xvf node-v12.22.12-linux-x64.tar.xz -C "$NODE_DIR"
sudo ln -s "$NODE_DIR/node-v12.22.12-linux-x64/bin/node" /usr/local/bin/node
sudo ln -s "$NODE_DIR/node-v12.22.12-linux-x64/bin/npm" /usr/local/bin/npm

export NODE_HOME=$NODE_DIR/node-v12.22.12-linux-x64
export PATH=$PATH:$HOME/bin:$NODE_HOME/bin