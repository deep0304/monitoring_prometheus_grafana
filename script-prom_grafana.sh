#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

apt update -y
apt install -y prometheus

systemctl enable prometheus
systemctl start prometheus

apt install -y apt-transport-https software-properties-common wget gnupg

mkdir -p /etc/apt/keyrings

wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg

echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" \
  > /etc/apt/sources.list.d/grafana.list

apt update -y
apt install -y grafana

systemctl enable grafana-server
systemctl start grafana-server