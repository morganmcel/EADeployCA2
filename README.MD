

## Introduction
Terraform configuration for R53, ACM, ALB, ECS, VPC, ECR, Code Pipeline, Code Build, Document DB and related configurations. 
frontend folder contains code for front-end Node.JS application
backend folder contains code for backend  Java service. 

Services register in AWS CloudMap and Frontend references this configuration. 
### Requirements: 

DocumentDB password saved to SSM Parameter store as follows: 

    aws ssm put-parameter --name "/eadesign/db_username" --value "USERNAME" --type SecureString --key-id alias/eadeployKey
    aws ssm put-parameter --name "/eadesign/db_password" --value "PASSWORD" --type SecureString --key-id alias/eadeployKey

Similarly, the buildspec files for backend and frontend reference /eadesign/backend_db_config and /eadesign/db_config respectively. 