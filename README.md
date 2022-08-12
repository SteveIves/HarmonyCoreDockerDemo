![Harmony Core Logo](https://github.com/Synergex/HarmonyCore/wiki/images/logo.png)

This repository contains an example Harmony Core service, as well as an example of how to
deploy the service in a Docker container under Ubuntu Linux.

To build, deploy and run this example you will need a reasonbable well specced Windows
development PC (Docker LOVES memory) with the following

* Latest version of Windows 10, or Windows 11, Professional or Enterprise, with all
  Windows updates installed.
* Visual Studio 2022 (latest version).
* Synergy/DE 12.1.1.3278 or later.
* Synergy DBL Integration for Visual Studio 2022.7.1223 or later.
* 7-Zip.
* dos2unix utility on Windows
* Hyper-V enabled.
* Windows Sybsystem for Linux V2 (WSL2) installed and running Ubuntu. I tested with Ubuntu
  22.04 but 20.04 should work also.
* Docker desktop installed, running in WSL2 integrated mode, and integrated wiht the
  Ubuntu WSL2 machine environment.

After cloning this repository, the steps to run the demonstration are as follows:

* Open the HarmonyCoreDeockerDemo.sln solution in Visual Studio.
* Build the complete solution.
Run the solution in VS and copy the ISAM and DDF files from SampleData to $HOME/data in your linux environment
Open a command prompt, go to solution folder and do a "publish linux"
Go to WSL2 cd to the windows "docker" folder
souce setup
build hcservice
run hcservice
The service now starts detached. If you want to run it and attach you can use start hcservice attach, or you can attach <containerid> later

