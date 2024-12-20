module "xc_lb" {
  source                       = "./modules/no-code"
  f5xc_api_url                 = local.f5xc_api_url
  f5xc_api_p12_file            = var.f5xc_api_p12_file
  f5xc_namespace               = var.f5xc_namespace
  f5xc_lb_domains              = var.f5xc_lb_domains
  f5xc_prefix                  = var.f5xc_prefix
  f5xc_origin_fqdns            = var.f5xc_origin_fqdns
  f5xc_origin_ips              = var.f5xc_origin_ips
  f5xc_origin_port             = var.f5xc_origin_port
  f5xc_origin-healthcheck-path = var.f5xc_origin-healthcheck-path
  f5xc_origin_virtual_site     = var.f5xc_origin_virtual_site
}