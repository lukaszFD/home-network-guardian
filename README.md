# Repository Structure: Home Network Guardian

This repository contains all configuration files, scripts, and templates required for the automated deployment of the **Home Network Guardian** stack on a Raspberry Pi (or compatible host) using Docker Compose and Ansible. The structure is organized for clarity, automation, and secure management of secrets.

---

## Directories

### ansible/
This directory holds all Ansible playbooks, configuration files, and variable definitions for automated deployment and configuration management.

* **Playbooks (e.g., `deploy-virustotal.yml`, `deploy-network.yml`, `deploy-portainer.yml`)**: Define the sequence of tasks for setting up services, copying configurations, and initializing databases.
* **`group_vars/`**: Contains environment-specific variables (e.g., `dev_vm.yml`, `home_guardian_servers.yml`).
* **`hosts.ini`**: The Ansible inventory file defining the target hosts (e.g., `home_guardian_servers`).
* **`ansible_commands.txt`**: A helper file listing useful Ansible commands.
* **`DOCUMENTATION.md`**: File with supplementary Ansible documentation.

### config/
This directory holds all persistent and service-specific configuration files, scripts, and database schema definitions. These files are typically mounted as Docker volumes to maintain state and custom settings.

#### config/disk/
Scripts and configuration for host-level disk monitoring.
* **`cron.txt`**: Configuration file for scheduling monitoring scripts.
* **`monitor_disk_usage.sh`**: Shell script for host disk usage monitoring.

#### config/filebeat/
Filebeat configuration for log collection.
* **`filebeat.yml`**: Main Filebeat configuration file for collecting host and container logs and forwarding them to a central logging system (Graylog/Elasticsearch).

#### config/grafana/
Grafana provisioning and dashboards.
* **`Raspberry_dashbord.json`**: Monitoring dashboard definitions for Grafana.

#### config/mysql/
Comprehensive database schemas and maintenance scripts for storing threat intelligence, DNS query logs, and scan results.
* **`deployment_script.sql`**: The primary SQL script for creating the database, users, tables, indexes, views, and procedures. It uses Jinja2 templates (e.g., `{{ mysql_password }}`) for password substitution by Ansible.
* **`CREATE_DATABASE.sql`**: Initial script for database creation.
* **`deploy_db.sh`**: Shell script for initial database setup and deployment.
* **`MySql.sql`**: Another SQL file with database definitions.
* **`url_skans.ods`**: Data or notes file related to URL scans.
* **`TABLE/`**: Directory for definitions of core data tables.
* **`INDEXES/`**: Directory for SQL files optimizing query performance on logs.
* **`PROCEDURES/`**: Directory for Stored procedures for database maintenance (e.g., `clean_old_data.sql`).
* **`VIEWS/`**: Directory for SQL views for aggregated and summarized reporting (e.g., `v_malicious_url_scans.sql`).

#### config/passive-dns/
Configuration for the passive DNS listener component.
* **`01-passive.conf`**: Configuration file for the passive DNS service.
* **`Dockerfile.pdns`**: Dockerfile for this component.

#### config/pihole/
Persistent and custom configuration for the Pi-hole DNS server.
* **`adlists.list`**: The list of domains to be blocked (adlists).
* **`setupVars.conf`**: Primary configuration settings for Pi-hole.

#### config/prometheus/
* **`prometheus.yml`**: Configuration for the Prometheus monitoring stack, including scrape configurations.

#### config/samba/
* **`smb.conf`**: Samba (SMB) service configuration for network shares.

#### config/squid/
Main Squid proxy configuration.
* **`squid.conf`**: The main Squid proxy configuration file.
* **`blocklists/`**: Sub-directory containing blocklists (e.g., `stevenblack-domains.txt`).

#### config/squid-tabl/
Auxiliary files for web filtering.
* **`squid.conf`**: Auxiliary ACL tables or additional access rule files for granular web filtering.

#### config/suricata/
Suricata IDS Core Configuration and rules.
* **`suricata.yaml`**: The main Suricata configuration file.
* **`classification.config`**: Classification configuration file.
* **`reference.config`**: Reference configuration file.
* **`threshold.config`**: Alert threshold configuration file.
* **`update.yaml`**: Update configuration file.
* **`rules/`**: Directory for network intrusion detection rules, including custom rules (`custom.rules`) and threat intelligence rules (`virustotal-ioc.rules`).

#### config/unbound/
* **`unbound.conf`**: Primary Unbound DNS resolver configuration.

#### config/unbound-firefox/
* **`unbound.conf`**: Dedicated Unbound DNS resolver configuration for the isolated Firefox container.

#### config/virust_total/
Python code and Dockerfiles for the VirusTotal integration component.
* **`dns_log_processor.py`**: Python code for processing DNS logs.
* **`dns_scanner.py`**: Python code for DNS scanning logic.
* **`virus_total.py`**: Primary Python code for VirusTotal integration.
* **`Dockerfile.dns`**: Dockerfile for the DNS log processing service.
* **`Dockerfile.scanner`**: Dockerfile for the DNS scanner service.
* **`Dockerfile.virustotal`**: Dockerfile for the VirusTotal integration service.

### docker/
This directory contains the various Docker Compose files (`*.yml`) used to deploy service stacks (SIEM, Monitoring, DNS) and helper containers.
* **`docker-compose-virus_total.yml`**: Defines the VirusTotal, DNS scanner, and `mysqldb` services.
* **`docker-compose-network.yml`**: Compose file for network services.
* **`docker-compose-portainer.yml`**: Compose file for the Portainer management tool.
* **`firefox.yml`**: Compose file for the isolated Firefox container.
* **`network-local.yml`**: Local network configuration settings.
* **`pi_alert.yml`**: Compose file for the Pi-Alert service.
* **`samba.yml`**: Compose file for the Samba service.
* **`server-monitoring.yml`**: Compose file for server monitoring stack.
* **`siem.yml`**: Compose file for the SIEM stack.
* **`suricata.yml`**: Compose file for the Suricata service.
* **`sudo_docker_compose.sh`**: Helper script for running Docker Compose with elevated privileges.

---

## Files

* **`.env`**: Environment variable definitions for secrets, passwords, network ranges, and other settings consumed by Docker Compose and services. This file is managed and copied to the target server by Ansible, and its contents are used for database initialization. (Recommended for use with **Ansible Vault/HashiCorp Vault** for security).
* **`.gitignore`**: Standard file to exclude sensitive information, temporary files, and build artifacts from version control.
* **`create_configs.sh`**: Shell script to automate the creation of initial configuration files and directories. (Recommendation: Migrate functions to Ansible tasks).
* **`README-INSTALL.md`**: The installation guide for the entire stack.
* **`docker-compose.yml`**: The main Docker Compose configuration file, defining all containers, volumes, networks, and links between services.

---

Would you like me to elaborate on how the VirusTotal integration component (`config/virust_total/`) is used for **Cyber Threat Intelligence** and **Indicators of Compromise (IoC)** in the context of your project?