module "backend" {
  source              = "./modules/backend"
  cname               = var.cname
  domain_name         = var.domain_name
  dynamodb_table_name = var.dynamodb_table_name
}

module "frontend" {
  source                  = "./modules/frontend"
  api_endpoint            = module.backend.api_endpoint
  bucket_name             = var.bucket_name
  cname                   = var.cname
  domain_name             = var.domain_name
  region                  = var.region
  route53_hosting_zone_id = var.route53_hosting_zone_id
}