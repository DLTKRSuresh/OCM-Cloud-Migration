# AWS to OCI Migration - Operations Runbook

**Version:** 1.0  
**Team:** Migration Operations  
**Emergency Contact:** [Migration Team Lead]

---

## 🎯 Quick Reference

### **Critical Information**
- **Project Duration:** 7 weeks
- **Total Workloads:** ~15 instances + database
- **Estimated Downtime:** <4 hours per wave
- **Rollback Time:** <15 minutes per component

### **Key Contacts**
```
Migration Manager: [Name] - [Phone] - [Email]
Technical Lead: [Name] - [Phone] - [Email]
AWS Admin: [Name] - [Phone] - [Email]
OCI Admin: [Name] - [Phone] - [Email]
Business Stakeholder: [Name] - [Phone] - [Email]
```

---

## 📋 Phase-by-Phase Execution Guide

### **PHASE 1: Discovery & Assessment (Week 1)**

#### **Day 1-2: AWS Asset Source Setup**
```bash
# Step 1: Configure AWS Asset Source in OCI Console
Location: Migration & Disaster Recovery → Cloud Migrations → Asset Sources

1. Click "Create Asset Source"
   - Name: aws-production-environment
   - Type: Amazon Web Services
   - Compartment: [Migration Compartment]

2. Configure Authentication:
   - Method: AWS IAM User [or Cross-Account Role]
   - Access Key ID: [From AWS setup]
   - Secret Access Key: [From AWS setup]
   - AWS Region: us-east-1
   
3. Test Connection:
   - Click "Test Connection"
   - Status should show: ✅ "Connection successful"
   
4. Save Configuration
```

#### **Day 3-4: Discovery Execution**
```bash
# Step 2: Create and Execute Discovery Schedule
Location: Migration & Disaster Recovery → Cloud Migrations → Discovery Schedules

1. Create Discovery Schedule:
   - Name: full-environment-discovery
   - Asset Source: aws-production-environment
   - Compartment: [Migration Compartment]
   - Schedule: "Run once" (for initial discovery)

2. Execute Discovery:
   - Click "Run Now"
   - Monitor progress in Discovery Schedules page
   - Typical duration: 30-60 minutes
   
3. Review Discovery Results:
   - Navigate to: Cloud Migrations → Inventory
   - Verify all expected resources discovered
   - Check resource details and dependencies
```

#### **Day 5: Target Architecture Validation**
```yaml
OCI Environment Checklist:
□ VCN and subnets configured
□ Security Lists and NSGs ready
□ Compute shapes analyzed and selected
□ Storage performance requirements validated
□ Network connectivity tested
□ Load balancer configuration planned
```

### **PHASE 2: Pilot Migration (Week 2)**

#### **Day 1: Migration Project Setup**
```bash
# Step 3: Create Migration Project
Location: Migration & Disaster Recovery → Cloud Migrations → Migration Projects

1. Create Migration Project:
   - Name: aws-to-oci-pilot-migration
   - Compartment: [Migration Compartment]
   - Asset Source: aws-production-environment

2. Configure Migration Settings:
   - Replication Schedule: Daily at 2:00 AM
   - Target Compartment: [Target Compartment]
   - Target VCN: [Migration VCN]
   
3. Save Configuration
```

#### **Day 2-3: Migration Plan Development**
```bash
# Step 4: Create Migration Plan
Location: Migration Projects → [Your Project] → Migration Plans

1. Create Migration Plan:
   - Name: pilot-dev-environment-migration
   - Migration Strategy: Lift and Shift
   
2. Configure Resource Mapping:
   Source Instance → Target Configuration:
   - t3.medium → VM.Standard.E4.Flex (2 OCPU, 16GB RAM)
   - Security Groups → Network Security Groups
   - EBS gp3 → Block Volume Ultra High Performance
   
3. Network Configuration:
   - Source VPC: 172.31.0.0/16
   - Target VCN: 10.0.0.0/16
   - Subnet mapping: Automatic with validation
   
4. Validate Migration Plan:
   - Run pre-flight checks
   - Review resource allocation
   - Confirm network connectivity
```

