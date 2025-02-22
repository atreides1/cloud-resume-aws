module "backend" {
  source = "./modules/backend"
}

module "frontend" {
  source       = "./modules/frontend"
  api_endpoint = module.backend.api_endpoint
}