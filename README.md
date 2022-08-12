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

* Open the HarmonyCoreDeockerDemo.sln solution in Visual Studio.

* Build the complete solution.

* From Visual Studio, open a Windows command prompt and go to the
  solution folder.

* Publish the application for Linux. This will take a little while, but when it
  completes you should find that there is now a zip file named
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

* Edit the file ExportHttpsCertificate.Settings.bat and edit the
  path in the WSL_CERT_LOCATION environment variable so it matches
  your WSL2 Ubuntu system name and user acccount. i.e. replace
  "Ubuntu-22.04" and "stevei" with appropriate values.

* Use the dos2unix utility to verify that all of the scripts in
  and below the "docker" directory have Linux line endings. Like this:
  ```
    tools\dos2unix docker\\* docker\\bin\\*
  ```
* Back at the command prompt type
  ```
    ExportHttpCertificate
  ```
* Log in to your WSL2 Linux environment and verify there is a file
  caled Services.Host.pfx in the $HOME/.aspnet/https
  ```
    ls $HOME/.aspnet/https
  ```
* From the Linux environment, go to the windows file system, and
  to the "docker" folder below your solution directory. For example
  if you cloned the repsottory to C:\DEV\HarmonyCoreDockerDemo then
  you would do this (assuming a default WSL2 configuration):
  ```
    cd /mnt/c/DEV/HarmonyCoreDockerDemo/docker
  ```
* Execute the setup script to add the "bin" folder to your PATH:
  ```
     souce setup
   ```
* Build the docker image
  ```
    build hcservice
  ```
  The first time you build the Docker image will tke some time (a few
  minutes) as it must download the image for the Ubuntu Operating
  system, as well as apply Linux patches, install the .NET runtime
  and Synergy, and copy also deploy the Harmony Core service. You
  will see messages as this process proceeds, and when it completes
  you should see something like this:
  ```
	INFO: Executing hcservice.Setup

	INFO: Build command is: docker build -f hcservice.Dockerfile  --build-arg LM_HOST=172.22.240.1 -t hcservice .

	[+] Building 114.2s (34/34) FINISHED
	 => [internal] load build definition from hcservice.Dockerfile                                                                           0.1s
	 => => transferring dockerfile: 2.28kB                                                                                                   0.0s
	 => [internal] load .dockerignore                                                                                                        0.1s
	 => => transferring context: 2B                                                                                                          0.0s
	 => [internal] load metadata for docker.io/library/ubuntu:22.04                                                                          1.5s
	 => [ 1/30] FROM docker.io/library/ubuntu:22.04@sha256:34fea4f31bf187bc915536831fd0afc9d214755bf700b5cdb1336c82516d154e                  4.9s
	 => => resolve docker.io/library/ubuntu:22.04@sha256:34fea4f31bf187bc915536831fd0afc9d214755bf700b5cdb1336c82516d154e                    0.0s
	 => => sha256:df5de72bdb3b711aba4eca685b1f42c722cc8a1837ed3fbd548a9282af2d836d 1.46kB / 1.46kB                                           0.0s
	 => => sha256:d19f32bd9e4106d487f1a703fc2f09c8edadd92db4405d477978e8e466ab290d 30.43MB / 30.43MB                                         3.4s
	 => => sha256:34fea4f31bf187bc915536831fd0afc9d214755bf700b5cdb1336c82516d154e 1.42kB / 1.42kB                                           0.0s
	 => => sha256:42ba2dfce475de1113d55602d40af18415897167d47c2045ec7b6d9746ff148f 529B / 529B                                               0.0s
	 => => extracting sha256:d19f32bd9e4106d487f1a703fc2f09c8edadd92db4405d477978e8e466ab290d                                                1.4s
	 => [internal] load build context                                                                                                        0.8s
	 => => transferring context: 97.84MB                                                                                                     0.7s
	 => [ 2/30] RUN apt update                                                                                                              25.6s
	 => [ 3/30] RUN apt install -y apt-transport-https apt-utils bash cpio dumb-init unzip wget                                             10.2s
	 => [ 4/30] RUN wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb    0.7s
	 => [ 5/30] RUN dpkg -i packages-microsoft-prod.deb                                                                                      0.7s
	 => [ 6/30] RUN rm packages-microsoft-prod.deb                                                                                           0.6s
	 => [ 7/30] RUN apt update                                                                                                               2.0s
	 => [ 8/30] RUN apt install -y --no-install-recommends aspnetcore-runtime-6.0                                                           50.4s
	 => [ 9/30] WORKDIR /tmp/sdeinst                                                                                                         0.1s
	 => [10/30] COPY 428SDE1211-3278.a 428SDE1211-3278.a                                                                                     0.1s
	 => [11/30] COPY install.auto install.auto                                                                                               0.1s
	 => [12/30] RUN umask 0                                                                                                                  0.4s
	 => [13/30] RUN cpio -icvBdum < 428SDE1211-3278.a                                                                                        0.8s
	 => [14/30] RUN chmod a+x install.auto install.sde                                                                                       0.7s
	 => [15/30] RUN ./install.auto -n 172.22.240.1 -l /synergyde                                                                             4.4s
	 => [16/30] WORKDIR /tmp                                                                                                                 0.1s
	 => [17/30] RUN rm -rf sdeinst                                                                                                           0.5s
	 => [18/30] WORKDIR /root                                                                                                                0.1s
	 => [19/30] COPY hcservice.Startup /root/hcservice.Startup                                                                               0.1s
	 => [20/30] RUN chmod +x /root/hcservice.Startup                                                                                         0.5s
	 => [21/30] WORKDIR /root/service                                                                                                        0.1s
	 => [22/30] RUN chmod 775 /root/service                                                                                                  0.6s
	 => [23/30] COPY HarmonyCoreService-linux.zip HarmonyCoreService-linux.zip                                                               0.2s
	 => [24/30] RUN unzip HarmonyCoreService-linux.zip                                                                                       2.3s
	 => [25/30] RUN rm -f HarmonyCoreService-linux.zip                                                                                       0.6s
	 => [26/30] RUN chmod 775 *                                                                                                              2.5s
	 => [27/30] WORKDIR /root                                                                                                                0.1s
	 => [28/30] RUN echo export TERM=vt100 >> .bashrc                                                                                        0.6s
	 => [29/30] RUN echo source /synergyde/setsde >> .bashrc                                                                                 0.7s
	 => exporting to image                                                                                                                   1.2s
	 => => exporting layers                                                                                                                  1.2s
	 => => writing image sha256:8ed14cd352b2f0bfaac3cd48344d080bd03705ed92642a390becc6e6f3acad38                                             0.0s
	 => => naming to docker.io/library/hcservice
  ```

* Start the Docker container
  ```
    start hcservice attach
  ```
  You should see the container and the Harmony Core service start,
  like this:
  ```
	INFO: Executing script hcservice.Startup
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
  You should be able to connect to and test the service using a web
  browser on your windows PC, by connecting to:
  ```
    https://localhost:8086
  ```
  To stop the service, go back to the Linux console and type `Ctrl + C`.


