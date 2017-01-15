# aws-lambda-terraform-java

This is a *very* simple demonstration of the code required to deploy a Java
[AWS Lambda Function](https://aws.amazon.com/lambda/) and expose the Function
with [AWS API Gateway](https://aws.amazon.com/api-gateway/) via [HashiCorp's Terraform](https://www.terraform.io/) programmable infrastructure tool.

To get started simply create a ```terraform.tfvars``` file in ```terraform```
directory with your AWS account/IAM details. The contents should follow the
template below (with you replacing the info between << >>):

```
aws_access_key = "<< your IAM user AWS access key >>"
aws_secret_key = "<< your IAM user AWS secret key >>"
region = "<< your chosen region >>"
account_id = "<<your AWS account id>>"

```

From the root of the project run the 'build_and_deploy.sh' script.
This compiles the Java application into the ```helloworld/target``` directory
and runs Terraform to upload and configure the Lambda function and API Gateway.

```
$ ./build_and_deploy.sh
```
You can make changes to the Java application and run the above script
repeatedly to update the Lambda Function deployed into AWS.

When you are finished, don't forget to shut your infrastructure down:

```
$ ./destroy.sh
```

Please note: I'm not responsible for any costs incurred within your AWS account :-)
