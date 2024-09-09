terraform {
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.35"
    }
  }
}

provider "volterra" {
  url          = local.api_url
  api_p12_file = var.api_p12_file
} 