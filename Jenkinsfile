pipeline {
  agent {
    kubernetes {
      label 'go'
      containerTemplate {
        name 'go'
        image 'golang:1.9.1-alpine3.6'
        ttyEnabled true
        command 'cat'
      }
    }
}

  stages {
    stage('Build Frontend component') {
      steps {
        container('go') {
          sh 'go build dispatcher.go'
        }
      }
    }
  }
}

