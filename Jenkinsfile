pipeline {
    agent any

    stages {

        stage('Verify Git Checkout') {
            steps {
                echo 'Jenkins pipeline started successfully!'

                sh 'git --version'
                sh 'pwd'
                sh 'ls -la'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying application to Kubernetes...'

                sh 'kubectl apply -f deployment.yaml'
                sh 'kubectl apply -f service.yaml'

                sh 'kubectl rollout status deployment/nginx-app -n devops-lab'
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Checking Kubernetes deployment...'

                sh 'kubectl get deployments -n devops-lab'
                sh 'kubectl get pods -n devops-lab'
                sh 'kubectl get services -n devops-lab'
            }
        }
    }
}
