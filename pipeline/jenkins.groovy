pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: go
      image: golang:1.24.1
      command: ['cat']
      tty: true
    - name: docker
      image: docker:26.0.0-cli
      command: ['cat']
      tty: true
      volumeMounts:
        - name: docker-sock
          mountPath: /var/run/docker.sock
  volumes:
    - name: docker-sock
      hostPath:
        path: /var/run/docker.sock
"""
            defaultContainer 'go'
        }
    }
    parameters {
        choice(name: 'OS', choices: ['linux', 'darwin', 'windows'], description: 'Target operating system')
        choice(name: 'ARCH', choices: ['amd64', 'arm64'], description: 'Target architecture')
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip running tests')
        booleanParam(name: 'SKIP_LINT', defaultValue: false, description: 'Skip running linter')
    }
    stages {
        stage('Lint') {
            when { expression { return !params.SKIP_LINT } }
            steps {
                sh 'git config --global --add safe.directory "*"'
                sh 'go version'
                sh 'go install golang.org/x/lint/golint@latest'
                sh 'export PATH=$PATH:$(go env GOPATH)/bin'
                sh 'make lint'
            }
        }
        stage('Test') {
            when { expression { return !params.SKIP_TESTS } }
            steps {
                sh 'git config --global --add safe.directory "*"'
                sh 'make test'
            }
        }
        stage('Build') {
            steps {
                sh "make build TARGETOS=${params.OS} TARGETARCH=${params.ARCH}"
            }
        }
        stage('Docker Image') {
            steps {
                container('docker') {
                    sh 'docker version'
                    sh "make image TARGETOS=${params.OS} TARGETARCH=${params.ARCH}"
                }
            }
        }
    }
}
