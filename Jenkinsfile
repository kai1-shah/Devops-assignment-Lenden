pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    stages {

        stage('Terraform Init & Plan') {
            steps {
                dir('terraform') {
                    sh '''
                    terraform init -input=false
                    terraform plan -var="ami_id=ami-0f5ee92e2d63afc18"
                    '''
                }
            }
        }

        stage('Security Scan - Checkov') {
            steps {
                sh '''
                pip3 install checkov || pip install checkov || true
                checkov -d terraform/ --framework terraform
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline execution completed"
        }
    }
}
