# rails-eks-playground

This is a toy project to try to create a Rails environment using EKS.

## Dependencies
- AWS command (`v1.18.*`)
- kubectl (`v1.17.*`)
- Terraform (`v0.12.*`)

## Create EKS base

```bash
// Initialize working dir
$ terraform init

// dry-run
$ terraform plan

// Create or change resources
$ terraform apply -var 'key_name=YOUR KEY NAME'

// Delete resources
$ terraform destroy
```

## Recognize nodes

```bash
$ mkdir -p .kube
$ mkdir -p manifests

$ terraform output kubectl_config > .kube/config
or
$ aws eks update-kubeconfig --name ${cluster_name}

// https://aws.amazon.com/premiumsupport/knowledge-center/eks-worker-nodes-cluster/?nc1=h_ls
// https://aws.amazon.com/jp/premiumsupport/knowledge-center/amazon-eks-cluster-access/
$ terraform output aws_auth_configmap > ./manifests/awh-auth.yml

$ export KUBECONFIG='.kube/config'
$ kubectl apply -f manifests/aws-auth.yml

// Check
$ kubectl get nodes
```