#### **Day 4-5: Execute Pilot Migration**
```bash
# Step 5: Execute Migration
Location: Migration Plans → [Your Plan] → Execute Migration

1. Pre-Migration Checks:
   □ All AWS instances stopped (if required)
   □ Snapshots created and verified
   □ OCI target environment ready
   □ Network connectivity validated
   
2. Start Migration:
   - Click "Execute Migration"
   - Monitor progress in real-time
   - Typical duration: 2-4 hours per instance
   
3. Post-Migration Validation:
   □ All instances started successfully
   □ Network connectivity verified
   □ Application functionality tested
   □ Performance baseline established
   
# Real-time Monitoring Commands
# Check migration status
oci cloud-migrations migration get --migration-id [MIGRATION_ID]

# Monitor instance provisioning
oci compute instance list --compartment-id [TARGET_COMPARTMENT]

# Verify network connectivity
ping [target-instance-ip]
telnet [target-instance-ip] [port]
```

#### **Pilot Validation Checklist**
```yaml
Technical Validation:
□ All instances provisioned correctly
□ Network security groups applied
□ Storage volumes attached and functional
□ Application services started
□ Database connections working
□ Load balancer health checks passing

Performance Validation:
□ Response times within acceptable range
□ Resource utilization normal
□ Network latency acceptable
□ Storage IOPS meeting requirements
□ Memory and CPU usage optimal

Functional Validation:
□ User authentication working
□ All application features functional
□ Data integrity verified
□ Integration endpoints responding
□ Backup procedures tested
```

### **PHASE 3: Production Data Layer (Week 3-4)**

#### **Database Migration Procedure**
```bash
# Step 6: Database Migration Strategy

# Option A: MySQL Database Server Migration
1. Pre-Migration Data Sync:
   # On AWS RDS
   mysqldump -h [rds-endpoint] -u admin -p --single-transaction \
             --routines --triggers [database_name] > backup.sql
   
   # Verify backup integrity
   mysql -h [rds-endpoint] -u admin -p [test_db] < backup.sql
   
2. OCI Database Setup:
   # On OCI MySQL instance
   mysql -u root -p
   CREATE DATABASE [database_name];
   GRANT ALL PRIVILEGES ON [database_name].* TO 'appuser'@'%';
   FLUSH PRIVILEGES;
   
3. Data Migration:
   # Transfer and restore
   scp backup.sql [oci-db-server]:/tmp/
   mysql -u root -p [database_name] < /tmp/backup.sql
   
4. Validation:
   # Row count verification
   SELECT COUNT(*) FROM [table_name];  # Compare AWS vs OCI
   
   # Data integrity check
   SELECT CHECKSUM TABLE [table_name]; # Compare checksums

# Option B: Real-time Replication (for minimal downtime)
1. Setup MySQL Replication:
   # On AWS (Master)
   CHANGE MASTER TO
     MASTER_HOST='[oci-db-ip]',
     MASTER_USER='repl_user',
     MASTER_PASSWORD='[password]',
     MASTER_LOG_FILE='mysql-bin.000001',
     MASTER_LOG_POS=154;
   
2. Monitor Replication:
   SHOW SLAVE STATUS\G
   # Check Seconds_Behind_Master: should be 0
   
3. Cutover Process:
   # Stop application writes
   # Wait for replication to catch up
   # Update application connection strings
   # Restart applications
```

