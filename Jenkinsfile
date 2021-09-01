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
                    sh 'newgrp docker && systemctl restart docker'
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
                sh 'docker system prune -af'
                sh 'docker run -d --name petclinic -p 8080:8080 eclipseq57/petclinic:latest'
                sh 'sleep 30'
              }
            }
        stage("Wait for an app is up"){
            steps{
                sh '''#!/bin/bash
                status=$(curl http://localhost:8080 -s -o /dev/null -w "%{http_code}")
                until [ $status == 200 ]
                  do
                    sleep 30
                    echo "Wait another 30 sec"
                    status=$(curl http://localhost:8080 -s -o /dev/null -w "%{http_code}")
                  done
                  echo "Petclinic is ready!!!"'''
              }
            }
       }
        post { 
            always { 
                cleanWs()
        }
    }
}
