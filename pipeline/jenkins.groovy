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
    - name: buildx
      image: moby/buildkit:buildx-stable-1
      command: ['buildkitd', '--addr', 'tcp://0.0.0.0:1234']
      tty: true
    - name: buildctl
      image: moby/buildkit:buildx-stable-1
      command: ['sleep', 'infinity']
      tty: true
      env:
        - name: BUILDKIT_HOST
          value: "tcp://localhost:1234"
      volumeMounts:
        - name: docker-config
          mountPath: /root/.docker
  volumes:
    - name: docker-config
      secret:
        secretName: regcred
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
                container('buildctl') {
                    sh '''
                    buildctl build \
                      --frontend=dockerfile.v0 \
                      --local context=. \
                      --local dockerfile=. \
                      --output type=image,name=ghcr.io/bwoogmy/kbot:test-buildx,push=true
                    '''
                }
            }
        }
    }
}
