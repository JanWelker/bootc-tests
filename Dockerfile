# Use Rocky Linux 9 as the base image and add bootc capabilities
FROM rockylinux:9

# Install bootc and required packages
RUN dnf update -y && \
    dnf install -y \
        bootc \
        kernel \
        grub2 \
        grub2-efi-x64 \
        efibootmgr \
        shim-x64 \
        chrony \
        cloud-init && \
    dnf clean all

# Configure bootc for this image
RUN bootc switch --mutate-in-place --transport registry ghcr.io/janwelker/bootc-tests:latest || true
