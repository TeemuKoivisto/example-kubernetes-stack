# AWS infra for the stack using Sceptre 2

The CloudFormation stacks for deploying the app with Sceptre on AWS.

**Table of Contents**

<!-- toc -->
<!-- tocstop -->

# Prerequisites

Requires Python >= 3.5, aws-cli and Sceptre 2.x installed globally: `pip install aws-cli sceptre -U` (or `python3 -m pip install aws-cli sceptre -U` if you have different default Python eg. macOS).

And I couldn't install Sceptre globally with pip and Brew installed Sceptre wouldn't work with custom resolvers, alas I had to install it the right way with virtualenvwrapper: `workon cf && pip install sceptre`. Pyenv I've heard is also pretty good, the basic virtualenv is bit annoying to use.

Also a local AWS IAM user with somewhat extensive access privileges. It's easiest to launch the stack locally with admin privileges.

# How to launch

Well as I've made this stack more and more complicated you now need to do a few things first before deploying the whole thing.

1) Install the custom resolver. So go to the `sceptre`-folder and enter: `pip install ./ssm_parameter`. There's a README inside it to explain what it does
2) Launch the `custom-resource-ssm-parameter` stack with eg: `AWS_PROFILE=yourprofile sceptre launch dev/eu-west-1/custom-resource-ssm-parameter`
3) Open the AWS console, **select `eu-west-1` AWS region** and create the `secret-ssm-parameter.yaml`-stack manually by going to CloudFormation and clicking `Create stack > With new resources (standard)`. Then select `Upload a template file` and choose that file, enter a stack name eg `example-app-dev-eu-west-1-secret-ssm-parameters` and generate the database credentials and JWT secret. You can use something like KeePassXC to generate 32-length passwords with special characters and whatnot. The db username can be just a regular name (but hopefully not `postgres`). After that just hit next until the stack is being deployed and if everything should go as planned, it should be ready in about 1 minute.
4) Then you should open up the `eu-west-1/ecr.yaml`-file and modify `AllowedPullAccessAWSAccountId` to your AWS account id where your stacks are being deployed to. If you are using your root account, I highly advise you to create another account for accessing the AWS console with admin+billing privileges since using root account is bad practise. Then launch the ECR stack: `AWS_PROFILE=yourprofile sceptre launch dev/eu-west-1/ecr`.
5) Go to the `my-node-bootstrap` folder and build and push the app's Docker image to ECR: `AWS_PROFILE=yourprofile ./cf-build-to-ecr.sh`. Change the values in the script accordingly (probably you should change them in every script while you are at it)
6) Now you can actually deploy the rest of the stack: `AWS_PROFILE=yourprofile sceptre launch dev`. This might take a while and hopefully you didn't have your old edge-lambdas lying around (and the version is correct)
7) As the stack is launching at some point when `static-bucket.yaml` is ready you can deploy the frontend React app. Go to the `my-react-bootstrap` and enter: `AWS_PROFILE=yourprofile ./deploy.sh bucket` where you should replace the bucket with yours eg `example-app-dev-eu-west-1-static-buc-staticbucket-y7jfi5ocjjwh`
8) Now, or possibly in ~15 minutes, the CloudFront should have the S3 assets available and visiting the distribution eg https://d2dqwr5ltqbyap.cloudfront.net/ should show a working React app. If you receive 403 with a S3 static site URL, wait for a while or try another url eg https://d2dqwr5ltqbyap.cloudfront.net/login (the error response might have gotten cached). It's weird that it doesn't work right away, I know ¯\_(ツ)_/¯. Just be patient and watch the CloudFormation logs for errors

You can also launch stacks one by one eg: `AWS_PROFILE=koodivelho sceptre launch dev/eu-west-1/static-bucket`

# Deletion

`AWS_PROFILE=yourprofile sceptre delete dev` should remove most of the resources, but some eg S3 bucket are retained. Deletion itself will take some time to disable and remove CloudFront, EdgeLambda and the ECS cluster.

