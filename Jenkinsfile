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
    - name: helm
      image: devth/helm
      command:
      - cat
      tty: true
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
        script {
            def now = new Date()
            APPLICATION_VERSION = now.format("yyyyMMdd-HHmm", TimeZone.getTimeZone('UTC'))
            writeFile(file: 'VERSION', text: APPLICATION_VERSION)
        }
        container('go') {
          sh 'go build dispatcher.go'
          sh """
            sed -i.bak -e "s/{{version}}/${APPLICATION_VERSION}/" wordsmith-front/values.yaml
            sed -i.bak -e "s/{{version}}/${APPLICATION_VERSION}/" wordsmith-front/Chart.yaml
          """
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
    stage('Build Helm chart') {
      steps {
        container('helm') {
          script {
            APPLICATION_VERSION = readFile("VERSION")
          }
          sh """
             # create helm chart version
             helm package wordsmith-front
             # upload helm chart
             curl --data-binary "@wordsmith-front-${APPLICATION_VERSION}.tgz" http://chartmuseum-chartmuseum.core.svc.cluster.local:8080/api/charts
             """
          archiveArtifacts artifacts: "wordsmith-front-${APPLICATION_VERSION}.tgz", fingerprint: true
        }
      }
    }
  }
}

