DevSecOps CI/CD Pipeline with Terraform & Jenkins
📌 Project Overview
<img width="759" height="695" alt="image" src="https://github.com/user-attachments/assets/18d51922-5eb0-4a89-b79f-f8caed461ac9" />



This project demonstrates a DevSecOps CI/CD pipeline that provisions and validates cloud infrastructure using Terraform, while enforcing security best practices through automated security scanning in Jenkins.

The pipeline ensures that insecure infrastructure configurations never reach deployment by automatically failing builds when critical security issues are detected, and passing only after those issues are properly remediated.

The primary focus of this project is Infrastructure as Code (IaC) security enforcement, rather than runtime application exposure.

🏗 Architecture Explanation
High-Level Workflow

A developer pushes Terraform code to GitHub

A Jenkins pipeline is automatically triggered

Jenkins performs the following stages:

Workspace cleanup

Source code checkout

Terraform initialization and validation

Security scanning using tfsec

Pipeline behavior:

❌ Fails if critical security issues are detected

✅ Passes once all security issues are fixed

🔐 Security Gate

The CI/CD pipeline acts as a security gate, ensuring that insecure cloud resources are blocked at the CI level and never provisioned in the cloud.


Jenkins Pipeline Fails
<img width="913" height="1080" alt="image" src="https://github.com/user-attachments/assets/5daf62d5-5027-4273-9d1e-51673420b44b" />


Debugging
AI prompt used
<img width="987" height="443" alt="image" src="https://github.com/user-attachments/assets/731692f5-82ad-4d62-a3bd-42068b962f47" />

What Did it suggest
# DevSecOps Pipeline Security Analysis Report

## AI Prompt Used

"Analyze the Jenkins pipeline execution log from the DevSecOps assignment. Identify all security vulnerabilities detected by tfsec, categorize them by severity, and provide recommendations for remediation. Explain how fixing these issues improves the overall security posture of the AWS infrastructure."

---

## Executive Summary

The Jenkins pipeline successfully executed the Terraform initialization and validation stages, but **failed during the security scanning phase**. The tfsec security scanner detected **6 security issues** across the Terraform configuration:
- **3 Critical** severity findings
- **2 High** severity findings  
- **1 Low** severity finding

The pipeline correctly failed the build to prevent deployment of insecure infrastructure, which is the expected behavior in a DevSecOps pipeline.

---

## Identified Security Risks

### Critical Severity Issues

#### 1. **Security Group Allows Unrestricted Public Ingress (Line 26)**
- **Issue**: CIDR block set to `0.0.0.0/0` allows ingress from any internet address
- **Impact**: Any actor on the internet can attempt to access the service on this port
- **Risk**: Exposure to unauthorized access, DDoS attacks, and scanning
- **Affected Resource**: `aws_security_group.insecure_sg` ingress rule

#### 2. **Security Group Allows Unrestricted Public Ingress (Line 34)**
- **Issue**: Second ingress rule with CIDR block `0.0.0.0/0`
- **Impact**: Multiple open ports to the public internet increases attack surface
- **Risk**: Privilege escalation, data exfiltration, and lateral movement
- **Affected Resource**: `aws_security_group.insecure_sg` second ingress rule

#### 3. **Security Group Allows Unrestricted Public Egress (Line 41)**
- **Issue**: Egress rule with `0.0.0.0/0` and protocol `-1` (all protocols)
- **Impact**: Instance can communicate to any destination on any port
- **Risk**: Data exfiltration, command-and-control communication, propagation of compromised systems
- **Affected Resource**: `aws_security_group.insecure_sg` egress rule

### High Severity Issues

#### 4. **IMDS Access Not Protected by Token Requirement (Lines 48-56)**
- **Issue**: EC2 instance metadata service (IMDS) not configured to require IMDSv2 tokens
- **Impact**: Instance metadata including IAM credentials can be accessed via SSRF attacks
- **Risk**: Credential theft, privilege escalation, unauthorized API calls
- **Affected Resource**: `aws_instance.web_server`
- **Recommendation**: Enable `metadata_options` with `http_tokens = "required"`

#### 5. **Root Block Device Not Encrypted (Lines 48-56)**
- **Issue**: EC2 instance root volume has no encryption enabled
- **Impact**: Data at rest is unencrypted and vulnerable to physical/snapshot access
- **Risk**: Compliance violations, data breach, unauthorized data access
- **Affected Resource**: `aws_instance.web_server` root block device
- **Recommendation**: Enable EBS encryption on all block devices

### Low Severity Issues

#### 6. **Security Group Rules Lack Descriptions (Lines 37-42)**
- **Issue**: Egress rule has no description explaining its purpose
- **Impact**: Operational confusion about firewall rule intent
- **Risk**: Accidental rule removal, maintenance difficulties
- **Affected Resource**: `aws_security_group.insecure_sg` egress block
- **Recommendation**: Add description field with rationale for the rule

---

## Security Improvements & Recommendations

### Network Security (Critical Priority)

**Current State**: Open to the world on all protocols
```terraform
cidr_blocks = ["0.0.0.0/0"]  # INSECURE
```

