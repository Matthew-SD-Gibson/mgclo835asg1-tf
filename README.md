# MGCLO835ASG1
# Create SSH Keypair for Linux EC@ instance
ssh-keygen -t rsa -f mgibson13-asgn1

# Deploy EC2 instance and ECR repository
terraform init
terraform apply --auto-approve
