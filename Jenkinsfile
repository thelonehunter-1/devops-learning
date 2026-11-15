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
    }
}