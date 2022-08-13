![Harmony Core Logo](https://github.com/Synergex/HarmonyCore/wiki/images/logo.png)

# Introduction

This repository contains an example Harmony Core service, as well as
an example of how to deploy the service in a Docker container under
Ubuntu Linux.

# Requirements

To build, deploy and run this example you will need a reasonbably
well equipped Windows development PC (Docker LOVES memory) with the
following:

* Windows 10 (latest version) or Windows 11 Professional or
  Enterprise editions with all Windows updates installed.
* Visual Studio 2022 (latest).
* Synergy/DE (latest).
* Synergy DBL Integration for Visual Studio (latest).
* 7-Zip.
* Hyper-V enabled.
* Windows Sybsystem for Linux V2 (WSL2) installed and running Ubuntu.
  I tested with Ubuntu 22.04 but 20.04 should work also.
* Docker desktop installed, running in WSL2 integrated mode, and
  integrated wiht the Ubuntu WSL2 machine environment.

**NOTE:** This demonstration assumes that you have a Synergy License
Server running on your Windows PC and that there are at least two
runtime licenses (e.g. RUN12) available. If this is not the case then
you must export an environment variable in your WSL2 environment that
specifies the IP address of the Synergy License Server to use. For
example:
```
  export LM_HOST=w.x.y.z
```
This must be in place BEFORE using the `build` or `start` scrips on Linux.

# Background Information

This example creates two Docker images, one called linuxbase and one
called demoservice.

The linuxbase image is a minimal Ubuntu 22.04 system with a handful of
additional packages (cpio, dumb-init, libicu70 and unzip) as well as
Synergy 12.1 installed.

The demoservice image is based on linuxbase, and adds a deployed
Harmony Core service that exposes both OData and Traditional Bridge
endpoints.

When a demoservice container is started the Harmony Core service is
launched and listens on ports 8085 (HTTP) and 8086 (HTTPS). Any requests
to the HTTP endpoint are redirected to the HTTPS endpoint.

# Procedure

After cloning this repository, the steps to run the demonstration
are shown below.

When working on Windows we use `C:\>` to indicate a command to be
typed on Windows, although your prompt may be different.

When working on Linux we use `$` to indicate a command to be typed
on Linux, although your prompt may be different.

1.  Open the HarmonyCoreDeockerDemo.sln solution in Visual Studio 2022.

2.  Build the complete solution.
    ```
	  C:\> Build > Build Solution
	```

3.  From Visual Studio, open a Windows command prompt and go to the
    solution folder.
	```
	  C:\> cd ..
	```

4.  Publish the application for Linux. This will take a little while, but
    when it completes you should find that there is now a zip file named
    HarmonyCoreService-linux.zip in the "docker" folder.
    ```
      C:\> publish linux
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

4.  Use the dos2unix utility to verify that all of the scripts in
    and below the "docker" directory have Linux line endings. Like this:
    ```
      C:\> tools\dos2unix docker\\* docker\\bin\\*
    ```
5.  Edit `ExportHttpsCertificate.Settings.bat`, changing the path in the
    WSL_CERT_LOCATION environment variable so it matches your WSL2
	Ubuntu system name and user acccount. i.e. replace "Ubuntu-22.04"
	and "stevei" with appropriate values.

6.  Back at the command prompt type
    ```
      C:\> ExportHttpCertificate
    ```
    Running this script does several things:
    * Creates a developer SSL certificate (if one does not already exist)
      and exports it to a file, protected by a password.
    * Trusts the certificate on Windows (if not already trusted).
    * Creates a directory to contain the certificate on your Linux system.
    * Copies the certificate to that directory on the Linux system.

7.  Log in to your WSL2 Linux environment and verify there is a file
    caled Services.Host.pfx in the $HOME/.aspnet/https
    ```
      $ ls $HOME/.aspnet/https
    ```
Next you need to copy the sample data from the Windows system to the Linux
system, from where it will be accessed by any running containers.

You will create a new directory called "data" and  copy the sample data
files into the new directory from Windows. The commands below assume that
you cloned the repsottory to C:\DEV\HarmonyCoreDockerDemo and have a default
WSL2 configuration.

8.  From the Linux environment, execute these commands:
    ```
      $ mkdir ~/data
      $ cd /mnt/c/DEV/HarmonyCoreDockerDemo/SampleData
      $ cp *.ism *.is1 *.ddf ~/data
      $ cd ~
    ```

Now it is time to build the Docker images for the demo environment. Once
again the command below assume that you cloned the repsottory to
`C:\DEV\HarmonyCoreDockerDemo` and are using a default WSL2 configuration.

9. Still in Linux, move to the docker folder in the Windows file system:
    ```
      $ cd /mnt/c/DEV/HarmonyCoreDockerDemo/docker
    ```

10. Execute the `setup` shell script. This simply adds the "docker/bin"
    folder to your PATH so that you can easily execute the shell scripts
    present there:
    ```
      $ souce setup
     ```

11. Build the 'linuxbase' docker image:
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

12. Build the 'demoservice' docker image:
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

13. Start the demoservice container
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
14. Connect to and test the service using a web browser on your windows PC
    by connecting to:
    ```
      https://localhost:8086
    ```

15. Return to the Linux console and stop the service:
    ```
      Ctrl + C`
    ```
# Where is the Data?

In this example there is no data present in the Docker images or containers.
The data being used resides in the `~/data` folder on your WSL2 Linux system
and is "mapped" into running containers via a Docker "volume". You can see
that happening in the `demoservice.Setup` file:

```
  export DATA_PATH=${HOME}/data:/root/data
```

To the container the data appears to be local in the `/root/data` folder
but is actually located in the `${HOME}/data` folder on the Linux system
hosting the container.

This approach may not be appropriate for data in production scenarios, but that
is a topic beyond the scope of this simple demo environment.

# Supporting HTTPS in Docker

The enironment used in this example is appropriate for development systems
but not for production systems.

In this environment we use the ASP.NET Developer SSL certificate that ASP.NET
creates on Windows and move a copy of that certificate to Linux, where it is
mapped into the running Docker container via a Docker volume mapping.

Several runtime environment variables are propagated into the running
container by the `start` shell script, based on information defined in the
`demoservice.Setup` shell script. These environment variables are:
```
  ASPNETCORE_URLS
  ASPNETCORE_HTTPS_PORT
  ASPNETCORE_Kestrel__Certificates__Default__Path
  ASPNETCORE_Kestrel__Certificates__Default__Password
```

# Helper Scripts

Several bash scripts are provided in the `docker/bin` folder to help you
work with the docker build process, images and containers. You can add the
bin folder to your path by sourcing the docker/setup script:

```
  source setup
```

The scripts are:
```
build \<imagename\>**
```

Executes `\<imagename\>.Setup` to configure appropriate settings then processes
`\<imagename\>.Dockerfile` to produce a Docker image named `\<imagename\>`.

**rebuild \<imagename\>**

Like build but the local image cache is not used so a full rebuild of the
image takes place.

**start \<imagename\> [attach]**

Executes `\<imagename\>.Setup` to configure appropriate settings then runs 
the image `\<imagename\>` in a container. The container will be assigned a
unique ID as well as a random name, both of which can be used to interact
with it.

**images**

Lists all Docker images that currently exist

**show**

Displays a list of all images and running containers.

**containers**

Lists all Docker containers that are currently running. You can use this
to obtain the generated name or ID of a container so you can connect to
it or stop it.

**attach <container_name_or_id>**

Attaches your terminal to the root user account of a running container.
Type `exit` to disconnect.

**stop <container_name_or_id>**

Stops a running container.

**stopall**

Stops all running containers.

**cleanup**

Cleans up the environment, removing any files that are no longer used.

**pull \<name\>[:\<tag\>]**

Pulls a Docker image from Docker Hub. 

**push \<name\>[:\<tag\>]**

Pushes a Docker image from Docker Hub
