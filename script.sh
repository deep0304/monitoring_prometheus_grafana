#!/bin/bash set -e
sudo apt update
sudo apt install prometheus-node-exporter   
sudo systemctl start prometheus-node-exporter
sudo systemctl enable prometheus-node-exporter
