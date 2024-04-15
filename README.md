# hello_world
This repository holds code to deploy a simple RESTful python flask application listening on port 8888 and returns "Hello world" when hitting the endpoint '/hello' using a 'GET' method in AWS.

## Assumptions
*A private ECR needs to be deployed first and a docker image must be pushed before creating an ECS service.

## Architectural Decisions
In this project, I will be using the Terraform Cloud workspace to deploy our AWS resources. With ECS being a popular service with AWS, which provides a fully managed container service solution, I have decided to use ECS to deploy our containerized application. For security best practices, I have configured to deploy the containers into our private subnets of the VPC. An internet facing application load balancer will be deployed into our public subnets with a HTTP (port 80) listener, which then forwards traffic to a target group, where our containers will be registered.
</br>
Because our containers are deployed into private subnets, in order for the ECS tasks to pull images from our private ECR the following VPC endpoints are required per AWS documentation:
1. com.amazonaws.region.ecr.dkr (This endpoint is used for the Docker Registry APIs. Docker client commands such as push and pull use this endpoint.)
2. com.amazonaws.region.ecr.api (This endpoint is used for calls to the Amazon ECR API. API actions such as DescribeImages and CreateRepository go to this endpoint.)
3. com.amazonaws.region.logs (This endpoint is used to send log information to CloudWatch Logs).
4. For your Amazon ECS tasks to pull private images from Amazon ECR, you must create a gateway endpoint for Amazon S3.
</br>
I have decided to go this route since VPC endpoints enables you to privately access Amazon ECR APIs through private IP addresses and is more secure than using a NAT gateway, per AWS's recommendations.

## Pipelines
I have created (3) workflows which are described below:
1. CI/CD workflow (On pull request and push to main): This includes a test stage, which has a job to run pytests to validate the GET requests from the / and /hello endpoint. If this is a push to main, the build and test stage is enabled, which has a job to build a new docker image and push the image to our private AWS ECR.
2. Terraform plan workflow (On pull request if changes are made to /terraform): This includes a terraform plan stage, which has a job that will read from our repository, uploads the terraform configuration to Terraform cloud and runs a speculative plan in Terraform cloud. It then extracts the plan output and adds a comment to our pull request and will link to the run in Terraform cloud.
3. Terraform apply workflow (On push to main if changes are made to /terraform): This includes a terraform apply stage, which has a job that will apply the terraform changes from our Terraform plan.

## Retrospective
Being that this was my first time launching an application into AWS - I initially tested within the console manually, so that I had a POC of a working application for myself. If I could go back in time and re-do this project, I would've used Terraform alongside my POC. Using Terraform allowed to me to clean up my resources more efficiently. However, experimenting first with the console allowed me to understand and visually see which inputs I needed to configure within Terraform. I did face challenges understanding how VPC endpoints worked and what ingress/egress rules to define to be able to use these endpoints. How I tackled this challenge was using the default security group and adding rules one a time and re-deployed my ECS service to validate if the containers were successfully launched.
</br></br>
If I had more time...
* I would set up Gitlab OIDC and use the best practice of assuming a role vs. using long term credentials, which this project is currently using.
* I would go over my terraform files and see which hard-coded values can be replaced with variables instead. (This can make updates to these variables to be a lot less complex.)
* I would re-visit my terraform code to see if modules could be used for better organization and reusability.
* If I wanted my application to be more scalable on AWS, I would add autoscaling. I could scale based on the number of requests per target, which could help with handling increased traffic.
* Because my repository isn't a part of a team or enterprise, I was not able to configure branch protection. Ideally, I would require there to be an approver, other than myself, and would not allow merge to main unless the test job has succeeded.

## Endpoint
To verify the output of GET /hello, you can visit this address on your browser: http://my-alb-33276149.us-east-1.elb.amazonaws.com/hello.
</br></br>
Or, on the terminal: curl http://my-alb-33276149.us-east-1.elb.amazonaws.com/hello
