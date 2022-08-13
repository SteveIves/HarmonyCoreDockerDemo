![Harmony Core Logo](https://github.com/Synergex/HarmonyCore/wiki/images/logo.png)

# Introduction

This repository contains an example Harmony Core service, as well as
an example of how to deploy the service in a Docker container under
Ubuntu Linux.

# Requirements

To build, deploy and run this example you will need a reasonbably
well equipped Windows development PC (Docker LOVES memory) with the
following:

* Latest version of Windows 10, or Windows 11, Professional or
  Enterprise, with all
  Windows updates installed.
* Visual Studio 2022 (latest version).
* Synergy/DE 12.1.1.3278 or later.
* Synergy DBL Integration for Visual Studio 2022.7.1223 or later.
* 7-Zip.
* Hyper-V enabled.
* Windows Sybsystem for Linux V2 (WSL2) installed and running Ubuntu.
  I tested with Ubuntu 22.04 but 20.04 should work also.
* Docker desktop installed, running in WSL2 integrated mode, and
  integrated wiht the Ubuntu WSL2 machine environment.

**NOTE:** This demonstration assumes that you have a Synergy License
Server running on your Windows PC and that there is at least two
available runtime licenses (e.g. RUN12). If this is not the case then
you must export an environment variable in your WSL2 environment that
specifies the IP address of the Synergy License Server to use. For
example:
```
  export LM_HOST=w.x.y.z
```
This must be in place BEFORE using the `build` or `start` scrips on Linux.

# Procedure

After cloning this repository, the steps to run the demonstration
are as follows:

1.  Open the HarmonyCoreDeockerDemo.sln solution in Visual Studio 2022.

2.  Build the complete solution.
    ```
	  Build > Build Solution
	```

3.  From Visual Studio, open a Windows command prompt and go to the
    solution folder.
	```
	  cd ..
	```

4.  Publish the application for Linux. This will take a little while, but
    when it completes you should find that there is now a zip file named
    HarmonyCoreService-linux.zip in the "docker" folder.
    ```
      publish linux
    ```

    You will see various messages as the publish proceeds:
    ```
      Publishing for linux to C:\DEV\HarmonyCoreDockerDemo\PUBLISH
      Publish complete
      Copying traditional bridge files
      Zipping to C:\DEV\HarmonyCoreDockerDemo\HarmonyCoreService-linux.zip
      Zip file created
      Deleting deployment folder C:\DEV\HarmonyCoreDockerDemo\PUBLISH
      The zip file was successfully copied to ".\docker"
    ```

4.  Edit `ExportHttpsCertificate.Settings.bat`, changing the path in the
    WSL_CERT_LOCATION environment variable so it matches your WSL2
	Ubuntu system name and user acccount. i.e. replace "Ubuntu-22.04"
	and "stevei" with appropriate values.

5.  Use the dos2unix utility to verify that all of the scripts in
    and below the "docker" directory have Linux line endings. Like this:
    ```
      tools\dos2unix docker\\* docker\\bin\\*
    ```
6.  Back at the command prompt type
    ```
      ExportHttpCertificate
    ```
7.  Log in to your WSL2 Linux environment and verify there is a file
    caled Services.Host.pfx in the $HOME/.aspnet/https
    ```
      ls $HOME/.aspnet/https
    ```
8.  From the Linux environment, go to the windows file system, and
    to the "docker" folder below your solution directory. For example
    if you cloned the repsottory to C:\DEV\HarmonyCoreDockerDemo then
    you would do this (assuming a default WSL2 configuration):
    ```
      cd /mnt/c/DEV/HarmonyCoreDockerDemo/docker
    ```
9.  Execute the setup script to add the "bin" folder to your PATH:
    ```
      souce setup
     ```
10. Build the 'linuxbase' docker image:
    ```
      $ build linuxbase
    ```
	As the image build proceeds you should see output like this:
    ```
      [+] Building 95.2s (22/22) FINISHED
       => [internal] load build definition from linuxbase.Dockerfile                                                                                                                                               0.1s
       => => transferring dockerfile: 1.33kB                                                                                                                                                                       0.0s
       => [internal] load .dockerignore                                                                                                                                                                            0.1s
       => => transferring context: 2B                                                                                                                                                                              0.0s
       => [internal] load metadata for docker.io/library/ubuntu:22.04                                                                                                                                              0.0s
       => [ 1/18] FROM docker.io/library/ubuntu:22.04                                                                                                                                                              0.0s
       => [internal] load build context                                                                                                                                                                            0.3s
       => => transferring context: 39.77MB                                                                                                                                                                         0.2s
       => [ 2/18] RUN apt update && apt install -y cpio dumb-init libicu70 unzip                                                                                                                                  82.8s
       => [ 3/18] WORKDIR /tmp/sdeinst                                                                                                                                                                             0.1s
       => [ 4/18] COPY 428SDE1211-3278.a 428SDE1211-3278.a                                                                                                                                                         0.1s
       => [ 5/18] COPY install.auto install.auto                                                                                                                                                                   0.1s
       => [ 6/18] RUN umask 0                                                                                                                                                                                      0.5s
       => [ 7/18] RUN cpio -icvBdum < 428SDE1211-3278.a                                                                                                                                                            1.8s
       => [ 8/18] RUN chmod a+x install.auto install.sde                                                                                                                                                           0.7s
       => [ 9/18] RUN ./install.auto -n 172.26.240.1 -p 16 -l /synergyde                                                                                                                                           3.7s
       => [10/18] WORKDIR /tmp                                                                                                                                                                                     0.1s
       => [11/18] RUN rm -rf sdeinst                                                                                                                                                                               0.6s
       => [12/18] WORKDIR /root                                                                                                                                                                                    0.1s
       => [13/18] COPY linuxbase.Startup /root/linuxbase.Startup                                                                                                                                                   0.1s
       => [14/18] RUN chmod +x /root/linuxbase.Startup                                                                                                                                                             0.6s
       => [15/18] WORKDIR /root                                                                                                                                                                                    0.1s
       => [16/18] RUN echo export TERM=vt100 >> .bashrc                                                                                                                                                            0.5s
       => [17/18] RUN echo source /synergyde/setsde >> .bashrc                                                                                                                                                     0.6s
       => exporting to image                                                                                                                                                                                       0.8s
       => => exporting layers                                                                                                                                                                                      0.8s
       => => writing image sha256:23c1b94364ce092d532953d7c4c72059946b7647fefcd920db8841b0a00feeb3                                                                                                                 0.0s
       => => naming to docker.io/library/linuxbase
    ```

11. Build the 'demoservice' docker image:
    ```
      $ build demoservice
    ```
	As the image build proceeds you should see output like this:
    ```
      [+] Building 12.1s (19/19) FINISHED
       => [internal] load build definition from demoservice.Dockerfile                                                                                                                                             0.0s
       => => transferring dockerfile: 1.24kB                                                                                                                                                                       0.0s
       => [internal] load .dockerignore                                                                                                                                                                            0.0s
       => => transferring context: 2B                                                                                                                                                                              0.0s
       => [internal] load metadata for docker.io/library/linuxbase:latest                                                                                                                                          0.0s
       => [internal] load build context                                                                                                                                                                            0.4s
       => => transferring context: 58.07MB                                                                                                                                                                         0.3s
       => [ 1/14] FROM docker.io/library/linuxbase:latest                                                                                                                                                          0.0s
       => [ 2/14] WORKDIR /root                                                                                                                                                                                    0.1s
       => [ 3/14] RUN rm /root/linuxbase.Startup                                                                                                                                                                   0.5s
       => [ 4/14] COPY demoservice.Startup /root/demoservice.Startup                                                                                                                                               0.1s
       => [ 5/14] RUN chmod +x /root/demoservice.Startup                                                                                                                                                           0.6s
       => [ 6/14] WORKDIR /root/service                                                                                                                                                                            0.1s
       => [ 7/14] RUN chmod 775 /root/service                                                                                                                                                                      0.7s
       => [ 8/14] COPY HarmonyCoreService-linux.zip HarmonyCoreService-linux.zip                                                                                                                                   0.2s
       => [ 9/14] RUN unzip HarmonyCoreService-linux.zip                                                                                                                                                           1.6s
       => [10/14] RUN rm -f HarmonyCoreService-linux.zip                                                                                                                                                           0.6s
       => [11/14] RUN chmod 775 *                                                                                                                                                                                  2.8s
       => [12/14] WORKDIR /root                                                                                                                                                                                    0.1s
       => [13/14] RUN echo export TERM=vt100 >> .bashrc                                                                                                                                                            0.5s
       => [14/14] RUN echo source /synergyde/setsde >> .bashrc                                                                                                                                                     0.6s
       => exporting to image                                                                                                                                                                                       0.9s
       => => exporting layers                                                                                                                                                                                      0.9s
       => => writing image sha256:b1ab496009a18c181ea822749b7c002e789d08ee4eb360619a90d88d528ce2d7                                                                                                                 0.0s
       => => naming to docker.io/library/demoservice
    ```

12. Start the demoservice container
    ```
      $ start demoservice attach
    ```
    You should see the container and the Harmony Core service start,
    like this:
    ```
	  INFO: Executing script demoservice.Startup
	  INFO: Setting Synergy environment
	  INFO: Setting Synergy license server to 172.22.240.1
	  INFO: Starting Synergy license server
	
	  API documentation     https://localhost:8086/swagger
	  Endpoint mappings     https://localhost:8086/odata/v1/$odata
	  OData metadata (XML)  https://localhost:8086/odata/v1/$metadata
	  OData metadata (JSON) https://localhost:8086/odata/v1/$metadata?$format=json
	  Bridge mode           LOCAL
	  Bridge logging level  2
	
	  Hosting environment: Production
	  Content root path: /root/service/
	  Now listening on: https://[::]:8086
	  Now listening on: http://[::]:8085
	  Application started. Press Ctrl+C to shut down.
    ```
13. Connect to and test the service using a web browser on your windows PC
    by connecting to:
    ```
      https://localhost:8086
    ```

14. Return to the Linux console and stop the service:
    ```
      Ctrl + C`
    ```

# Linux Docker Scripts

Several bash scripts are provided in the docker/bin folder to help you
work with the docker build process, images and containers. These scripts
are:

## build \<imagename\>

Executes `\<imagename\>.Setup` to configure appropriate settings then processes
`\<imagename\>.Dockerfile` to produce a Docker image named `\<imagename\>`.

## rebuild \<imagename\>

Like build but the local image cache is not used so a full rebuild of the
image takes place.

## start \<imagename\> [attach]

Executes `\<imagename\>.Setup` to configure appropriate settings then runs 
the image `\<imagename\>` in a container. The container will be assigned a
unique ID as well as a random name, both of which can be used to interact
with it.

## images

Lists all Docker images that currently exist

## show

Displays a list of all images and running containers.

## containers

Lists all Docker containers that are currently running. You can use this
to obtain the generated name or ID of a container so you can connect to
it or stop it.

## attach <container_name_or_id>

Attaches your terminal to the root user account of a running container.
Type `exit` to disconnect.

## stop <container_name_or_id>

Stops a running container.

## stopall

Stops all running containers.

## cleanup

Cleans up the environment, removing any files that are no longer used.

## pull \<name\>[:\<tag\>]

Pulls a Docker image from Docker Hub. 

## push \<name\>[:\<tag\>]

Pushes a Docker image from Docker Hub
