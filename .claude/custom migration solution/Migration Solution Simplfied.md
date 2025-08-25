 AWS to OCI Migration Tool - Simple Architecture Design

  Overview

  This document outlines a straightforward custom migration tool that moves applications and data from AWS to Oracle Cloud Infrastructure (OCI) using
  AWS public APIs for discovery and automated migration processes.

  Core Migration Flow

  1. AWS Account Setup

  - Create IAM role with migration permissions
  - Configure AWS API access credentials
  - Set up cross-account trust policies

  2. Discovery Phase

  - Use AWS public APIs to scan resources
  - Collect complete inventory of AWS environment
  - Store resource information in database

  3. Resource Selection

  - Review discovered resources
  - Select items for migration to OCI
  - Group resources by dependencies

  4. Migration Execution

  - Create snapshots of selected resources
  - Transfer data from AWS to OCI
  - Provision new resources in OCI

  ---
  Detailed Component Flow

  AWS IAM Policy Setup

  Step 1: Create Migration Role
  Role Name: OCIMigrationRole
  Purpose: Allow discovery and snapshot operations

  Step 2: Attach Required Policies
  - EC2 read and snapshot permissions
  - EBS volume and snapshot access
  - S3 bucket creation and transfer rights
  - VPC and security group discovery
  - RDS database discovery

  Step 3: Configure Trust Relationship
  - Allow migration tool to assume the role
  - Set external ID for additional security

  Discovery Engine Components

  AWS API Connections:
  - EC2 API: Find all virtual machines, their configurations, and current state
  - EBS API: Discover storage volumes, sizes, and attachments
  - VPC API: Map network setup, subnets, and security groups
  - RDS API: Identify databases, versions, and configurations

  Discovery Process:
  1. Connect to AWS account using IAM role
  2. Scan all AWS regions for resources
  3. Collect detailed information about each resource
  4. Identify relationships between resources
  5. Store everything in inventory database

  Inventory Database Structure

  Resource Information Stored:
  - Resource ID and name
  - Resource type (EC2, EBS, RDS, etc.)
  - Current configuration details
  - Location (region, availability zone)
  - Dependencies on other resources
  - Migration readiness status

  Database Tables:
  - Resources Table: Basic resource information
  - Dependencies Table: Resource relationships
  - Migration Status Table: Track migration progress

  Resource Selection Interface

  Selection Process:
  1. Display all discovered resources in organized view
  2. Allow administrator to select resources for migration
  3. Show dependencies and recommend related resources
  4. Group selected resources into migration waves
  5. Generate migration plan based on selections

  Migration Execution Engine

  Migration Steps:

  For EC2 Instances: (for details of these refer below section -  AWS to OCI Migration - EBS and AMI Transfer Details )
  1. Create EBS snapshots of all attached volumes
  2. Create machine image (AMI) from instance
  3. Transfer snapshots to S3 staging bucket
  4. Copy data from S3 to OCI Object Storage
  5. Create OCI compute instance from transferred image
  6. Attach migrated storage volumes

  For RDS Databases:
  1. Create database snapshot in AWS
  2. Export snapshot to S3 bucket
  3. Transfer database files to OCI Object Storage
  4. Create new database instance in OCI
  5. Restore data from transferred files

  For Network Components:
  1. Map AWS VPC structure to OCI VCN design
  2. Create equivalent subnets in OCI
  3. Replicate security group rules as security lists
  4. Configure routing and internet gateways

  ---
  Data Transfer Process

  Snapshot Creation

  - Use AWS APIs to create point-in-time snapshots
  - Ensure data consistency during snapshot process
  - Track snapshot IDs for transfer operations

  Staging Area

  - Create temporary S3 bucket for data transfer
  - Store snapshots and images in S3
  - Manage transfer queue and progress tracking

  OCI Transfer

  - Download data from S3 staging bucket
  - Upload to OCI Object Storage
  - Convert AWS formats to OCI-compatible formats
  - Create OCI resources from transferred data

  Resource Provisioning

  - Create OCI compute instances with equivalent specifications
  - Attach migrated storage volumes
  - Configure network connectivity
  - Apply security policies and access controls

  ---
  Simple Architecture Diagram

  AWS Account                    Migration Tool                    OCI Tenancy
  ┌─────────────┐               ┌─────────────────┐              ┌─────────────┐
  │ EC2         │──────────────►│ Discovery       │              │ Compute     │
  │ EBS         │               │ Engine          │              │ Block Vol   │
  │ VPC         │               │                 │              │ VCN         │
  │ RDS         │               │ ┌─────────────┐ │              │ Database    │
  │             │               │ │ Inventory   │ │              │             │
  │ S3 Staging  │◄──────────────│ │ Database    │ │──────────────┤             │
  └─────────────┘               │ └─────────────┘ │              └─────────────┘
                                │                 │
                                │ ┌─────────────┐ │
                                │ │ Migration   │ │
                                │ │ Executor    │ │
                                │ └─────────────┘ │
                                └─────────────────┘

  ---
  Migration States

  Each resource progresses through these states:

  1. Discovered: Found by discovery engine
  2. Selected: Chosen for migration
  3. Planned: Included in migration plan
  4. Migrating: Currently being transferred
  5. Completed: Successfully migrated to OCI
  6. Failed: Migration encountered error (retry possible)

  ---
  Key Components Summary

  Discovery Engine

  - Automatically scans AWS environment
  - Uses standard AWS public APIs
  - Collects comprehensive resource inventory
  - Identifies resource dependencies

  Inventory Management

  - Stores all discovered resource information
  - Provides interface for resource selection
  - Tracks migration status and progress
  - Maintains audit trail of all operations

  Migration Executor

  - Handles actual resource transfer process
  - Creates snapshots and backups
  - Manages data transfer between clouds
  - Provisions new resources in OCI

  Data Transfer Service

  - Coordinates movement of data between AWS and OCI
  - Uses S3 as intermediate staging area
  - Handles large file transfers efficiently
  - Validates data integrity during transfer

  ---
