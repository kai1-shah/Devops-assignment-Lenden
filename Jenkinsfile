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
            echo "All stages completed - Check security findings above"
        }
    }
}