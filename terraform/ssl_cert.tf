module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = format("%s.%s", var.dns_name, var.domain_suffix)
  zone_id     = var.hosted_zone

  wait_for_validation = false

  tags = {
    Name = format("%s.%s", var.dns_name, var.domain_suffix)
  }
}