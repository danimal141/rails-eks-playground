locals {
  aws_auth = <<CONFIGMAP
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAP

  rails_config = <<CONFIGMAP
apiVersion: v1
kind: ConfigMap
metadata:
  name: rails-config
data:
  RAILS_ENV: ${var.environment}
  RAILS_SERVE_STATIC_FILES: "true"
  DB_USER: ${var.db_username}
  DB_PASSWORD: ${var.db_password}
  DB_HOST: ${aws_db_instance.rds.address}
CONFIGMAP

  db_setup_job = <<JOB
apiVersion: batch/v1
kind: Job
metadata:
  name: db-setup-job
spec:
  template:
    metadata:
      name: db-setup-job
    spec:
      containers:
      - name: db-setup-job
        image: ${aws_ecr_repository.ecr.repository_url}
        imagePullPolicy: Always
        command: ["bash"]
        args: ["-c", "bundle exec rails db:create && bundle exec rails db:migrate"]
        envFrom:
        - configMapRef:
            name: rails-config
      restartPolicy: Never
  backoffLimit: 1
JOB

  deploy = <<DEPLOY
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy
  labels:
    app: sample-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sample-api
  template:
    metadata:
      labels:
        app: sample-api
    spec:
      containers:
      - name: sample-api
        image: ${aws_ecr_repository.ecr.repository_url}
        imagePullPolicy: Always
        ports:
        - containerPort: 3000
        envFrom:
        - configMapRef:
            name: rails-config

---
apiVersion: v1
kind: Service
metadata:
  name: sample-api-service
spec:
  type: LoadBalancer
  selector:
    app: sample-api
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
DEPLOY
}

output "aws_auth" {
  value = local.aws_auth
}

output "rails_config" {
  value = local.rails_config
}

output "db_setup_job" {
  value = local.db_setup_job
}

output "deploy" {
  value = local.deploy
}
