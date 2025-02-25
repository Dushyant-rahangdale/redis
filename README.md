# redis
his project provisions a Redis environment on AWS using Terraform. It creates three Ubuntu 22.04 LTS instances:  VM1: Redis Master Node  VM2: Redis Replica (Slave) Node  VM3: Redis Client Node  The Redis Master-Replica replication is configured, allowing the client to read/write data and verify replication.
