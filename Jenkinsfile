pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        sh 'echo "--------- Build stage ---------"'
        sh '''ansiblev=$(rpm -qa | grep ansible)
ansible=$(echo "$ansiblev" | awk -F "-" \'{print $1}\')
if [ $ansible = \'ansible\' ]
then
   echo "---------- Ansible is Already installed ---------"
   echo "$ansiblev"
else
   echo "---------- Installing Ansible ----------"   
   yum install -y ansible
fi'''
      }
    }

    stage('Deploy') {
      steps {
        sh '''echo "--------- Executing Ansible Playbook -------------"
ansible-playbook  /var/lib/jenkins/workspace/ELK_stack_automation_master/playbook.yml'''
      }
    }

    stage('Test') {
      steps {
        sh 'echo "-------- Testing ----------"'
      }
    }

  }
}