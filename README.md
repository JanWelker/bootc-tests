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
3. Uses `bootc-image-builder` to create a bootable ISO from the container image
4. Uploads the ISO as a workflow artifact

### Downloading Built Images

1. Go to the "Actions" tab in this repository
2. Click on a successful workflow run
3. Download the artifact named `fedora-bootc-image-<run-number>.iso`
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

## Customization

### Adding Packages

Edit `container/Containerfile` to add additional packages:

```dockerfile
RUN rpm-ostree install \
    vim-minimal \
    curl \
    wget \
    your-additional-package \
    && rpm-ostree cleanup -m && \
    ostree container commit
```

### Changing Base Image

Modify the `FROM` line in `container/Containerfile` to use a different Fedora version:

```dockerfile
FROM quay.io/fedora/fedora-bootc:41  # For Fedora 41
```

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── build-bootc-image.yml    # GitHub Actions workflow
├── container/
│   └── Containerfile                # Container definition for bootc image
└── README.md                        # This file
```

## Requirements

The build process requires:
- GitHub Actions runner with Ubuntu
- Podman container runtime
- Privileged container execution for image building
- GitHub Container Registry access for storing container images

## Security Notes

- The workflow uses privileged containers for image building
- Container images are pushed to GitHub Container Registry
- Only trusted base images from quay.io are used
- Minimal package installation reduces attack surface

## Troubleshooting

### Build Failures

1. Check the workflow logs in GitHub Actions
2. Verify the Containerfile syntax
3. Ensure base image availability

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