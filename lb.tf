resource "volterra_http_loadbalancer" "lb1" {
  name        = format("%s-route-examples", var.prefix)
  namespace   = var.namespace
  description = "TF deploy to show alternatives to iRules"
  domains     = ["irule.internal"]

  http {
    dns_volterra_managed = false
    port                 = "80"
  }


  advertise_custom {
    advertise_where {
      virtual_site {
        network = "SITE_NETWORK_OUTSIDE"
        virtual_site {
          namespace = var.namespace
          name      = volterra_virtual_site.ce.name
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

resource "volterra_origin_pool" "origin" {
  name                   = format("%s-route-examples", var.prefix)
  namespace              = var.namespace
  description            = "TF deploy to show alternatives to iRules"
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"
  port                   = 80
  no_tls                 = true

  origin_servers {

    public_name {
      dns_name = "sentence.emea.f5se.com"
    }
  }
}