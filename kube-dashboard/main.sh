###A script to deploy the kubernetes dashboard
##Copyright Cloud Technology Experts
###https://cloudtechnologyexperts.com
###prerequisite: requires a running kubernetes cluster. It was tested on a cluster deployed with kubeadm

#prepare the certificates
BASE_DIR=$(pwd)
mkdir $HOME/certs
cd $HOME/certs
openssl genrsa -out dashboard.key 2048
openssl rsa -in dashboard.key -out dashboard.key
openssl req -sha256 -new -key dashboard.key -out dashboard.csr -subj '/CN=localhost'
openssl x509 -req -sha256 -days 365 -in dashboard.csr -signkey dashboard.key -out dashboard.crt

#load the certificates
kubectl -n kube-system create secret generic kubernetes-dashboard-certs --from-file=$HOME/certs

#Deploy the dashboard
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml
#lets check
kubectl -n kubernetes-dashboard get rs

#create the pod security policy
cd $BASE_DIR
kubectl create -f psp.yaml

#Create a role to allow use of the PSP
kubectl -n kubernetes-dashboard create role psp:dashboard --verb=use --resource=podsecuritypolicy --resource-name=dashboard
#Bind the role to kubernetes-dashboard service account
kubectl -n kubernetes-dashboard create rolebinding kubernetes-dashboard-policy --role=psp:dashboard --serviceaccount=kube-system:kubernetes-dashboard
#test the role is effective
kubectl --as=system:serviceaccount:kube-system:kubernetes-dashboard -n kubernetes-dashboard auth can-i use podsecuritypolicy/dashboard

#Lets edit the role for Nodeport
#we did the existing and then we create a new one

kubectl delete svc kubernetes-dashboard -n kubernetes-dashboard
kubectl create -f nodeport-svc.yaml

kubectl create -f dashboard.yaml
kubectl describe secret admin-token -n kube-system

#now you can login with the token
