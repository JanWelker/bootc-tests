# Fedora 42 bootc Image Builder

This repository builds an immutable Fedora 42 disk image using bootc image-builder via GitHub Actions.

## Overview

This project creates a minimal, immutable Fedora 42 system image that can be used for:
- Virtual machines (QEMU/KVM)
- Container-based deployments
- Immutable infrastructure setups

## Features

- **Immutable OS**: Built with bootc for atomic updates and rollbacks
- **Minimal footprint**: Only essential base packages included
- **Automated builds**: GitHub Actions workflow for consistent image creation
- **Artifact storage**: Built images are stored as workflow artifacts

## Usage

### Triggering a Build

The workflow can be triggered in three ways:

1. **Push to main branch**: Automatically builds on code changes
2. **Pull request**: Builds for testing proposed changes
3. **Manual trigger**: Use the "Run workflow" button in GitHub Actions

### Downloading Built Images

1. Go to the "Actions" tab in this repository
2. Click on a successful workflow run
3. Download the "fedora-bootc-image" artifact
4. Extract the `.qcow2` file from the downloaded archive

### Using the Image

The built image is in qcow2 format and can be used with:

```bash
# QEMU/KVM
qemu-system-x86_64 -m 2048 -hda fedora-bootc-image.qcow2

# Convert to other formats if needed
qemu-img convert -f qcow2 -O vmdk fedora-bootc-image.qcow2 fedora-bootc-image.vmdk
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
├── bootc-image-builder.md           # Technical documentation
└── README.md                        # This file
```

## Requirements

The build process requires:
- GitHub Actions runner with Ubuntu
- Podman container runtime
- Privileged container execution for image building

## Security Notes

- The workflow uses privileged containers for image building
- Only trusted base images from quay.io are used
- Minimal package installation reduces attack surface

## Troubleshooting

### Build Failures

1. Check the workflow logs in GitHub Actions
2. Verify the Containerfile syntax
3. Ensure base image availability

### Image Boot Issues

1. Verify the image was built successfully
2. Check virtualization platform compatibility
3. Ensure sufficient memory allocation (minimum 2GB recommended)

## Contributing

1. Fork the repository
2. Make changes to the Containerfile or workflow
3. Test your changes via pull request
4. Submit for review

## License

This project is open source. See individual components for their respective licenses.