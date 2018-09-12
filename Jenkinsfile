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
    - name: kubectl
      image: lachlanevenson/k8s-kubectl:v1.10.7
      command:
      - cat
      tty: true
    - name: curl
      image: appropriate/curl
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
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
    disableConcurrentBuilds()
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
             helm lint wordsmith-front
             helm package wordsmith-front
             # upload helm chart
             curl --data-binary "@wordsmith-front-${APPLICATION_VERSION}.tgz" http://chartmuseum-chartmuseum.core.svc.cluster.local:8080/api/charts
             """
          archiveArtifacts artifacts: "wordsmith-front-${APPLICATION_VERSION}.tgz", fingerprint: true
        }
      }
    }

    stage('Deploy to Preview Environment') {
      environment {
         APP_HOST = 'front.preview.wordsmith.beescloud.com'
      }
      steps {
        container('helm') {
          script {
            APPLICATION_VERSION = readFile("VERSION")
          }
          sh """

             helm init --client-only
             helm repo add wordsmith http://chartmuseum-chartmuseum.core.svc.cluster.local:8080
             helm repo update

             helm upgrade wordsmith-front-preview wordsmith/wordsmith-front --version ${APPLICATION_VERSION} --install --namespace preview --wait \
                --set ingress.hosts[0]=${APP_HOST},api.url=api.preview.wordsmith.beescloud.com,image.pullPolicy=Always
            """
        }
        container('kubectl') {
          sh """
            kubectl describe deployment wordsmith-front-preview --namespace preview
            kubectl get ingress wordsmith-front-preview --namespace preview
          """
        }
        container('curl') {
          sh """
            curl -v https://front.preview.wordsmith.beescloud.com/version
          """
        }
      }
    }
  }
}

