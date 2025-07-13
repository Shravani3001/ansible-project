# Automated Nginx Deployment on AWS using Ansible + Terraform

## Project Overview

This project demonstrates how to provision infrastructure on AWS using **Terraform** and configure a web server using **Ansible**, just like a real-world DevOps setup. It deploys two EC2 instances:

- **Ansible Controller EC2 (Ubuntu)**: Runs Ansible commands.
- **Target EC2 (Ubuntu)**: Gets configured remotely to install and run Nginx, serving a custom HTML page.

---

## Tools & Technologies Used

- **Terraform** (Infrastructure as Code)
- **AWS EC2, VPC, Subnet, IGW, Security Groups**
- **Ansible** (Configuration Management)
- **Ubuntu 20.04 LTS**
- **Nginx** (Web Server)

---

## Project Structure

```bash
project-folder/
├── main.tf
├── variables.tf
├── outputs.tf
├── ansible/
│ ├── inventory.ini
│ ├── playbook.yml
│ └── files/
│ └── index.html
├── .gitignore
└── README.md
```

### How It Works

**Infrastructure Setup (Terraform)**

Terraform provisions two EC2 instances in a single public subnet:

**ansible_controller:** Accessible via public IP, used to run Ansible commands.

**target_node:** Accessible via public IP (for demo purposes), used as the Ansible target.

**Terraform also:**

Creates a VPC, Subnet, Internet Gateway, and Security Groups.

Generates key pairs for SSH access.

Outputs relevant IP addresses.

**Configuration Automation (Ansible)**

On the Ansible Controller:

We define an inventory file that points to the Target node.

An Ansible playbook is executed to:

Install Nginx

Copy a custom HTML file

Start and enable the Nginx service

---

## Features

Here are the key features of this Ansible + Terraform project:

✅ Infrastructure as Code with Terraform
Automates the provisioning of AWS resources like VPC, Subnet, EC2 instances, and Security Groups.

✅ Configuration Management with Ansible
Remotely installs and configures the Nginx web server on the target EC2 using a playbook.

✅ Key-Based SSH Access
Uses an SSH key pair for secure and automated connection between controller and target nodes.

✅ Modular Project Structure
Keeps Terraform and Ansible code separate and organized.

✅ Custom HTML Page Deployment
Delivers a pre-defined index.html file to /var/www/html via Ansible.

✅ Browser-Accessible Web Server
Access the deployed Nginx web page using the public IP of the target EC2.

✅ Easy Teardown
One command (terraform destroy) cleans up all resources when the demo is done.

---

## Architecture Diagram

Here’s a simple diagram that illustrates how components interact:
```bash

         +-------------------+                            +---------------------+
         |  Your Local Machine|                            | AWS Cloud           |
         +-------------------+                            +---------------------+
                  |                                               |
      Generate SSH Keys & Terraform Apply                         |
                  |                                               |
                  |---------------------------------------------->|
                  |                                               |
         Provisions VPC, Subnet, 2 EC2s, SGs                      |
                  |                                               |
        <------------------- Public IPs --------------------------|
                  |
         SSH into Ansible Controller EC2
                  |
         +---------------------------+
         | Ansible Controller EC2    |
         | (Public IP)               |
         |---------------------------| 
         | ✅ Install Ansible         |
         | ✅ Copy private key here   |
         | ✅ Write inventory.ini     |
         | ✅ Write playbook.yml      |
         |---------------------------|
         | Run ansible-playbook ----> SSH to Target EC2
         +---------------------------+        |
                                              |
                                              v
                          +-------------------------+
                          |     Target EC2          |
                          |-------------------------|
                          | - Nginx Installed       |
                          | - index.html Copied     |
                          | - Nginx Started         |
                          +-------------------------+

                  |
     Open browser to http://<Target Public IP>
                  |
         View: "Hello from Ansible!"
```

---

## ✅ Step-by-Step Procedure

### 1️⃣ Provision Infrastructure using Terraform

- Launch **2 EC2 Instances** in the **same public subnet** and **availability zone**:
  - `ansible_controller` with a **public IP**
  - `target_node` also with a **public IP** (for testing)
- Use `aws_key_pair` to generate SSH access.
- Open necessary ports using **security groups**:
  - `ansible_controller`: Port 22 (SSH)
  - `target_node`: Port 22 (SSH), Port 80 (HTTP)
- Output the:
- ✅ **Public IP of the Ansible Controller** (for SSH from your local machine)
- ✅ **Private IP of the Target Node** (for Ansible SSH from controller)
- ✅ **Public IP of the Target Node** (for browser access to test Nginx page)

### ✅ 1. Clone the Repo

```bash
git clone https://github.com/Shravani3001/ansible-project.git
cd ansible-project
```
### ✅ 2. Generate SSH Key Pair

```bash
ssh-keygen -t rsa -b 4096 -f ansible-key
```

This generates ansible-key and ansible-key.pub

### ✅ 3. Deploy Infrastructure

```bash
terraform init
terraform apply
```
### ✅ 4. SSH into Ansible Controller & Install Ansible

```bash
ssh -i ./ansible-key ubuntu@<controller_public_ip>
```
### ✅ 5. Install Ansible

```bash
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
```
### ✅ 6. Copy SSH Private Key to Controller (for internal SSH)

From your local machine: Run the following command in your project folder (ansible-project folder)

```bash
scp -i ansible-key ansible-key ubuntu@<controller_public_ip>:/home/ubuntu/
```
**On controller:** Now SSH into ansible-controller instance and run the following command 

```bash
chmod 400 ansible-key
```
### ✅ 7. Test SSH from Controller → Target Node

```bash
ssh -i ansible-key ubuntu@<target_private_ip>
```
✅ If successful, you're ready for Ansible.

### ✅ 8. Setup Ansible Project Structure

```bash
mkdir ansible-nginx-setup
cd ansible-nginx-setup
touch inventory.ini playbook.yml
mkdir files
```

### ✅ 9. Create Ansible Inventory File (inventory.ini) using nano inventory.ini command in the ansible-nginx-setup folder

```bash
[webservers]
target ansible_host=<target_private_ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/ansible-key
```
### ✅ 10. Create Ansible Playbook (playbook.yml) using nano playbook.yml command in the ansible-nginx-setup folder

```bash
---
- name: Install and configure Nginx on target node
  hosts: webservers
  become: true

  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Install Nginx
      apt:
        name: nginx
        state: present

    - name: Copy custom index.html to web server
      copy:
        src: files/index.html
        dest: /var/www/html/index.html

    - name: Ensure Nginx is running
      service:
        name: nginx
        state: started
        enabled: yes
```

### ✅ 11. Add HTML File (ansible-nginx-setup/files/index.html)

```bash
<h1>Hello from Ansible</h1>
```

### ✅ 12. Run the Playbook in the ansible-nginx-setup folder

```bash
ansible-playbook -i inventory.ini playbook.yml
```
**Verify Output**

Open your target EC2’s public IP in a browser:

```bash
http://<target_public_ip>
```
✅ You should see your custom HTML page served via Nginx!



**Destroy Infrastructure**

To clean everything up:

```bash
terraform destroy
```

---

## About Me

I'm Shravani — a self-taught DevOps engineer passionate about solving real-world problems through hands-on projects.  
I focus on building scalable infrastructure, automating workflows, and continuously learning to stay ahead in DevOps.