#### **Storage Migration Procedure**
```bash
# Step 7: EBS to Block Volume Migration

1. Create EBS Snapshots:
   aws ec2 create-snapshot \
     --volume-id vol-1234567890abcdef0 \
     --description "Pre-migration backup"
   
2. Verify Snapshot Status:
   aws ec2 describe-snapshots --snapshot-ids snap-1234567890abcdef0
   
3. OCM handles the data transfer automatically:
   # Monitor in OCI Console → Migration Projects → Data Replication
   # Verify replication status and progress
   
4. Post-Migration Volume Validation:
   # On OCI instance
   df -h                    # Check mounted volumes
   sudo fsck /dev/sdb1     # Filesystem check
   sudo mount /dev/sdb1 /data  # Mount volume
   ls -la /data            # Verify data integrity
```

### **PHASE 4: Application Layer (Week 5-6)**

#### **Application Server Migration**
```bash
# Step 8: Application Server Migration

1. Pre-Migration Application Preparation:
   # Update configuration files
   vim /etc/app/config.properties
   # Update database connection strings
   DB_HOST=[new-oci-db-ip]
   DB_PORT=3306
   
   # Update service endpoints
   API_ENDPOINT=https://[new-oci-domain]/api
   
2. Migration Execution:
   # OCM handles server migration automatically
   # Monitor in Migration Projects → Migration Plans
   
3. Post-Migration Application Setup:
   # SSH to new OCI instance
   ssh -i ~/.ssh/key.pem opc@[oci-instance-ip]
   
   # Start application services
   sudo systemctl start application-service
   sudo systemctl enable application-service
   
   # Verify service status
   sudo systemctl status application-service
   
4. Health Check Validation:
   # Application health check
   curl -f http://[oci-instance-ip]:8080/health
   
   # Database connectivity check
   curl -f http://[oci-instance-ip]:8080/db-status
   
   # API endpoint validation
   curl -f http://[oci-instance-ip]:8080/api/version
```

#### **Load Balancer Configuration**
```bash
# Step 9: OCI Load Balancer Setup

1. Create Load Balancer:
   # Via OCI Console: Networking → Load Balancers
   - Name: production-app-lb
   - Type: Application Load Balancer
   - Shape: Flexible (10 Mbps minimum)
   - Subnets: Public subnet for internet-facing
   
2. Configure Backend Set:
   - Name: app-servers-backend
   - Health Check: /health (port 8080)
   - Backend Servers: [list of app server IPs]
   
3. Create Listener:
   - Name: http-listener
   - Protocol: HTTP
   - Port: 80
   - Backend Set: app-servers-backend
   
4. SSL Configuration (if applicable):
   - Upload SSL certificate
   - Create HTTPS listener on port 443
   - Configure SSL policies
   
# CLI Configuration
oci lb load-balancer create \
  --compartment-id [compartment-id] \
  --display-name production-app-lb \
  --shape-name "flexible" \
  --subnet-ids '[subnet-id]'
```

### **PHASE 5: Web Layer & DNS Cutover (Week 7)**

#### **Web Server Migration**
```bash
# Step 10: Web Server Migration

1. Web Server Preparation:
   # Update web server configuration
   vim /etc/nginx/nginx.conf
   # Update upstream servers
   upstream app_servers {
     server [oci-app-ip-1]:8080;
     server [oci-app-ip-2]:8080;
   }
   
2. Execute Web Server Migration:
   # OCM migration process
   # Monitor migration progress
   
3. Post-Migration Web Setup:
   # SSH to migrated web servers
   ssh -i ~/.ssh/key.pem opc@[oci-web-ip]
   
   # Start web services
   sudo systemctl start nginx
   sudo systemctl enable nginx
   
   # Verify configuration
   sudo nginx -t
   curl -f http://[oci-web-ip]/
```

