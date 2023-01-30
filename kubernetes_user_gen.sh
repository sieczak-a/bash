#!/bin/bash

# WARNING
# You need in the same localization ca.crt and ca.key files

# Script generates kubeconfig file for external users. By default certs are valid 365 days.

   # REMEMBER TO SET PROPER CONTEXT
   # kubectl config use-context ...

# for testing use command below:
# kubectl --kubeconfig $user.kubeconfig get pods

echo "Give the username: "
read user

echo "Give the namespace: "
read namespace

if [ -n "$user" ] && [ -n "$namespace" ] ; then

   certificate_data=#paste here hash of certificate data
   
   ip_prod=#clusterIP:6444
   
   cluster_name=test_cluster   
   
   # Generate certs
   openssl genrsa -out $user.key 2048
   openssl req -new -key $user.key -out $user.csr -subj "/CN=$user/O=$namespace"
   openssl x509 -req -in $user.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out $user.crt -days 365
   
   
   # Decode and save certs in variables
   user_cert_base64=$(cat $user.crt | base64 -w0)
   user_private_base64=$(cat $user.key | base64 -w0)
   cur_dir=$(pwd)  
   

   # Create kubeconfig for user
   cat <<-EOF > $cur_dir/$user-kubeconfig
   apiVersion: v1
   clusters:
   - cluster:
       certificate-authority-data: $certificate_data
       server: https://$ip_test
     name: $cluster_name
   contexts:
   - context:
       cluster: $cluster_name
       user: $user
       namespace: $namespace
     name: $user-context
   current-context: $user-context
   kind: Config
   preferences: {}
   users:
   - name: $user
     user:
       client-certificate-data: $user_cert_base64
       client-key-data: $user_private_base64
EOF

   # create given namespace & enable RBAC for given user  
   kubectl create ns $namespace
   kubectl create role $user-$namespace-role --verb=get,list,watch,create,update,patch,delete --resource=pod,sts,deployment,cm,secret,pvc,daemonset,ingress,svc,replicaset --namespace $namespace
   kubectl create rolebinding $user-$namespace-rolebinding --role=$user-$namespace-role --user=$user --namespace $namespace


else
        echo "Username and namespace are required"
        exit
fi
