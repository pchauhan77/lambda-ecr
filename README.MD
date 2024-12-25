
**Overview** <br>
This project demonstrates the deployment of a Python-based serverless application using Terraform, AWS, and Docker. The application is packaged as a Docker container and deployed to AWS Lambda. It includes API Gateway integration with endpoints to retrieve, create, and update games, as well as make external API calls.

The infrastructure is provisioned using Terraform and includes a secure Virtual Private Cloud (VPC) with public and private subnets. The application is secured with API Gateway keys for controlled access.

**Features** <br>
Lambda Function:<br>
Implements 4 API endpoints:

/list-games: Retrieves a list of games<br>
/create-game: Creates a new game<br>
/update-game: Updates an existing game<br> 
/external-call: Makes an external API call<br>

**API Gateway:** Routes HTTP requests to the Lambda function<br>
**Dockerized Lambda Function:** Optimized for AWS Lambda runtime<br>
**AWS ECR:** Hosts the Docker image for Lambda<br>
**Secure Infrastructure:** Private subnet for Lambda and API key protection<br>

**Requirements:**<br>
AWS CLI installed and configured with credentials<br>
Terraform installed<br>
Docker installed<br>

**Setup Instructions:**<br>
Clone the Repository<br>
``` bash
git clone https://github.com/pchauhan77/lambda-ecr
```
``` bash
cd lambda-ecr
```

**Build and Push Docker Image:**<br>
Authenticate Docker to AWS ECR:<br>
```bash
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <account_id>.dkr.ecr.ap-south-1.amazonaws.com
```
Build the Docker image:

```bash
docker build -t lambda-docker-repo .
```

Tag the Docker image:

```bash
docker tag lambda-docker-repo:latest <account_id>.dkr.ecr.ap-south-1.amazonaws.com/lambda-docker-repo:latest
```

Push the image to AWS ECR:

```bash
docker push <account_id>.dkr.ecr.ap-south-1.amazonaws.com/lambda-docker-repo:latest
```

Deploy Infrastructure with Terraform

Initialize Terraform:

```bash
terraform init

```
Plan the deployment:

```bash
terraform plan

```
Apply the configuration:

```bash
terraform apply

```
Retrieve the API endpoint and API key:

```bash
terraform output

```

**Key Components**<br>

1. VPC and Subnets:

 Public and private subnets for a secure setup<br>
 Lambda function deployed in the private subnet

2. AWS ECR:
 Repository for hosting the Docker image used by the Lambda function

3. AWS Lambda:

 Serverless function deployed as a Docker container<br>
 Implements the API endpoints
 
4. API Gateway:

 Routes HTTP requests to the Lambda function<br>
 Secured with API keys

5. IAM Roles and Policies:

 Provides Lambda with necessary permissions for logging, VPC access, and ECR

Use the provided API endpoint and API key to test the API. Test all endpoints using curl or Postman
