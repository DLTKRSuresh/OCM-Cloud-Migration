# Oracle Cloud Migrations Prerequisites - Deployment Guide

## Free-Form Tags Analysis ✅

**GOOD NEWS:** After thorough analysis of all Terraform files, **NO free-form tags (including "ziporigin") were found**. 

The code uses **only defined tags** within the "CloudMigrations" namespace, which is compliant with tag enforcement policies.

## Prerequisites Checklist

Before deployment, ensure you have:

- [ ] OCI CLI configured with proper credentials
- [ ] Terraform >= 1.0 installed
- [ ] OCI user with sufficient IAM permissions (Identity and Access Management Administrator or similar)
- [ ] Target compartment OCID identified
- [ ] Tenancy OCID available

## Step-by-Step Deployment Process

### Step 1: Configure Authentication
Ensure your OCI CLI is configured or you have API key authentication set up:
```bash
# Test OCI CLI authentication
oci iam compartment list --compartment-id <your-tenancy-ocid>
```

### Step 2: Prepare Variables
1. Copy the example variables file:
   ```bash
   cd C:\Users\rsuresh\ocm-prerequisites
   copy terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your actual values:
   - **tenancy_ocid**: Your OCI tenancy OCID
   - **compartment_ocid**: Compartment where migration resources will be created
   - **migration_from_aws**: Set to `true` for AWS migration
   - **migration_from_vmware**: Set to `true` for VMware migration

### Step 3: Initialize Terraform
```bash
cd C:\Users\rsuresh\ocm-prerequisites
terraform init
```

### Step 4: Plan the Deployment
```bash
terraform plan
```
Review the planned resources carefully. Expected resources:
- Tag namespace and tag definitions (CloudMigrations)
- Identity compartments (Migration, MigrationSecrets)
- Dynamic groups for various services
- IAM policies for migration services
- KMS vault and key for secrets
- Object storage bucket for replication

### Step 5: Deploy Resources
```bash
terraform apply
```
When prompted, type `yes` to confirm deployment.

### Step 6: Verify Deployment
After successful deployment, verify key resources:
```bash
# Check compartments
oci iam compartment list --compartment-id <your-compartment-ocid>

# Check tag namespace
oci iam tag-namespace list --compartment-id <your-tenancy-ocid>

# Check dynamic groups
oci iam dynamic-group list --compartment-id <your-tenancy-ocid>
```

## Resource Creation Sequence

The Terraform code creates resources in this dependency order:

1. **Tag Namespace and Tags** (if enabled)
   - CloudMigrations namespace
   - Version, ResourceLevel, VMware/AWS use case tags

2. **Identity Compartments**
   - Migration compartment
   - MigrationSecrets compartment

3. **Dynamic Groups**
   - Migration Dynamic Group
   - Remote Agent Dynamic Groups (AWS/VMware)
   - Discovery Dynamic Group (AWS)
   - Hydration Agent Dynamic Groups

4. **IAM Policies**
   - Tenancy-level policies for OCM/OCB services
   - Compartment-level policies for dynamic groups
   - Optional logging and administrator policies

5. **KMS Resources**
   - KMS Vault for secrets
   - KMS Key for encryption

6. **Object Storage**
   - Replication bucket for migration snapshots

## Configuration Options

### Migration Sources
- **AWS Migration**: Set `migration_from_aws = true`
- **VMware Migration**: Set `migration_from_vmware = true`
- **Both**: Set both to `true`

### Optional Features
- **Migration Groups**: Set `migration_groups = true` for admin/operator groups
- **Remote Agent Logging**: Set `remote_agent_logging = true` for log policies
- **Hydration Agent Logging**: Set `hydration_agent_logging = true` for log policies

### Tag Management
- **Create Tags**: Set `create_cloud_migrations_tag_namespace_and_tag_definitions = true`
- **Use Existing**: Set to `false` if CloudMigrations namespace already exists

## Troubleshooting

### Common Issues and Solutions

1. **Permission Denied Errors**
   - Ensure your OCI user has Identity and Access Management permissions
   - Verify you can create policies in the tenancy

2. **Tag Namespace Already Exists**
   - Set `create_cloud_migrations_tag_namespace_and_tag_definitions = false`
   - Or use a different compartment

3. **Compartment Not Found**
   - Verify your compartment OCID is correct
   - Ensure the compartment exists and is accessible

4. **Service Tenancy OCID Errors**
   - The default service OCIDs should work for most regions
   - Contact Oracle support if you encounter service OCID issues

### Validation Commands
```bash
# Validate Terraform configuration
terraform validate

# Check resource state
terraform state list

# Show specific resource details
terraform state show <resource_name>
```

## Post-Deployment Steps

After successful deployment:

1. **AWS Setup** (if migrating from AWS):
   - Create AWS IAM user with cross-account access
   - Apply the AWS IAM policies for discovery and replication
   - Configure Oracle Cloud Bridge with AWS credentials

2. **VMware Setup** (if migrating from VMware):
   - Configure VMware connectivity
   - Set up Remote Agent appliances

3. **Test Migration**:
   - Use OCI Console to access Cloud Migrations service
   - Verify connectivity to source environments
   - Run discovery processes

## Cleanup (if needed)
To remove all created resources:
```bash
terraform destroy
```
**Warning**: This will delete all migration prerequisites. Only use if you're sure you want to remove everything.

## Support

For issues with:
- **Terraform**: Check terraform.io documentation
- **OCI Resources**: Check Oracle Cloud Infrastructure documentation
- **Migration Process**: Contact Oracle Cloud Migrations support