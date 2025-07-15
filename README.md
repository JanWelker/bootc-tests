# Fedora 42 bootc Image Builder

This repository builds an immutable Fedora 42 bootable ISO image using bootc image-builder via GitHub Actions.

## Overview

This project creates a minimal, immutable Fedora 42 bootable ISO that can be used for:

- Physical hardware installation
- Virtual machine installation
- Container-based deployments
- Immutable infrastructure setups

## Features

- **Immutable OS**: Built with bootc for atomic updates and rollbacks
- **Minimal footprint**: Only essential base packages included
- **Automated builds**: GitHub Actions workflow for consistent image creation
- **Container registry**: Built container images are pushed to GitHub Container Registry
- **Artifact storage**: Built ISO images are stored as workflow artifacts

## Usage

### Triggering a Build

The workflow can be triggered in two ways:

1. **Push to main branch**: Automatically builds on code changes
2. **Manual trigger**: Use the "Run workflow" button in GitHub Actions

### Build Process

The workflow performs these steps:

1. Builds a container image from the [`Containerfile`](container/Containerfile)
2. Pushes the container image to GitHub Container Registry (`ghcr.io`)
3. Substitutes GitHub Secrets into the [`config.toml`](config.toml) file
4. Uses `bootc-image-builder` to create a bootable ISO from the container image
5. Uploads the ISO as a workflow artifact

### Downloading Built Images

1. Go to the "Actions" tab in this repository
2. Click on a successful workflow run
3. Download the artifact named `fedora-bootc-42_<run-number>.iso`
4. Extract the `install.iso` file from the downloaded archive

### Using the ISO Image

The built image is in ISO format and can be used for:

```bash
# Boot from ISO in QEMU/KVM
qemu-system-x86_64 -m 2048 -cdrom install.iso

# Write to USB drive for physical installation (replace /dev/sdX with your USB device)
sudo dd if=install.iso of=/dev/sdX bs=4M status=progress sync

# Mount and inspect the ISO contents
sudo mount -o loop install.iso /mnt
ls -la /mnt
sudo umount /mnt
```

### Using the Container Image

The container image is also available from GitHub Container Registry:

```bash
# Pull the latest container image
podman pull ghcr.io/janwelker/bootc-tests/fedora-bootc:latest

# Run the container
podman run -it ghcr.io/janwelker/bootc-tests/fedora-bootc:latest
```

### SSH Access

After booting the image, you can access the system via SSH using the configured admin user:

```bash
# SSH as admin user (with sudo privileges)
ssh <admin-username>@<ip-address>
```

**Important**: The admin username, password, and SSH public key are configured via GitHub Secrets in the workflow. The actual values are substituted during the build process from environment variables.

## Setup

### Required GitHub Secrets

Before building the image, you must configure the following GitHub Secrets in your repository:

1. Go to your repository's Settings → Secrets and variables → Actions
2. Add the following repository secrets:
   - `ADMIN_USERNAME`: The username for the admin user (e.g., `admin`)
   - `ADMIN_PASSWORD`: The password for the admin user
   - `SSH_PUBLIC_KEY`: Your SSH public key for passwordless access

These secrets are automatically substituted into the [`config.toml`](config.toml) file during the build process.

## Customization

### User Configuration

The [`config.toml`](config.toml) file configures users and SSH access for the bootable image using environment variables:

- **Admin user**: Username, password, and SSH key are configured via GitHub Secrets
- **Environment variables**: `BOOTC_ADMIN_USERNAME`, `BOOTC_ADMIN_PASSWORD`, `BOOTC_SSH_PUBLIC_KEY`
- **SSH service**: Automatically enabled and configured in firewall
- **Sudo access**: Admin user has wheel group membership for sudo privileges

To customize users:

1. Set the GitHub Secrets in your repository:
   - `ADMIN_USERNAME`: The admin username
   - `ADMIN_PASSWORD`: The admin password
   - `SSH_PUBLIC_KEY`: Your SSH public key
2. To add additional users, modify the `config.toml` file by adding more `[[customizations.user]]` sections
3. The workflow automatically substitutes environment variables during the build process using `envsubst`

### Adding Packages

Edit `container/Containerfile` to add additional packages:

```dockerfile
ARG FEDORA_VERSION
FROM quay.io/fedora/fedora-bootc:${FEDORA_VERSION}

RUN rpm-ostree install \
    vim-minimal \
    curl \
    wget \
    your-additional-package \
    && rpm-ostree cleanup -m && \
    ostree container commit
```

### Changing Base Image

The Fedora version is controlled by the `FEDORA_VERSION` environment variable in the workflow (currently set to 42). The `Containerfile` uses this as a build argument to dynamically select the base image version.

## Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── build-bootc-image.yml    # GitHub Actions workflow
├── container/
│   └── Containerfile                # Container definition for bootc image
├── config.toml                      # User and SSH configuration for bootc-image-builder
└── README.md                        # This file
```

## Requirements

The build process requires:

- GitHub Actions runner with Ubuntu
- Podman container runtime
- Privileged container execution for image building
- GitHub Container Registry access for storing container images
- GitHub Secrets configured for user credentials

## Security Notes

- The workflow uses privileged containers for image building
- Container images are pushed to GitHub Container Registry
- Only trusted base images from quay.io are used
- Minimal package installation reduces attack surface
- User credentials are stored as GitHub Secrets and substituted at build time
- SSH access is configured with public key authentication
- Admin user has sudo privileges via wheel group membership

## Troubleshooting

### Build Failures

1. Check the workflow logs in GitHub Actions
2. Verify the Containerfile syntax
3. Ensure base image availability
4. Verify that all required GitHub Secrets are configured:
   - `ADMIN_USERNAME`
   - `ADMIN_PASSWORD`
   - `SSH_PUBLIC_KEY`
5. Check that the secrets contain valid values (no special characters that might break shell substitution)

### ISO Boot Issues

1. Verify the ISO was built successfully
2. Check that the ISO file is not corrupted
3. Ensure sufficient memory allocation (minimum 2GB recommended)
4. For physical hardware, verify boot order and UEFI/BIOS compatibility

## Contributing

1. Fork the repository
2. Make changes to the Containerfile or workflow
3. Test your changes via pull request
4. Submit for review

## License

This project is open source. See individual components for their respective licenses.
