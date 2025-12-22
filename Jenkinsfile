// pipeline {
//     agent any
    
//     options {
//         skipDefaultCheckout(true)
//     }
    
//     stages {
//         stage('Clean Checkout') {
//             steps {
//                 deleteDir()
//                 checkout scm
//             }
//         }
        
//         stage('Terraform Init & Plan') {
//             steps {
//                 dir('terraform') {
//                     sh '''
//                     terraform init -input=false
//                     terraform plan -var="ami_id=ami-0f5ee92e2d63afc18"
//                     '''
//                 }
//             }
//         }
        
//         stage('Security Scan - Checkov') {
//             steps {
//                 sh '''
//                 pip3 install checkov --break-system-packages || pip install checkov || true
//                 checkov -d terraform/ --framework terraform || true
//                 '''
//             }
//         }
//     }
    
//     post {
//         always {
//             echo "Pipeline execution completed"
//         }
//     }
// }

pipeline {
    agent any
    
    options {
        skipDefaultCheckout(true)
    }
    
    stages {
        stage('Clean Checkout') {
            steps {
                deleteDir()
                checkout scm
            }
        }
        
        stage('Terraform Validate') {
            steps {
                dir('terraform') {
                    sh '''
                    echo "Initializing Terraform..."
                    terraform init -input=false -backend=false
                    
                    echo "Validating Terraform syntax..."
                    terraform validate
                    '''
                }
            }
        }
        
        stage('Security Scan - Checkov') {
            steps {
                sh '''
                echo "Installing Checkov..."
                pip3 install checkov --break-system-packages || pip install checkov
                
                echo "Running Checkov security scan..."
                echo "=================================================="
                checkov -d terraform/ --framework terraform --compact
                echo "=================================================="
                '''
            }
        }
        
        stage('Security Scan - tfsec') {
            steps {
                sh '''
                echo "Installing tfsec..."
                wget -q https://github.com/aquasecurity/tfsec/releases/download/v1.28.1/tfsec-linux-amd64 -O tfsec
                chmod +x tfsec
                
                echo "Running tfsec security scan..."
                echo "=================================================="
                ./tfsec terraform/ --no-color || true
                echo "=================================================="
                '''
            }
        }
        
        stage('Security Summary') {
            steps {
                echo "=================================================="
                echo "         SECURITY SCAN COMPLETED"
                echo "=================================================="
                echo "Review the logs above for security vulnerabilities"
                echo ""
                echo "Your intentional 0.0.0.0/0 security fault should be"
                echo "detected and reported in the scan results above."
                echo "=================================================="
            }
        }
    }
    
    post {
        always {
            echo "Pipeline execution completed"
        }
        success {
            echo "✓ All stages completed - Check security findings above"
        }
    }
}
```

## Key Changes:

1. ✅ **Removed `terraform plan`** - This requires AWS credentials we don't have
2. ✅ **Added `terraform init -backend=false`** - Initializes without backend/credentials
3. ✅ **Added `terraform validate`** - Checks syntax without needing credentials
4. ✅ **Kept Checkov scan** - Will detect your `0.0.0.0/0` issue
5. ✅ **Added tfsec scan** - Another scanner to catch security issues
6. ✅ **Removed `|| true` from Checkov** - So you see the actual findings (but added to tfsec)

## Apply This NOW:

1. **Go to GitHub**: http://github.com/kai1-shah/devops-assignment-Lenden
2. **Click Jenkinsfile** → **Edit** (pencil icon)
3. **Delete everything and paste the code above**
4. **Commit**: "Final fix - skip plan and run security scans"
5. **Go to Jenkins** → **Build Now**

## Expected Output:
```
[Security Scan - Checkov]
Check: CKV_AWS_260: "Ensure no security groups allow ingress from 0.0.0.0:0"
	FAILED for resource: aws_security_group.your_security_group
	File: terraform/main.tf:XX-XX
	
[Security Scan - tfsec]
Problem found in main.tf
  aws-ec2-no-public-ingress-sgr
  Security group rule allows ingress from 0.0.0.0/0
  Line: XX
  cidr_blocks = ["0.0.0.0/0"]  ← YOUR SECURITY FAULT!