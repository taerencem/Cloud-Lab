#!/bin/bash
# ============================================================
# AWS IAM Security Audit Script
# Author: Taerence McNeal
# Description:
#   Audits IAM users, roles, MFA status, access keys, and policies.
# ============================================================

REGION="us-west-2"
OUTPUT="../examples/iam-report.csv"

echo "Running IAM Security Audit..."

echo "User,Arn,MFAEnabled,AccessKey1Age,AccessKey2Age,PasswordLastUsed,AttachedPolicies" > $OUTPUT

USERS=$(aws iam list-users --query "Users[*].UserName" --output text)

for USER in $USERS; do
    echo "Auditing user: $USER"

    ARN=$(aws iam get-user --user-name $USER --query "User.Arn" --output text)

    # MFA Status
    MFA=$(aws iam list-mfa-devices --user-name $USER --query "MFADevices" --output text)
    if [ -z "$MFA" ]; then
        MFAEnabled="No"
    else
        MFAEnabled="Yes"
    fi

    # Access Key Age
    KEYS=$(aws iam list-access-keys --user-name $USER --query "AccessKeyMetadata[*].AccessKeyId" --output text)
    KEY1Age=""
    KEY2Age=""

    INDEX=1
    for KEY in $KEYS; do
        CREATED=$(aws iam list-access-keys --user-name $USER --query "AccessKeyMetadata[?AccessKeyId=='$KEY'].CreateDate" --output text)
        AGE=$(( ( $(date +%s) - $(date -d "$CREATED" +%s) ) / 86400 ))

        if [ $INDEX -eq 1 ]; then
            KEY1Age=$AGE
        else
            KEY2Age=$AGE
        fi

        INDEX=$((INDEX+1))
    done

    # Password Last Used
    LASTUSED=$(aws iam get-user --user-name $USER --query "User.PasswordLastUsed" --output text)

    # Attached Policies
    POLICIES=$(aws iam list-attached-user-policies --user-name $USER --query "AttachedPolicies[*].PolicyName" --output text | tr '\t' ';')

    echo "$USER,$ARN,$MFAEnabled,$KEY1Age,$KEY2Age,$LASTUSED,$POLICIES" >> $OUTPUT
done

echo "IAM Security Audit Complete!"
echo "Report saved to: $OUTPUT"
