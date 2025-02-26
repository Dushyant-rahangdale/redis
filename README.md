# Redis Setup on AWS using Terraform

## Overview
This project provisions a Redis environment on AWS using Terraform. It creates three Ubuntu 22.04 LTS instances:

- **VM1**: Redis Master Node
- **VM2**: Redis Replica (Slave) Node
- **VM3**: Redis Client Node

The Redis Master-Replica replication is configured with authentication and data persistence enabled. The client connects securely using private IPs.

## Architecture Diagram

![Redis Architecture](https://github.com/Dushyant-rahangdale/redis/blob/6825f123d80718442f18809c76ef9ebf2fbb1dd7/Architecture%20Diagram.png)

---

## Infrastructure Details

### AWS Resources:
- VPC (10.0.0.0/16)
- Subnet (10.0.1.0/24)
- Internet Gateway
- Route Table & Association
- Security Group (Allows SSH on port 22 and Redis on port 6379)
- EC2 Instances (t3.small, Ubuntu 22.04 LTS)
- SSH Key Pair

### Ports:
- **22**: SSH
- **6379**: Redis

---

## Prerequisites

- Terraform Installed
- AWS CLI Configured with appropriate credentials
- SSH Key Pair (Ensure the path in `aws_key_pair` matches your environment)

---

## Deployment Steps

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Validate Configuration**
   ```bash
   terraform validate
   ```

3. **Apply Terraform Plan**
   ```bash
   terraform apply -auto-approve
   ```

4. **Retrieve Public IPs and SSH Commands**
   Terraform outputs the public IPs and SSH commands after deployment.

---

## Post-Deployment Configuration

1. **SSH into the Instances**
   ```bash
   ssh -i /path/to/id_rsa ubuntu@<PUBLIC_IP>
   ```

2. **Configure Redis for Replication and Security**
   - Edit `/etc/redis/redis.conf`:
     ```bash
     sudo nano /etc/redis/redis.conf
     ```
     - Change or add:
       ```
       bind 0.0.0.0
       protected-mode yes
       requirepass <REDIS_PASSWORD>
       masterauth <REDIS_PASSWORD> (On Replica)
       appendonly yes
       ```
   - Restart Redis:
     ```bash
     sudo systemctl restart redis-server
     ```

3. **Set Up Replica on VM2 Using Private IP**
   ```bash
   redis-cli -h <VM2_PRIVATE_IP> -p 6379 -a <REDIS_PASSWORD> replicaof <VM1_PRIVATE_IP> 6379
   ```

---

## Verification Steps

1. **Check Replication Status**
   On **Master (VM1)**:
   ```bash
   redis-cli -h <MASTER_PRIVATE_IP> -p 6379 -a <REDIS_PASSWORD> INFO replication
   ```

   On **Replica (VM2)**:
   ```bash
   redis-cli -h <REPLICA_PRIVATE_IP> -p 6379 -a <REDIS_PASSWORD> INFO replication
   ```

2. **Test Data Replication**
   - Set a key on Master:
     ```bash
     redis-cli -h <MASTER_PRIVATE_IP> -p 6379 -a <REDIS_PASSWORD> set setup redis
     ```
   - Get the key from Replica:
     ```bash
     redis-cli -h <REPLICA_PRIVATE_IP> -p 6379 -a <REDIS_PASSWORD> get setup
     ```

---

## Outputs

- **Redis VM IPs**: Public IP addresses of the Redis instances.
- **SSH Commands**: Ready-to-use SSH commands to access each VM.

---

## Client Connection

To connect from the client node securely using private IP:
```bash
redis-cli -h <MASTER_PRIVATE_IP> -p 6379 -a <REDIS_PASSWORD>
```

---

## Cleanup

To tear down the infrastructure:
```bash
terraform destroy -auto-approve
```

---

## Notes
- Redis authentication is enabled using `requirepass` and `masterauth`.
- Append-only file (AOF) is enabled for data persistence.
- Private IPs are used for inter-server communication for enhanced security.

---

**End of README**


