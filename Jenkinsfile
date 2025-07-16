pipeline {
    agent any

    environment {
        IMAGE_NAME = 'btthanhk4/dvna:latest'
        DOCKERFILE = 'Dockerfile.glibc229'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Trivy FS Scan (Source Code)') {
            steps {
                echo 'Scanning source code with Trivy (filesystem)...'
                sh '''
                    echo "=== Trivy FS Scan ==="
                    trivy fs . --severity HIGH,CRITICAL || true
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${IMAGE_NAME} -f ${DOCKERFILE} ."
            }
        }

        stage('Trivy Image Scan') {
            steps {
                echo 'Scanning Docker image with Trivy...'
                sh '''
                    echo "=== Trivy Image Scan ==="
                    trivy image ${IMAGE_NAME} --severity HIGH,CRITICAL || true
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push btthanhk4/dvna:latest
                    '''
                }
            }
        }

        stage('Deploy MySQL') {
            steps {
                echo 'Deploying MySQL...'
                sh 'kubectl apply -f k8s/mysql-deployment.yaml'
            }
        }

        stage('Deploy DVNA') {
            steps {
                echo 'Deploying DVNA App...'
                sh '''
                    kubectl delete pod -l app=dvna --ignore-not-found
                    kubectl apply -f k8s/dvna-deployment.yaml
                '''
            }
        }
    }
}
