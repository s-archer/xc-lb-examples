# xc-lb-examples

## How to use this project:

Rename `vars.auto.tfvars.example` to `vars.auto.tfvars` and then update the variables as necessary.

For F5 XC API cert auth, obtain a new .p12 from the F5 XC console.  Store.  Reference the location in the `volt_api_p12_file` variable.  Then set the .p12 passphrase as ENV:

	`export VES_P12_PASSWORD=<cert passphrase>`

Initialise and apply terraform in the usual way.