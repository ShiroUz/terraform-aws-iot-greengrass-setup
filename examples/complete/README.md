# Complete AWS IoT Greengrass Setup Example

This example demonstrates a complete setup of AWS IoT Core and Greengrass infrastructure using this module.

## Features Demonstrated

- Creation of parent and child Thing Groups
- Multiple IoT Things creation (3 devices)
- Automatic certificate generation for each Thing
- IAM Role and Role Alias configuration for Greengrass
- Custom IoT policies for MQTT communication
- Custom IAM policies for CloudWatch Logs
- Integration with S3 for Greengrass component artifacts

## Usage

To run this example, you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

## Prerequisites

- AWS credentials configured
- An S3 bucket for Greengrass component artifacts (update the `component_artifact_location` in main.tf)
- Appropriate IAM permissions to create IoT and IAM resources

## Outputs

This example outputs:
- Thing Group ARN
- Role Alias ARN
- IAM Role ARN
- List of created Thing names and ARNs
- Detailed information about all Things (marked as sensitive due to certificate data)

## Notes

- Certificates are automatically stored in AWS Systems Manager Parameter Store
- Each Thing is automatically attached to the child Thing Group
- The first Thing triggers creation of shared resources (Role Alias, IAM Role)
- Subsequent Things reuse the same Role Alias and IAM Role
