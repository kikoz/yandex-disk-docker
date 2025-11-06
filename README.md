# Docker Image with Yandex Disk CLI Client

This project provides a lightweight Docker container image for running the **Yandex Disk CLI client** inside a minimal **Debian Slim** base image (~100 MB). It's ideal for headless setups or NAS systems (e.g., running on Open Media Vault) where you want to sync Yandex Disk files without installing the full desktop client.

---

## 📦 Project Structure

| File | Description |
|------|-------------|
| **Dockerfile** | Defines the container image based on Debian Bookworm Slim and installs the latest version of the Yandex Disk CLI client from the official Yandex repository. |
| **docker-compose.yml** | Simplifies container deployment by defining configuration and data volumes, environment variables, and runtime parameters. |
| **entrypoint.sh** | Entrypoint script that handles authentication token detection, configuration, and starts the Yandex Disk service daemon. |
| **Open Media Vault/yandex-disk-status.sh** | Helper script to check the current synchronization status, disk usage, and last sync time from the running container. |
| **Open Media Vault/yandex-disk-logs-check.sh** | Optional monitoring script for Open Media Vault to check sync activity and alert if synchronization has stopped. |

---

## 🚀 Features

- **Lightweight**: Small image footprint (~100 MB based on Debian Bookworm Slim)
- **Official Client**: Runs the official Yandex Disk command-line client from the official Yandex repository
- **Configurable**: Environment variables for data path, token location, exclude directories, and custom options
- **Persistent Storage**: Separate volumes for configuration and synced data
- **Headless Operation**: Designed for servers, NAS, and always-on setups without GUI
- **NAS Integration**: Supplies required environment variables for running under Open Media Vault or similar systems
- **Automatic Waiting**: Waits for authentication token if not present at startup

---

## 🧰 Usage

### Build the Image

You can build the image locally using either command:

```bash
# Simple build with custom tag
docker build -t yandex-disk .

# Build with detailed progress output
docker build --progress plain --tag yandex-disk .
```

### Run Using Docker Compose

The included `docker-compose.yml` file provides a complete configuration for running the Yandex Disk container.

#### 1. Configure Environment Variables

Create a `.env` file in the same directory as your `docker-compose.yml` (or set these in your system):

```bash
# User/Group IDs (important for file permissions)
APPUSER_PUID=1000
APPUSER_PGID=1000

# Timezone
TIME_ZONE_VALUE=Europe/Moscow

# Path to store Yandex Disk configuration
PATH_TO_APPDATA=/path/to/your/appdata

# Path where Yandex Disk files will be synced
PATH_TO_YANDEX_DISK=/path/to/your/yandex/disk
```

#### 2. Start the Container

```bash
docker-compose up -d
```

This command will:
- Build the image (if not already built)
- Create and start the container in detached mode
- Set up the necessary configuration and data volumes
- Wait for authentication token if not present

#### 3. Check Container Status

```bash
# View logs
docker-compose logs -f

# Check running containers
docker-compose ps
```

---

## ⚙️ Configuration

### Environment Variables

The container supports the following environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `DATA` | `/yandex` | Directory inside the container where Yandex Disk files are synced |
| `TOKEN_FILE` | `$HOME/.config/yandex-disk/passwd` | Path to the authentication token file |
| `EXCLUDE` | _(empty)_ | Comma-separated list of directories to exclude from sync |
| `OPTIONS` | _(empty)_ | Additional options to pass to the `yandex-disk` command |
| `PUID` | _(none)_ | User ID for file permissions (useful for NAS systems) |
| `PGID` | _(none)_ | Group ID for file permissions (useful for NAS systems) |
| `TZ` | _(none)_ | Timezone setting (e.g., `Europe/Moscow`, `America/New_York`) |

### Volumes

The container requires two volumes to be mounted:

#### 1. Configuration Volume
```yaml
- ${PATH_TO_APPDATA}/yandex_disk/config:/root/.config/yandex-disk
```
- Stores the authentication token (`passwd` file) and Yandex Disk configuration
- **Must persist** between container restarts to avoid re-authentication

#### 2. Data Volume
```yaml
- ${PATH_TO_YANDEX_DISK}:/yandex
```
- Directory where Yandex Disk files are synchronized
- This is your actual cloud storage folder on the host system

### Authentication

The Yandex Disk client requires an OAuth token for authentication. You have two options:

#### Option 1: Generate Token Inside Container (Recommended)

1. Start the container (it will wait for the token):
```bash
docker-compose up -d
```

2. Access the container shell:
```bash
docker exec -it yandex_disk bash
```

3. Generate the token:
```bash
yandex-disk token /root/.config/yandex-disk/passwd
```

4. Follow the on-screen instructions:
   - Open the provided URL in your browser
   - Grant access to your Yandex Disk
   - Copy the verification code
   - Paste the code into the terminal

5. Exit the container and restart (optional):
```bash
exit
docker-compose restart
```

#### Option 2: Mount Pre-existing Token

If you already have a token file from another installation:

1. Place your existing `passwd` file in: `${PATH_TO_APPDATA}/yandex_disk/config/passwd`
2. Start the container normally

**Note**: The container will automatically detect the token and start syncing.

---

## 📝 Additional Notes

### Exclude Directories

To exclude certain directories from synchronization, set the `EXCLUDE` environment variable:

```yaml
environment:
  - EXCLUDE=temp,cache,.git
```

### Running One-Time Sync

Instead of running the daemon continuously, you can perform a one-time sync:

```bash
docker run --rm \
  -v ${PATH_TO_APPDATA}/yandex_disk/config:/root/.config/yandex-disk \
  -v ${PATH_TO_YANDEX_DISK}:/yandex \
  yandex-disk sync
```

### Checking Yandex Disk Status

The `yandex-disk-status.sh` script provides a convenient way to check the current status of your Yandex Disk synchronization:

```bash
# Run the status script
. yandex-disk-status.sh
```

The script will:
- Automatically find the running Yandex Disk container
- Execute the `yandex-disk status` command inside the container
- Display synchronization status, used/available space, and last sync time
- Show error messages if the container is not running or not found

This is useful for:
- Verifying that synchronization is working correctly
- Checking available disk space on your Yandex Disk
- Troubleshooting sync issues
- Integration into monitoring dashboards or scheduled health checks

### Open Media Vault Integration

The included monitoring script (`Open Media Vault/yandex-disk-logs-check.sh`) can be used with Open Media Vault to:
- Monitor sync activity by checking log files
- Send alerts if no new files have been downloaded within a threshold period
- Integrate with OMV's notification system

Configure the script path and run it as a scheduled task in OMV.

---

## 🔗 Links

- [Yandex Disk CLI Documentation](https://yandex.ru/support/yandex-360/customers/disk/desktop/linux/ru/installation)
- [Official Yandex Disk Repository](http://repo.yandex.ru/yandex-disk/)
- [Debian Bookworm Slim Base Image](https://hub.docker.com/_/debian)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [OMV Documentation](https://docs.openmediavault.org/en/stable/index.html)
- [OMV Extras Documentation](https://wiki.omv-extras.org/)
- [OMV List of RPCs](https://github.com/openmediavault/openmediavault/blob/master/deb/openmediavault/usr/share/openmediavault/engined/rpc/exec.inc)
- Based on projects from [ruslanys](https://github.com/ruslanys/docker-yandex.disk?tab=readme-ov-file), [WorldException](https://github.com/WorldException/docker-yandex-disk/) and [ipglotov](https://github.com/ipglotov/yandex-disk)

---

## 📄 License

This project is provided as-is for personal and commercial use.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page or submit a pull request.