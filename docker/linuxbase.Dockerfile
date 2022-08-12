
FROM ubuntu:22.04

# Put the apt utility into "noninteractive" mode where is totally silent
ARG DEBIAN_FRONTEND=noninteractive
ARG LM_HOST

# Make bash the default shell for RUN commands and others
SHELL ["/bin/bash", "-c"]

# Install the packages we need in the container
RUN apt update && apt install -y cpio dumb-init libicu70 unzip

# Install Synergy
WORKDIR /tmp/sdeinst
COPY 428SDE1211-3278.a 428SDE1211-3278.a
COPY install.auto install.auto
RUN umask 0
RUN cpio -icvBdum < 428SDE1211-3278.a
RUN chmod a+x install.auto install.sde
RUN ./install.auto -n $LM_HOST -p 16 -l /synergyde
WORKDIR /tmp
RUN rm -rf sdeinst
WORKDIR /

# Provide the script that dumb-init will execute on startup
WORKDIR /root
COPY linuxbase.Startup /root/linuxbase.Startup
RUN chmod +x /root/linuxbase.Startup

WORKDIR /root
RUN echo export TERM=vt100 >> .bashrc
RUN echo source /synergyde/setsde >> .bashrc

# Run the startup script
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/bash", "-c", "/root/linuxbase.Startup $LM_HOST"]
# Note: In Windows 11 the environment variables are propagated into the hcservice.Startup script
# and can be used there. But in Windows 10 that doesn't appear to happen, so we must pass everything
# to the hcservice.Startup script via command line parameters!