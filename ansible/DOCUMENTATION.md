# Home Network Guardian - Ansible Deployment Documentation

## 1. Project Directory Structure and Configuration

This section describes the repository structure, which is organized for clear separation between configuration files and deployment orchestration files.

### 1.1 Configuration Directory: `config/` (Source: Local Repository)

This directory holds all persistent and service-specific configuration files, scripts, and database schema definitions. These files are designed to be mounted as Docker volumes inside the respective containers.

| Directory | Content / Key Files | Role |
| :--- | :--- | :--- |
| **etc-filebeat/** | `filebeat.yml` | Filebeat config for collecting logs and forwarding them to a central SIEM/logging system. |
| **etc-grafana/** | Dashboard JSONs | Grafana provisioning files and monitoring dashboards. |
| **etc-pihole/** | `adlists`, `setupVars.conf` | Persistent and custom configuration for the Pi-hole DNS server. |
| **etc-suricata/** | `suricata.yaml`, `rules/` | Suricata IDS rules and configuration for network intrusion detection and alerting. |
| **etc-prometheus/** | `prometheus.yml` | Configuration for the Prometheus monitoring stack. |
| **etc-squid/** | `squid.conf` | Main Squid proxy configuration and access rules. |
| **etc-unbound/** | `unbound.conf` | Primary Unbound DNS resolver configuration. |
| **etc-unbound-firefox/** | `unbound.conf` | Dedicated Unbound configuration for the isolated Firefox container. |
| **etc-samba/** | `smb.conf` | Samba (SMB) service configuration for network shares. |
| **etc-squid-tabl/** | Auxiliary ACL tables | Additional Squid access rule files for granular web filtering. |

### 1.2 Deployment and Utility Files (Source: Local Repository)

| File / Directory | Role |
| :--- | :--- |
| **docker-compose.yml** | Main configuration file defining all containers, networks, and links between services. |
| **.env** | Environment variables for secrets, passwords, and network ranges (recommended to move secrets to **Vault**). |
| **create_configs.sh** | Shell script to automate the initial creation of configuration files and directories. |

---

## 2. Ansible Controller Setup and Working Environment

This section documents the initial steps executed on the Ansible Controller (`ansible@ansible:~`) to prepare the deployment environment.

### 2.1 Environment Setup

| Action | Command | Purpose |
| :--- | :--- | :--- |
| **Create venv** | `python3 -m venv ~/ansible_venv` | Isolates Python dependencies for Ansible. |
| **Activate venv** | `source ~/ansible_venv/bin/activate` | Activates the isolated environment. |

### 2.2 Project Directory Structure

| Directory | Command | Role in Deployment |
| :--- | :--- | :--- |
| **Project Root** | `mkdir -p ~/ansible_home_guardian` | Directory for Ansible playbooks and roles. |
| **Source Files** | `mkdir -p ~/home-network-guardian-files` | Local source directory for Docker Compose files (e.g., `docker-compose-portainer.yml`) and configurations. |
| **Inventory File** | `nano hosts.ini` | Creation/editing of the Inventory file to define target nodes (e.g., `pi5`). |

---

## 3. Test Deployment: Portainer Service

The following steps document the execution of the first test playbook (`deploy-portainer.yml`), demonstrating the orchestration of Docker Compose on a remote node.

### 3.1 Playbook Execution

| Action | Command | Outcome / Context |
| :--- | :--- | :--- |
| **Change Directory** | `cd ansible_home_guardian` | Sets the correct working directory for the playbook. |
| **Execute Playbook** | `ansible-playbook -i ../hosts.ini deploy-portainer.yml` | Executes the playbook logic: copies the Docker Compose file to the remote node, changes the working directory, and runs the `docker compose` command. |

### 3.2 `deploy-portainer.yml` Logic Summary (English)

The playbook ensures the deployment is idempotent and uses the required `sudo docker compose` command:

```yaml
# Simplified logic from deploy-portainer.yml
- name: 01 - Deploy Portainer Service with custom command
  hosts: home_guardian_servers
  become: yes 
  vars:
    source_docker_file: "docker-compose-portainer.yml"
    remote_deploy_base: "/opt/guardian_deployment"
    project_name: "portainer-service"

  tasks:
    # 1. Copy the docker-compose file to the remote node (when inventory_hostname != 'pi4b')
    - name: Task 1.1 - Copy the Docker Compose file to the remote node (RPi 5)
      # ... copy task ...
      
    # 2. Define the correct path (local or remote) for 'chdir'
    - name: Task 2.0 - Define working directory based on host
      # ... set_fact: workdir_path ...
      
    # 3. Execute deployment with project name and daemon mode
    - name: Task 3.0 - Deploy service using 'sudo docker compose -p' command
      ansible.builtin.shell:
        cmd: "docker compose -f {{ source_docker_file }} -p {{ project_name }} up -d"
        chdir: "{{ workdir_path }}"