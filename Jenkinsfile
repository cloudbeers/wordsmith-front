pipeline {
  agent {
    docker {
      image 'golang:1.9.1-alpine3.6'
      label 'go'
    }
  }

  stages {
    stage('Build Frontend component') {
      steps {
        sh 'go build dispatcher.go'
      }
    }
  }
}