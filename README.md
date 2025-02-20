# AWS Cloud Resume Challenge

## Background

While continuing on my learning journey for AWS and cloud services, I heard of the [Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/aws/) and wanted to try it out. The challenge is to create a website of one’s resume, using cloud resources to host it. This includes a backend and database to keep track of the number of visitors, plus creating an API to access the database, as well as tests. All of this is deployed using IaC and CI/CD, in my case using Terraform and Github Actions. While the end result may seem simple, creating the underlying infrastructure was a fun challenge.

## Infrastructure

Here’s a breakdown of what the infrastructure entails:

![AWS Cloud Resume Diagram](/img/cloudResumeArchitecture.png)

### Frontend

The frontend consists of HTML, CSS, and a JavaScript script to fetch and display the total visitor count. These files are stored in S3, which is used by CloudFront, AWS's content delivery network (CDN) offering. CloudFront caches the files across different edge locations for quick load times around the world. Route 53 is used to route requests from the domain to the CloudFront distribution.

In order to use custom domains, CloudFront requires a SSL cert. Fortunately, it's easy to create one with AWS Certificate Manager. There's one caveat, however. The certificate must be created in the us-east-1 region in order for CloudFront to use it, even if the CloudFront distribution is in a different region. Once you have a certificate, you can validate it by creating a CNAME record for your domain, or an ALIAS record if you are using Route 53.

Originally, the domain I used was hosted by GoDaddy, and I was able to get everything working manually. However, when it came time to automate creation by using Terraform, I was unable to use GoDaddy's DNS API as it requires a payment or ownership of at least 10 domains. Fortunately, it was easy to create a hosted zone with Route 53 and switch the nameservers over, so I used Route 53 to update CNAME records and manage the domain. This is needed to validate the SSL certificate and to point to the CloudFront distribution.

That's it for the frontend: S3 + CloudFront + Route 53 = a shiny new website with fast loading times!


### Backend

As for the backend, that consists of DynamoDB to keep track of the visitor count, Lambda to update and fetch the visitor count, and API Gateway to trigger the Lambda function. Also, I created tests in Python to make sure the Lambda function was working as intended. This was done using Boto3, Moto, and Pytest.

After that, the JavaScript file on the frontend side can query the API for the current visitor count.

## IaC with Terraform

 For Infrastructure as Code (IaC), I decided to use Terraform in order to gain experience with the tool. I stuck to small project [best practices](https://www.terraform-best-practices.com/examples/terraform/small-size-infrastructure) as presented by Terraform, and found it easy to use. It is very developer-friendly! For example, getting resources to connect to each other and keeping secrets out of the code was much easier than I had expected. The challenges here were finding the correct settings for specific resources (looking at you, CloudFront and API Gateway!) In those cases, I found looking at both Terraform and CloudFormation documentation helpful for understanding which settings were needed.

 One thing I did a bit differently was generating the `main.js` file locally so that the API gateway URL can be created and used in the file without being in source control. I use `template.js` and add the created API Gateway URL inside the file using Terraform. Because of this, the initial `terraform apply` has to be run twice in order for `main.js` to get uploaded to S3. Subsequent applies can be run as normal, however.

## CI/CD with Github Actions

I created CI/CD workflows using Github Actions. This is very easy to set up- provided you have the correct permissions in AWS for OpenID Connect (OIDC) access. This means creating an OIDC provider in IAM on the AWS side of things, creating a role for Github Actions to assume, and making sure that role has permissions policies for everything that needs to be created via Terraform, plus an s3 bucket for the Terraform backend storage. Then, on the Github side of things, adding the necessary AWS secrets.

After the setup, I created workflows (yaml files) for running the Python tests and deploying the infrastructure, tearing down the infrastructure, and deploying the static website files plus invalidating the CloudFront cache.

One quirk I experienced that didn’t happen locally but did using Github Actions- sometimes Terraform and AWS would hang even if a resource was successfully created or deleted. It would be fine on a subsequent re-run, and only happened twice. Since then, I haven’t experienced it.  ¯\\\_(ツ)\_/¯

All in all, this was a fun challenge to take on, with a satisfying end result: an easy-to-update and deploy resume on the cloud!
