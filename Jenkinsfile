pipeline {
    agent any

    environment {
        IMAGE_NAME = 'btthanhk4/dvna:latest'
        DOCKERFILE = 'Dockerfile.glibc229'
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME -f $DOCKERFILE .'
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh '''
                    echo "=================== TRIVY IMAGE SCAN ==================="
                    trivy image --severity HIGH,CRITICAL --format table --exit-code 0 $IMAGE_NAME || true
                    echo "=================== END TRIVY REPORT ==================="
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push $IMAGE_NAME
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

    post {
        success {
            echo "Pipeline completed successfully."
        }
        failure {
            echo "Pipeline failed. Check logs for errors."
        }
    }
}
