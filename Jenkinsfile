pipeline {
    agent none // We define the agent per stage for better control

    environment {
        IMAGE_NAME = "demo"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        APP_PORT = "9001"
    }

    stages {
        stage('Compile & Package') {
            agent {
                docker {
                    image 'maven:3.9.6-eclipse-temurin-17'
                    // This shares the local maven repo so it doesn't redownload internet every time
                    args '-v $HOME/.m2:/var/maven/.m2'
                }
            }
            steps {
                echo '📦 Compiling inside Maven container...'
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            agent any // Switch back to the main node to run Docker commands
            steps {
                echo "🏗️ Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Verify & Approve') {
            agent any
            steps {
                input message: "Deploy version ${IMAGE_TAG}?", ok: "Deploy!"
            }
        }

        stage('Deploy to Production') {
            agent any
            steps {
                script {
                    sh "docker rm -f ${IMAGE_NAME} || true"
                    sh "docker run -d -p ${APP_PORT}:${APP_PORT} --name ${IMAGE_NAME} ${IMAGE_NAME}:${IMAGE_TAG}"

                    echo "⏳ Triggered the deployment for app..."
                }
            }
        }
    }
}
