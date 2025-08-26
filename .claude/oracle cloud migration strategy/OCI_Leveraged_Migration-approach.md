OCI Cloud Bridge + Migration Projects

Instead of reinventing migration discovery and replication, shifted to orchestrating Oracle’s built-in services.

Oracle provides Cloud Bridge + OCI Migration Service APIs, which already do the heavy lifting.

✅ Key OCI Services in play

Cloud Bridge (Discovery & Inventory)

Purpose: Connect OCI to your AWS environment and discover resources.

APIs from oracle: (Discovery Phase)

create_asset_source() → registers AWS account as a discovery source.

refresh_asset_source() → triggers discovery job (calls AWS APIs behind the scenes).

list_assets() → inventory of discovered AWS assets stored in OCI.

Output: OCI now has a full inventory of your AWS environment (instances, volumes, VPCs, etc.).

Migration Service (Planning & Execution)

Purpose: Take discovered assets and migrate them into OCI.

APIs From Oracled:(Migration Phase)

create_migration() → defines a migration project (e.g., “AWS → OCI App1 Migration”).

create_migration_plan() → generates an actual step-by-step plan (wave-based migration, mapping resources).

start_asset_replication() → initiates data replication from AWS → OCI (snapshots, block storage transfer).

create_target_asset() → provisions target OCI resources (Compute, Block Volumes, VCN, etc.).

Output: Migration projects, replication jobs, and OCI resources ready.

✅ Your Role: Orchestration/UI

Instead of implementing all the logic yourself, you:

Build Terraform + UI orchestration → deploy prerequisites (Vaults, Object Storage, IAM roles).

Use Oracle APIs (Cloud Bridge + Migration Service) to:

Connect AWS account

Trigger discovery

Show inventory in your custom dashboard

Let users plan migration waves (drag-and-drop UI, cost compare, etc.)

Start/monitor migrations via API calls

🔑 Why this approach makes sense

Discovery logic: Already done by Cloud Bridge → no need to reimplement AWS APIs yourself.

Migration reliability: Oracle’s migration service already tested for edge cases.

UI differentiation: You still build a custom dashboard/workflow (better UX), but you rely on Oracle’s backend engine for accuracy.

Support & SLA: Oracle supports you when something fails, instead of debugging AWS APIs.

Speed: Claude estimated ~9-13 weeks vs 20+ weeks building AWS-native migration from scratch.

📊 In short:

AWS Public API approach = Full custom pipeline (flexible but costly). the DIY approach

Oracle Cloud Bridge + Migration Projects = Use Oracle’s migration engine, you only orchestrate & provide UI.