● Oracle Cloud Migration Setup Guide

  As a migration expert, here's the complete step-by-step process for setting up a migration project after prerequisites are deployed.

  Phase 1: OCI Console - Migration Project Setup

  Step 1: Create Migration Project

  1. Navigate to: Migration & Disaster Recovery → Cloud Migrations
  2. Click: Create Migration
  3. Configure:
    - Name: AWS-to-OCI-Migration-Project
    - Compartment: Select your migration compartment
    - Description: Production AWS workload migration to OCI

  Step 2: Configure Source Environment

  1. In Migration Project → Source Environments
  2. Click: Add Source Environment
  3. Select: Amazon Web Services (AWS)
  4. Configure:
    - Environment Name: Production-AWS-Environment
    - AWS Account ID: Your 12-digit AWS account
    - AWS Region: Your primary AWS region (e.g., us-east-1)
    - Discovery Schedule: Daily at 2 AM UTC

  Step 3: Setup Asset Source (Cloud Bridge)

  1. Navigate to: Migration & Disaster Recovery → Cloud Bridge
  2. Click: Create Asset Source
  3. Configure:
    - Type: Amazon Web Services
    - Name: AWS-Production-Assets
    - Compartment: Your migration compartment
    - Inventory: Create new or select existing
    - Discovery Schedule: Every 6 hours

  Step 4: Configure Target Environment

  1. Back to Migration Project → Target Environments
  2. Click: Add Target Environment
  3. Configure:
    - Name: OCI-Production-Target
    - Compartment: Target compartment for migrated resources
    - VCN: Select or create target VCN
    - Subnet: Select appropriate subnet
    - Availability Domain: Choose target AD

  ---
  Phase 2: AWS Console - Required Setup

  Step 1: Create Cross-Account IAM Role

  # Role Name: OracleCloudBridgeRole
  # Trust Policy:
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::644324601891:root"
        },
        "Action": "sts:AssumeRole",
        "Condition": {
          "StringEquals": {
            "sts:ExternalId": "YOUR_EXTERNAL_ID"
          }
        }
      }
    ]
  }

  Step 2: Create Discovery IAM Policy

  Policy Name: OracleCloudBridgeDiscoveryPolicy
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:DescribeImages",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeRegions",
          "ce:GetCostAndUsageWithResources",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ],
        "Resource": "*"
      }
    ]
  }

  Step 3: Create Replication IAM Policy

  Policy Name: OracleCloudBridgeReplicationPolicy
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:CreateSnapshot",
          "ec2:CreateSnapshots",
          "ec2:DeleteSnapshot",
          "ec2:DescribeSnapshots",
          "ec2:DescribeSnapshotAttribute",
          "ec2:ModifySnapshotAttribute",
          "ec2:CreateTags",
          "ec2:DescribeTags",
          "ebs:ListChangedBlocks",
          "ebs:ListSnapshotBlocks",
          "ebs:GetSnapshotBlock",
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        "Resource": "*"
      }
    ]
  }

  Step 4: Attach Policies to Role

  1. Navigate to: IAM → Roles → OracleCloudBridgeRole
  2. Attach Policies:
    - OracleCloudBridgeDiscoveryPolicy
    - OracleCloudBridgeReplicationPolicy

  Step 5: Create S3 Staging Bucket (Optional)

  # Bucket Name: oracle-migration-staging-{account-id}-{region}
  # Region: Same as your EC2 instances
  # Encryption: AES-256

  ---
  Phase 3: OCI Console - Connect AWS Environment

  Step 1: Configure AWS Credentials in Cloud Bridge

  1. Navigate to: Cloud Bridge → Asset Sources → Your AWS asset source
  2. Click: Edit
  3. AWS Credentials:
    - Authentication Type: Cross-account IAM Role
    - Role ARN: arn:aws:iam::YOUR_ACCOUNT:role/OracleCloudBridgeRole
    - External ID: Generate and use in AWS role trust policy
    - AWS Region: Your primary region

  Step 2: Test Discovery

  1. In Asset Source → Discovery
  2. Click: Run Discovery Now
  3. Monitor: Discovery progress and results
  4. Verify: Assets appear in inventory

  Step 3: Create Migration Plan

  1. Back to Migration Project → Migration Plans
  2. Click: Create Migration Plan
  3. Configure:
    - Name: Production-Workload-Wave-1
    - Source: Select discovered AWS assets
    - Target: Configure OCI shapes and networking
    - Migration Strategy: Lift and shift or Transform

  ---
  Phase 4: Validation Checklist

  OCI Side Validation

  - Migration project created successfully
  - Asset source shows "Active" status
  - Discovery completed with assets found
  - Target environment configured
  - Migration plan created

  AWS Side Validation

  - IAM role created with correct trust policy
  - Discovery policy attached and tested
  - Replication policy attached
  - Cross-account access working
  - S3 bucket accessible (if using)

  Network Connectivity

  - AWS VPC peering/VPN to OCI (if needed)
  - Security groups allow Oracle service access
  - OCI NSGs configured for migration traffic