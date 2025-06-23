# Repository Structure

This repository contains all configuration files, scripts, and templates required for the deployment of the **Home Network Guardian** stack on a Raspberry Pi (or compatible host) using Docker Compose. Each directory holds service-specific configuration, while root-level scripts and files manage orchestration and environment variables.

---

## Directories

- **etc-filebeat/**
  - Filebeat configuration directory. Contains `filebeat.yml`, module definitions, and other config files needed for collecting host and container logs and forwarding them to Graylog/Elasticsearch.

- **etc-grafana/**
  - Grafana provisioning and config files. Includes dashboard JSONs, data source definitions, and user settings for monitoring dashboards.

- **etc-pihole/**
  - All persistent and custom configuration for the Pi-hole DNS server: adlists, whitelist, blacklist, and additional Pi-hole settings.

- **etc-prometheus/**
  - Configuration for the Prometheus monitoring stack. Contains `prometheus.yml` scrape configs, alerting rules, and custom exporter targets.

- **etc-samba/**
  - Samba (SMB) service configuration. Used if you expose any network shares for backup or file exchange between host and containers.

- **etc-squid-tabl/**
  - Auxiliary ACL tables, blacklists, or additional Squid access rule files, used for granular web filtering.

- **etc-squid/**
  - Main Squid proxy configuration, including `squid.conf` and any SSL/interception or access rules.

- **etc-suricata/**
  - Suricata IDS rules, configuration files (`suricata.yaml`), and custom detection rules for network intrusion detection and alerting.

- **etc-unbound-firefox/**
  - Unbound DNS resolver configuration dedicated to the isolated Firefox container (separated from the main Unbound used by Pi-hole).

- **etc-unbound/**
  - Primary Unbound DNS resolver configuration files, used as the upstream resolver for Pi-hole and other services.

---

## Files

- **.env**
  - Environment variable definitions for secrets, passwords, network ranges, and other settings consumed by Docker Compose and services.

- **.gitignore**
  - Standard file to exclude sensitive information, temporary files, and build artifacts from version control.

- **create_configs.sh**
  - Shell script to automate creation of initial configuration files and directories (runs on first setup or when resetting configs).

- **docker-compose.yml**
  - Main Docker Compose configuration file. Defines all containers, volumes, networks, and links between services.
    - Specifies isolated networks for DNS, Proxy, Monitoring, etc.
    - Binds persistent configs from the above directories into containers.
    - Controls restart policies and resource allocation.

---

All configuration (except Filebeat, which runs directly on the host) is managed via Docker Compose, ensuring modularity, reproducibility, and secure isolation of services.
