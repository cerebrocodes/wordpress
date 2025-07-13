# Dockerized WordPress

![WordPress and MariaDB Logo](https://i.imgur.com/J5q7X0j.png)

A simple solution to deploy WordPress with MariaDB using Docker. Automatically generates secure credentials and configures the environment.

## Features

- 🐳 **Docker Containers**: WordPress + MariaDB in isolated containers
- 🔐 **Auto-generated Secrets**: Secure passwords and credentials
- 📁 **Persistent Storage**: Data survives container restarts
- 🔧 **Easy Configuration**: Interactive setup script
- 🌐 **Network Isolation**: Dedicated Docker network

## Prerequisites

- Docker Engine (v20.10+)
- Docker Compose (v2.0+)
- Git (optional)

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/wordpress-docker.git
cd wordpress

# 2. Make the setup script executable
chmod +x deploy.sh

# 3. Run the configuration wizard
./deploy.sh

# 4. Launch the containers
docker-compose up -d
