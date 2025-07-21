# Automated Nginx Deployment on AWS using Ansible + Terraform

## Project Overview

This project demonstrates how to provision infrastructure on AWS using **Terraform** and configure a web server using **Ansible**, just like a real-world DevOps setup. It deploys two EC2 instances:

- **Ansible Controller EC2 (Ubuntu)**: executes Ansible playbooks.
- **Target EC2 (Ubuntu)**: receives automated setup: Nginx installed and a custom HTML page served.

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

- **✅ Infrastructure as Code with Terraform**
Provision VPC, Subnets, EC2 Instances, Security Groups using Terraform

- **✅ Key-Based SSH Access**
Automate secure communication between controller and target via SSH key pair

- **✅ Modular & Organized Project Structure**
Separates Terraform and Ansible logic for better maintainability

- **✅ Custom HTML Page Deployment**
Automatically deploy a user-defined `index.html` via Ansible

- **✅ Easy Teardown**
Use `terraform destroy` to tear down the full stack in one step
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

<img width="1759" height="959" alt="ansible-nginx-output" src="https://github.com/user-attachments/assets/ed6bb55b-7fa1-4507-9d8a-8e56349c1ee1" />

---

**Destroy Infrastructure**

To clean everything up:

```bash
terraform destroy
```

---

## About Me

I'm **Shravani**, a self-taught and project-driven DevOps engineer passionate about building scalable infrastructure and automating complex workflows.

I love solving real-world problems with tools like Terraform, Ansible, Docker, Jenkins, and AWS — and I’m always learning something new to sharpen my edge in DevOps.

**Connect with me:**

[LinkedIn](https://www.linkedin.com/in/shravani3001) 

[GitHub](https://github.com/Shravani3001)