#### **DNS Cutover Procedure**
```bash
# Step 11: DNS Migration Strategy

# Phase 1: Parallel Environment (Blue-Green)
1. Update DNS with low TTL:
   # Reduce TTL to 300 seconds (5 minutes)
   your-domain.com.    300    IN    A    [aws-ip]
   
2. Create OCI DNS entries:
   # OCI Console → Networking → DNS Management
   - Zone: your-domain.com
   - Record: A record pointing to OCI load balancer IP
   
# Phase 2: Gradual Traffic Shift
3. Weighted DNS Distribution:
   # 90% AWS, 10% OCI (testing)
   your-domain.com.    300    IN    A    10   [aws-ip]
   your-domain.com.    300    IN    A    1    [oci-ip]
   
4. Monitor and Increase OCI Traffic:
   # 50% AWS, 50% OCI (validation)
   your-domain.com.    300    IN    A    1    [aws-ip]
   your-domain.com.    300    IN    A    1    [oci-ip]
   
5. Complete Cutover:
   # 100% OCI traffic
   your-domain.com.    300    IN    A    [oci-ip]
   
# Phase 3: Verification and Cleanup
6. Verify Full Functionality:
   nslookup your-domain.com
   curl -f https://your-domain.com/health
   
7. Increase TTL after validation:
   your-domain.com.    3600   IN    A    [oci-ip]
```

---

## 🔧 Troubleshooting Guide

### **Common Issues & Solutions**

#### **Migration Failures**
```yaml
Issue: Instance migration fails with "Insufficient capacity"
Solution:
  - Check target availability domain capacity
  - Try different availability domain
  - Use different instance shape if available
  - Contact Oracle support for capacity increase

Issue: Network connectivity fails post-migration
Solution:
  - Verify security list rules
  - Check NSG configurations
  - Validate route table entries
  - Test with security list allow-all temporarily

Issue: Application won't start after migration
Solution:
  - Check system logs: journalctl -xe
  - Verify configuration file paths
  - Update database connection strings
  - Check file permissions and ownership
```

#### **Performance Issues**
```yaml
Issue: Slow database performance
Solution:
  - Check storage performance (Block Volume IOPS)
  - Verify database configuration (buffer pool, etc.)
  - Monitor resource utilization
  - Consider database service migration

Issue: High network latency
Solution:
  - Check instance placement (same AD)
  - Verify VCN routing configuration
  - Test with network performance tools
  - Consider instance shape upgrade
```

#### **Rollback Procedures**
```bash
# Emergency Rollback Process

1. DNS Immediate Rollback:
   # Revert DNS to AWS
   your-domain.com.    60    IN    A    [aws-ip]
   
2. Application-Level Rollback:
   # Update load balancer to point to AWS
   # Revert database connections to AWS RDS
   
3. Complete Infrastructure Rollback:
   # Stop OCI instances
   # Restart AWS instances
   # Verify all services operational
   
# Rollback Validation
curl -f https://your-domain.com/health  # Should return AWS response
```

---

## 📊 Monitoring & Alerting

### **Real-Time Migration Monitoring**

#### **OCI Console Monitoring**
```bash
# Key Monitoring Locations:
1. Migration Projects → [Project] → Overview
   - Migration progress percentage
   - Resource migration status
   - Error logs and alerts

2. Compute → Instances
   - Instance provisioning status
   - Health checks and metrics
   
3. Storage → Block Volumes
   - Volume attachment status
   - IOPS and throughput metrics

4. Networking → Load Balancers
   - Backend health status
   - Traffic distribution
   - Error rates
```

#### **CLI Monitoring Commands**
```bash
# Check migration status
oci cloud-migrations migration get \
  --migration-id [migration-id] \
  --query "data.{status:lifecycleState,progress:progressPercentage}"

# Monitor compute instances
oci compute instance list \
  --compartment-id [compartment-id] \
  --lifecycle-state RUNNING

# Check load balancer health
oci lb backend-set get \
  --load-balancer-id [lb-id] \
  --backend-set-name [backend-set-name]
```

