pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: kaniko
spec:
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
      command:
        - cat
      tty: true
      volumeMounts:
        - name: docker-config
          mountPath: /kaniko/.docker
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
        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Build & Push with Kaniko') {
            steps {
                container('kaniko') {
                    sh '''
                    /kaniko/executor \
                      --dockerfile=Dockerfile.glibc229 \
                      --context=. \
                      --destination=docker.io/${IMAGE_NAME} \
                      --skip-tls-verify \
                      --verbosity=info
                    '''
                }
            }
        }

        stage('Trivy Image Scan') {
            agent {
                docker {
                    image 'aquasec/trivy:latest'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                sh '''
                    trivy image --severity HIGH,CRITICAL --format table --exit-code 0 ${IMAGE_NAME} | tee trivy-report.txt
                '''
                archiveArtifacts artifacts: 'trivy-report.txt', onlyIfSuccessful: true
            }
        }

        stage('Deploy MySQL') {
            steps {
                sh 'kubectl apply -f k8s/mysql-deployment.yaml'
            }
        }

        stage('Deploy DVNA App') {
            steps {
                sh '''
                    kubectl delete pod -l app=dvna --ignore-not-found
                    kubectl apply -f k8s/dvna-deployment.yaml
                '''
            }
        }
    }
}
