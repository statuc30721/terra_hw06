This project is for learning how to use terraform in an AWS environment leveraging core services used in DevOps.

Created: 3 November 2024

Purpose: For educational purposes only.

Content: This leverages terraform variables, but can also accept inputs from
the command line. You can add additional terraform var files but to use them you must set the names of each variable file to something unique.

For example if you have a development and test environment you can create two separate files:
terraform-dev.tfvars
terraform-test.tfvars

Note: This project defaults with no "terraform.tfvar" file present on github. You will need to make your own variable file or provide the inputs via command line.