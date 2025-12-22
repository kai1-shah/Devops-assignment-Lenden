pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    stages {

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh '''
                    echo "Running Terraform plan"
                    terraform init -input=false
                    terraform plan -var="ami_id=ami-0f5ee92e2d63afc18"
                    '''
                }
            }
        }

    }
}
