```bash
#!/bin/bash
# ============================================================
# AWS CloudWatch Monitoring Script
# Author: Taerence McNeal
# ============================================================

REGION="us-west-2"
INSTANCE_ID=$1

echo "Fetching CloudWatch Metrics for $INSTANCE_ID..."

aws cloudwatch get-metric-statistics \
    --metric-name CPUUtilization \
    --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%SZ) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
    --period 300 \
    --namespace AWS/EC2 \
    --statistics Average \
    --dimensions Name=InstanceId,Value=$INSTANCE_ID \
    --region $REGION \
    --output json > ../examples/cloudwatch-output.json

echo "Metrics saved to cloudwatch-output.json"
