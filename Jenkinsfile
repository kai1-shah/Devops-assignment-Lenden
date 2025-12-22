pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Trivy Scan - Terraform') {
            steps {
                sh '''
                docker run --rm \
                  -v "$PWD:/project" \
                  aquasec/trivy:latest \
                  config /project/terraform
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
