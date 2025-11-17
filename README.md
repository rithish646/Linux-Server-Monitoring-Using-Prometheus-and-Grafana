# Linux-Server-Monitoring-Using-Prometheus-and-Grafana

This repository contains all the required systemd service files and scripts used to monitor a Linux server with Prometheus, Grafana, and Node Exporter, along with a custom updates exporter that reports the number of pending system updates.

This setup is compatible with any Debian/Ubuntu Linux server and integrates with Prometheus running on Windows, Linux, or Docker.

Files in This Repository

The following files are included (all stored in the main branch):

| File Name                 | Purpose                                              |
| ------------------------- | ---------------------------------------------------- |
| node_exporter.service     | Systemd service to run Prometheus Node Exporter      |
| updates_check.sh          | Script that checks number of pending package updates |
| updates_check.service     | Systemd service that executes updates_check.sh       |
| updates_check.timer       | Timer that schedules update checks every 30 minutes  |


These four files together enable:

Node Exporter running as a systemd service
Automatic update count generation
Integration with Prometheus via textfile collector
Grafana dashboard visualization

1. node_exporter.service

This service launches Node Exporter under systemd and enables the textfile collector, allowing custom metrics to be read by Prometheus.

Installation:

sudo mv node_exporter.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter


Node Exporter metrics will be available on:

http://<SERVER_IP>:9100/metrics

2. updates_check.sh

This script:

Runs apt-get update

Counts how many packages are upgradable

Writes metric to:

/var/lib/node_exporter/textfile_collector/updates.prom


Prometheus will read this via Node Exporter automatically.

Installation:

sudo mv updates_check.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/updates_check.sh


Test manually:

sudo /usr/local/bin/updates_check.sh
cat /var/lib/node_exporter/textfile_collector/updates.prom


Expected:

updates_available_total X

3. updates_check.service

A systemd oneshot service that runs the update script.

Installation:

sudo mv updates_check.service /etc/systemd/system/


Run manually:

sudo systemctl start updates_check.service


4. updates_check.timer

A systemd timer that triggers the updates service:

2 minutes after boot

Every 30 minutes

Uses persistent scheduling

Installation:

sudo mv updates_check.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now updates_check.timer


Check timer status:

systemctl status updates_check.timer

erification Steps
Check generated metric file
cat /var/lib/node_exporter/textfile_collector/updates.prom

Check if Node Exporter can read it
curl -s http://localhost:9100/metrics | grep updates_available_total

Confirm no scrape errors
curl -s http://localhost:9100/metrics | grep node_textfile_scrape_error


Should show:

node_textfile_scrape_error 0

Prometheus Integration

Add this to your prometheus.yml:

- job_name: "node_exporter"
  static_configs:
    - targets: ["<SERVER_IP>:9100"]


Prometheus will now scrape both native metrics and your custom:

updates_available_total

Grafana Dashboard Integration

To display the update count:

Query:
updates_available_total

Recommended visualization:

Stat

Gauge

Thresholds:
Value	Color
0	Green
10-20	Yellow
>20	Red

Summary

This repository provides:

Systemd service for Node Exporter
Automated update-checking script
Periodic scheduling using systemd timer
Prometheus-compatible metrics
Grafana-ready visualizations
Works on any Linux server or VM

This setup forms a complete monitoring pipeline for both system performance and update status, suitable for DevOps, SRE, or observability projects.
