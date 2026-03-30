pipeline {
    agent any

    environment {
        // Name of your image
        IMAGE_NAME = "demo"
        // Use Jenkins build number as a unique version tag
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        APP_PORT = "9001"
    }

    stages {
        stage('Compile & Package') {
            steps {
                echo '📦 Compiling the application...'
                // Build the JAR using the host's Maven
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🏗️ Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                // Also tag it as 'latest' for convenience
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
            }
        }

        stage('Security Scan (Optional)') {
            steps {
                echo '🛡️ Scanning for vulnerabilities...'
                // Example: sh "docker scout cves ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Verify & Approve') {
            steps {
                // This pauses the pipeline and waits for a human to click 'Proceed'
                input message: "Do you want to deploy version ${IMAGE_TAG} to Production?", ok: "Deploy!"
            }
        }

        stage('Deploy to Production') {
            steps {
                script {
                    echo "🚀 Deploying version ${IMAGE_TAG}..."
                    // 1. Force stop and remove old container
                    sh "docker rm -f ${IMAGE_NAME} || true"

                    // 2. Run new container with unique tag
                    sh "docker run -d -p ${APP_PORT}:${APP_PORT} --name ${IMAGE_NAME} ${IMAGE_NAME}:${IMAGE_TAG}"

                    // 3. Simple health check
                    echo "⏳ Waiting for app to start..."
                    sleep 10
                    sh "curl -f http://localhost:${APP_PORT}/ping || (echo '❌ Health check failed!' && exit 1)"
                }
            }
        }
    }

    post {
        always {
            echo "🧹 Cleaning up workspace..."
            cleanWs()
        }
        success {
            echo "✅ Successfully deployed ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Pipeline failed. Check logs for version ${IMAGE_TAG}"
        }
    }
}
