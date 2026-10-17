# MercaAndes AWS IAM Security & Access Control (US-03)

## Overview
This repository contains the Infrastructure as Code (IaC) configuration and documentation for the Identity and Access Management (IAM) strategy of the MercaAndes project. 

The primary objective of this setup is to establish standard team access and enforce the **Principle of Least Privilege (PoLP)** across all cloud infrastructure services without relying on hardcoded credentials or long-term static access keys.

---

## 1. Functional IAM Users
To separate responsibilities and avoid shared credentials, four functional IAM users were provisioned. These allow team members to access the AWS Management Console securely.

| IAM User | Assigned Function / Responsibility | Initial Password Policy |
| :--- | :--- | :--- |
| `developer-api` | Backend API development and service monitoring | Temporary credentials (`MercaAndes2026!`), force reset on first login. |
| `developer-data` | Data pipeline management (Batch & Streaming) | Temporary credentials (`MercaAndes2026!`), force reset on first login. |
| `devops-engineer` | Infrastructure provisioning and pipeline setup | Temporary credentials (`MercaAndes2026!`), force reset on first login. |
| `qa-engineer` | Quality assurance, testing, and audit inspection | Temporary credentials (`MercaAndes2026!`), force reset on first login. |

### Rationale
- **Traceability:** Isolates console activities per domain responsibility.
- **Credential Hygiene:** Eliminates shared accounts and forces immediate password rotation upon initial authentication.

---

## 2. Infrastructure IAM Roles (Least Privilege)
To allow workloads and services to communicate securely, four specific IAM execution roles were created. Services assume these roles dynamically using temporary STS credentials instead of static API keys.

| IAM Role Name | Target Service / Component | Purpose & Access Scope |
| :--- | :--- | :--- |
| `mercaandes-api-ec2-role` | EC2 Instances (APIs) | Grants compute instances access to write application logs and interact with database endpoints. |
| `mercaandes-batch-node-role` | Batch Processing (Spark/Airflow) | Allows batch compute nodes to read raw datasets from S3 and write processed results to RDS. |
| `mercaandes-streaming-node-role` | Streaming Ingestion (Kafka/RabbitMQ) | Authorizes stream processing workloads to ingest real-time events and store summaries in S3. |
| `mercaandes-cicd-pipeline-role` | CI/CD Automation (GitHub Actions/ECS/ECR) | Enables deployment automation to push container images to ECR and deploy service updates. |

### Rationale
- **Zero Hardcoded Secrets:** Prevents embedding `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY` inside repositories or Docker containers.
- **Blast Radius Reduction:** Each component possesses strictly the permissions needed for its operational layer (API, Data, Ingestion, or Deployment).

---

## 3. Compliance & Security Best Practices
1. **Root Key Deprecation:** All administrative access keys generated during initial setup have been revoked/deleted from the Root account.
2. **IaC Sinking:** All user definitions and trust policies are maintained declaratively within `main.tf` for auditing and version control.