# Additional Tools and Project Structure

This document provides instructions on how to visualize the project's directory structure and outlines the necessary tools required for initial project analysis before automation.

## I. Visualizing the Configuration Structure

Before deployment with Ansible, it is highly recommended to inspect and understand the structure of the configuration files located within the **`home-network-guardian/`** directory.

### 1. Installing the `tree` Utility

The `tree` utility is useful for graphically displaying the directory hierarchy in the terminal.

To install `tree` on a Debian-based system (e.g., Raspberry Pi OS):

```bash
sudo apt update
sudo apt install tree

hunter@hunter:~/IdeaProjects$ tree -L 3 home-network-guardian -I '.git|venv|__pycache__'
home-network-guardian
├── ansible
│   ├── ansible_commands.txt
│   ├── deploy-network.yml
│   ├── deploy-portainer.yml
│   ├── deploy-virustotal.yml
│   ├── DOCUMENTATION.md
│   ├── group_vars
│   │   ├── dev_vm.yml
│   │   └── home_guardian_servers.yml
│   └── hosts.ini
├── config
│   ├── disk
│   │   ├── cron.txt
│   │   └── monitor_disk_usage.sh
│   ├── filebeat
│   │   └── filebeat.yml
│   ├── grafana
│   │   └── Raspberry_dashbord.json
│   ├── mysql
│   │   ├── CREATE_DATABASE.sql
│   │   ├── deploy_db.sh
│   │   ├── deployment_script.sql
│   │   ├── INDEXES
│   │   ├── MySql.sql
│   │   ├── PROCEDURES
│   │   ├── TABLE
│   │   ├── url_skans.ods
│   │   └── VIEWS
│   ├── node.lock
│   ├── passive-dns
│   │   ├── 01-passive.conf 
│   │   └── Dockerfile.pdns
│   ├── pihole
│   │   ├── adlists.list
│   │   └── setupVars.conf
│   ├── prometheus
│   │   └── prometheus.yml
│   ├── samba
│   │   └── smb.conf
│   ├── squid
│   │   ├── blocklists
│   │   └── squid.conf
│   ├── squid-tabl
│   │   └── squid.conf
│   ├── suricata
│   │   ├── classification.config
│   │   ├── reference.config
│   │   ├── rules
│   │   ├── suricata.yaml
│   │   ├── threshold.config
│   │   └── update.yaml
│   ├── unbound
│   │   └── unbound.conf
│   ├── unbound-firefox
│   │   └── unbound.conf
│   └── virust_total
│       ├── dns_log_processor.py
│       ├── dns_scanner.py
│       ├── Dockerfile.dns
│       ├── Dockerfile.scanner
│       ├── Dockerfile.virustotal
│       └── virus_total.py
├── create_configs.sh
├── docker
│   ├── docker-compose-network.yml
│   ├── docker-compose-portainer.yml
│   ├── docker-compose-virus_total.yml
│   ├── firefox.yml
│   ├── network-local.yml
│   ├── pi_alert.yml
│   ├── samba.yml
│   ├── server-monitoring.yml
│   ├── siem.yml
│   ├── sudo_docker_compose.sh
│   └── suricata.yml
├── README-INSTALL.md
├── README.md
└── tmp
