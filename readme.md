docker pull jenkins/jenkins
docker run -d -p 8080:8080 --name=jenkins-master jenkins/jenkins
docker run -p 8080:8080 --name=jenkins-master -d --env JAVA_OPTS="-Xmx8192m" --env JENKINS_OPTS=" --handlerCountMax=300" jenkins/jenkins


#docker run and mount efs to jenkins home 
docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home --name=jenkins-master jenkins/jenkins:latest