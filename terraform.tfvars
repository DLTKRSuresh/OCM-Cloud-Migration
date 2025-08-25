# Updated with your actual OCI values

# Required: Your OCI tenancy OCID
tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaa63bfpmjm4g2hrtwoliqw6ewnqmb2v6lfwoc6jjyvlto7exfwwm3q"

# Required: Compartment where migration resources will be created
# Choose one of the compartments from the list above, for example:
compartment_ocid = "ocid1.compartment.oc1..aaaaaaaawaz5eqjm2b4bq2flowqsmddiynbnwvadhutv476wowg73ezog6xq"  # Eng-Sandbox

# Object Storage bucket name for replication snapshots
replication_bucket = "my-ocm-replication-bucket"
create_replication_bucket = true

# Enable tag namespace and tag creation (set to false if already exists)
create_cloud_migrations_tag_namespace_and_tag_definitions = true

# Migration source configuration
migration_from_aws = true
migration_from_vmware = false

# Stack configuration
primary_prerequisite_stack = true

# Optional features - enable as needed
migration_groups = false
remote_agent_logging = false
hydration_agent_logging = false

# Service tenancy OCIDs (usually don't need to change these)
ocb-service-tenancy-ocid = "ocid1.tenancy.oc1..aaaaaaaahr2xcduf4knzkzhkzt442t66bpqt3aazss6cy2ll6x4xj3ci7tiq"
ocm-service-tenancy-ocid = "ocid1.tenancy.oc1..aaaaaaaartv6j5muce2s4djz7rvfn2vwceq3cnue33d72isntnlfmi7huv7q"