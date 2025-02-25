provider "aws" {
  region     = "ap-south-1"
}


resource "aws_vpc" "redis_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "redis_subnet" {
  vpc_id                  = aws_vpc.redis_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "redis_igw" {
  vpc_id = aws_vpc.redis_vpc.id
}

resource "aws_route_table" "redis_route_table" {
  vpc_id = aws_vpc.redis_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.redis_igw.id
  }
}

resource "aws_route_table_association" "redis_rta" {
  subnet_id      = aws_subnet.redis_subnet.id
  route_table_id = aws_route_table.redis_route_table.id
}

resource "aws_security_group" "redis_sg" {
  name        = "redis_sg"
  description = "Allow SSH and Redis ports"
  vpc_id      = aws_vpc.redis_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "redis_key" {
  key_name   = "redis_key"
  public_key = file("/Users/drahangdale/Desktop/redis/id_rsa.pub")
}

resource "aws_instance" "redis_vm" {
  count         = 3
  ami           = "ami-00bb6a80f01f03502"  # Ubuntu 22.04 LTS (update if needed)
  instance_type = "t3.small"
  subnet_id     = aws_subnet.redis_subnet.id
  vpc_security_group_ids = [aws_security_group.redis_sg.id]
  key_name                 = aws_key_pair.redis_key.key_name

  tags = {
    Name = "redis-vm-${count.index + 1}"
  }

  provisioner "remote-exec" {
    inline = [
    "sudo apt-get update",
    "sudo apt-get install -y lsb-release curl gpg",
    "curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg",
    "sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg",
    "echo \"deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/redis.list",
    "sudo apt-get update",
    "sudo apt-get install -y redis",
    "sudo systemctl enable redis-server",
    "sudo systemctl start redis-server",
    "redis-server --version"
  ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/Users/drahangdale/Desktop/redis/id_rsa")
      host        = self.public_ip
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "redis_vm_ips" {
  value       = aws_instance.redis_vm[*].public_ip
  description = "Public IPs of the Redis VMs"
}

output "ssh_connect" {
  value       = [for instance in aws_instance.redis_vm : "ssh -i /Users/drahangdale/Desktop/redis/id_rsa ubuntu@${instance.public_ip}"]
  description = "SSH commands to connect to the Redis VMs"
}