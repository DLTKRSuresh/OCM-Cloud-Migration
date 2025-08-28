 AWS IAM Setup for Oracle Cloud Migration - Complete Guide

  Overview of Required IAM Components

  You need to create:
  1. 2 IAM Policies (using your JSON files)
  2. 1 IAM User (for Oracle service authentication)
  3. 1 Access Key Pair (for programmatic access)

  ---
  Step-by-Step AWS Console Instructions

  Step 1: Create Discovery Policy

  1.1 Navigate to IAM Policies

  AWS Console → IAM → Policies → Create Policy

  1.2 Create Discovery Policy

  1. Click: Create policy
  2. Click: JSON tab
  3. Clear existing content and paste exactly:
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "ec2:DescribeInstances",
                  "ec2:DescribeInstanceTypes",
                  "ec2:DescribeVolumes",
                  "ce:GetCostAndUsageWithResources",
                  "cloudwatch:GetMetricData",
                  "cloudwatch:GetMetricStatistics"
              ],
              "Resource": "*"
          }
      ]
  }

  4. Click: Next: Tags (skip tags)
  5. Click: Next: Review
  6. Policy Details:
    - Name: OracleCloudMigration-DiscoveryPolicy
    - Description: Policy for Oracle Cloud Migration service to discover EC2 resources and collect metrics
  7. Click: Create policy

  Step 2: Create Replication Policy

  2.1 Create Replication Policy

  1. Click: Create policy (again)
  2. Click: JSON tab
  3. Clear existing content and paste exactly:
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "ebs:ListChangedBlocks",
                  "ebs:ListSnapshotBlocks",
                  "ebs:GetSnapshotBlock",
                  "ec2:CreateSnapshots",
                  "ec2:CreateTags",
                  "ec2:DescribeInstances",
                  "ec2:DescribeVolumes",
                  "ec2:DescribeSnapshots"
              ],
              "Resource": "*"
          }
      ]
  }

  4. Click: Next: Tags (skip tags)
  5. Click: Next: Review
  6. Policy Details:
    - Name: OracleCloudMigration-ReplicationPolicy
    - Description: Policy for Oracle Cloud Migration service to replicate EBS volumes and create snapshots
  7. Click: Create policy

  ---
  Step 3: Create IAM User

  3.1 Navigate to IAM Users

  AWS Console → IAM → Users → Add users

  3.2 Create Migration User

  1. Click: Add users
  2. User Details:
    - User name: oracle-cloud-migration-user
    - Access type: ✅ Programmatic access ONLY
    - ❌ Do NOT check "AWS Management Console access"
  3. Click: Next: Permissions

  3.3 Attach Policies to User

  1. Select: Attach existing policies directly
  2. Search and Select:
    - ✅ OracleCloudMigration-DiscoveryPolicy
    - ✅ OracleCloudMigration-ReplicationPolicy
  3. Click: Next: Tags (skip tags)
  4. Click: Next: Review
  5. Review Configuration:
  User: oracle-cloud-migration-user
  Policies: 2 policies attached
  Access: Programmatic access only
  6. Click: Create user

  ---
  Step 4: Generate Access Keys

  4.1 Save Credentials (CRITICAL)

  ⚠️ IMPORTANT: This is your ONLY chance to see the Secret Access Key

  1. After user creation, you'll see:
  Access key ID: AKIA...
  Secret access key: [HIDDEN - Click "Show" to reveal]
  2. Click: Show next to Secret access key
  3. IMMEDIATELY COPY AND SAVE:
  Access Key ID: AKIA...
  Secret Access Key: [Long string - copy this securely]
  4. Click: Download .csv (backup option)
  5. Store credentials securely - you'll need these for OCI setup

  4.2 Security Best Practices

  - Never share these credentials
  - Store in secure password manager
  - Don't commit to version control
  - Use temporary credentials where possible

  ---
  Step 5: Verify IAM Setup

  5.1 Validate User Configuration

  1. Navigate to: IAM → Users → oracle-cloud-migration-user
  2. Verify:
    - Permissions tab: Shows 2 attached policies
    - Security credentials tab: Shows 1 access key (Active)
    - Access type: Programmatic access only

  5.2 Test Permissions (Optional)

  # Using AWS CLI (if available)
  aws sts get-caller-identity
  aws ec2 describe-instances --region us-east-1 --max-items 1
  aws ec2 describe-volumes --region us-east-1 --max-items 1

  ---
  Step 6: Advanced Configuration (Optional)

  6.1 Restrict Access by Tag (If Needed)

  If you want to limit discovery to specific instances, modify the Discovery Policy:

  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "ec2:DescribeInstances",
                  "ec2:DescribeInstanceTypes",
                  "ec2:DescribeVolumes"
              ],
              "Resource": "*",
              "Condition": {
                  "StringEquals": {
                      "ec2:ResourceTag/MigrationGroup": "Wave1"
                  }
              }
          },
          {
              "Effect": "Allow",
              "Action": [
                  "ce:GetCostAndUsageWithResources",
                  "cloudwatch:GetMetricData",
                  "cloudwatch:GetMetricStatistics"
              ],
              "Resource": "*"
          }
      ]
  }

  6.2 Cross-Account Role (Alternative to User)

  For Production/Enterprise Setup, create a cross-account role:

  Create Role Instead of User:

  1. Navigate: IAM → Roles → Create role
  2. Select: Another AWS account
  3. Account ID: 644324601891 (Oracle's service account)
  4. External ID: [Unique string provided by Oracle]
  5. Attach both policies created above
  6. Role Name: OracleCloudMigrationRole
  7. Note Role ARN: arn:aws:iam::YOUR_ACCOUNT:role/OracleCloudMigrationRole

  ---
  Step 7: Regional Considerations

  7.1 Multi-Region Setup

  If you have resources in multiple AWS regions:

  1. IAM policies are global - same user works for all regions
  2. Specify regions in OCI Asset Source configuration
  3. Consider regional compliance requirements

  7.2 Resource Tagging Strategy

  For better organization:

  # Tag your test instances
  aws ec2 create-tags \
    --resources i-1234567890abcdef0 i-0987654321fedcba0 \
    --tags Key=MigrationGroup,Value=Wave1 \
           Key=Environment,Value=Test \
           Key=Owner,Value=MigrationTeam

  ---
  Summary: What You'll Need for OCI Setup

  After completing AWS IAM setup, you'll have:

  AWS Credentials for OCI:
    Access Key ID: AKIA...
    Secret Access Key: [Your secret key]
    Account ID: [Your 12-digit AWS account]
    Primary Region: us-east-1 (or your region)

  IAM Resources Created:
    - OracleCloudMigration-DiscoveryPolicy
    - OracleCloudMigration-ReplicationPolicy
    - oracle-cloud-migration-user (with both policies attached)

  Next Step: Use these credentials when configuring the Asset Source in OCI Console as shown in the migration demo.

  ⚠️ Security Reminder: These credentials provide significant access to your AWS environment. Monitor their usage and rotate them regularly according
  to your security policies.