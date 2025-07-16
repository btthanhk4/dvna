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
                sh 'trivy fs . --exit-code 0 --severity HIGH,CRITICAL || true'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME} -f ${DOCKERFILE} ."
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh "trivy image ${IMAGE_NAME} --exit-code 0 --severity HIGH,CRITICAL || true"
            }
        }

        stage('Push Docker Image') {
            steps {
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
                sh 'kubectl apply -f k8s/mysql-deployment.yaml'
            }
        }

        stage('Deploy DVNA') {
            steps {
                sh '''
                    kubectl delete pod -l app=dvna --ignore-not-found
                    kubectl apply -f k8s/dvna-deployment.yaml
                '''
            }
        }
    }
}
