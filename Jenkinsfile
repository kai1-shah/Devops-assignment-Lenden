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
                    terraform plan
                    '''
                }
            }
        }

        stage('Security Scan - Checkov') {
            steps {
                sh '''
                pip install checkov
                checkov -d terraform/ --framework terraform
                '''
            }
        }
    }
}
