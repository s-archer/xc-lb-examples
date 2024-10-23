resource "volterra_virtual_site" "re" {
  name      = format("%s-tf-re-vs", var.prefix)
  namespace = var.namespace

  site_selector {
    expressions = ["ves.io/siteName = ves-io-tn2-lon"]
  }

  site_type = "REGIONAL_EDGE"
}

resource "volterra_virtual_site" "ce" {
  name      = format("%s-tf-ce-vs", var.prefix)
  namespace = var.namespace

  site_selector {
    expressions = ["arch = virtual-site"]
  }

  site_type = "CUSTOMER_EDGE"
}