#### **Custom Monitoring Scripts**
```bash
#!/bin/bash
# migration-monitor.sh - Real-time migration monitoring

echo "=== Migration Status Monitor ==="
echo "Time: $(date)"
echo

# Check migration progress
MIGRATION_STATUS=$(oci cloud-migrations migration get \
  --migration-id ${MIGRATION_ID} \
  --query "data.lifecycleState" --raw-output)
  
echo "Migration Status: ${MIGRATION_STATUS}"

# Check instance health
INSTANCE_COUNT=$(oci compute instance list \
  --compartment-id ${TARGET_COMPARTMENT} \
  --lifecycle-state RUNNING \
  --query "length(data)")
  
echo "Running Instances: ${INSTANCE_COUNT}"

# Check application health
for instance_ip in ${INSTANCE_IPS[@]}; do
  if curl -f --max-time 10 http://${instance_ip}:8080/health >/dev/null 2>&1; then
    echo "✅ ${instance_ip} - Healthy"
  else
    echo "❌ ${instance_ip} - Unhealthy"
  fi
done
```

### **Alerting Configuration**
```yaml
Critical Alerts (Immediate Response):
  - Migration failure or stuck
  - Application down/unreachable
  - Database connectivity lost
  - Load balancer health check failures

Warning Alerts (1 hour response):
  - High resource utilization
  - Performance degradation
  - Network connectivity issues
  - Storage performance issues

Info Alerts (Next business day):
  - Migration progress updates
  - Resource utilization reports
  - Cost analysis updates
  - Performance optimization suggestions
```

---

## 📝 Migration Day Checklist

### **Go-Live Day Procedure**

#### **T-4 Hours: Final Preparation**
```bash
□ All team members available and on standby
□ Communication plan activated
□ Rollback procedures tested and ready
□ Monitoring dashboards active
□ Emergency contact list distributed
□ Final backups completed and verified
```

#### **T-2 Hours: Pre-Migration Checks**
```bash
□ AWS environment stable and operational
□ OCI target environment ready
□ Network connectivity validated end-to-end
□ Database replication synchronized (if applicable)
□ Load balancer configuration verified
□ DNS changes staged but not applied
```

#### **T-0: Migration Execution**
```bash
□ Maintenance page activated
□ Application writes stopped
□ Final data sync initiated
□ Migration execution started
□ Real-time monitoring active
□ Team communication every 15 minutes
```

#### **T+2 Hours: Post-Migration Validation**
```bash
□ All instances provisioned successfully
□ Application services started
□ Database connectivity verified
□ Load balancer health checks passing
□ End-to-end functionality tested
□ Performance baseline established
```

#### **T+4 Hours: DNS Cutover**
```bash
□ DNS changes applied (gradual rollout)
□ Traffic monitoring active
□ User experience validation
□ Error rate monitoring
□ Performance monitoring
□ Maintenance page removed
```

#### **T+24 Hours: Stabilization**
```bash
□ Full functionality validated
□ Performance optimized
□ Monitoring and alerting tuned
□ User feedback collected
□ Issues resolved
□ Documentation updated
```

---

## 📞 Emergency Contacts & Escalation

### **Emergency Response Team**
```
Primary Contacts (24/7 during migration):
- Migration Lead: [Name] - [Mobile] - [Email]
- Technical Lead: [Name] - [Mobile] - [Email]
- Database Admin: [Name] - [Mobile] - [Email]
- Network Engineer: [Name] - [Mobile] - [Email]

Secondary Contacts:
- Project Manager: [Name] - [Mobile] - [Email]
- Business Stakeholder: [Name] - [Mobile] - [Email]
- Oracle Support: [Case Number] - [Phone] - [Portal]
- AWS Support: [Case Number] - [Phone] - [Console]
```

### **Communication Channels**
```
Primary: Microsoft Teams Channel - "Migration Command Center"
Secondary: Conference Bridge - [Phone Number] / [Pin]
Emergency: SMS Group - "Migration Team"
Status Updates: Email Distribution List - migration-updates@company.com
```

---

**🎯 Ready for Migration Execution!**

This runbook provides step-by-step operational procedures for executing your AWS to OCI migration. Each phase includes detailed commands, validation steps, and troubleshooting guidance to ensure a successful migration.

**Remember:** Test all procedures in the pilot phase before applying to production! 🚀