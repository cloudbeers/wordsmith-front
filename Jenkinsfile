pipeline {
  agent {
    kubernetes {
      label 'wordsmith-front'
      yaml """
  spec:
    containers:
    - name: jnlp
    - name: go
      image: golang:1.9.1-alpine3.6
      command:
      - cat
      tty: true
    - name: docker
      image: docker:stable-dind
      command:
      - cat
      tty: true
      volumeMounts:
        - mountPath: /var/run/docker.sock
          name: docker-sock
    volumes:
      - name: docker-sock
        hostPath:
          path: /var/run/docker.sock
          type: File
      """
    }
}

  stages {
    stage('Build component') {
      steps {
        container('go') {
          sh 'go build dispatcher.go'
        }
      }
    }
    stage('Build Docker image') {
      steps {
        container('docker') {
          sh 'docker build .'
        }
      }
    }
  }
}

