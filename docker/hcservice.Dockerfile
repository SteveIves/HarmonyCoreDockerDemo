FROM ubuntu:22.04

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
SHELL ["/bin/bash", "-c"]

# In order to be able to set environment variables from the "docker run" command
# line, the variables must be declared here
ENV LM_HOST=
ENV ASPNETCORE_ENVIRONMENT=
ENV ASPNETCORE_URLS=
ENV ASPNETCORE_HTTPS_PORT=
ENV ASPNETCORE_Kestrel__Certificates__Default__Path=
ENV ASPNETCORE_Kestrel__Certificates__Default__Password=
ENV TERM=vt100

# Install the packages we need in the container
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y apt-transport-https apt-utils bash ca-certificates cpio dos2unix \
dumb-init gdb git gzip iproute2 iputils-ping libtinfo6 sudo tar unzip vim wget

# Install the Microsoft package feed
RUN wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb
RUN apt update

# Install the ASP.NET 6 runtime
RUN apt install -y --no-install-recommends aspnetcore-runtime-6.0
 
# Download and install Synergy
ARG LM_HOST
WORKDIR /tmp/sdeinst
COPY 428SDE1211-3278.a 428SDE1211-3278.a
COPY install.auto install.auto
RUN umask 0
RUN cpio -icvBdum < 428SDE1211-3278.a
RUN chmod a+x install.auto install.sde
RUN ./install.auto -n $LM_HOST -l /synergyde
WORKDIR /tmp
RUN rm -rf sdeinst
WORKDIR /

# Provide the script that dumb-init will execute on startup
WORKDIR /root
COPY hcservice.Startup /root/hcservice.Startup
RUN chmod +x /root/hcservice.Startup

# Make a directory to put the Harmony Core files in
WORKDIR /root/service
RUN chmod 775 /root/service

# Copy and unzip the Harmony Core service files
COPY HarmonyCoreService-linux.zip HarmonyCoreService-linux.zip
RUN unzip HarmonyCoreService-linux.zip
RUN rm -f HarmonyCoreService-linux.zip
RUN chmod 775 *

# Open the ports that the Harmony Core service uses
EXPOSE 8085 8086

WORKDIR /root
RUN echo export TERM=vt100 >> .bashrc
RUN echo source /synergyde/setsde >> .bashrc

# Run the startup script
CMD ["/bin/bash", "-c", "/root/hcservice.Startup $LM_HOST $ASPNETCORE_ENVIRONMENT $ASPNETCORE_URLS $ASPNETCORE_HTTPS_PORT $ASPNETCORE_Kestrel__Certificates__Default__Path $ASPNETCORE_Kestrel__Certificates__Default__Password $TERM"]
# Note: In Windows 11 the environment variables are propagated into the hcservice.Startup script
# and can be used there. But in Windows 10 that doesn't appear to happen, so we must pass everything
# to the hcservice.Startup script via command line parameters!