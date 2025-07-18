pipeline {
    agent any

    environment {
        IMAGE_NAME = 'btthanhk4/dvna:latest'
        MINIO_ALIAS = 'localminio'
        MINIO_BUCKET = 'cicd-artifacts'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME -f Dockerfile.glibc229 .'
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

        stage('Trivy Image Scan') {
            steps {
                sh '''
                    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                        aquasec/trivy:latest \
                        image --severity HIGH,CRITICAL --format table --exit-code 0 $IMAGE_NAME | tee trivy-report.txt
                '''
                archiveArtifacts artifacts: 'trivy-report.txt', onlyIfSuccessful: true
            }
        }

        stage('Upload Artifact to MinIO') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'minio-creds', usernameVariable: 'MINIO_USER', passwordVariable: 'MINIO_PASS')]) {
            sh '''
                curl -s https://dl.min.io/client/mc/release/linux-amd64/mc -o mc
                chmod +x mc
                ./mc alias set minio http://192.168.65.3:30737 "$MINIO_USER" "$MINIO_PASS"
                ./mc mb minio/cicd-artifacts || true
                ./mc cp trivy-report.txt minio/cicd-artifacts/
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
