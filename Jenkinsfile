pipeline {
    agent any
    
    options {
        skipDefaultCheckout(true)
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Terraform Init & Plan') {
            steps {
                dir('terraform') {
                    sh '''
                    echo "Initializing Terraform..."
                    terraform init -input=false
                    
                    echo "Running Terraform plan..."
                    terraform plan -var="ami_id=ami-0f5ee92e2d63afc18"
                    '''
                }
            }
        }
        
        stage('Security Scan - Checkov') {
            steps {
                sh '''
                echo "Installing Checkov..."
                pip3 install checkov --break-system-packages || pip install checkov || true
                
                echo "Running Checkov security scan..."
                checkov -d terraform/ --framework terraform --compact || true
                '''
            }
        }
        
        stage('Security Summary') {
            steps {
                echo "=================================================="
                echo "Security Scan Complete!"
                echo "Check the logs above for any security issues"
                echo "Look for findings related to 0.0.0.0/0"
                echo "=================================================="
            }
        }
    }
    
    post {
        always {
            echo "Pipeline execution completed"
        }
    }
}