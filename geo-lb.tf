
resource "volterra_origin_pool" "geo_origin" {
  name      = "geo-origin"
  namespace = var.namespace
  description            = "TF deploy to show geo-lb"
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"

  origin_servers {
    public_name {
      dns_name         = format("%s%s", "geo-lb-uk", var.domain)
      refresh_interval = 300
    }
    labels = {
      arch = "geo-uk"
    }
  }

  origin_servers {
    public_name {
      dns_name         = format("%s%s", "geo-lb-us", var.domain)
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
  namespace = var.namespace
  description            = "TF deploy to show geo-lb"
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"


  origin_servers {
    public_name {
      dns_name         = format("%s%s", "uk-1.geo-respond", var.domain)
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
  namespace = var.namespace
  description            = "TF deploy to show geo-lb"
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"

  origin_servers {
    public_name {
      dns_name         = format("%s%s", "uk-2.geo-respond", var.domain)
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
  namespace = var.namespace
  description            = "TF deploy to show geo-lb"
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"

  origin_servers {
    public_name {
      dns_name         = format("%s%s", "us-1.geo-respond", var.domain)
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
  namespace = var.namespace
  description            = "TF deploy to show geo-lb"
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"

  origin_servers {
    public_name {
      dns_name         = format("%s%s", "us-2.geo-respond", var.domain)
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
  namespace = var.namespace

  domains = [format("%s%s", "geo", var.domain)]

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
      namespace = var.namespace
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
  namespace = var.namespace

  domains = [format("%s%s", "geo-lb-uk", var.domain)]

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
      namespace = var.namespace
      name      = volterra_origin_pool.geo_origin_uk_only.name
    }
    weight   = 1
    priority = 1
  }

  default_route_pools {
    pool {
      namespace = var.namespace
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
  namespace = var.namespace

  domains = [format("%s%s", "geo-lb-us", var.domain)]

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
      namespace = var.namespace
      name      = volterra_origin_pool.geo_origin_us_only.name
    }
    weight   = 1
    priority = 2
  }

  default_route_pools {
    pool {
      namespace = var.namespace
      name      = volterra_origin_pool.geo_origin_us_only_fallback.name
    }
    weight   = 1
    priority = 1
  }

  disable_waf  = true
  add_location = true
}

# volterra_http_loadbalancer: geo-respond-rules
# Provider: volterraedge/volterra v0.11.47

resource "volterra_http_loadbalancer" "geo_respond_rules" {
  name      = "geo-respond-rules"
  namespace = var.namespace

  domains = [
    format("%s%s", "geo-respond", var.domain),
    format("%s%s", "*.geo-respond", var.domain),
  ]

  https_auto_cert {
    port = 443
    tls_config { 
        default_security = true 
    }
    http_redirect = false
    add_hsts      = false
  }

  advertise_on_public_default_vip = true

  # Explicit in JSON
  disable_waf  = true
  add_location = true

  more_option {
    response_headers_to_add {
      name   = "Content-Type"
      value  = "text/html"
      append = false
    }

    max_request_header_size      = 60
    idle_timeout                 = 30000
    disable_default_error_pages  = false
  }

  routes {
    direct_response_route {
      http_method = "ANY"

      path {
        prefix = "/"
      }

      headers {
        name         = "Host"
        exact        = format("%s%s", "uk-1.geo-respond", var.domain)
        invert_match = false
      }

      route_direct_response {
        response_code = 200
        response_body = <<-HTML
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>You are in UK-1 Region</title>
 <style>
 html,body{height:100%;margin:0}
    body{display:flex;align-items:center;justify-content:center;font-family:system-ui,-apple-system,Segoe UI,Roboto,'Helvetica Neue',Arial}
    h1{font-size:clamp(2rem, 8vw, 6rem);margin:0}
  </style>
</head>
<body>
  <h1>You are in UK-1 Region</h1>
</body>
</html>
HTML
      }
    }
  }

  routes {
    direct_response_route {
      http_method = "ANY"

      path {
        prefix = "/"
      }

      headers {
        name         = "Host"
        exact        = format("%s%s", "uk-2.geo-respond", var.domain)
        invert_match = false
      }

      route_direct_response {
        response_code = 200
        response_body = <<-HTML
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>You are in UK-2 Region</title>
 <style>
 html,body{height:100%;margin:0}
    body{display:flex;align-items:center;justify-content:center;font-family:system-ui,-apple-system,Segoe UI,Roboto,'Helvetica Neue',Arial}
    h1{font-size:clamp(2rem, 8vw, 6rem);margin:0}
  </style>
</head>
<body>
  <h1>You are in UK-2 Region</h1>
</body>
</html>
HTML
      }
    }
  }

  routes {
    direct_response_route {
      http_method = "ANY"

      path {
        prefix = "/"
      }

      headers {
        name         = "Host"
        exact        = format("%s%s", "us-1.geo-respond", var.domain)
        invert_match = false
      }

      route_direct_response {
        response_code = 200
        response_body = <<-HTML
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>You are in US-1 Region</title>
 <style>
 html,body{height:100%;margin:0}
    body{display:flex;align-items:center;justify-content:center;font-family:system-ui,-apple-system,Segoe UI,Roboto,'Helvetica Neue',Arial}
    h1{font-size:clamp(2rem, 8vw, 6rem);margin:0}
  </style>
</head>
<body>
  <h1>You are in US-1 Region</h1>
</body>
</html>
HTML
      }
    }
  }

  routes {
    direct_response_route {
      http_method = "ANY"

      path {
        prefix = "/"
      }

      headers {
        name         = "Host"
        exact        = format("%s%s", "us-2.geo-respond", var.domain)
        invert_match = false
      }

      route_direct_response {
        response_code = 200
        response_body = <<-HTML
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>You are in US-2 Region</title>
 <style>
 html,body{height:100%;margin:0}
    body{display:flex;align-items:center;justify-content:center;font-family:system-ui,-apple-system,Segoe UI,Roboto,'Helvetica Neue',Arial}
    h1{font-size:clamp(2rem, 8vw, 6rem);margin:0}
  </style>
</head>
<body>
  <h1>You are in US-2 Region</h1>
</body>
</html>
HTML
      }
    }
  }
}