To manually delete the rest of them, go to the following service pages:
* S3 > Bucket 
* CloudFront > AccessIdentity
* ECR > example-app & migration repositories
* CloudFormation > `secret-ssm-parameters` stack you launched manually
* RDS > Snapshots

Most importantly you should, when your CloudFront distribution has been finally purged from the edge locations, delete the EdgeLambda in `us-east-1` region. Otherwise it will fail your next fresh deployments.

Aand if you have manually bumped the `EdgeLambdaVersion` in the `eu-west-1/cloudfront.yaml` file, remember to reset it to `'1'`. Although for some reason the old version persists even when I have deleted the edge-lambda. So ehh, keep that in mind when re-launching this same stack.

# Description

So as you can see from the CloudFormation files, this is a lot more complicated version of the stack than the Docker Compose and local Kubernetes versions. Mainly because this thing is actually production-ready, and not just a toy-app.

What makes the whole thing so large are the various AWS services and boilerplate gluing between them eg exporting/outputting parameters and so on. But in short, this is how it works:

**VPC**:
* One VPC with CIDR of 10.10.0.0/16 meaning 2^16 addresses (a lot) 
* 3 public, 3 private subnets with each a /20 block (2^(32-20)=2^12=4096 addresses minus reserved ones)
* Each subnet requires its own route table
* Each private subnet requires NAT for internet access (which costs €)
* VPC requires its own Internet Gateway for internet access
* One private Hosted Zone for accessing private resources inside AWS

**ECS Cluster**:
* In the same VPC the ECS cluster with the ALB and its target group and scaling role

**ECS Service**:
* In the same VPC the ECS Fargate service, running on the previous ECS cluster
* Runs the public facing application servers
* It has some hand-crafted CPU & RAM limits (to keep the costs reasonably low)
* It runs the Example NodeJS app tasks with logs outputted to CloudWatch and env variables fetched from SSM
* Has role for the task and task's execution
* Target group and policy for autoscaling

**ECR**:
* The template for creating the Elastic Container Registry (ECR)
* Used for storing the Docker images (example-nodejs, migration)

**Security groups**:
* The security groups for the app, DB and ALB

**CloudFront**:
* Creates the endpoints for the static S3 assets (React) in /
* And the endpoint for the NodeJS app's ALB in /api/
* Redirects to HTTPS, stores logs to the static bucket and some other basic config

**Static Bucket**:
* The bucket for the static frontend assets & CloudFront logs
* Also CloudFrontOriginAccessIdentity for best practise way of accessing the bucket
* Policy for the AccessIdentity to allow GetObject -access

**Edge Lambda**:

Since the way CDNs work, you can only cache "real" URLs that access directly a resource using URL. Meaning since SPAs are by definition Single Page Applications, they have a single page/endpoint for everything. So every route eg /login or /user/1/edit should resolve to the same page/URL where the SPA is. To do this we need an Edge Lambda that redirects all requests to that SPA, which in our case is the `index.html` at / of the domain.

* The edge lambda for rewriting URLs
* Also role for the lambda, with access to CloudWatch and XRay to better monitor it
* TODO I think there should be now an automatic way to deploy the new Edge Lambda versions

**DB**:
* Database with minimal size & cost (eg no MultiAZ in dev, smallest EBS possible)
* Basic Postgres database, no Aurora (as it's little more expensive)
* Its own private db subnet
* Outputs some values for the application & migration ECS tasks

**DB ECS Task**:
* ECS task for launching the migration Docker containers
* Includes also log group, task role and task execution role
* Runs Flyway migrations & seeding of the database
* Uses "MigrationChecksumParameter" to avoid running migrations needlessly in the CI pipeline

**SSM parameter Custom Resource**:
* Custom CF resource for creating SSM parameters inside the CF stacks 

**Secret SSM paramaters (manual)**:
* Manual stack for creating the JWT & DB credentials with user inputted values
* Uses the previous custom resource

# TODO

* maybe instructions for adding domain with Route53?
* SES and some type of error messages to email?