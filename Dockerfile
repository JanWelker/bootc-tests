# Use the bootc base image for CentOS Stream 9 as a compatible starting point
# This provides the necessary ostree setup in the container
FROM quay.io/centos-bootc/centos-bootc:stream9

# Remove the existing CentOS ostree commit
RUN rm -rf /usr/lib/ostree

# Copy our newly composed Rocky Linux repo into the image
COPY ./repo /usr/lib/ostree/repo
