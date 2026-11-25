pipeline {
    agent any

    triggers {
        pollSCM('H/2 * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Security Tools') {
            steps {
                sh '''
                    python3 -m venv .jenkins-venv
                    .jenkins-venv/bin/pip install -q bandit pip-audit
                    .jenkins-venv/bin/bandit --version | head -n 1
                    .jenkins-venv/bin/pip-audit --version
                '''
            }
        }

        stage('Bandit Security Scan') {
            steps {
                sh '''
                    .jenkins-venv/bin/bandit -r app monitoring -f txt -o bandit-report.txt || test "$?" -eq 1
                    cat bandit-report.txt
                '''
            }
        }

        stage('Security Gate') {
            steps {
                sh '''
                    echo "Gate rule: the build fails if Bandit reports any HIGH severity issue."
                    .jenkins-venv/bin/bandit -r app monitoring -lll -q
                    echo "No HIGH severity issue found. Gate passed."
                '''
            }
        }

        stage('Dependency Audit') {
            steps {
                sh '''
                    .jenkins-venv/bin/pip-audit -r requirements.txt -f json -o pip-audit-report.json
                    .jenkins-venv/bin/pip-audit -r requirements.txt
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'bandit-report.txt,pip-audit-report.json', allowEmptyArchive: true
        }
        success {
            echo 'DevSecOps pipeline completed successfully!'
        }
        failure {
            echo 'DevSecOps pipeline failed: a security check did not pass.'
        }
    }
}
