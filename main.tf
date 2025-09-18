

resource "aws_iot_thing_group" "parent" {
  name = var.thing_group_parent_name
}

resource "aws_iot_thing_group" "child" {
  name              = var.thing_group_child_name
  parent_group_name = aws_iot_thing_group.parent.name

  properties {
    attribute_payload {
      attributes = {
        One = "11111"
      }
    }
    description = var.description
  }
}

module "things" {
  source = "./things"
  count  = var.things_amount

  things_base_name            = var.things_base_name
  things_number               = count.index
  thing_group_child_arn       = aws_iot_thing_group.child.arn
  region                      = var.region
  account_name                = var.account_name
  env                         = var.env
  secret_version              = var.secret_version
  enable_greengrass           = var.enable_greengrass
  role_alias_name             = var.role_alias_name
  credential_duration         = var.credential_duration
  component_artifact_location = var.component_artifact_location
  role_name                   = var.role_name
  policy_name                 = var.policy_name
  extra_policy_statement      = var.extra_policy_statement
}


