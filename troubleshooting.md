# Redis Master-Replica Troubleshooting Guide

This guide provides a detailed troubleshooting process for resolving common issues in a Redis master-replica setup, focusing on network connectivity, Redis configuration, and replication problems.

---

## ⚡ 1. **Check Redis Service Status**
Ensure Redis is running on both master and replica nodes:

```bash
sudo systemctl status redis-server
```

- If Redis is not running, start it:
  ```bash
  sudo systemctl start redis-server
  ```
- To restart after configuration changes:
  ```bash
  sudo systemctl restart redis-server
  ```

---

## 🌐 2. **Check Network Connectivity**

### ✅ **Ping the Master Node**
Check if the replica can reach the master:
```bash
ping <MASTER_IP>
```

### 🔌 **Test Redis Port Accessibility (6379)**
```bash
telnet <MASTER_IP> 6379
```
If `telnet` is not installed:
```bash
nc -zv <MASTER_IP> 6379
```

### 📡 **Check Listening Ports with `ss` Command**
The `ss` command shows which ports Redis is listening on:

```bash
ss -tlnp | grep 6379
```

**Expected Output:**
```
LISTEN 0      511        0.0.0.0:6379      0.0.0.0:*
LISTEN 0      511           [::1]:6379        [::]:*
```

If Redis is only listening on `127.0.0.1:6379`, it will not accept external connections.

---

## 📝 3. **Update Redis Configuration**
Edit `/etc/redis/redis.conf` on the master node:

```bash
sudo nano /etc/redis/redis.conf
```

### 🔧 **Key Changes:**
```ini
bind 0.0.0.0
protected-mode no
```

### 🔄 **Restart Redis After Changes:**
```bash
sudo systemctl restart redis-server
```

---

## 🔥 4. **Security Group Configuration**


### ☁️ **Check AWS Security Groups (if using AWS):**
Ensure inbound rules allow TCP traffic on port 6379 from the replica's IP or `0.0.0.0/0` (for testing purposes).

---

## 🔗 5. **Configure Replication**

### 🔄 **Set Up Replication from Replica (VM2):**
```bash
redis-cli replicaof <MASTER_IP> 6379
```

### ❌ **Remove Existing Replication (Reset Connection):**
```bash
redis-cli replicaof no one
```

### 🔄 **Reconnect:**
```bash
redis-cli replicaof <MASTER_IP> 6379
```

---

## 🏃 6. **Verify Replication Status**
Check replication details:

### 🔍 **On Master (VM1):**
```bash
redis-cli INFO replication
```
**Expected Output:**
```
connected_slaves:1
slave0:ip=<Replica_IP>,port=6379,state=online,offset=...,lag=0
```

### 🔍 **On Replica (VM2):**
```bash
redis-cli INFO replication
```
**Expected Output:**
```
master_link_status:up
```

---

## 🏗 7. **Test Data Replication**

### 🔑 **On Master (VM1):**
```bash
redis-cli set testkey "HelloReplica"
```

### 🔄 **On Replica (VM2):**
```bash
redis-cli get testkey
```
**Expected Output:**
```
"HelloReplica"
```

---

## 🛠 8. **Check Redis Logs**
Review logs for any error messages:

```bash
sudo cat /var/log/redis/redis-server.log
```
Look for:
- Authentication errors
- Connection issues
- Timeout warnings

---

## 🎯 **Conclusion**

By following these troubleshooting steps, you should be able to:
- Resolve connectivity issues between Redis master and replica nodes.
- Ensure proper Redis configuration for external connections.
- Set up and verify successful Redis replication.

If issues persist, ensure cloud provider settings (such as AWS Security Groups) and local firewalls are correctly configured. Additionally.

---

💡 **Tip:** For a production environment, ensure you configure proper authentication and IP restrictions to secure your Redis instances.

