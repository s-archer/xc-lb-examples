resource "volterra_http_loadbalancer" "lb" {
  name        = format("%s-nocode-example", var.f5xc_prefix)
  namespace   = var.f5xc_namespace
  description = "Pattern A1 TF deployment zero-code module"
  domains     = [var.f5xc_lb_domains]

  https_auto_cert {
    port          = 443
    add_hsts      = true
    http_redirect = true

    tls_config {
      default_security = true
    }
  }

  app_firewall {
    namespace = "shared"
    name      = "arch-shared-waf"
  }

  enable_challenge {
    # default_mitigation_settings = true 
    # default_js_challenge_parameters = true 
    # default_captcha_challenge_parameters = true
  }

  user_identification {
    namespace = "shared"
    name      = "akamai-true-client-ip"
  }

  enable_ip_reputation {
    ip_threat_categories = [
      "SPAM_SOURCES",
      "WINDOWS_EXPLOITS",
      "WEB_ATTACKS",
      "BOTNETS",
      "SCANNERS",
      "REPUTATION",
      "PROXY",
      "MOBILE_THREATS",
      "TOR_PROXY",
      "DENIAL_OF_SERVICE",
      "NETWORK",
      "PHISHING"
    ]
  }

  enable_malicious_user_detection = true
  enable_threat_mesh              = true
  add_location                    = true

  default_route_pools {
    pool {
      namespace = var.f5xc_namespace
      name      = volterra_origin_pool.origin.name
    }
  }
}


resource "volterra_origin_pool" "origin" {
  name                   = format("%s-nocode-example", var.f5xc_prefix)
  namespace              = var.f5xc_namespace
  description            = "Pattern A1 TF deployment zero-code module"
  loadbalancer_algorithm = "LB_OVERRIDE"

  dynamic "origin_servers" {
    for_each = var.f5xc_origin_ips
    content {
      private_ip {
        ip             = origin_servers.value
        inside_network = true
        site_locator {
          virtual_site {
            name      = var.f5xc_origin_virtual_site
            namespace = "shared"
          }
        }
      }
    }
  }

  dynamic "origin_servers" {
    for_each = var.f5xc_origin_fqdns
    content {
      private_name {
        dns_name         = origin_servers.value
        refresh_interval = "60"
        inside_network   = true
        site_locator {
          virtual_site {
            name      = var.f5xc_origin_virtual_site
            namespace = "shared"
          }
        }
      }
    }
  }

  port               = var.f5xc_origin_port
  endpoint_selection = "LOCAL_PREFERRED"
  use_tls {
    no_mtls                  = true
    skip_server_verification = true
    tls_config {
      default_security = true
    }
    use_host_header_as_sni = true
  }
  healthcheck {
    name      = volterra_healthcheck.healthcheck.name
    namespace = var.f5xc_namespace
  }
}

resource "volterra_healthcheck" "healthcheck" {
  name      = format("%s-nocode-example", var.f5xc_prefix)
  namespace = var.f5xc_namespace

  http_health_check {
    use_origin_server_name = true
    path                   = var.f5xc_origin-healthcheck-path
  }

  healthy_threshold   = 3
  interval            = 15
  timeout             = 3
  unhealthy_threshold = 1
}