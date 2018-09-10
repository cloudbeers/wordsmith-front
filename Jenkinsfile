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
      script {
            def now = new Date()
            APPLICATION_VERSION = now.format("yyMMdd.HHmm", TimeZone.getTimeZone('UTC'))
            writeFile('VERSION', APPLICATION_VERSION)
          }
      steps {
        container('go') {
          sh 'go build dispatcher.go'
          archiveArtifacts artifacts: "dispatcher", fingerprint: true
        }
      }
    }
    stage('Build Docker image') {
      environment {
        DOCKER_HUB_CREDS = credentials('hub.docker.com')
      }
      steps {
        script {
            APPLICATION_VERSION = readFile('VERSION')
          }
        container('docker') {
          sh """
             docker login --username ${DOCKER_HUB_CREDS_USR} --password ${DOCKER_HUB_CREDS_PSW}
             docker build -t ${DOCKER_HUB_CREDS_USR}/wordsmith-front:${APPLICATION_VERSION} .
             docker push ${DOCKER_HUB_CREDS_USR}/wordsmith-front:${APPLICATION_VERSION}
           """
        }
      }
    }
  }
}

