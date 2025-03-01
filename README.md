# Create SSH Keypair for Linux EC2 instance
ssh-keygen -t rsa -f mgibson13-asgn2

# Deploy EC2 instance and ECR repository
terraform init

terraform apply --auto-approve
