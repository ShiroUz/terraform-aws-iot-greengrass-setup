# Parent Thing Group is created another module
# Child Thing Group is created here
resource "aws_iot_thing_group" "child" {
  name              = var.thing_group_child_name
  parent_group_name = var.thing_group_parent_name

  properties {
    attribute_payload {
      attributes = var.thing_group_attributes
    }
    description = var.description
  }
}

module "things" {
  source = "./things"
  count  = var.things_amount

  things_name                 = "${var.things_base_name}-${count.index}-thing"
  things_type_name            = var.things_type_name
  thing_group_child_arn       = aws_iot_thing_group.child.arn
  region                      = var.region
  env                         = var.env
  credential_duration         = var.credential_duration
  component_artifact_location = var.component_artifact_location
  extra_policy_statement      = var.extra_policy_statement
  extra_iot_policy_statement  = var.extra_iot_policy_statement

  depends_on = [ aws_iot_thing_group.child ]
}
