#!/bin/bash
dir="/root/compose"
echo "Update imagedarcigats/api"
docker pull darcigats/api
echo "Update mmcb-main worker"
cd $dir && /usr/local/bin/docker compose down && /usr/local/bin/docker compose up -d --remove-orphans
docker image prune -a -f