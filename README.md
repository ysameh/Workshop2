# Workshop 2

## Overview

*Workshop 2* is a project designed to build and deploy an application called **Pet Clinic** to a Tomcat server and configure Nagios to monitor Tomcat. The entire process is automated using Ansible and Jenkins.

## Project Structure

The repository is organized as follows:

- `ansible/`: Contains Ansible playbooks for installing tools, deploying the application, and configuring monitoring.
- `scripts/`: Includes the shell scripts for installing required tools and preparing the application for building.
- `jenkinsfile`: Holds the Jenkins pipeline script for automating the build and deployment process.

## Getting Started

To get started with this project, follow these steps:

1. **Clone the repository**:
   - Clone the repo in your home directory.
   ```bash
   git clone https://github.com/ysameh/Workshop2.git
   cd Workshop2
   ```

2. **Prerequisites**:
   - Ansible must be installed on the system.
   
3. **Installation**:
   - Run the Ansible playbook to install the required tools:
     ```bash
     ansible-playbook ansible/install_tools.yml
     ```
   - This installs JDK, Tomcat, Nagios, and Jenkins.
   
4. **Jenkins pipeline**:
   - Run the Jenkins pipeline located in the `jenkinsfile` to automate the build and deployment process. 
     ```bash
     java -Dhudson.util.ProcessTree.disable=true -jar jenkins.war
     ```
   - Disabling the process tree ensures that tomcat and nagios are not killed after the pipeline finishes.
    

## Usage

### Running the Pipeline

Once the required tools are installed, the user should execute the Jenkins pipeline located in the `jenkinsfile` to automate the build and deployment process. The pipeline consists of five stages:

1. **Cloning the Repository**: Fetches the Pet Clinic application source code.
2. **Preparation**: Runs a script to prepare the application for generating the WAR file.
3. **Building the Application**: Compiles the application and produces a deployable WAR file.
4. **Deployment and Configuration**: Runs the Ansible playbook `ansible/petclinic.yml` to deploy the application on Tomcat and configure Nagios for monitoring.
5. **Sanity Checks**: Executes `ansible/sanity_checks.yml` to verify that the application has been successfully deployed.

## Customization

By default, the app is configured to run on port 9090. Modify if needed in `ansible/tomcat/tasks/main.yml`.

Tomcat GUI manager has a default username and password. Modify in `ansible/tomcat/tasks/main.yml` with your preferred credentials.


## Troubleshooting

If you encounter issues while setting up or running the project, consider the following solutions:

- **Permission Issues**: Make sure all the scripts have execute permissions.
- **Ansible Playbook Fails**: Ensure that Ansible is installed and properly configured. Run `ansible --version` to check.
- **Tomcat Deployment Issues**: Check if Tomcat is running on the correct port using `netstat -tulnp | grep 9090`. Restart Tomcat if necessary.
- **Nagios Not Monitoring Tomcat**: Ensure that Nagios is properly configured and the Tomcat service is being monitored.
- **Application Not Accessible**: Check firewall settings to ensure that port 9090 is open: `sudo ufw allow 9090`.


