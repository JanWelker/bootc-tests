# Use Rocky Linux 9 as the base image and add bootc capabilities
FROM rockylinux:9

# Install bootc and required packages for a bootable system
RUN dnf update -y && \
    dnf install -y \
        bootc \
        kernel \
        grub2 \
        grub2-efi-x64 \
        efibootmgr \
        shim-x64 \
        chrony \
        cloud-init \
        systemd \
        NetworkManager && \
    dnf clean all

# Enable essential services
RUN systemctl enable chronyd NetworkManager cloud-init

# Set up a basic bootc-compatible filesystem structure
RUN mkdir -p /var/lib/containers
