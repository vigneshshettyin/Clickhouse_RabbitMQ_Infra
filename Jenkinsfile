pipeline {
    agent any

    environment {
        GIT_REPO_URL = 'https://github.com/vigneshshettyin/Clickhouse_RabbitMQ_Infra.git'
        GIT_BRANCH = 'main'
        CH_CRED = credentials('CLICKHOUSE_CREDENTIALS')
        MQ_CRED = credentials('RABBITMQ_CREDENTIALS')
        CLICKHOUSE_USER = "${CH_CRED_USR}"
        CLICKHOUSE_PASSWORD = "${CH_CRED_PSW}"
        RABBITMQ_DEFAULT_USER = "${MQ_CRED_USR}"
        RABBITMQ_DEFAULT_PASS = "${MQ_CRED_PSW}"
    }

    stages {
        stage('Pull Code') {
            steps {
                git url: env.GIT_REPO_URL, branch: env.GIT_BRANCH
            }
        }
        stage('Deploy Container') {
            steps {
                sh "chmod +x rabbitmq-entrypoint.sh"
                sh "docker compose down && docker compose up -d"
            }
        }
    }

    post {
        always {
            sh 'rm -f *.log'
            script {
                def logContent = currentBuild.rawBuild.getLog(1000).join("\n")
                writeFile file: 'console.log', text: logContent
                archiveArtifacts artifacts: 'console.log', allowEmptyArchive: true
            }
            sh "docker system prune -af"
            sh "docker volume prune -f"
            emailext (
                subject: "Build ${currentBuild.fullDisplayName}: ${currentBuild.currentResult}",
                body: """
                    <html>
                        <head>
                            <style>
                                body { font-family: Arial, sans-serif; color: #333333; }
                                .email-header {
                                    background-color: #333333;
                                    color: #ffffff;
                                    padding: 15px;
                                    text-align: center;
                                }
                                .email-header img {
                                    width: 50px;
                                    vertical-align: middle;
                                    margin-right: 10px;
                                }
                                .email-header h2 {
                                    display: inline;
                                    font-size: 20px;
                                }
                                .build-status-card {
                                    padding: 10px;
                                    color: #ffffff;
                                    font-size: 16px;
                                    border-radius: 5px;
                                    width: fit-content;
                                    margin: 10px auto;
                                    text-align: center;
                                }
                                .success-card { background-color: #4CAF50; }
                                .failure-card { background-color: #F44336; }
                                .build-details {
                                    width: 100%;
                                    margin-top: 20px;
                                }
                                .build-details table {
                                    width: 100%;
                                    border-collapse: collapse;
                                }
                                .build-details th, .build-details td {
                                    border: 1px solid #dddddd;
                                    padding: 8px;
                                    text-align: left;
                                }
                                .build-details th {
                                    background-color: #f2f2f2;
                                }
                                .footer {
                                    margin-top: 30px;
                                    font-size: 12px;
                                    color: #555555;
                                    text-align: center;
                                }
                            </style>
                        </head>
                        <body>
                            <div class="email-header">
                                <img src="https://www.jenkins.io/images/logos/jenkins/jenkins.png" alt="Jenkins Logo" />
                                <h2>Jenkins Build Notification</h2>
                            </div>
            
                            <div class="build-status-card ${currentBuild.currentResult == 'SUCCESS' ? 'success-card' : 'failure-card'}">
                                <b>Build Status:</b> ${currentBuild.currentResult}
                            </div>
            
                            <div class="build-details">
                                <table>
                                    <tr>
                                        <th>Project</th>
                                        <td>Clickhouse RabbitMQ Infra</td>
                                    </tr>
                                    <tr>
                                        <th>Build Number</th>
                                        <td>${env.BUILD_NUMBER}</td>
                                    </tr>
                                    <tr>
                                        <th>Branch</th>
                                        <td>${GIT_BRANCH}</td>
                                    </tr>
                                    <tr>
                                        <th>Duration</th>
                                        <td>${currentBuild.durationString}</td>
                                    </tr>
                                    <tr>
                                        <th>Changes</th>
                                        <td>${currentBuild.changeSets.collect { it.items.collect { it.msg } }.flatten().join('<br>')}</td>
                                    </tr>
                                    <tr>
                                        <th>Build URL</th>
                                        <td><a href="${env.BUILD_URL}">${env.BUILD_URL}</a></td>
                                    </tr>
                                </table>
                            </div>
            
                            <div class="footer">
                                <p>Best regards,<br><b>Jenkins CI/CD</b></p>
                                <p>Attached logs, if any, can be found below.</p>
                            </div>
                        </body>
                    </html>
                """,
                mimeType: 'text/html',
                from: 'Jenkins <build@vshetty.dev>',
                to: 'jenkins+vignesh@vshetty.dev, vijeshsshetty@gmail.com',
                attachmentsPattern: '*.log'
            )
        }
    }
}
