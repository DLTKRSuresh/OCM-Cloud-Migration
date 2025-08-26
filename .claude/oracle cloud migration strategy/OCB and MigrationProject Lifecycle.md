Oracle Cloud Bridge (OCB)

Oracle Cloud Bridge is Oracle’s framework/service for discovery, assessment, and migration of workloads into Oracle Cloud Infrastructure (OCI). It integrates multiple services and tools (both native and partner) to provide an end-to-end migration journey.

Key components:

Discovery & Assessment

Uses OCI Cloud Migrations Service (CMS), Application Discovery, or partner integrations (like Cloudamize, Device42, etc.) to scan your AWS, Azure, VMware, or on-prem environment.

Collects inventory metadata (instances, VMs, storage, networks, databases).

Generates reports: utilization, sizing, dependencies.

Migration & Replication

Replication Manager / CMS handles block-level replication from AWS EBS, VMware, or on-prem storage to OCI Object Storage.

Data is staged → transformed → provisioned into OCI Block Volumes, Compute, VCNs, etc.

Automation using Terraform, SDKs, or Oracle Migration toolkits.

Integration with Governance & Ops

OCI Resource Manager (Terraform) for infra provisioning.

OCI Operations services (Cloud Guard, Logging, Monitoring) for security and observability.

Ensures compliance with tenancy security rules.

🔹 Migration Project Lifecycle

Yes — migration projects always split into phases (your diagram already shows something similar):

1. Discovery Phase

Inventory collection

AWS APIs (EC2, EBS, RDS, VPC) or VMware vCenter, or on-prem scanning.

Dependency mapping

Which app servers talk to which DBs.

Assessment & sizing

Right-size compute, DB shape, storage type (Block Volumes, File Storage, Object).

Readiness report

Highlight OS versions, licensing, unsupported features.

👉 Deliverable: Migration Assessment Report + Target Architecture.

2. Migration Phase

Planning

Which workloads first (usually non-prod), cutover strategy (big bang vs wave-based).

Replication & Staging

Data copied to OCI Object Storage → Block Volumes.

Provisioning

Create VCNs, Subnets, IAM policies, Compute Shapes in OCI.

Cutover

Switch traffic (DNS, LB), validate workloads, decommission legacy infra.

👉 Deliverable: Running application in OCI with verification & rollback plan.

Your Flowchart vs. Phases

Your diagram shows:

Discovery Phase → (AWS APIs → Inventory DB → Resource Selection UI → Migration Plan Generator).

Migration Phase → (Snapshots → Transfer → OCI provisioning → Cutover).

That’s exactly how OCI Cloud Bridge orchestrates it.



==============================================================================================================================================
Discovery Phase Inventory Details 
  Oracle Cloud Bridge Asset Storage

  When using Oracle Cloud Bridge (not the console), discovered assets are stored in:

  Oracle's Internal Inventory Database

  - Location: Oracle's managed database service (not in your tenancy)
  - Access: Via Oracle Cloud Bridge APIs and Cloud Migration APIs
  - Format: Structured inventory data accessible through REST endpoints

  Your OCI Tenancy Storage

  - Object Storage Bucket: Stores discovery snapshots and metadata
  - Location: ocm-replication-bucket (created by prerequisites)
  - Purpose: Staging area for migration data and backup inventory

  What Our Prerequisites Actually Create

  Looking at our current main.tf, we do NOT create any databases. The prerequisites only create:

  # Storage (not database)
  resource "oci_objectstorage_bucket" "replication_bucket"

  # Security
  resource "oci_kms_vault" "ocm_secrets"
  resource "oci_kms_key" "ocm_key"

  # IAM (Identity and Access Management)
  resource "oci_identity_dynamic_group" "migration_dynamic_group"
  resource "oci_identity_policy" "migration_compartment_policy"

  Asset Discovery Flow

  1. Discovery: Oracle Cloud Bridge discovers AWS assets → Stored in Oracle's managed inventory
  2. API Access: Our app calls Oracle APIs → Gets discovered assets from Oracle's inventory
  3. Local Cache: Our app can cache/display this data → But it's sourced from Oracle's APIs
  4. Migration: Oracle uses its inventory → Creates resources in your OCI tenancy

  No Database in Prerequisites

  The prerequisites are purely for:
  - Identity/Access: Permissions for Oracle services to work
  - Security: KMS for credential encryption
  - Storage: Object storage for migration data staging

  The actual asset inventory lives in Oracle's managed service, accessible via their APIs.