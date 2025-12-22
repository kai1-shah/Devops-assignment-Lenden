pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Tools') {
            steps {
                sh '''
                apt-get update
                apt-get install -y wget ca-certificates
                '''
            }
        }

        stage('Install Trivy') {
            steps {
                sh '''
                wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_0.50.1_Linux-64bit.tar.gz
                tar -xzf trivy_0.50.1_Linux-64bit.tar.gz
                mv trivy /usr/local/bin/trivy || mv trivy trivy
                chmod +x /usr/local/bin/trivy || chmod +x trivy
                '''
            }
        }

        stage('Trivy Scan - Terraform') {
            steps {
                sh '''
                trivy config terraform
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh '''
                    terraform init -input=false
                    terraform plan -var="ami_id=ami-0f5ee92e2d63afc18"
                    '''
                }
            }
        }
    }
}
