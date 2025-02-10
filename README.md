# Secure Home in the Digital World

## Introduction

In the modern digital age, online privacy and security are more critical than ever. Cyber threats, data breaches, and intrusive advertisements are daily challenges for individuals and businesses alike. This project aims to provide a secure home network infrastructure using various tools such as Pi-hole, DNS filtering, proxy servers, and network monitoring to enhance security and privacy in the digital world.

## Project Overview

This project is designed to build a secure, private, and flexible home network environment with the following key components:

1. **Pi-hole**: A network-wide ad blocker that prevents intrusive ads and trackers from loading on any device in the network.
2. **Private DNS**: A secure DNS solution to avoid using third-party DNS providers, ensuring better privacy and security.
3. **Proxy Server**: A proxy server for monitoring and filtering outbound traffic, ensuring that potentially harmful websites are blocked.
4. **Network Monitoring**: Tools for monitoring the network and detecting potential intrusions or malicious activities.

## Hardware Requirements

This project is designed to run on the following hardware:

- **Dell OptiPlex** (16GB RAM, 500GB NVMe, Intel Core i5-7500T processor) 
  - Provides flexibility, performance, and sustainability for long-term use.
- **Alternative**: Raspberry Pi (if looking for lower power consumption).

## Software Requirements

- **Operating System**: Debian (minimal installation without GUI for security reasons).
- **Pi-hole**: For network-wide ad-blocking.
- **Proxy**: For content filtering and monitoring.
- **Network Monitoring**: Using tools like Suricata or Snort for real-time traffic analysis.
- **Proxmox**: Virtualization platform to isolate different services.
- **Ansible**: For automating the deployment and configuration of the services.

## Components

### 1. Pi-hole Setup

Pi-hole blocks unwanted ads and trackers at the DNS level, providing a cleaner and safer browsing experience.

### 2. Private DNS Setup

Configuring a private DNS server ensures that your network requests are routed securely and privately, without relying on third-party DNS providers.

### 3. Proxy Setup

A proxy server helps manage internet access for devices, ensuring that potentially harmful content is blocked, and monitoring internet traffic to prevent data breaches.

### 4. Network Monitoring

Tools like Suricata or Snort are used for real-time traffic analysis to detect malicious activities, including attempts to access harmful websites or DDoS attacks.

## Setup Guide

### Prerequisites

1. A **Debian** machine (minimal install).
2. Basic knowledge of using **SSH**, **Ansible**, and basic **Linux commands**.
3. Installed **Proxmox** (for virtualization) and **Ansible** (for automation).
