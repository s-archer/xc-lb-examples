
resource "volterra_origin_pool" "geo_origin" {
  name      = "geo-origin"
  namespace = "s-archer"
  description            = "TF deploy to show geo-lb"
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"

  origin_servers {
    public_name {
      dns_name         = "geo-lb-uk.archf5.com"
      refresh_interval = 300
    }
    labels = {
      arch = "geo-uk"
    }
  }

  origin_servers {
    public_name {
      dns_name         = "geo-lb-us.archf5.com"
      refresh_interval = 300
    }
    labels = {
      arch = "geo-us"
    }
  }

  port = 443

  use_tls {
    default_session_key_caching = true
    no_mtls = true
    skip_server_verification = true
    use_host_header_as_sni = true
    tls_config { 
        default_security = true 
    }
  }

  healthcheck {
    namespace = "s-archer"
    name      = "arch-http-generic"
  }

  advanced_options {
    enable_subsets {
      endpoint_subsets {
        keys = ["arch"]
      }
      fail_request = true
    }
    connection_timeout = 2000
    http_idle_timeout = 300000
  }
}

resource "volterra_origin_pool" "geo_origin_uk_only" {
  name      = "geo-origin-uk-only"
  namespace = "s-archer"
  description            = "TF deploy to show geo-lb"
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"


  origin_servers {
    public_name {
      dns_name         = "uk-1.geo-respond.archf5.com"
      refresh_interval = 300
    }
  }

  port = 443

  use_tls {
    default_session_key_caching = true
    no_mtls = true
    skip_server_verification = true
    use_host_header_as_sni = true
    tls_config { 
        default_security = true 
    }
  }

  advanced_options {
    outlier_detection {
      consecutive_5xx             = 10
      interval                    = 5000
      base_ejection_time          = 5000
      max_ejection_percent        = 100
      consecutive_gateway_failure = 10
    }
  }
}

resource "volterra_origin_pool" "geo_origin_uk_only_fallback" {
  name      = "geo-origin-uk-only-fallback"
  namespace = "s-archer"
  description            = "TF deploy to show geo-lb"
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"

  origin_servers {
    public_name {
      dns_name         = "uk-2.geo-respond.archf5.com"
      refresh_interval = 300
    }
  }

  port = 443

  use_tls {
    default_session_key_caching = true
    no_mtls = true
    skip_server_verification = true
    use_host_header_as_sni = true
    tls_config { 
        default_security = true 
    }
  }

  advanced_options {
    outlier_detection {
      consecutive_5xx             = 3
      interval                    = 5000
      base_ejection_time          = 5000
      max_ejection_percent        = 100
      consecutive_gateway_failure = 3
    }
  }
}

resource "volterra_origin_pool" "geo_origin_us_only" {
  name      = "geo-origin-us-only"
  namespace = "s-archer"
  description            = "TF deploy to show geo-lb"
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"

  origin_servers {
    public_name {
      dns_name         = "us-1.geo-respond.archf5.com"
      refresh_interval = 300
    }
  }

  port = 443

  use_tls {
    default_session_key_caching = true
    no_mtls = true
    skip_server_verification = true
    use_host_header_as_sni = true
    tls_config { 
        default_security = true 
    }
  }

  advanced_options {
    outlier_detection {
      consecutive_5xx             = 3
      interval                    = 5000
      base_ejection_time          = 5000
      max_ejection_percent        = 100
      consecutive_gateway_failure = 3
    }
  }
}

resource "volterra_origin_pool" "geo_origin_us_only_fallback" {
  name      = "geo-origin-us-only-fallback"
  namespace = "s-archer"
  description            = "TF deploy to show geo-lb"
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"

  origin_servers {
    public_name {
      dns_name         = "us-2.geo-respond.archf5.com"
      refresh_interval = 300
    }
  }

  port = 443

  use_tls {
    default_session_key_caching = true
    no_mtls = true
    skip_server_verification = true
    use_host_header_as_sni = true
    tls_config { 
        default_security = true 
    }
  }

  advanced_options {
    outlier_detection {
      consecutive_5xx             = 3
      interval                    = 5000
      base_ejection_time          = 5000
      max_ejection_percent        = 100
      consecutive_gateway_failure = 3
    }
  }
}

resource "volterra_http_loadbalancer" "geo_lb" {
  name      = "geo-lb"
  namespace = "s-archer"

  domains = ["geo.archf5.com"]

  advertise_on_public_default_vip = true

  https_auto_cert {
    port                  = 443
    add_hsts              = true
    http_redirect         = false
    no_mtls               = true
    default_header        = true
    enable_path_normalize = true
    non_default_loadbalancer = true
    connection_idle_timeout = 120000
    http_protocol_options {
      http_protocol_enable_v1_v2 = true
    }

    tls_config {
      default_security = true
    }
  }

  default_route_pools {
    pool {
      namespace = "s-archer"
      name      = volterra_origin_pool.geo_origin.name
    }
    weight   = 1
    priority = 1
  }

  origin_server_subset_rule_list {
    origin_server_subset_rules {
      any_asn = true
      any_ip = true
      none = true
      metadata {
        name    = "geo-uk"
      }
      origin_server_subsets_action = {
        arch = "geo-uk"
      }
      country_codes = ["COUNTRY_GB"]
    }

    origin_server_subset_rules {
      metadata {
        name    = "geo-us"
      }
      origin_server_subsets_action = {
        arch = "geo-us"
      }
      country_codes = ["COUNTRY_US"]
    }
  }
  

  # Explicit in JSON: no WAF enforced here
  disable_waf  = true
  add_location = true
}

resource "volterra_http_loadbalancer" "geo_lb_uk" {
  name      = "geo-lb-uk"
  namespace = "s-archer"

  domains = ["geo-lb-uk.archf5.com"]

  advertise_on_public_default_vip = true

  https_auto_cert {
    port                  = 443
    add_hsts              = true
    http_redirect         = true
    no_mtls               = true
    default_header        = true
    enable_path_normalize = true

    tls_config {
      default_security = true
    }
  }

  default_route_pools {
    pool {
      namespace = "s-archer"
      name      = volterra_origin_pool.geo_origin_uk_only.name
    }
    weight   = 1
    priority = 1
  }

  default_route_pools {
    pool {
      namespace = "s-archer"
      name      = volterra_origin_pool.geo_origin_uk_only_fallback.name
    }
    weight   = 1
    priority = 2
  }

  disable_waf  = true
  add_location = true
}

resource "volterra_http_loadbalancer" "geo_lb_us" {
  name      = "geo-lb-us"
  namespace = "s-archer"

  domains = ["geo-lb-us.archf5.com"]

  advertise_on_public_default_vip = true

  https_auto_cert {
    port                  = 443
    add_hsts              = true
    http_redirect         = true
    no_mtls               = true
    default_header        = true
    enable_path_normalize = true

    tls_config {
      default_security = true
    }
  }

  default_route_pools {
    pool {
      namespace = "s-archer"
      name      = volterra_origin_pool.geo_origin_us_only.name
    }
    weight   = 1
    priority = 2
  }

  default_route_pools {
    pool {
      namespace = "s-archer"
      name      = volterra_origin_pool.geo_origin_us_only_fallback.name
    }
    weight   = 1
    priority = 1
  }

  disable_waf  = true
  add_location = true
}
