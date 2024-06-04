#!/usr/bin/sh

NODE_DIR=~/.node

if [ -d "$NODE_DIR" ]; then
  echo "Directory $NODE_DIR already exists. Skipping creation."
else
  echo "Directory $NODE_DIR does not exist. Creating..."
  mkdir -p "$NODE_DIR"
fi

function usage {
    echo "usage: $0 [12|18] "
    echo "  12      install node 12"
    echo "  18      install node 18"
    exit 1
}

if [[ $1 == "12"]]
then
  tar -xvf node-v12.22.12-linux-x64.tar.xz -C "$NODE_DIR"
  sudo ln -s "$NODE_DIR/node-v12.22.12-linux-x64/bin/node" /usr/local/bin/node
  sudo ln -s "$NODE_DIR/node-v12.22.12-linux-x64/bin/npm" /usr/local/bin/npm
elif [[ $1 == "18"]]
then
  tar -xvf node-v18.20.3-linux-x64.tar.xz -C "$NODE_DIR"
  sudo ln -s "$NODE_DIR/node-v18.20.3-linux-x64/bin/node" /usr/local/bin/node
  sudo ln -s "$NODE_DIR/node-v18.20.3-linux-x64/bin/npm" /usr/local/bin/npm
else
  usage()
fi
