# Scalable Web Application with Terraform and GitHub Actions

This repository contains a production-ready infrastructure-as-code setup to deploy a **scalable and cost-optimized web application** using AWS services. It provisions a fully functional environment with:

- **Highly Available VPC** setup with public and private subnets
- **EC2 Auto Scaling Group (ASG)** behind an **Application Load Balancer (ALB)**
- **Multi-AZ RDS MySQL** database for data persistence
- **CloudWatch** monitoring with alarms
- **IAM roles and policies** for secure access
- **GitHub Actions CI/CD** pipeline for automated deployment

---

## Stack Components

###  VPC (`vpc.tf`)
- Creates VPC with public/private subnets across availability zones
- Adds routing, NAT Gateway, Internet Gateway

###  EC2 ASG (`ec2_asg.tf`)
- Launch template for EC2 instances
- Auto Scaling Group based on CPU utilization

###  ALB (`alb.tf`)
- Application Load Balancer in public subnets
- Listener and Target Group
- Attaches ALB to ASG using `aws_autoscaling_attachment`

###  RDS (`rds.tf`)
- Multi-AZ MySQL RDS instance
- Subnet group and parameter group for DB

###  IAM (`iam.tf`)
- IAM Role for EC2 instance to access CloudWatch
- Policy to allow logging and SSM access

###  Monitoring (`cloudwatch.tf`)
- CloudWatch alarm for CPU threshold breach

###  GitHub Actions CI/CD (`.github/workflows/deploy.yml`)
- Deploys on `main` branch push
- Configures AWS credentials
- Archives and optionally uploads app to S3
- Triggers EC2 update via AWS SSM

---

##  Adding GitHub Secrets

To authenticate your GitHub Actions pipeline with AWS:

1. Navigate to your GitHub repo → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

---

##  Getting Started

1. Clone this repository
2. Customize your application source code and instance settings
3. Run the following to deploy:

```bash
terraform init
terraform plan
terraform apply
```
