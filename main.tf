terraform {
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.11.35"
    }
    # unable to use this provider as it is incompatible with darwin_arm64
    # hex = {
    #   source = "Jupiter-Inc/hex"
    #   version = "1.0.4"
    # }
  }
}

provider "volterra" {
  url          = local.api_url
  api_p12_file = var.api_p12_file
}

# provider "hex" {
#   # Configuration options
# }

