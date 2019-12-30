# AWS infra for the stack using Sceptre 2

The CloudFormation stacks for deploying the app with Sceptre on AWS.

# Prerequisites

Requires Python >= 3.5, aws-cli and Sceptre 2.x installed globally: `pip install aws-cli sceptre -U` (or `python3 -m pip install aws-cli sceptre -U` if you have different default Python eg. macOS).

For some reason I couldn't install Sceptre globally with pip so I instead used Brew: `brew install sceptre`.

Note though, that you can't use custom resolvers with Brew installed Sceptre. So the "right" way would be to use something like pyenv or virtualenvwrapper to install sceptre locally, but I'll skip that for now.

Also a local AWS IAM user with somewhat extensive access privileges. It's easiest to launch the stack locally with admin privileges.

# How to launch

Before launching you should define manually the required parameters in SSM Parameter Store **in the `eu-west-1` region**. The name is the full URL eg `/example-app/dev/examplenodejs/example-account` (not JWT_SECRET as in the `.env`) and SecureString variables are encrypted.

* `/example-app/dev/examplenodejs/jwt-secret SecureString`

No DB variables since haven't added the Postgres DB yet.

```sh
# Let's first create ECR repository to push our Docker image to. This way the ECS won't crash and burn, as there won't be an image to pull
# Modify before launching however the AWS account id in the ecr.yaml config file
AWS_PROFILE=koodivelho sceptre launch dev/eu-west-1/ecr

# After that has launched, you should change the AWS account id from both example-node-app build.sh and deploy.sh, then build the image to have it available for the ECS
cd ../my-node-bootstrap
AWS_PROFILE=koodivelho ./build-to-ecr.sh

# Then launch to rest of the stack
cd ../sceptre
AWS_PROFILE=koodivelho sceptre launch dev

# Now you should deploy the react app
cd ../my-react-bootstrap
# Change the bucket accordingly!
AWS_PROFILE=koodivelho ./deploy.sh example-app-dev-eu-west-1-static-b-staticbucket-1ls690ylt416l

# Now, or possibly in ~15 minutes, the CloudFront should have the S3 assets available and visiting the distribution eg https://d2dqwr5ltqbyap.cloudfront.net/
# would yield a working React app. If you receive 403 with a S3 static site URL, wait for a while or try another url eg https://d2dqwr5ltqbyap.cloudfront.net/login
# It's weird that it doesn't work right away, I know ¯\_(ツ)_/¯
```

Or you can launch the stacks one by one, using your locally configured AWS user: `AWS_PROFILE=koodivelho sceptre launch dev/eu-west-1/static-bucket`

# Clean up

`AWS_PROFILE=koodivelho sceptre delete dev` should remove most of the resources, but some eg S3 bucket are retained. Deletion itself will take some time to disable and remove CloudFront, EdgeLambda and the ECS cluster.

To manually delete the rest of them, in AWS Tag Editor search resources tagged with `Project` and you should find at least S3, CloudFront AccessIdentity, ECR and SSM parameters in the `eu-west-1` region.

Most importantly you should, when your CloudFront distribution has been finally purged from the edge locations, delete the EdgeLambda in `us-east-1` region. Otherwise it will fail your next fresh deployments.

Aand if you have manually bumped the `EdgeLambdaVersion` in the `eu-west-1/cloudfront.yaml` file, remember to reset it to `'1'`.

# Description

So as you can see from the CloudFormation files, this is a lot more nuanced version of the stack than the Docker Compose and local Kubernetes versions.

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
* Used for storing the application images (Example NodeJS)

**Security groups**:
* The security groups for the app, DB and ALB

**CloudFront**:
* Creates the endpoints for the static S3 assets (React) in /
* And the endpoint for the NodeJS app's ALB in /api/
* Redirects to HTTPS, stores logs to bucket and some other basic config

**Static Bucket**:
* The bucket for the static frontend assets
* Also CloudFrontOriginAccessIdentity for best practise way of accessing the bucket
* Policy for the AccessIdentity to allow GetObject -access

**Edge Lambda**:

Since the way CDNs work, you can only cache "real" URLs that access directly a resource using URL. Meaning since SPAs are by definition Single Page Applications, they have a single page/endpoint for everything. So every route eg /login or /user/1/edit should resolve to the same page/URL where the SPA is. To do this we need an Edge Lambda that redirects all requests to that SPA, which in our case is the `index.html` at / of the domain.

* The edge lambda for rewriting URLs
* Also role for the lambda, with access to CloudWatch and XRay to better monitor it
* TODO I think there should be now an automatic way to deploy the new Edge Lambda versions
