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
- ✅ **Generate SSH Key Pair**
  ➡️ Run:
  ```bash
  ssh-keygen -t rsa -b 4096 -f monitoring-key
  ``` 

➡️ Run:
```bash
terraform init
terraform apply
2️⃣ SSH into Ansible Controller & Install Ansible
bash
Copy
Edit
ssh -i ./ansible-key ubuntu@<controller_public_ip>
Install Ansible:

bash
Copy
Edit
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
3️⃣ Copy SSH Private Key to Controller (for internal SSH)
From your local machine: Run the following command in your project folder (ansible-project folder)

bash
Copy
Edit
scp -i ansible-key ansible-key ubuntu@<controller_public_ip>:/home/ubuntu/
On controller: Now SSH into ansible-controller instance and run the following command 

bash
Copy
Edit
chmod 400 ansible-key
4️⃣ Test SSH from Controller → Target Node
bash
Copy
Edit
ssh -i ansible-key ubuntu@<target_private_ip>
✅ If successful, you're ready for Ansible.

5️⃣ Setup Ansible Project Structure
bash
Copy
Edit
mkdir ansible-nginx-setup
cd ansible-nginx-setup
touch inventory.ini playbook.yml
mkdir files
6️⃣ Create Ansible Inventory File (inventory.ini) using nano inventory.ini command 
ini
Copy
Edit
[webservers]
target ansible_host=<target_private_ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/ansible-key
7️⃣ Create Ansible Playbook (playbook.yml) using nano playbook.yml command 
yaml
Copy
Edit
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
8️⃣ Add HTML File (files/index.html)
html
Copy
Edit
<h1>Hello from Ansible</h1>
9️⃣ Run the Playbook
bash
Copy
Edit
ansible-playbook -i inventory.ini playbook.yml
Verify Output
Open your target EC2’s public IP in a browser:

cpp
Copy
Edit
http://<target_public_ip>
✅ You should see your custom HTML page served via Nginx!

Destroy Infrastructure
To clean everything up:

bash
Copy
Edit
terraform destroy

---

## Author

**Shravani K**  
Aspiring DevOps Learner  
LinkedIn: www.linkedin.com/in/shravani-k-25953828a
