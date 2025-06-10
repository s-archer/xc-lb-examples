resource "volterra_http_loadbalancer" "http" {
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

  enable_trust_client_ip_headers {
    client_ip_headers = ["true-client-ip"]
  }
}

resource "volterra_http_loadbalancer" "http-custom-cert" {
  name        = format("%s-custom-cert-example", var.prefix)
  namespace   = var.namespace
  description = "TF deploy to show alternatives to iRules"
  domains     = ["custom-cert.archf5.com"]

  advertise_on_public_default_vip = true

  https {
    port          = 443
    http_redirect = true
    add_hsts      = true

    tls_cert_params {
      no_mtls = true
      certificates {
        name = volterra_certificate.custom-cert.name
        namespace = var.namespace
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

resource "volterra_http_loadbalancer" "http-blindfold-cert" {
  name        = format("%s-vesctl-blindfold-example", var.prefix)
  namespace   = var.namespace
  description = "TF deploy to show alternatives to iRules"
  domains     = ["blindfold.archf5.com"]

  advertise_on_public_default_vip = true

  https {
    port          = 443
    http_redirect = true
    add_hsts      = true

    tls_cert_params {
      no_mtls = true
      certificates {
        name = volterra_certificate.blindfold-cert.name
        namespace = var.namespace
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

# The next 3 blocks import my own CA signed certs
data "local_sensitive_file" "custom-crt" {
  filename = "${path.module}/../../../certs/custom-cert/custom-cert.crt"
}

data "local_sensitive_file" "custom-key" {
  filename = "${path.module}/../../../certs/custom-cert/custom-cert.key"
}

resource "volterra_certificate" "custom-cert" {
  name            = format("%s-custom-cert", var.prefix)
  namespace       = var.namespace
  certificate_url = "string:///${base64encode(data.local_sensitive_file.custom-crt.content)}"

  private_key {
    clear_secret_info {
      url = "string:///${base64encode(data.local_sensitive_file.custom-key.content)}"
    }
  }
}

# The next 3 blocks import my own CA signed certs and key which has been blindfolded by vesctl
# Note that the vesctl output must be cleaned up as it outputs 3 lines... you must use line 2 only.  My cert script does that already
data "local_sensitive_file" "blindfold-crt" {
  filename = "${path.module}/../../../certs/blindfold/blindfold.crt"
}

data "local_sensitive_file" "blindfold-key" {
  filename = "${path.module}/../../../certs/blindfold/blindfold.key.blindfold"
}

resource "volterra_certificate" "blindfold-cert" {
  name            = format("%s-blindfold-cert", var.prefix)
  namespace       = var.namespace
  certificate_url = "string:///${base64encode(data.local_sensitive_file.blindfold-crt.content)}"
  private_key {
    blindfold_secret_info {
      location = "string:///${data.local_sensitive_file.blindfold-key.content}"
    }
  }
}