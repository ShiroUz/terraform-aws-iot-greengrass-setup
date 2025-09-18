# Role Alias
resource "aws_iot_role_alias" "this" {
  alias               = var.role_alias_name
  role_arn            = aws_iam_role.role.arn
  credential_duration = var.credential_duration
}

# Role AliasにアタッチするIAM Role
resource "aws_iam_role" "role" {
  name               = "${var.role_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["credentials.iot.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}
data "aws_iam_policy_document" "greengrass-core-policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
       "greengrass:DescribeComponent",
       "greengrass:ListComponents",
       "greengrass:ListDeployments",
       "greengrass:ListInstalledComponents",
       "greengrass:GetDeploymentConfiguration",
       "greengrass:GetComponentVersionArtifact",
       # test
      #  "greengrass:*",
      #  "iot:*",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${var.component_artifact_location}/*"
    ]
  }
}

resource "aws_iam_policy" "greengrass_core_policy" {
  name   = "${var.policy_name}-policy"
  policy = data.aws_iam_policy_document.greengrass-core-policy.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.greengrass_core_policy.arn
}

# extra policy
module "policy_document" {
  source     = "../../iam/policy_document"
  statements = var.extra_policy_statement
}
resource "aws_iam_policy" "extra_greengrass_core_policy" {
  count  = var.extra_policy_statement != null ? 1 : 0
  name   = "${var.policy_name}-extra-policy"
  policy = module.policy_document.json
}
resource "aws_iam_role_policy_attachment" "extra_policy" {
  count      = var.extra_policy_statement != null ? 1 : 0
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.extra_greengrass_core_policy[0].arn
}

resource "aws_iot_thing_group" "parent" {
  count = try(var.thing_group_parent_name, null) != null ? 1 : 0
  name  = var.thing_group_parent_name
}

resource "aws_iot_thing_group" "child" {
  count             = try(var.is_child, false) != false ? 1 : 0
  name              = var.thing_group_child_name
  parent_group_name = try(var.thing_group_parent_name, null)

  # Dynamic statement を入れて、動的に処理する
  properties {
    attribute_payload {
      attributes = {
        # each.value.attributes[0].key = each.value.attributes[0].value
        One = "11111"
      }
    }
    description = "This is my test thing group"
  }
}

resource "aws_iot_thing" "this" {
  count = var.things_number > 0 ? var.things_number : 0
  name  = "${var.things_name}-${count.index}"
}

resource "aws_iot_thing_group_membership" "this" {
  count            = var.things_number > 0 ? var.things_number : 0
  thing_group_name = regex("([^:/]+)$", aws_iot_thing_group.child[0].arn)[0]
  thing_name       = regex("([^:/]+)$", aws_iot_thing.this[count.index].arn)[0]
  depends_on       = [aws_iot_thing.this]
}

# 証明書
resource "aws_iot_certificate" "this" {
  count  = var.things_number > 0 ? var.things_number : 0
  active = true
}

resource "aws_iot_policy_attachment" "this" {
  count  = var.things_number > 0 ? var.things_number : 0
  policy = aws_iot_policy.this[count.index].name
  target = aws_iot_certificate.this[count.index].arn
}

resource "aws_iot_thing_principal_attachment" "this" {
  count     = var.things_number > 0 ? var.things_number : 0
  principal = aws_iot_certificate.this[count.index].arn
  thing     = regex("([^:/]+)$", aws_iot_thing.this[count.index].arn)[0]
}

# TODO: あとで考える。
# resource "aws_iot_policy_attachment" "ext" {
#   count  = try(var.is_child, false) != false ? 1 : 0
#   policy = aws_iot_policy.this.name
#   target = aws_iot_certificate.cert.arn
# }



