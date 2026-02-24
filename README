# AWS Monitoring & Alerting Stack
Prometheus + Grafana + Node Exporter (Terraform-Based Deployment)

---

## Project Summary

Designed and deployed a monitoring and alerting stack on AWS using Terraform, Prometheus, Grafana, and Node Exporter inside a newly created isolated VPC.

The objective was to implement end-to-end infrastructure provisioning, metric scraping, dashboard visualization, alert validation, and email notification testing under real load conditions.

---

## Infrastructure Architecture

### Network Setup (Provisioned via Terraform)

- Custom VPC (10.0.0.0/16)
- Public Subnet (10.0.1.0/24)
- Internet Gateway attached to VPC
- Route table configured with 0.0.0.0/0 → Internet Gateway
- Security groups configured for required inbound and outbound rules
- Two EC2 instances deployed in the isolated environment

---

## EC2 Instances

### Web Server Instance
- Nginx installed
- Node Exporter installed (Port 9100)
- Port 80 exposed for HTTP
- Metrics scraped by Prometheus

### Monitoring Server
- Prometheus installed (Port 9090)
- Grafana installed (Port 3000)
- Prometheus and Grafana running on the same instance

---

## Automated Installation (user_data)

Installation of:
- Prometheus
- Grafana
- Node Exporter

was performed using EC2 user_data scripts during instance launch.

This ensured:
- Automated provisioning
- No manual installation steps
- Infrastructure reproducibility

---

## Post-Deployment Configuration (SSH Based)

After the instances were running:

- Connected via SSH
- Updated /etc/prometheus/prometheus.yml to configure scrape targets
- Updated /etc/grafana/grafana.ini to configure SMTP settings
- Restarted services using systemctl

This ensured proper metric scraping and email alert functionality.

---

## Prometheus Configuration

Configured scrape targets inside prometheus.yml:

    - job_name: node
      static_configs:
        - targets: ['localhost:9100', '<public-ip>:9100']
        <!-- public ip for the instance in which node-exported was installed was 44.192.11.65 -->   

Verified targets at:

    http://<monitoring-server-ip>:9090/targets
    <!-- prometheus server ip : 44.202.182.51     -->

Metrics were successfully collected from Node Exporter.

---

## Grafana Configuration

- Added Prometheus as Data Source:
  
      http://localhost:9090

- Imported dashboard ID: 11074
- Visualized:
  - CPU usage
  - Memory usage
  - Disk utilization
  - Network activity

---

## Alerting Implementation

Created CPU usage alert using PromQL:

    100 - (
      avg by (instance) (
        rate(node_cpu_seconds_total{mode="idle"}[5m])
      ) * 100
    )

Alert condition:
- Trigger when CPU usage exceeds 70%

---

## Alert Validation

Installed stress package on web server:

    stress --cpu 2 --timeout 360

Results:
- CPU load exceeded threshold
- Alert state transitioned to Firing
- Alert rule validated successfully

---

## Email Notification Setup

Configured AWS SMTP in:

    /etc/grafana/grafana.ini

Updated:
- SMTP host
- Username
- Password
- From address

Configured:
- Email contact point
- Linked alert rule to contact point
- Tested contact point successfully

Received email notification when alert fired.

---

## Challenges Faced

- Connection refused errors due to incorrect inbound rules
- Port mismatches between services and security groups
- Public vs private IP confusion
- Service binding issues
- YAML configuration mistakes

Resolved using:
- systemctl status
- ss -tulnp
- Prometheus /targets
- Terraform re-apply and configuration corrections

---

## Skills Demonstrated

- Infrastructure as Code (Terraform)
- AWS Networking (VPC, Subnet, Internet Gateway, Routing)
- Prometheus metric scraping configuration
- Grafana dashboard and alert engineering
- PromQL for CPU percentage calculation
- SMTP integration for email notifications
- Load testing and alert validation
- Troubleshooting cloud networking and service issues

---

## Conclusion

Successfully implemented a functional monitoring and alerting stack on AWS using core observability technologies. The project demonstrates the ability to provision infrastructure, automate installations, configure monitoring, implement alerting, integrate email notifications, and troubleshoot distributed systems in a cloud environment.