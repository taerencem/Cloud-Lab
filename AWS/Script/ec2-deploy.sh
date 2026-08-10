#!/bin/bash
# ============================================================
# AWS EC2 Deployment Script
# Author: Taerence McNeal
# Description:
#   Deploys an EC2 instance, security group, IAM role, and key pair.
# ============================================================

# --- Variables ---
INSTANCE_NAME="LabEC2"
REGION="us-west-2"
AMI_ID="ami-0c02fb55956c7d316"   # Amazon Linux 2
INSTANCE_TYPE="t2.micro"
KEY_NAME="LabEC2-Key"
SEC_GROUP="LabEC2-SG"
IAM_ROLE="LabEC2-Role"

echo "Deploying EC2 instance in $REGION..."

# --- Create Key Pair ---
echo "Creating key pair..."
aws ec2 create-key-pair \
    --region $REGION \
    --key-name $KEY_NAME \
    --query "KeyMaterial" \
    --output text > ${KEY_NAME}.pem

chmod 400 ${KEY_NAME}.pem

# --- Create Security Group ---
echo "Creating security group..."
aws ec2 create-security-group \
    --group-name $SEC_GROUP \
    --description "Security group for EC2 lab" \
    --region $REGION

# Allow SSH
aws ec2 authorize-security-group-ingress \
    --group-name $SEC_GROUP \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 \
    --region $REGION

# --- Create IAM Role ---
echo "Creating IAM role..."
aws iam create-role \
    --role-name $IAM_ROLE \
    --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy \
    --role-name $IAM_ROLE \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess

# --- Launch EC2 Instance ---
echo "Launching EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-groups $SEC_GROUP \
    --region $REGION \
    --query "Instances[0].InstanceId" \
    --output text)

echo "Instance launched: $INSTANCE_ID"

# --- Tag Instance ---
aws ec2 create-tags \
    --resources $INSTANCE_ID \
    --tags Key=Name,Value=$INSTANCE_NAME Key=Owner,Value="Taerence" \
    --region $REGION

echo "EC2 Deployment Complete!"
