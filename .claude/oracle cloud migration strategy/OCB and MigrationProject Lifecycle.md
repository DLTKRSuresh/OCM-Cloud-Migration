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