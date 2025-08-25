● AWS to OCI Migration Flow - Architecture Diagram

  Migration Flow Diagram

  flowchart TD
      A[AWS Account] --> B[Setup IAM Role & Policies]
      B --> C[Discovery Engine]
      C --> D[AWS Public APIs]

      D --> E[EC2 API - Instances]
      D --> F[EBS API - Volumes]
      D --> G[VPC API - Network]
      D --> H[RDS API - Databases]

      E --> I[Inventory Database]
      F --> I
      G --> I
      H --> I

      I --> J[Resource Selection UI]
      J --> K[Migration Plan Generator]
      K --> L[Migration Executor]

      L --> M[Create EBS Snapshots]
      L --> N[Setup OCI Network]
      L --> O[Transfer Data to OCI]

      M --> P[S3 Staging Bucket]
      P --> Q[OCI Object Storage]
      Q --> R[OCI Block Volumes]

      N --> S[OCI VCN & Subnets]
      O --> T[OCI Compute Instances]

      R --> U[Mount to OCI Instances]
      S --> T
      U --> V[Migrated Applications in OCI]

      style A fill:#ff9999
      style V fill:#99ff99
      style I fill:#ffcc99
      style L fill:#99ccff

  Step-by-Step Migration Process

  Phase 1: AWS Setup & Discovery

  sequenceDiagram
      participant Admin as Administrator
      participant AWS as AWS Account
      participant IAM as AWS IAM
      participant APIs as AWS APIs
      participant DB as Inventory DB

      Admin->>AWS: Access AWS Console
      Admin->>IAM: Create Migration Role
      IAM->>IAM: Attach Discovery Policies
      Admin->>APIs: Execute Discovery
      APIs->>AWS: Scan EC2 Instances
      APIs->>AWS: Scan EBS Volumes
      APIs->>AWS: Scan VPC/Security Groups
      APIs->>AWS: Scan RDS Databases
      AWS-->>APIs: Return Resource Data
      APIs->>DB: Store Inventory Data

  Phase 2: Resource Selection & Planning

  flowchart LR
      A[Inventory Database] --> B[Resource List]
      B --> C{Select Resources}
      C -->|Yes| D[Add to Migration Plan]
      C -->|No| E[Keep in AWS]
      D --> F[Group by Dependencies]
      F --> G[Create Migration Waves]
      G --> H[Generate Execution Plan]

  Phase 3: Migration Execution

  sequenceDiagram
      participant Exe as Migration Executor
      participant AWS as AWS Services
      participant S3 as S3 Staging
      participant OCI as OCI Services

      Exe->>AWS: Create EBS Snapshots
      AWS-->>Exe: Snapshot IDs
      Exe->>AWS: Export Snapshots to S3
      AWS->>S3: Store Snapshot Data
      Exe->>OCI: Create VCN & Subnets
      Exe->>OCI: Setup Security Lists
      Exe->>S3: Download Snapshot Data
      S3-->>Exe: Snapshot Files
      Exe->>OCI: Upload to Object Storage
      Exe->>OCI: Create Block Volumes
      Exe->>OCI: Launch Compute Instances
      Exe->>OCI: Attach Block Volumes
      OCI-->>Exe: Migration Complete

  Component Architecture

  graph TB
      subgraph "AWS Environment"
          A1[EC2 Instances]
          A2[EBS Volumes]
          A3[VPC/Subnets]
          A4[RDS Databases]
          A5[S3 Staging Bucket]
      end

      subgraph "Migration Platform"
          B1[Discovery Engine]
          B2[Inventory Database]
          B3[Resource Selector]
          B4[Migration Executor]
          B5[Transfer Service]
      end

      subgraph "OCI Environment"
          C1[Compute Instances]
          C2[Block Volumes]
          C3[VCN/Subnets]
          C4[Database Service]
          C5[Object Storage]
      end

      A1 --> B1
      A2 --> B1
      A3 --> B1
      A4 --> B1

      B1 --> B2
      B2 --> B3
      B3 --> B4
      B4 --> B5

      B5 --> A5
      A5 --> C5
      B4 --> C1
      B4 --> C2
      B4 --> C3
      B4 --> C4

  AWS IAM Policy Setup Flow

  flowchart TD
      A[Start IAM Setup] --> B[Create Migration Role]
      B --> C[Attach EC2 Read Policies]
      C --> D[Attach EBS Snapshot Policies]
      D --> E[Attach S3 Transfer Policies]
      E --> F[Attach VPC Discovery Policies]
      F --> G[Add Cross-Account Trust]
      G --> H[Test API Access]
      H --> I{API Access Working?}
      I -->|Yes| J[IAM Setup Complete]
      I -->|No| K[Fix Policy Issues]
      K --> H

  Data Flow Architecture

  flowchart LR
      subgraph "Discovery Flow"
          A[AWS APIs] --> B[Raw Resource Data]
          B --> C[Data Processor]
          C --> D[Inventory Database]
      end

      subgraph "Migration Flow"
          E[Selected Resources] --> F[Snapshot Creator]
          F --> G[S3 Staging]
          G --> H[OCI Transfer]
          H --> I[OCI Provisioner]
          I --> J[Migrated Resources]
      end

      D --> E

  Simple Migration States

  stateDiagram-v2
      [*] --> Discovered
      Discovered --> Selected
      Selected --> Planned
      Planned --> Migrating
      Migrating --> Completed
      Migrating --> Failed
      Failed --> Planned
      Completed --> [*]


