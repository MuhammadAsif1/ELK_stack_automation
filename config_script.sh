#! /bin/bash

# include parse_yaml function
. /etc/ansible/ELK_stack_automation/parse_yaml.sh

# read yaml file
eval $(parse_yaml nodes_config.yml "config_")


echo "---------------------------------------------------------------------------------------------"
echo "-------------------------- Ansible Playbook to Configure K8-master and docker ---------------"
echo "---------------------------------------------------------------------------------------------"
ansible-playbook -i /etc/ansible/ELK_stack_automation/hosts k8_playbook.yml 
echo "---------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------"


k8_nodes_config()
{
  sshpass -p $config_workernode2_password ssh $config_workernode2_user@$config_workernode2_IP "hostname worker-node2"
  echo "---------------------------------------------------------------------------------------------"
  echo "------------ Ansible Playbook to Configure K8-nodes and docker on worker nodes --------------"
  echo "---------------------------------------------------------------------------------------------"
  ansible-playbook -i /etc/ansible/ELK_stack_automation/hosts k8_worker_nodes.yml
  echo "---------------------------------------------------------------------------------------------"
  echo "---------------------------------------------------------------------------------------------"
}


scaning_and_joining_cluster()
{
  node=$(kubectl get nodes | awk  '/worker-node2/{print $1}')
  if [ "$node" != 'worker-node2' ]
  then
    echo "======================= Reseting Kubeadm on worker node ==============================="
    sshpass -p $config_workernode2_password ssh $config_workernode2_user@$config_workernode2_IP "echo y | kubeadm reset"
    echo "======================= Creating Token ==============================="
    token=$(kubeadm token create)
    echo "======================= Worker Node joining K8 Cluster ==============================="
    port=':6443'
    masterserver=$config_k8smaster_IP$port
    sshpass -p $config_workernode2_password ssh $config_workernode2_user@$config_workernode2_IP "kubeadm join $masterserver --token $token  --discovery-token-unsafe-skip-ca-verification"
  else
    echo "------------------------------------------------------------------------------------------"
    echo "---------------------- 'worker-node2' Already present in Cluster -------------------------"
    echo "------------------------------------------------------------------------------------------"
  fi
}





kubectl get nodes 2> file
data=$(cat file)
[ -s file ]
data=$(echo $?)
if [ "$data" -lt 1  ];
then
  echo "Error Occured!"
  echo "Resolving issues ..........................................."
  echo "----------------------- Reset Kubeadm ----------------------"
  echo y | kubeadm reset
  echo "----------------------- Initializing Kubeadm ---------------"
  v=$(kubeadm init)
  echo "$v"
  echo "$v" > kubeadm_init
  echo "----------------------- Setting cluster as a root user ----"
  mkdir -p $HOME/.kube
  sudo echo y | cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  echo "-----------------------------------------------------------"
  echo "----------------------- Kubectl Nodes ---------------------"
  echo "-----------------------------------------------------------"
  output=$(kubectl get nodes)
  echo "$output"
  echo "-----------------------------------------------------------"
  echo "-----------------------------------------------------------"
  export kubever=$(kubectl version | base64 | tr -d '\n')
  kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
  k8_nodes_config
  scaning_and_joining_cluster
  rm -f file
  echo "-----------------------------------------------------------"
  echo "----------------------- Kubectl Pods ----------------------"
  echo "-----------------------------------------------------------"
  output=$(kubectl get pods --all-namespaces)
  echo "$output"
  echo "-----------------------------------------------------------"
  echo "-----------------------------------------------------------"
else
  echo "Successfully running"
  echo "-----------------------------------------------------------"
  echo "----------------------- Kubectl Nodes ---------------------"
  echo "-----------------------------------------------------------"
  output=$(kubectl get nodes)
  echo "$output"
  echo "-----------------------------------------------------------"
  echo "-----------------------------------------------------------"
  echo "-----------------------------------------------------------"
  echo "----------------------- Kubectl Pods ----------------------"
  echo "-----------------------------------------------------------"
  output1=$(kubectl get pods --all-namespaces)
  echo "$output1"
  echo "-----------------------------------------------------------"
  echo "-----------------------------------------------------------"
  scaning_and_joining_cluster
fi








