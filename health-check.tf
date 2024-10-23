# F5 XC does not currently support POST health check.  But it is possible to craft a POST Request using TCP monitor.
#  TCP monitor requires that you encode the HTTP request as hex encoded string.

resource "volterra_healthcheck" "http-post-using-tcp-hex" {
  name      = "http-post-using-tcp-hex"
  namespace = var.namespace
  tcp_health_check {
    send_payload = data.local_file.hex_encoded_request.content
    expected_response = data.local_file.hex_encoded_response.content
  }
  healthy_threshold           = 1
  interval                    = 10
  timeout                     = 3
  unhealthy_threshold         = 1
  jitter_percent              = 30
}


# The below is not complete yet anyway, and would not work.
locals {
    http_request = <<-EOF
        POST /api/sentence/locations HTTP/1.1
        Host: aws.sentence.archf5.com
        Connection: Keep-Alive
        Content-Length: ${length(local.json_body)}
        User-Agent: F5-XC-Healthcheck
        Content-Type: application/json
        Accept: */*
        Accept-Encoding: gzip, deflate

        ${local.json_body}
    EOF
    json_body = "{\"value\":\"cave\"}"
    http_response = "HTTP/1.1 200 OK"
}

# This assumes that terraform has local access to bash with printf, sed, xxd and tr
# The purpose is to clean up CRLF characters and hex encode the HTTP request
resource "null_resource" "hex_encode_http_request" {
  provisioner "local-exec" {
    command = <<EOT
    printf -v hex_encoded_request '%s' '${local.http_request}' && echo "$hex_encoded_request" | sed 's/$/\r/' | sed 's/\n/\r\n/g' | xxd -p | tr -d '\n' > ${path.module}/hex_encoded_request.txt
    EOT
  }
}

# Read the contents of the hex-encoded request file back into a Terraform variable
data "local_file" "hex_encoded_request" {
  filename   = "${path.module}/hex_encoded_request.txt"
  depends_on = [null_resource.hex_encode_http_request]
}

output "http_request" {
  value       = local.http_request
}

# This assumes that terraform has local access to bash with printf, sed, xxd and tr
# The purpose is to clean up CRLF characters and hex encode the HTTP response
resource "null_resource" "hex_encode_http_response" {
  provisioner "local-exec" {
    command = <<EOT
    printf -v hex_encoded_response '%s' '${local.http_response}' && echo "$hex_encoded_response" | sed 's/$/\r/' | sed 's/\n/\r\n/g' | xxd -p | tr -d '\n' > ${path.module}/hex_encoded_response.txt
    EOT
  }
}

# Read the contents of the hex-encoded response file back into a Terraform variable
data "local_file" "hex_encoded_response" {
  filename   = "${path.module}/hex_encoded_response.txt"
  depends_on = [null_resource.hex_encode_http_response]
}

output "hex_encoded_http_request" {
  value       = data.local_file.hex_encoded_request.content
}

output "hex_encoded_http_response" {
  value       = data.local_file.hex_encoded_response.content
}

# Unable to use the hex provider, because it is not compatible with darwin_arm64
# resource "hex_string" "http-hex" {
#   data = var.http_request
# }

# output "hex" {
#   value       = hex_string.http-hex.result
# }

