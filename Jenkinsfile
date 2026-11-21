
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'daemonst/devops-nginx'
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
        BUILDKIT_HOST = 'tcp://localhost:1234'
    }

    stages {

        stage('Verify Git Checkout') {
            steps {
                echo 'Checking out application source code...'
                sh 'git --version'
                sh 'pwd'
                sh 'ls -la'
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    env.IMAGE_TAG = "build-${env.BUILD_NUMBER}"
                }

                echo "Building ${DOCKER_IMAGE}:${IMAGE_TAG}"

                withCredentials([
                    usernamePassword(
                        credentialsId: "${DOCKERHUB_CREDENTIALS}",
                        usernameVariable: 'DOCKERHUB_USR',
                        passwordVariable: 'DOCKERHUB_PSW'
                    )
                ]) {
                    sh '''
                        set +x

                        export DOCKER_CONFIG="$(mktemp -d)"
                        trap 'rm -rf "$DOCKER_CONFIG"' EXIT

                        mkdir -p "$DOCKER_CONFIG"

                        AUTH=$(printf '%s' "$DOCKERHUB_USR:$DOCKERHUB_PSW" | base64 -w 0)

                        printf '{"auths":{"https://index.docker.io/v1/":{"auth":"%s"}}}' "$AUTH" > "$DOCKER_CONFIG/config.json"

                        chmod 600 "$DOCKER_CONFIG/config.json"

                        buildctl \
                          --addr "$BUILDKIT_HOST" \
                          build \
                          --frontend dockerfile.v0 \
                          --local context=. \
                          --local dockerfile=. \
                          --opt filename=Dockerfile.nginx \
                          --output type=image,name=${DOCKER_IMAGE}:${IMAGE_TAG},push=true
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying application to Kubernetes...'

                sh '''
                    sed "s|image: daemonst/devops-nginx:v1|image: ${DOCKER_IMAGE}:${IMAGE_TAG}|" \
                        deployment-monitoring.yaml > deployment-ci.yaml

                    kubectl apply -f nginx-configmap.yaml
                    kubectl apply -f service.yaml
                    kubectl apply -f deployment-ci.yaml

                    kubectl rollout status deployment/nginx-app \
                      -n devops-lab --timeout=180s
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying Kubernetes deployment...'

                sh 'kubectl get deployments -n devops-lab'
                sh 'kubectl get pods -n devops-lab'
                sh 'kubectl get services -n devops-lab'
                sh 'kubectl get deployment nginx-app -n devops-lab -o jsonpath="{.spec.template.spec.containers[?(@.name==\\"nginx\\")].image}"'
            }
        }
    }
}