● AWS to OCI Migration - EBS and AMI Transfer Details ---

  EC2 Instance Migration Process (Detailed)

  Step 1: Create EBS Snapshots of All Attached Volumes

  - Use AWS API to create snapshots of all EBS volumes attached to the EC2 instance
  - Snapshots are stored in AWS EBS snapshot storage (managed by AWS)
  - Each snapshot gets a unique snapshot ID (snap-xxxxxxxxx)

  Step 2: Create Machine Image (AMI) from Instance

  Where is this image stored?
  - AMI is stored in AWS EC2 Image Storage (managed by AWS)
  - AMI consists of:
    - Root volume snapshot (boot disk)
    - Additional volume snapshots (data disks)
    - Instance metadata (instance type, kernel, RAM disk)
  - AMI gets a unique identifier (ami-xxxxxxxxx)
  - Storage Location: AWS keeps AMI in their internal storage, linked to your account
  - Regional: AMI is stored in the specific AWS region where it was created

  Step 3: Transfer Snapshots to S3 Staging Bucket

  - Export EBS snapshots to S3 bucket using AWS export APIs
  - Creates VMDK or VHD format files in S3
  - S3 objects can be accessed and downloaded

  Step 4: Copy Data from S3 to OCI Object Storage

  - Download snapshot files from S3 bucket
  - Upload the same files to OCI Object Storage bucket
  - Files remain in VMDK/VHD format during transfer

  Step 5: Create OCI Compute Instance from Transferred Image

  How is this transferred from AWS to OCI?

  The Transfer Process:

  1. AMI to Image File Conversion
  AWS AMI → Export to S3 as VMDK file → Download VMDK → Upload to OCI Object Storage
  2. OCI Custom Image Creation
    - Use OCI Console or API to create custom image
    - Point to the VMDK file stored in OCI Object Storage
    - OCI converts VMDK to OCI-compatible image format
    - New OCI custom image gets an OCID (ocid1.image.oc1...)
  3. Instance Creation from Custom Image
    - Launch new OCI compute instance
    - Select the custom image created in step 2
    - Instance boots from the transferred AWS image

  Step 6: Attach Migrated Storage Volumes

  - Create OCI block volumes from transferred EBS snapshot files
  - Attach these block volumes to the running OCI compute instance
  - Mount volumes inside the operating system

  ---
  Detailed Technical Flow

  AMI Storage and Transfer Details

  AWS Side:
  EC2 Instance → Create AMI → AMI stored in AWS Image Registry
                                      ↓
                              Export AMI to S3 as VMDK file
                                      ↓
                              VMDK file in S3 bucket

  Transfer Process:
  S3 Bucket (AWS) → Download VMDK file → Upload to OCI Object Storage → OCI Bucket

  OCI Side:
  OCI Object Storage → Import as Custom Image → OCI Image Registry
                                                        ↓
                                              Launch Compute Instance

  Storage Location Breakdown

  | Component       | AWS Storage Location | Transfer Format | OCI Storage Location |
  |-----------------|----------------------|-----------------|----------------------|
  | AMI             | AWS Image Registry   | VMDK file       | OCI Custom Images    |
  | Boot Volume     | EBS Snapshot         | VMDK file       | OCI Boot Volume      |
  | Data Volumes    | EBS Snapshots        | VMDK files      | OCI Block Volumes    |
  | Instance Config | AMI Metadata         | JSON/Config     | OCI Instance Config  |

  File Transfer Sizes and Formats

  Typical Transfer Sizes:
  - Small instance: 8-20 GB (boot volume)
  - Medium instance: 20-100 GB (boot + data volumes)
  - Large instance: 100GB-2TB+ (multiple large data volumes)

  File Formats During Transfer:
  - AWS Export Format: VMDK (VMware Virtual Disk)
  - Alternative Format: VHD (Virtual Hard Disk)
  - OCI Import Format: VMDK or QCOW2

  Step-by-Step AMI Transfer Process

  1. AWS: Create and Export AMI
  aws ec2 create-image --instance-id i-1234567890abcdef0 --name "MyServerImage"
  aws ec2 export-image --image-id ami-12345678 --disk-image-format VMDK --s3-export-location S3Bucket=my-export-bucket,S3Prefix=exports/
  2. Transfer: Download from S3, Upload to OCI
  Download: aws s3 cp s3://my-export-bucket/exports/MyServerImage.vmdk ./
  Upload: oci os object put --bucket-name migration-bucket --file MyServerImage.vmdk
  3. OCI: Create Custom Image
  oci compute image create --compartment-id ocid1.compartment.oc1... --display-name "Migrated-Server" --source-details
  '{"sourceType":"objectStorageTuple","bucketName":"migration-bucket","objectName":"MyServerImage.vmdk"}'
  4. OCI: Launch Instance
  oci compute instance launch --image-id ocid1.image.oc1... --shape VM.Standard2.1 --subnet-id ocid1.subnet.oc1...

  Important Notes

  AMI Storage:
  - AMIs are not files - they are AWS service objects
  - Cannot directly download AMI - must export to S3 first
  - Export process creates actual file (VMDK) from AMI object

  Transfer Limitations:
  - Large images take time to export and transfer
  - Network bandwidth affects transfer speed
  - Some AWS marketplace AMIs cannot be exported

  OCI Import Process:
  - OCI can import VMDK, VHD, and QCOW2 formats
  - Import process creates OCI custom image
  - Custom image can then be used to launch instances

  This process ensures the complete AWS EC2 instance (operating system, applications, data) is preserved and recreated in OCI with the same
  functionality.