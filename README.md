# Redis Setup on AWS using Terraform

## Overview
This project provisions a Redis environment on AWS using Terraform. It creates three Ubuntu 22.04 LTS instances:

- **VM1**: Redis Master Node
- **VM2**: Redis Replica (Slave) Node
- **VM3**: Redis Client Node

The Redis Master-Replica replication is configured, allowing the client to read/write data and verify replication.

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

- Terraform Installed ([Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli))
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

2. **Change Redis User Shell and Password**
   ```bash
   sudo usermod -s /bin/bash redis
   sudo passwd redis
   ```

3. **Configure Redis for Replication**
   - Edit `/etc/redis/redis.conf`:
     ```bash
     sudo nano /etc/redis/redis.conf
     ```
     - Change:
       ```
       bind 0.0.0.0
       protected-mode no
       ```
   - Restart Redis:
     ```bash
     sudo systemctl restart redis-server
     ```

4. **Set Up Replica on VM2**
   ```bash
   redis-cli replicaof <VM1_MASTER_IP> 6379
   ```

---

## Verification Steps

1. **Check Replication Status**
   On **Master (VM1)**:
   ```bash
   redis-cli -h <MASTER_IP> -p 6379 INFO replication
   ```

   On **Replica (VM2)**:
   ```bash
   redis-cli -h <REPLICA_IP> -p 6379 INFO replication
   ```

2. **Test Data Replication**
   - Set a key on Master:
     ```bash
     redis-cli -h <MASTER_IP> -p 6379 set interview redis
     ```
   - Get the key from Replica:
     ```bash
     redis-cli -h <REPLICA_IP> -p 6379 get interview
     ```

---

## Outputs

- **Redis VM IPs**: Public IP addresses of the Redis instances.
- **SSH Commands**: Ready-to-use SSH commands to access each VM.

---

## Cleanup

To tear down the infrastructure:
```bash
terraform destroy -auto-approve
```

---

## Notes
- Ensure that `redis.conf` changes are applied before setting up replication.
- For production, consider private subnets, stronger security rules, and Redis authentication.

---

**End of README**

