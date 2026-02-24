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

<img width="1332" height="651" alt="Screenshot 2026-02-24 151044" src="https://github.com/user-attachments/assets/3d8fba23-c2ad-42a7-9538-0933d708d4ef" />

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


<img width="1461" height="511" alt="Screenshot 2026-02-24 151237" src="https://github.com/user-attachments/assets/02ad4d00-6dbe-46b7-8610-06e8e2740d6d" />

<img width="1490" height="526" alt="Screenshot 2026-02-24 151825" src="https://github.com/user-attachments/assets/2087f1f4-7162-4700-a272-398cb167e13f" />

<img width="1495" height="491" alt="Screenshot 2026-02-24 151832" src="https://github.com/user-attachments/assets/291c2f1a-42f6-454a-8982-2bf91ba58282" />



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

<img width="1884" height="711" alt="image" src="https://github.com/user-attachments/assets/c477c0e0-60aa-474d-b650-f080c4a0f595" />

<!-- graph data usage of cpu via prometheus itself -->
<img width="1854" height="896" alt="Screenshot 2026-02-24 164347" src="https://github.com/user-attachments/assets/a1624a18-4202-470b-a4a7-646dfe74383a" />

---

## Grafana Configuration

- Grafana running on port 3000
      http://<public-ip>:3000
      same as the prometheus server  (prometheus server ip : 44.202.182.51 )
<img width="1772" height="897" alt="Screenshot 2026-02-24 151010" src="https://github.com/user-attachments/assets/e4a63fbe-8036-426d-8e33-570f2047e4fa" />


- Added Prometheus as Data Source:
  
      http://localhost:9090

<img width="1490" height="526" alt="Screenshot 2026-02-24 151825" src="https://github.com/user-attachments/assets/ef8128ab-8696-44a8-bdda-26b0ff8c6d1b" />

---

<img width="1059" height="341" alt="Screenshot 2026-02-24 153504" src="https://github.com/user-attachments/assets/ed64ecc4-8330-4bdd-af25-956f05904ec1" />


- Imported dashboard ID: 11074
- Visualized:
  - CPU usage
  - Memory usage
  - Disk utilization
  - Network activity

<img width="1495" height="763" alt="Screenshot 2026-02-24 172745" src="https://github.com/user-attachments/assets/eee3afa1-b4b8-43a3-a81b-4134ef7500da" />

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

<img width="1509" height="561" alt="Screenshot 2026-02-24 164400" src="https://github.com/user-attachments/assets/70462bcd-97f8-4bfe-8aa7-613cd1d09271" />


<img width="1425" height="732" alt="Screenshot 2026-02-24 155131" src="https://github.com/user-attachments/assets/ee4583f8-c21d-4789-b317-34414fe5dddc" />

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
<img width="1576" height="828" alt="Screenshot 2026-02-24 164054" src="https://github.com/user-attachments/assets/225d6b42-22f2-46eb-a251-35c7ba291376" />

<img width="1420" height="731" alt="Screenshot 2026-02-24 164107" src="https://github.com/user-attachments/assets/9d723c63-c0b1-4e90-b44f-14da40a15172" />


---

## Challenges Faced

- Connection refused errors due to incorrect inbound rules
- Port mismatches between services and security groups
- Public vs private IP confusion
- Service binding issues
- YAML configuration mistakes

<img width="1909" height="736" alt="Screenshot 2026-02-24 153008" src="https://github.com/user-attachments/assets/c29953ce-1248-4c4e-9a23-9cb0871f2ecb" />

<img width="1826" height="612" alt="Screenshot 2026-02-24 153430" src="https://github.com/user-attachments/assets/2bdb627e-8167-4371-a37e-1089e736ae79" />


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
