# F5 XC No-Code Terraform Module Example

## How to use this project:

Rename `vars.auto.tfvars.example` to `vars.auto.tfvars` and then update the variables as necessary.

In [lb-origin.tf](./modules/no-code/lb-origin.tf) update the references for your organisation WAF policy `volterra_http_loadbalancer.lb.app_firewall.name` and User Identification Policy `volterra_http_loadbalancer.lb.user_identification.name`.

For F5 XC API cert auth, obtain a new .p12 from the F5 XC console.  Store.  Reference the location in the `volt_api_p12_file` variable.  Then set the .p12 passphrase as ENV:

	`export VES_P12_PASSWORD=<cert passphrase>`

Initialise and apply terraform in the usual way.