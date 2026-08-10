#!/bin/bash
# ============================================================
# AWS EC2 Snapshot Backup Script
# Author: Taerence McNeal
# ============================================================

REGION="us-west-2"
DATE=$(date +%Y-%m-%d)

echo "Starting EC2 Snapshot Backup..."

INSTANCES=$(aws ec2 describe-instances \
    --query "Reservations[*].Instances[*].InstanceId" \
    --output text)

for INSTANCE in $INSTANCES; do
    echo "Creating snapshot for $INSTANCE"

    SNAPSHOT_ID=$(aws ec2 create-snapshot \
        --region $REGION \
        --description "Backup-$INSTANCE-$DATE" \
        --query "SnapshotId" \
        --output text)

    aws ec2 create-tags \
        --resources $SNAPSHOT_ID \
        --tags Key=Name,Value="Backup-$INSTANCE" Key=Date,Value="$DATE"

    echo "Snapshot created: $SNAPSHOT_ID"
done

echo "EC2 Snapshot Backup Complete!"
