# AWS Cloud Resume Challenge

## Background

While learning about AWS and cloud services, I heard of the [Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/aws/) and wanted to give it a go. The challenge is to create a resume website using cloud resources. This includes a database to keep track of the number of visitors and backend to fetch and update the data, an API to access the backend, and tests to ensure the backend is working properly. All of this is deployed using Infrastructure as Code (IaC) and continuous integration / continuous deployment (CI/CD). While the end result may seem simple, creating the underlying infrastructure was a fun challenge.

## Infrastructure

Here’s what the infrastructure looks like:

![AWS Cloud Resume Diagram](/img/cloudResumeArchitecture.png)

### Frontend

The frontend consists of HTML, CSS, and a JavaScript script to fetch and display the total visitor count. These files are stored in a S3 bucket, which is accessed by CloudFront, AWS's content delivery network (CDN) offering. CloudFront caches the files across different edge locations for quick load times around the world. Route 53 is used to route requests from the domain to the CloudFront distribution.

The frontend was straightforward enough to implement, but I did run into a few challenges along the way.

In order to use custom domains, CloudFront requires a SSL certificate which can be created with AWS Certificate Manager. However, the certificate must be created in the us-east-1 region in order for CloudFront to find it, even if the CloudFront distribution is in a different region. For deployments, I wanted to give users the freedom to choose the AWS region to deploy in, as well as create the SSL certificate specifically in us-east-1. To do so in Terraform, I used a 'main' AWS provider configuration, as well as an 'alternate' provider configuration with the region set to us-east-1, and used an alias to access it. That provider was used only for the certificate creation and validation, allowing the user to deploy to another region.

The second challenge I faced was when attempting to automate the DNS record creation process. Originally, the domain I used was hosted by GoDaddy. When it came time to automate record creation by using Terraform, I found GoDaddy's DNS API requires a payment or ownership of at least 10 domains. Fortunately, it was easy to create a hosted zone with Route 53 and switch the nameservers over, so I used Route 53 to update CNAME records and manage the domain. This was needed to validate the SSL certificate and to point to the CloudFront distribution.

That's it for the frontend: S3 + CloudFront + Route 53 = a shiny new website with fast loading times!


### Backend

As for the backend, I used DynamoDB to keep track of the visitor count, Lambda to fetch and update the data, and API Gateway to trigger the Lambda function. Also, I created tests in Python to make sure the Lambda function was working as intended. This was done using Boto3, Moto, and Pytest.

Once CORS is correctly set up in API Gateway, the JavaScript file on the frontend side can query the API for the current visitor count.

## IaC with Terraform

 For Infrastructure as Code (IaC), I decided to use Terraform in order to gain more experience with the tool. I stuck to small project [best practices](https://www.terraform-best-practices.com/examples/terraform/small-size-infrastructure) as presented by Terraform, and found it easy to use. It is very developer-friendly! For example, resources are created in the correct order in regards to dependencies, and keeping secrets out of the code was much easier than I had expected. 
 
 The challenges here were finding the correct settings for specific resources (looking at you, CloudFront and API Gateway!) In those cases, I found it helpful to look at both Terraform and CloudFormation documentation to find the settings I needed.

 Another challenge was generating the `main.js` file so that the API gateway URL could be created and used in the file without being in source control. I created a `template.js` file with a dummy URL and added the API Gateway URL inside that file to create `main.js` using Terraform. Because of this, the initial `terraform apply` has to be run twice in order for `main.js` to get uploaded to S3. Subsequent applies can be run as normal, however.

## CI/CD with Github Actions

I created CI/CD workflows using Github Actions. This requires setting up permissions in AWS for OpenID Connect (OIDC) access. To do so, I created an OIDC provider in IAM on the AWS side of things, created a role for Github Actions to assume, and made sure the role had permissions policies for everything that needed to be created via Terraform. I also created another S3 bucket for the Terraform backend storage, in order to remotely keep track of the deployment state. Then, on the Github side of things, I added the necessary AWS secrets and environment variables to the repository.

After that, I created the workflows. 

1) `run-pytest-and-terraform.yml` If any of the infrastructure files are changed, the Python tests for the backend run using Pytest. If those are successful, the infrastructure is then deployed via Terraform.

2) `delete-terraform.yml` This workflow is manually run, and tears down the infrastructure via Terraform.

3) `deploy-static-files.yml` If any of the website files are updated, the static website files are deployed to the S3 bucket, plus the CloudFront cache is invalidated for the updated files.

4) `get-id-token.yml` Used for debugging, this workflow gets the JWT token from Github's OIDC endpoint. I used this to double-check the authorized user's name (the AWS role).

---

All in all, this was a fun challenge to take on, with a satisfying end result: an easy-to-update and deploy resume on the cloud!