**Recommended Changes**:
1. **Restrict Ingress**: Replace `0.0.0.0/0` with specific IP ranges
   - Use company VPN/office IPs for administrative access
   - Use load balancer security group for application traffic
   - Example: `cidr_blocks = ["203.0.113.0/24"]` (your office network)

2. **Restrict Egress**: Replace all-protocol egress with specific requirements
   - Allow only necessary destinations (e.g., package repositories, APIs)
   - Block unnecessary outbound internet access
   - Example: Restrict to specific DNS, NTP, and application servers

3. **Security Group Rule Documentation**: Add descriptions
   ```terraform
   description = "Allow HTTPS from office network"
   ```

### Instance Security (High Priority)

**1. Enable IMDSv2 (Token-Required)**
```terraform
metadata_options {
  http_endpoint               = "enabled"
  http_tokens                 = "required"
  http_put_response_hop_limit = 1
}
```
Impact: Prevents SSRF-based credential theft, enforces modern security standards

**2. Enable EBS Encryption**
```terraform
root_block_device {
  encrypted           = true
  volume_type         = "gp3"
  delete_on_termination = true
}
```
Impact: Encrypts data at rest, meets compliance requirements (PCI-DSS, HIPAA), protects against unauthorized access

---

## How These Changes Improve Security

| Security Aspect | Before | After | Improvement |
|---|---|---|---|
| **Network Exposure** | Open to entire internet (0.0.0.0/0) | Restricted to specific IPs | Eliminates unauthorized access vectors |
| **Attack Surface** | All ports, all protocols exposed | Only required ports open | Reduces attack surface by 99%+ |
| **Data Exfiltration** | Unrestricted outbound access | Limited to approved destinations | Prevents data leakage and C2 communication |
| **Credential Security** | IMDS accessible without token | Requires valid token (IMDSv2) | Prevents SSRF credential theft |
| **Data at Rest** | Unencrypted volumes | Encrypted EBS volumes | Meets compliance, prevents data breach |
| **Operational Clarity** | Undocumented rules | Rules have descriptive comments | Reduces misconfiguration risk |

---

## Compliance & Best Practices Alignment

These fixes align with:
- **AWS Well-Architected Framework**: Security pillar
- **CIS AWS Foundations Benchmark**: Network segmentation and encryption
- **OWASP**: Principle of least privilege
- **Industry Standards**: PCI-DSS, HIPAA, SOC2
- **Zero Trust Security**: Explicit allow, default deny

---

## Pipeline Impact

**Current Status**: FAILURE (Expected)
- The pipeline correctly failed because security issues were detected
- This prevents deployment of insecure infrastructure to production
- Demonstrates mature DevSecOps practices: "fail fast" on security

**To Pass the Pipeline**:
1. Fix all 3 critical security group CIDR issues
2. Enable IMDSv2 on EC2 instance
3. Enable EBS encryption on instance volumes
4. Add descriptions to security group rules
5. Re-run tfsec scan to verify all issues resolved
6. Commit and push corrected Terraform code
7. Re-trigger pipeline

---

## Conclusion

This pipeline execution demonstrates proper DevSecOps implementation by catching security misconfigurations before deployment. The identified vulnerabilities would have created significant security risks in production. Implementing the recommended changes will reduce attack surface, protect data, enforce compliance, and establish security-first infrastructure practices.

**Priority**: Implement Critical findings immediately before any production deployment.

Changes Made

Document 1: Remediated main.tf (Copy-Paste Ready)
This is the complete, production-ready Terraform file with all 6 security issues fixed. Just copy the entire code and paste it into your main.tf.
Changes made:

✅ Ingress CIDR #1 (Line 26): 0.0.0.0/0 → 10.0.0.0/8
✅ Ingress CIDR #2 (Line 34): 0.0.0.0/0 → 10.0.0.0/8
✅ Egress rules: All protocols → Limited to HTTPS + DNS only
✅ Added descriptions to all security group rules
✅ Added metadata_options for IMDSv2 enforcement
✅ Added root_block_device with EBS encryption
✅ Created customer-managed KMS key for encryption

Document 2: Before vs After Comparison
Shows exactly what changed with:

Side-by-side code comparison
Explanation of each change
Why it matters for compliance
Step-by-step implementation guide
Testing checklist
Copy-paste commands for validation

Key Points:
Replace this CIDR with your actual network:
hclcidr_blocks = ["10.0.0.0/8"]  # Your office, VPN, or load balancer
Validation command:
bashtfsec terraform/
# Should now show: ✅ 4 passed, 0 problem(s) detected


 links for gen ai usage report for chat gpt and claude
 Claude:https://claude.ai/share/c8dd0321-4234-4cd8-9b0f-024acd192a8e
 Chat GPT:https://chatgpt.com/share/694abc5d-8ae8-8010-80dd-8d2bdc555a54

Jenkins Pipeline Works successfully
<img width="1224" height="605" alt="image" src="https://github.com/user-attachments/assets/e802600b-bd15-4edb-89ea-1c9d47e07ef6" />


Could not show the output via a public ip could not configure and re run ec2 along with terraform
