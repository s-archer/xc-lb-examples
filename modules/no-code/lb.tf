resource "volterra_http_loadbalancer" "lb1" {
  name        = var.lb_name
  namespace   = var.namespace
  description = "Created with Terraform no-code module"
  domains     = var.lb_domains
  
  http {
    dns_volterra_managed = false
    port                 = "80"
  }

  # advertise_custom {
  #   advertise_where {
  #     site {
  #       network = "SITE_NETWORK_OUTSIDE"
  #       site {
  #         namespace = "system"
  #         name      = var.lb_site
  #       }
  #     }
  #   }
  # }

  advertise_custom {
    advertise_where {
      virtual_site {
        network = "SITE_NETWORK_OUTSIDE"
        virtual_site {
          namespace = var.namespace
          name      = var.lb_virtual_site
        }
      }
    }
  }

  default_route_pools {
    pool {
      namespace = var.namespace
      name      = volterra_origin_pool.origin.name
    }
  }
}