# 権限系
resource "aws_iot_policy" "this" {
  count = var.things_number > 0 ? var.things_number : 0
  name  = "${var.things_name}-${count.index}-base-policy"
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
  policy = data.aws_iam_policy_document.iot_base_policy[count.index].json
}
data "aws_iam_policy_document" "iot_base_policy" {
  count = var.things_number > 0 ? var.things_number : 0
  statement {
    actions   = ["iot:Connect"]
    resources = ["arn:aws:iot:${var.region}:${var.account_name}:client/${var.things_name}-${count.index}"]
    effect    = "Allow"
  }

  statement {
    actions = ["iot:Publish"]
    resources = [
      "arn:aws:iot:${var.region}:${var.account_name}:topic/cmd/*/${var.things_name}-${count.index}*",
      "arn:aws:iot:${var.region}:${var.account_name}:topic/data/*/${var.things_name}-${count.index}*",
      "arn:aws:iot:${var.region}:${var.account_name}:topic/$aws/things/${var.things_name}-${count.index}/shadow/*",
    ]
    effect = "Allow"
  }

  statement {
    actions = ["iot:Receive"]
    resources = [
      "arn:aws:iot:${var.region}:${var.account_name}:topic/$aws/things/${var.things_name}-${count.index}/shadow/*",
    ]
    effect = "Allow"
  }

  statement {
    actions = ["iot:Subscribe"]
    resources = [
      "arn:aws:iot:${var.region}:${var.account_name}:topicfilter/cmd/*/${var.things_name}-${count.index}*",
      "arn:aws:iot:${var.region}:${var.account_name}:topicfilter/$aws/things/${var.things_name}-${count.index}/shadow/*",
    ]
    effect = "Allow"
  }

  statement {
    actions = ["iot:UpdateThingShadow"]
    resources = [
      "arn:aws:iot:${var.region}:${var.account_name}:thing/${var.things_name}-${count.index}*"
    ]
    effect = "Allow"
  }
  # 確認
  statement {
    actions = [
      "iot:Publish",
      "iot:Subscribe",
      "iot:Receive",
      "iot:Connect",
      "greengrass:*",
      # test
      # "iot:*",
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
  }
}

resource "aws_ssm_parameter" "certificate" {
  count            = var.things_number > 0 ? var.things_number : 0
  name             = "/${var.env}/${var.things_name}/${count.index}/public"
  type             = "SecureString"
  value_wo         = aws_iot_certificate.this["${count.index}"].public_key
  value_wo_version = var.secret_version
}

resource "aws_ssm_parameter" "private" {
  count            = var.things_number > 0 ? var.things_number : 0
  name             = "/${var.env}/${var.things_name}/${count.index}/private"
  type             = "SecureString"
  value_wo         = aws_iot_certificate.this["${count.index}"].private_key
  value_wo_version = var.secret_version
}

resource "aws_ssm_parameter" "certificate_pem" {
  count            = var.things_number > 0 ? var.things_number : 0
  name             = "/${var.env}/${var.things_name}/${count.index}/certificate"
  type             = "SecureString"
  value_wo         = aws_iot_certificate.this["${count.index}"].certificate_pem
  value_wo_version = var.secret_version
}

# TODO: あとで考える。
# resource "aws_iot_policy" "ext" {
#   count = 
# }

# For Greengrass
data "aws_iam_policy_document" "greengrass-core-thing-policy" {
  statement {
    effect = "Allow"
    actions = [
      "iot:AssumeRoleWithCertificate",
    ]
    resources = ["arn:aws:iot:${var.region}:${var.account_name}:rolealias/${var.role_alias_name}"]
  }
}

resource "aws_iot_policy" "greengrass" {
  count  = var.enable_greengrass ? var.things_number : 0
  name   = "${var.things_name}-${count.index}-greengrass-policy"
  policy = data.aws_iam_policy_document.greengrass-core-thing-policy.json
}

resource "aws_iot_policy_attachment" "greengrass" {
  count  = var.enable_greengrass ? var.things_number : 0
  policy = aws_iot_policy.greengrass[count.index].name
  target = aws_iot_certificate.this[count.index].arn
}
