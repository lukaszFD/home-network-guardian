# Additional Tools and Project Structure (README - INSTALLATION)

This document provides instructions on how to visualize the project's directory structure and outlines the necessary tools required for initial project analysis before automation.

## I. Visualizing the Configuration Structure

Before deployment with Ansible, it is highly recommended to inspect and understand the structure of the configuration files located within the **`config/`** directory.

### 1. Installing the `tree` Utility

The `tree` utility is useful for graphically displaying the directory hierarchy in the terminal.

To install `tree` on a Debian-based system (e.g., Raspberry Pi OS):

```bash
sudo apt update
sudo apt install tree

hunter@hunter:~/IdeaProjects/home-network-guardian$ tree -L 3 config -I '.git|venv|__pycache__'
config
├── disk
│   ├── cron.txt
│   └── monitor_disk_usage.sh
├── filebeat
│   └── filebeat.yml
├── grafana
│   └── Raspberry_dashbord.json
├── mysql
│   ├── CREATE_DATABASE.sql
│   ├── deploy_db.sh
│   ├── deployment_script_2025_09_14.sql
│   ├── INDEXES
│   │   ├── dns_queries_idx.sql
│   │   ├── url_scans_idx.sql
│   │   └── yara_detections_idx.sql
