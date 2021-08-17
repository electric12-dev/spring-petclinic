pipeline {
    agent any
    stages {
        stage('Pull SCM') {
            steps {
                dir("$WORKSPACE") {
                checkout(
                    scm: [
                        $class: 'GitSCM',
                        branches: [[name: "*/main"]],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [],
                        submoduleCfg: [],
                        userRemoteConfigs: [[url: 'https://github.com/electric12-dev/spring-petclinic', credentialsId: 'git-hub_key']]]
                    )
                }
            }
            
        }
        stage("Build Jar artefact"){
            steps{
                echo 'Running build automation'
                sh './mvnw clean package -Dmaven.test.skip=true'
              }
            }
        stage('Build Docker Image Petclinic') {
            steps {
                script {
                    sh 'newgrp docker'
                    app = docker.build("eclipseq57/petclinic")
                }
            }
        
        }
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', "Docker"){
                        app.push("${env.BUILD_ID}")
                        app.push("latest")
                    }
                }
            }
        }
        stage("Deploy Petclinic to server"){
            steps{
                echo 'Donload image'
                sh 'docker run -d --name petclinic -p 8080:8080 eclipseq57/petclinic:latest'
                sh 'sleep 30'
              }
            }
    }
}
