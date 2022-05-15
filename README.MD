

### Requirements: 

Password for DocumentDB set in secrets.tf file as follows: 

    db_username = "USERNAME"
    db_password = "PASSWORD"

Same password also saved to SSM Parameter store as follows: 

    aws ssm put-parameter --name "/eadesign/db_username" --value "USERNAME" --type SecureString --key-id alias/eadeployKey

    aws ssm put-parameter --name "/eadesign/db_password" --value "PASSWORD" --type SecureString --key-id alias/eadeployKey

The details are also stored as GitHub secrets to ensure the GitHub TF action continues to function. Secret names are as follows: 

    TF_VAR_DB_PASSWORD
    TF_VAR_DB_USERNAME

Additional values stored in secret.tfvars: 

    dns_name      = "eadeploy"
    hosted_zone   = "HOSTED_ZONE_ID"
    domain_suffix = "DOMAIN_NAME"
