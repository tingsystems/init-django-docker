#!/usr/bin/env bash
set -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
export PATH="$PATH:/usr/bin"
sudo apt-get update
# docker
echo "Installing docker"
sudo apt-get install -y ca-certificates curl gnupg
sudo apt-get install -y apt-transport-https ca-certificates gnupg curl sudo
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo "creating dirs"
mkdir /root/logs /root/scripts /root/compose
touch /root/compose/docker-compose.yml /root/scripts/update.sh
chmod u+x /root/scripts/update.sh
echo 'services:
  db:
    image: postgres
    volumes:
      - pg-data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
  web:
    image: my-image
    ports:
      - "8000:8000"
    environment:
      - POSTGRES_NAME=postgres
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - DEBUG=1
      - PROCESS_TYPE=server
    entrypoint: ./docker-entrypoint.sh
    depends_on:
      - db
volumes:
    pg-data:' >> /root/compose/docker-compose.yml

echo '#!/bin/bash
dir="/root/compose"
echo "Update image darcigats/api"
docker pull darcigats/api
echo "Update service"
cd $dir && /usr/local/bin/docker compose down && /usr/local/bin/docker compose up -d --remove-orphans
docker image prune -a -f' >> /root/scripts/update.sh