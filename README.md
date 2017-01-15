# aws-lambda-terraform-java

Create terraform.tfvars file in ```terraform``` directory with your AWS account/IAM details:

```
aws_access_key = "<< your IAM user AWS access key >>"
aws_secret_key = "<< your IAM user AWS secret key >>"
region = "<< your chosen region >>"
account_id = "<<your AWS account id>>"

```

From the root of the project run the 'build_and_deploy.sh' script

```
$ ./build_and_deploy.sh
```

and when you are done, don't forget to shut your infrastrcture down:

```
$ ./destroy.sh
```

Please note: I'm not responsible for any costs incurred within your AWS account :-)
