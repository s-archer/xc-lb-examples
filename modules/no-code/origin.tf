resource "volterra_origin_pool" "origin" {
  name                   = var.lb_name
  namespace              = var.namespace
  description            = "Created with Terraform no-code module"
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"
  port                   = 80
  no_tls                 = true

  origin_servers {

    k8s_service {
      service_name   = var.origin_service_name
      inside_network = true

      site_locator {

        site {
          namespace = "system"
          name      = var.origin_site
        }
      }
    }
  }
}
