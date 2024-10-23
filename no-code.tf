module "xc_lb" {
  source = "./modules/no-code"

  # Configure the XC namespace that will be used 
  #  for the load-balancer (LB) and origin pool objects.
  namespace = var.namespace

  # Configure the LB name, the domain the LB will listen on (match Host header) 
  #  and the site where the LB will be created.
  lb_name         = "no-code-example"
  lb_domains      = ["no-code.internal", "nocode.internal"]
  lb_virtual_site = volterra_virtual_site.ce.name

  # Configure the upstream target k8s service, where we will send  
  #  requests and the site where the origin will be created.
  origin_service_name = "sentence-colors.api"
  origin_site         = "arch-azure-aks-site"

  volt_api_url      = local.api_url
  volt_api_p12_file = var.api_p12_file

}