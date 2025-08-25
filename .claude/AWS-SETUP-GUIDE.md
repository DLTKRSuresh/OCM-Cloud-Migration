# AWS IAM Setup for Oracle Cloud Migrations

## 📋 What You Need

### **AWS Account Information**
- **AWS Account ID** (12-digit number, e.g., 123456789012)
- **AWS Regions** where your resources are located
- **AWS Console Access** with IAM admin permissions

## 🛠️ AWS Setup Process

### **Method 1: IAM User (Recommended for Testing)**

#### Step 1: Create IAM User
1. Login to **AWS Console → IAM → Users**
2. Click **"Add Users"**
3. User name: `oci-migration-user`
4. Access type: **"Programmatic access"** ✓
5. Click **"Next: Permissions"**

#### Step 2: Create IAM Policies
1. Go to **IAM → Policies → Create Policy**
2. Click **"JSON"** tab

**Create Discovery Policy:**
```json
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
```
- Policy name: `OCIMigrationDiscoveryPolicy`

**Create Replication Policy:**
```json
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
```
- Policy name: `OCIMigrationReplicationPolicy`

#### Step 3: Attach Policies to User
1. Go to **IAM → Users → oci-migration-user**
2. Click **"Attach policies directly"**
3. Search and attach:
   - `OCIMigrationDiscoveryPolicy`
   - `OCIMigrationReplicationPolicy`

#### Step 4: Generate Access Keys
1. User **oci-migration-user** → **"Security credentials"** tab
2. Click **"Create access key"**
3. Choose **"Application running outside AWS"**
4. **Save the credentials securely:**
   - **Access Key ID**: AKIA...
   - **Secret Access Key**: (keep secret)

### **Method 2: Cross-Account Role (Production)**

#### Step 1: Create IAM Role
1. **IAM → Roles → Create Role**
2. Trusted entity: **"AWS account"**
3. Account ID: `[Oracle Service Account]` (provided by Oracle)
4. Require external ID: **Yes**
5. External ID: `[Provided by Oracle]`

#### Step 2: Attach Policies
- Attach the same policies created above

#### Step 3: Note Role ARN
- Copy the Role ARN: `arn:aws:iam::123456789012:role/OCIMigrationRole`

## 🔗 Connect to Oracle Cloud Migrations

### **In OCI Console:**

1. **Go to Migration Service**
   ```
   Migration & Disaster Recovery → Cloud Migrations → Asset Sources
   ```

2. **Create Asset Source**
   - Click **"Create Asset Source"**
   - Type: **AWS**
   - Name: `aws-production-environment`

3. **Configure AWS Credentials**
   
   **For IAM User:**
   - Authentication: **AWS IAM User**
   - Access Key ID: `AKIA...`
   - Secret Access Key: `[your secret]`
   - AWS Region: `us-east-1` (or your region)

   **For Cross-Account Role:**
   - Authentication: **AWS Cross-Account Role**
   - Role ARN: `arn:aws:iam::123456789012:role/OCIMigrationRole`
   - External ID: `[provided by Oracle]`
   - AWS Region: `us-east-1`

4. **Test Connection**
   - Click **"Test Connection"**
   - Should show ✅ **"Connection Successful"**

## ✅ Verification Steps

### **Test Discovery**
1. **Cloud Migrations → Discovery Schedules**
2. **Create Discovery Schedule**
3. Asset Source: `aws-production-environment`
4. Schedule: **"Run once"**
5. **Run Discovery**

### **Verify Results**
1. **Cloud Migrations → Inventory**
2. Should show your AWS resources:
   - EC2 Instances
   - EBS Volumes
   - Cost information

## 📊 What Gets Discovered

**Resources:**
- ✅ EC2 Instances (all states)
- ✅ EBS Volumes (attached/unattached)
- ✅ Instance Types and sizing
- ✅ Cost and usage data
- ✅ Performance metrics

**Regions Supported:**
- All AWS commercial regions
- Government regions (with appropriate access)

## 🔒 Security Best Practices

1. **Use Least Privilege**: Only grant required permissions
2. **Rotate Keys**: Regularly rotate access keys
3. **Monitor Access**: Enable CloudTrail logging
4. **Use Roles**: Prefer IAM roles over users for production
5. **External ID**: Always use External ID for cross-account roles

## 📞 Support

**Issues with AWS Setup:**
- Check IAM policies are attached correctly
- Verify AWS account ID is correct
- Ensure regions match your resources

**Issues with OCI Connection:**
- Verify credentials in OCI vault
- Check Oracle Cloud Bridge service policies
- Test network connectivity

---

**🎉 Ready to Migrate!** Once connected, you can begin discovering and planning your AWS → OCI migration.