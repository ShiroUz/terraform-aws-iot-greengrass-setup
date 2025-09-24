data "aws_caller_identity" "self" {}

# IoT Things
resource "aws_iot_thing" "this" {
  name            = var.things_name
  thing_type_name = var.things_type_name
}

# Thing Group Membership
resource "aws_iot_thing_group_membership" "this" {
  thing_group_name = regex("([^:/]+)$", var.thing_group_child_arn)[0]
  thing_name       = aws_iot_thing.this.name
}

# Certificate
resource "aws_iot_certificate" "this" {
  active = true
}

# Stored Keys and Certificate in SSM Parameter Store
#   /<env>/<thing_name>/public
#   /<env>/<thing_name>/private
#   /<env>/<thing_name>/certificate
resource "aws_ssm_parameter" "public_key" {
  name  = "/${var.env}/${var.things_name}/public"
  type  = "SecureString"
  value = aws_iot_certificate.this.public_key
}

resource "aws_ssm_parameter" "private_key" {
  name  = "/${var.env}/${var.things_name}/private"
  type  = "SecureString"
  value = aws_iot_certificate.this.private_key
}

resource "aws_ssm_parameter" "certificate_pem" {
  name  = "/${var.env}/${var.things_name}/certificate"
  type  = "SecureString"
  value = aws_iot_certificate.this.certificate_pem
}

# IoT Policy(For Connection to AWS IoT Core)
resource "aws_iot_policy" "this" {
  name   = "${var.things_name}-base-policy"
  policy = data.aws_iam_policy_document.iot_base_policy.json
}

data "aws_iam_policy_document" "iot_base_policy" {
  statement {
    actions   = ["iot:Connect"]
    resources = ["arn:aws:iot:${var.region}:${data.aws_caller_identity.self.account_id}:client/${var.things_name}"]
    effect    = "Allow"
  }

  # statement {
  #   actions = ["iot:Publish"]
  #   resources = [
  #     "arn:aws:iot:${var.region}:${data.aws_caller_identity.self.account_id}:topic/cmd/*/${var.things_name}*",
  #     "arn:aws:iot:${var.region}:${data.aws_caller_identity.self.account_id}:topic/data/*/${var.things_name}*",
  #     "arn:aws:iot:${var.region}:${data.aws_caller_identity.self.account_id}:topic/$aws/things/${var.things_name}/shadow/*",
  #   ]
  #   effect = "Allow"
  # }

  statement {
    actions = ["iot:Receive"]
    resources = [
      "arn:aws:iot:${var.region}:${data.aws_caller_identity.self.account_id}:topic/$aws/things/${var.things_name}/shadow/*",
    ]
    effect = "Allow"
  }

  # statement {
  #   actions = ["iot:Subscribe"]
  #   resources = [
  #     "arn:aws:iot:${var.region}:${data.aws_caller_identity.self.account_id}:topicfilter/cmd/*/${var.things_name}*",
  #     "arn:aws:iot:${var.region}:${data.aws_caller_identity.self.account_id}:topicfilter/$aws/things/${var.things_name}/shadow/*",
  #   ]
  #   effect = "Allow"
  # }

  statement {
    actions = ["iot:UpdateThingShadow"]
    resources = [
      "arn:aws:iot:${var.region}:${data.aws_caller_identity.self.account_id}:thing/${var.things_name}*"
    ]
    effect = "Allow"
  }

  # statement {
  #   actions = [
  #     "iot:Publish",
  #     "iot:Subscribe",
  #     "iot:Receive",
  #     "iot:Connect",
  #     "greengrass:*",
  #   ]
  #   resources = ["*"]
  #   effect    = "Allow"
  # }

  # Connect for Greengrass
  statement {
    effect = "Allow"
    actions = [
      "iot:AssumeRoleWithCertificate",
    ]
    resources = ["arn:aws:iot:${var.region}:${data.aws_caller_identity.self.account_id}:rolealias/${var.things_name}-alias"]
  }
}

resource "aws_iot_policy_attachment" "this" {
  policy = aws_iot_policy.this.name
  target = aws_iot_certificate.this.arn
}

resource "aws_iot_thing_principal_attachment" "this" {
  principal = aws_iot_certificate.this.arn
  thing     = aws_iot_thing.this.name
}

# Greengrass Core Role & Role Alias
resource "aws_iam_role" "role" {
  name               = "${var.things_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
resource "aws_iot_role_alias" "this" {
  alias               = "${var.things_name}-alias"
  role_arn            = aws_iam_role.role.arn
  credential_duration = var.credential_duration
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

# Greengrass Core Policy & Attach to Role
data "aws_iam_policy_document" "greengrass_core_policy" {
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
    ]
    resources = ["*"]
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
  name   = "${var.things_name}-policy"
  policy = data.aws_iam_policy_document.greengrass_core_policy.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.greengrass_core_policy.arn
}

# Greengrass Extra Policy Statement
resource "aws_iam_policy" "extra_greengrass_core_policy" {
  count  = var.extra_policy_statement != null ? 1 : 0
  name   = "${var.things_name}-extra-policy"
  policy = data.aws_iam_policy_document.extra_policy.json
}

data "aws_iam_policy_document" "extra_policy" {
  count = var.extra_policy_statement != null ? 1 : 0
  dynamic "statement" {
    for_each = var.extra_policy_statement != null ? var.extra_policy_statement : []
    content {
      effect    = lookup(statement.value, "effect", "Allow")
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

resource "aws_iam_role_policy_attachment" "extra_policy" {
  count      = var.extra_policy_statement != null ? 1 : 0
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.extra_greengrass_core_policy.arn
}
