
FROM linuxbase:latest

ARG LM_HOST

# Make bash the default shell for RUN commands and others
SHELL ["/bin/bash", "-c"]

# Provide the script that dumb-init will execute on startup
WORKDIR /root
RUN rm /root/linuxbase.Startup
COPY demoservice.Startup /root/demoservice.Startup
RUN chmod +x /root/demoservice.Startup

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
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/bash", "-c", "/root/demoservice.Startup $LM_HOST"]
# Note: In Windows 11 the environment variables are propagated into the hcservice.Startup script
# and can be used there. But in Windows 10 that doesn't appear to happen, so we must pass everything
# to the hcservice.Startup script via command line parameters!