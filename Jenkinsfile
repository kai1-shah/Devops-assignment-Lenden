pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Trivy Scan - Terraform') {
            agent {
                docker {
                    image 'aquasec/trivy:latest'
                    args '-v /var/jenkins_home/workspace:/project'
                }
            }
            steps {
                sh '''
                trivy config /project/devsecops-pipeline/terraform
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
