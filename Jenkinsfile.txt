pipeline {
    agent any

    environment {
        IMAGE_NAME = "btthanhk4/dvna"
        TAG = "latest"
    }

    stages {
        stage('Clone') {
            steps {
                git 'https://github.com/appsecco/dvna'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t $IMAGE_NAME:$TAG ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh "echo $PASSWORD | docker login -u $USERNAME --password-stdin"
                    sh "docker push $IMAGE_NAME:$TAG"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/dvna-deployment.yaml'
            }
        }
    }
}
