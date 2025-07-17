pipeline {
    agent {
        kubernetes {
            label 'kaniko-agent'
            defaultContainer 'kaniko'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: kaniko-agent
spec:
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
      command:
        - /busybox/cat
      tty: true
      volumeMounts:
        - name: docker-config
          mountPath: /kaniko/.docker/
    - name: kubectl
      image: bitnami/kubectl:latest
      command:
        - cat
      tty: true
  restartPolicy: Never
  volumes:
    - name: docker-config
      secret:
        secretName: docker-config
"""
        }
    }

    environment {
        IMAGE_NAME = 'btthanhk4/dvna:latest'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Push Docker Image (Kaniko)') {
            steps {
                container('kaniko') {
                    sh '''
                        /kaniko/executor \
                          --context `pwd` \
                          --dockerfile Dockerfile.glibc229 \
                          --destination=$IMAGE_NAME
                    '''
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh '''
                    docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        aquasec/trivy:latest \
                        image --severity HIGH,CRITICAL --format table --exit-code 0 $IMAGE_NAME | tee trivy-report.txt
                '''
                archiveArtifacts artifacts: 'trivy-report.txt', onlyIfSuccessful: true
            }
        }

        stage('Deploy MySQL') {
            steps {
                container('kubectl') {
                    sh 'kubectl apply -f k8s/mysql-deployment.yaml'
                }
            }
        }

        stage('Deploy DVNA') {
            steps {
                container('kubectl') {
                    sh '''
                        kubectl delete pod -l app=dvna --ignore-not-found
                        kubectl apply -f k8s/dvna-deployment.yaml
                    '''
                }
            }
        }
    }
}
