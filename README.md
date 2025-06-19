# Home Network Guardian — Secure Home in the Digital World

## Introduction

In the modern digital age, online privacy and security are more critical than ever. Cyber threats, data breaches, and intrusive advertisements are daily challenges for individuals and families alike. This project provides a secure home network infrastructure using Raspberry Pi 5 with Docker, combining DNS filtering, proxy servers, IDS/IPS, log analysis, and monitoring tools to enhance security and privacy.

Full project documentation is also available here: [https://lukaszfd.github.io/ICYB_PW/](https://lukaszfd.github.io/ICYB_PW/)

## Project Overview

The goal is to build a secure, flexible home network based on:

1. **Pi-hole + Unbound**: Private DNS with ad blocking and secure DNS resolution.
2. **Squid Proxy**: To control and filter outbound web traffic.
3. **Suricata IDS/IPS**: Intrusion detection and prevention.
4. **Graylog + Elasticsearch + MongoDB**: Centralized log collection and analysis.
5. **Filebeat**: Installed directly on the server to collect host system logs.
6. **Prometheus + Grafana**: Monitoring and visualization of system metrics.
7. **Firefox in isolated container**: For secure browsing.
8. **Portainer**: Docker container management.
9. **Custom firewall configuration**: To allow only necessary ports and services.
10. All services (except Filebeat) run in **Docker** containers with dedicated network isolation.

## Hardware Requirements

- **Raspberry Pi 5** — 8 GB RAM, 32/64 GB SD card or NVMe SSD  
  *(Low-power, ARM64-based hardware with excellent performance for home network services)*

## Software Requirements

- **Operating System**: Raspberry Pi OS Lite (64-bit), based on Debian 12 (Bookworm), minimal installation.
- **Docker + Docker Compose**: For service orchestration.
- **Pi-hole & Unbound**: DNS and ad-blocking.
- **Squid Proxy**: Outbound filtering.
- **Suricata IDS**: Traffic analysis and threat detection.
- **Graylog 6.x**, **Elasticsearch 7.17.18**, **MongoDB**: Log analysis stack.
- **Filebeat**: Host log shipping.
- **Prometheus + Grafana**: Monitoring and visualization.
- **Firewall**: Configured to expose only required ports.
- **Portainer**: GUI management of containers.
- **Firefox** in isolated Docker network with private DNS.

## Benefits

- Improved online privacy through DNS filtering and private DNS.
- Control over traffic with proxy filtering.
- Real-time intrusion detection.
- Centralized logging and alerting.
- Network and system monitoring via dashboards.
- Full isolation of services using Docker networks.
- Lightweight and energy-efficient setup.

## Setup Guide

### Prerequisites

1. Raspberry Pi OS Lite installed on Raspberry Pi 5.
2. Installed: Docker, Docker Compose, Filebeat.
3. Basic knowledge of SSH and Linux CLI.
4. Hardware firewall/router configured to allow only necessary ports (as defined in the project).

### Deployment

- Services are orchestrated using `docker-compose.yml`, with separated networks for DNS, Proxy, IDS, Logging and Monitoring.
- Filebeat runs on the host to provide system-level logs.
- Graylog dashboards allow for real-time log visibility.
- Monitoring dashboards created in Grafana.
- Secure browsing with Firefox container using its own DNS (Unbound).

---

This project was developed as part of my post-graduate thesis for Cybersecurity Engineering studies at Warsaw University of Technology.

© 2025 — [Łukasz F. D.](https://github.com/lukaszFD)
