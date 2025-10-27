# Repository Structure

This repository contains all configuration files, scripts, and templates required for the deployment of the **Home Network Guardian** stack on a Raspberry Pi (or compatible host) using Docker Compose. The structure has been organized for better clarity and automation readiness, particularly for use with Ansible.
---

## Directories

### config/
This directory holds all persistent and service-specific configuration files, scripts, and database schema definitions. These files are typically mounted as Docker volumes inside the respective containers to maintain state and custom settings.

- **config/disk/**
    - Scripts and configuration (`cron.txt`, `monitor_disk_usage.sh`) for host-level disk monitoring, often used by Prometheus/Grafana or Graylog.

- **config/filebeat/**
    - Filebeat configuration (`filebeat.yml`) for collecting host and container logs and forwarding them to a central logging system (Graylog/Elasticsearch).

- **config/grafana/**
    - Grafana provisioning and config files, including monitoring dashboards (`Raspberry_dashbord.json`) and data source definitions.

- **config/mysql/**
    - **Comprehensive database schemas** and maintenance scripts for storing threat intelligence, DNS query logs, and scan results.
        - **TABLE/**: Definitions for core data tables (`dns_queries.sql`, `yara_detections.sql`).
        - **INDEXES/**: SQL files for optimizing query performance on logs (`dns_queries_idx.sql`).
        - **PROCEDURES/**: Stored procedures for database maintenance (`clean_old_data.sql`).
        - **VIEWS/**: SQL views for aggregated and summarized reporting (`v_malicious_url_scans.sql`).
        - **Scripts**: Contains initial setup and deployment scripts (`deploy_db.sh`).

- **config/passive-dns/**
    - Configuration files, including `Dockerfile.pdns`, for the passive DNS listener component.

- **config/pihole/**
    - Persistent and custom configuration for the Pi-hole DNS server: adlists (`adlists.list`) and primary settings (`setupVars.conf`).

- **config/prometheus/**
    - Configuration for the Prometheus monitoring stack, including scrape configs (`prometheus.yml`).

- **config/samba/**
    - Samba (SMB) service configuration (`smb.conf`) for network shares.

- **config/squid/**
    - Main Squid proxy configuration (`squid.conf`), including sub-directories for blocklists (`stevenblack-domains.txt`).

- **config/squid-tabl/**
    - Auxiliary ACL tables or additional access rule files for granular web filtering (e.g., specific blocklists).

- **config/suricata/**
    - **Suricata IDS Core Configuration:** Contains `suricata.yaml`, classification files, and threshold settings.
    - **rules/**: Dedicated directory for network intrusion detection rules, including custom rules (`custom.rules`) and threat intelligence rules (`virustotal-ioc.rules`).

- **config/unbound/**
    - Primary Unbound DNS resolver configuration (`unbound.conf`).

- **config/unbound-firefox/**
    - Dedicated Unbound DNS resolver configuration for the isolated Firefox container.

- **config/virust_total/**
    - **Python code and Dockerfiles** for the VirusTotal integration component, responsible for processing logs and scanning suspicious URLs/files (`dns_scanner.py`, `virus_total.py`).

### docker/
This directory contains the various Docker Compose files (`*.yml`) used to deploy service stacks (SIEM, Monitoring, DNS) and helper containers.

---

## Files

- **.env**
    - Environment variable definitions for secrets, passwords, network ranges, and other settings consumed by Docker Compose and services. (Recommended for use with **Ansible Vault/HashiCorp Vault**).

- **.gitignore**
    - Standard file to exclude sensitive information, temporary files, and build artifacts from version control.

- **create_configs.sh**
    - Shell script to automate creation of initial configuration files and directories. (Recommended to migrate functions to Ansible tasks).

- **docker-compose.yml**
    - Main Docker Compose configuration file. Defines all containers, volumes, networks, and links between services.