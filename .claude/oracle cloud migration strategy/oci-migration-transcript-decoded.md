 Oracle Cloud Migration - Complete Step-by-Step Guide (From Demo Video)

  Phase 1: Navigate to Oracle Console Migration Services

  Step 1: Main Console Navigation

  # From Demo Transcript (32:59 - 33:12)
  Navigate to: Main menu → Migration and Disaster Recovery → Cloud Migrations

  Console Path: Migration and Disaster Recovery → Cloud Migrations

  ---
  Phase 2: Create Asset Source (Discovery Setup)

  Step 2: Start with Asset Source Creation

  # From Demo Transcript (38:54 - 39:26)
  "And this is where you would start, right? So for AWS, you would start at discovery migration."

  Navigation: Cloud Migrations → Create Asset Source

  Key Points from Demo:
  - For AWS: You don't need remote connections (that's for VMware only)
  - Start directly with "Create Asset Source" for AWS discovery

  Step 3: Configure Asset Source

  # From Demo Transcript (39:36 - 40:12)
  Configuration Details:
  1. AWS Account ID: [Your 12-digit account]
  2. Select Region: [Your primary AWS region]
  3. Compartment: [Migration compartment - leave as "migration"]
  4. Target Compartment: IMPORTANT - Always use "migration" compartment

  Critical Note from Demo:
  "Target compartment doesn't mean where you're going to launch things... if you say I want to launch this in my dev compute compartment, that's not
  the correct way, it'll break things. So in most cases you could just leave it in migration."

  ---
  Phase 3: Configure AWS Credentials

  Step 4: AWS Credentials Setup

  # From Demo Transcript (40:17 - 41:38)
  Credentials Configuration:
  1. Click "Create New" for AWS credentials
  2. Name: "AWS" (or your preferred name)
  3. Compartment: MUST be "migration-secrets" compartment
  4. Select KMS Vault: "OCM-secrets" vault (created by prerequisites)
  5. Select KMS Key: [Migration encryption key]
  6. AWS Access Key ID: [From AWS IAM setup]
  7. AWS Secret Access Key: [From AWS IAM setup]

  Security Architecture from Demo:
  - Credentials stored in separate migration-secrets compartment
  - Only migration service has read access to secrets
  - Uses OCI Vault for encryption
  - Based on least privilege principle

  Step 5: AWS IAM Permissions

  # From Demo Transcript (41:43 - 42:12)
  Required AWS Permissions for Discovery:
  - describe-instances (EC2)
  - describe-instance-types (EC2)
  - describe-volumes (EBS)
  - cost-and-usage-with-resources (Cost Explorer) [Optional]
  - get-metric-data (CloudWatch) [Optional]

  From Demo: Oracle provides JSON policy templates you can copy-paste directly into AWS IAM

  ---
  Phase 4: Discovery Execution

  Step 6: Run Discovery Process

  # From Demo Transcript (12:22 - 12:27)
  Discovery Method:
  - Agent-less approach for AWS
  - Uses public AWS APIs directly
  - No software installation on source VMs required
  - Service pulls metadata and stores in your OCI tenancy

  Discovery Process:
  1. Asset Source Creation → Run Discovery
  2. Discovery Results → View Inventory Assets
  3. Asset Selection → Create Migration Project

  ---
  Phase 5: Migration Project Creation

  Step 7: Create Migration Project

  # From Demo Transcript (39:23 - 39:30)
  Workflow Steps:
  1. Create Asset Source Discovery ✓
  2. View Inventory Assets
  3. Create Migration Projects ← (This step)
  4. Plan Migration
  5. Execute Migration

  Migration Project Setup:
  - Link to discovered asset source
  - Select assets for migration (can filter by tags)
  - Configure target environment settings

  ---
  Phase 6: Migration Planning

  Step 8: Create Migration Plan

  # From Demo Transcript (11:22 - 11:45)
  Migration Plan Capabilities:
  - Create plan for testing
  - Create plan for cutover
  - Create plan for performance testing
  - Multiple plans from same replication
  - Different target subnets/shapes per plan

  Target Configuration:
  - Map AWS instance types to OCI shapes
  - Configure VCN and subnet placement
  - Set up security group equivalents (NSGs)
  - Configure storage performance requirements

  ---
  Phase 7: Replication Process

  Step 9: Start Replication

  # From Demo Transcript (17:25 - 18:26)
  Replication Architecture:
  1. Service creates temporary VCN in migration compartment
  2. Launches "Hydration Agent" compute instance
  3. Hydration agent connects to EBS APIs
  4. Creates crash-consistent snapshots in AWS
  5. Streams data directly to OCI block volumes
  6. Agent terminates after job completion

  Hydration Agent Details from Demo:
  - Temporary worker instances in your tenancy
  - Max 10 agents per tenancy (soft limit)
  - Handles multiple assets concurrently
  - Auto-terminates when jobs complete
  - Creates tagged snapshots in AWS for tracking

  ---
  Phase 8: Cutover Execution

  Step 10: Execute Migration

  # From Demo Transcript (42:55 - 43:00)
  Cutover Options:
  - Test cutover (smaller outage window)
  - Production cutover (planned maintenance)
  - Multiple test runs from same replication

  Final Cutover Process:
  1. Stop AWS instances (planned downtime)
  2. Final snapshot and replication
  3. Launch OCI instances from replicated volumes
  4. Validate functionality and performance
  5. Update DNS and application configurations

  ---
  Key Navigation Summary (From Demo Video)

  Correct Console Paths:

  1. Main Entry: Migration and Disaster Recovery → Cloud Migrations
  2. Asset Source: Cloud Migrations → Create Asset Source
  3. Discovery: Asset Sources → Run Discovery
  4. Projects: Cloud Migrations → Create Migration Project
  5. Planning: Migration Projects → Create Migration Plan
  6. Execution: Migration Plans → Execute Migration

  Critical Compartment Configuration:

  - Asset Sources: migration compartment
  - Credentials: migration-secrets compartment
  - Replication Volumes: migration compartment (moved later)
  - Target Instances: Your production compartments (post-cutover)

  This is the exact workflow demonstrated in your Oracle Cloud Migration Demo video, with specific console navigation paths and configuration details
  as shown in the actual demo.