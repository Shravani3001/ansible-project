# Ansible + Terraform Project: Automated Nginx Deployment on AWS

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

```
project-folder/
├── main.tf
├── variables.tf
├── outputs.tf
├── ansible/
│ ├── inventory.ini
│ ├── playbook.yml
│ └── files/
│ └── index.html
└── README.md
```

### Project Overview:

This project demonstrates how to automate software installation and configuration on remote EC2 servers using Ansible, just like DevOps engineers do in real-world infrastructure automation tasks.

We provision two EC2 instances using Terraform:

Ansible Controller (Public Instance):
This server has Ansible installed and acts as the control node.
It connects to other servers via SSH and executes automation tasks.

Target Node (Public Instance):
This is the remote machine where software is installed automatically using Ansible (in our case, Apache Web Server).

### How it works together:

You write a Playbook (YAML file) on the controller instance that defines:

Which hosts to connect to (via inventory)

What tasks to perform (e.g., install Apache, enable and start the service)

The controller SSHs into the target node using a private key and runs the playbook.

Once executed, the Apache server gets installed, and you can test it in your browser using the target node’s public IP.

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
This generates monitoring-key and monitoring-key.pub

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
On controller: Now SSH into ansible-controller instance and run the following command 

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

### ✅ 9. Create Ansible Inventory File (inventory.ini) using nano inventory.ini command 
```bash
[webservers]
target ansible_host=<target_private_ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/ansible-key
```
### ✅ 10. Create Ansible Playbook (playbook.yml) using nano playbook.yml command 
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

### ✅ 11. Add HTML File (files/index.html)
```bash
<h1>Hello from Ansible</h1>
```

### ✅ 12. Run the Playbook
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

## Author

**Shravani K**  
Aspiring DevOps Learner  
LinkedIn: www.linkedin.com/in/shravani-k-25953828a