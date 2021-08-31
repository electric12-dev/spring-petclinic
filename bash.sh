#!/bin/bash
status=$(curl http://$1:8081 -s -o /dev/null -w "%{http_code}")
until [ $status == 200 ]
  do
    sleep 30
    echo "Wait another 30 sec"
    status=$(curl http://$1:8081 -s -o /dev/null -w "%{http_code}")
  done
sleep 100
wget http://$1:8081/jnlpJars/jenkins-cli.jar
PluginsList=(
  git
  github-branch-source
  matrix-auth
  role-strategy
  configuration-as-code
  credentials-binding
  ssh-agent
  ws-cleanup
  junit
  build-pipeline-plugin
  conditional-buildstep
  pipeline-stage-view
  parameterized-trigger
  docker-java-api
  docker-workflow
  docker-plugin
  gitlab-plugin
  ssh-slaves
  job-dsl
  )
 
# Print array values in  lines
echo "Print every element in new line"
for plugin in ${PluginsList[*]}; 
  do
   java -jar jenkins-cli.jar -s http://$1:8081/ -auth admin:$2 install-plugin $plugin
  done
java -jar jenkins-cli.jar -s http://$1:8081/ -auth admin:$2 restart
status=$(curl http://$1:8081 -s -o /dev/null -w "%{http_code}")
until [ $status == 200 ]
  do
    sleep 30
    echo "Wait another 30 sec"
    status=$(curl http://$1:8081 -s -o /dev/null -w "%{http_code}")
  done
echo "Jenkins is ready, go ahead" http://$1:8081
