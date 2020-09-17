# rails-eks-playground

This is a toy project to try to create a Rails environment using EKS.

## Development in local

```bash
$ docker-compose up
// Access http://localhost:3000

// Execute commands
$  server/bin/run-server rails console
```

## Deployment

There is a container to execute commands related to the deployment.

```bash
$ docker-compose up

// Work in the deploy container
$ docker-compose exec deploy ash
```

### For terraform
```bash
$ cd /workspace/terraform

// Initialize working dir
$ terraform init

// dry-run
$ terraform plan

// Create or change resources
// Specify key_name for EC2 instances
// If necessary, please override variables
$ terraform apply

$ terraform output aws_auth > /workspace/k8s/aws-auth.yaml
$ terraform output rails_config > /workspace/k8s/rails-config.yaml
$ terraform output db_setup_job > /workspace/k8s/db-setup-job.yaml
$ terraform output deploy > /workspace/k8s/aws-auth.yaml

// Delete resources
$ terraform destroy
```

### Push an image

```bash
$ aws ecr describe-repositories
// Check the repository uri

$ cd /workspace/server

$ docker build -t ${repositoryUri}:latest --build-arg BUILD_MODE=production .
// Log in to ECR
$ $(aws ecr get-login --no-include-email --region ap-northeast-1)
$ docker push ${repositoryUri}:latest
```

### For kubernetes

```bash
$ cd /workspace/k8s

$ aws eks update-kubeconfig --name ${cluster_name}
$ kubectl apply -f aws-auth.yaml

// Check whether to get nodes correctly
$ kubectl get nodes

$ kubectl apply -f rails-config.yaml
$ kubectl apply -f db-setup-job.yaml
$ kubectl apply -f deploy.yaml

$ kubectl get services
// Find LoadBalancer Ingress value and make sure whether it works well

// Create a new record
$ kubectl exec -it ${pod_name} rails c
$ User.create(name: 'some-name')

// Clean up
$ kubectl delete -f rails-config.yaml
$ kubectl delete -f db-setup-job.yaml
$ kubectl delete -f deploy.yaml
```
