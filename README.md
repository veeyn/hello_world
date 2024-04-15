# hello_world
This repository holds code to deploy a simple RESTful python flask application listening on port 8888 and returns "Hello world" when hitting the endpoint '/hello' using a 'GET' method in AWS.
## Assumptions
*A private ECR needs to be deployed first.
## Architectural Decisions
Because ECS is a popular service within AWS that provides a fully managed container service solution, I've decided to use ECS to deploy our containerized application. The DockerFile gets automatically built and pushed to our private ECR repository when changes are pushed to main. ECS will then pull from our ECR and use the image tag we provide to deploy the containerized application.</br></br>
For security best practices, ECS is configured to deploy the containers into our private subnets of the VPC only. An internet facing application load balancer will be deployed into our public subnet with a HTTP (port 80) listener, which then forwards traffic to a target group, where our containers will be registered.
</br>
Because our containers are deployed into private subnets, in order for the ECS tasks to pull images from our private ECR the following VPC endpoints:
1. com.amazonaws.region.ecr.dkr (This endpoint is used for the Docker Registry APIs. Docker client commands such as push and pull use this endpoint.)
2. com.amazonaws.region.ecr.api (This endpoint is used for calls to the Amazon ECR API. API actions such as DescribeImages and CreateRepository go to this endpoint.)
3. com.amazonaws.region.logs (This endpoint is used to send log information to CloudWatch Logs).
4. For your Amazon ECS tasks to pull private images from Amazon ECR, you must create a gateway endpoint for Amazon S3.
</br>
I have decided to go this route since VPC endpoints enables you to privately access Amazon ECR APIs through private IP addresses and because this project does not require an internet gateway.
