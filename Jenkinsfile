// Jenkinsfile
// End-to-end CI/CD pipeline for the Node.js application.
//
// "agent none" at the pipeline level: each stage explicitly declares its own agent, rather than one agent for the whole pipeline. 
//  stash/unstash is used to pass source code and node_modules between stages, rather than relying on filesystem paths matching across different containers. 
//  Docker Hub credentials are injected via Jenkins' credential store (credentials-binding plugin) using the 'dockerhub-credentials' ID 

pipeline {
    agent none // each stage declares its own agent, not one agent for whole pipeline

    options {
        skipDefaultCheckout(true) // checkout scm - default behaviour to skip it
	disableConcurrentBuilds()                       // avoid concurrent builds racing to push the same tag
        buildDiscarder(logRotator(numToKeepStr: '10'))   // keep logs bounded
    }

    environment {
        IMAGE_NAME = "helly829/secdev-ass2"
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            agent any
            steps {
                checkout scm
                stash name: 'source', useDefaultExcludes: false, includes: '**'
            }
        }

        stage('Install Dependencies') {
            agent {
                docker {
                    image 'node:16'
                    args '-u root:root'   // avoids file-permission mismatches between the node:16 image's default user and the files unstashed into the workspace
                }
            }
            steps {
                unstash 'source'
                sh 'npm install'
                stash name: 'node_modules', includes: 'node_modules/**'
            }
        }

        stage('Run Unit Tests') {
            agent {
                docker {
                    image 'node:16'
                    args '-u root:root'
                }
            }
            steps {
                unstash 'source'
                unstash 'node_modules'
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            agent any   // runs on the Jenkins controller - it already has the Docker CLI installed and DOCKER_HOST pointed at docker-dind (in docker-compose.yml)
            steps {
                unstash 'source'
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Push to Registry') {
            agent any
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKERHUB_USER',
                    passwordVariable: 'DOCKERHUB_TOKEN'
                )]) {
                    sh '''
                        echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${IMAGE_NAME}:latest
                    '''
                }
            }
            post {
                always {
                    sh 'docker logout || true'   // never leave credentials cached
                                                  // on the agent after this stage
                }
            }
        }
    }

    post {
        always {
            node('') {
            }
        }
        failure {
            echo "Pipeline failed - check the stage logs above for details."
        }
    }
}
EOF
