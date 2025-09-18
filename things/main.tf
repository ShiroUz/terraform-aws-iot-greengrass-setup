# Role Alias (shared resource, created only once)
resource "aws_iot_role_alias" "this" {
  count               = var.things_number == 0 ? 1 : 0
  alias               = var.role_alias_name
  role_arn            = aws_iam_role.role[0].arn
  credential_duration = var.credential_duration
}

resource "aws_iam_role" "role" {
  count              = var.things_number == 0 ? 1 : 0
  name               = "${var.role_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
}

data "aws_iam_policy_document" "assume_role" {
  count = var.things_number == 0 ? 1 : 0
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["credentials.iot.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "greengrass_core_policy" {
  count = var.things_number == 0 ? 1 : 0
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
  count  = var.things_number == 0 ? 1 : 0
  name   = "${var.policy_name}-policy"
  policy = data.aws_iam_policy_document.greengrass_core_policy[0].json
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.things_number == 0 ? 1 : 0
  role       = aws_iam_role.role[0].name
  policy_arn = aws_iam_policy.greengrass_core_policy[0].arn
}

resource "aws_iam_policy" "extra_greengrass_core_policy" {
  count  = var.things_number == 0 && var.extra_policy_statement != null ? 1 : 0
  name   = "${var.policy_name}-extra-policy"
  policy = data.aws_iam_policy_document.extra_policy[0].json
}

data "aws_iam_policy_document" "extra_policy" {
  count = var.things_number == 0 && var.extra_policy_statement != null ? 1 : 0
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
  count      = var.things_number == 0 && var.extra_policy_statement != null ? 1 : 0
  role       = aws_iam_role.role[0].name
  policy_arn = aws_iam_policy.extra_greengrass_core_policy[0].arn
}

resource "aws_iot_thing" "this" {
  name = "${var.things_base_name}-${var.things_number}"
}

resource "aws_iot_thing_group_membership" "this" {
  thing_group_name = regex("([^:/]+)$", var.thing_group_child_arn)[0]
  thing_name       = aws_iot_thing.this.name
}

resource "aws_iot_certificate" "this" {
  active = true
}

resource "aws_iot_policy" "this" {
  name   = "${var.things_base_name}-${var.things_number}-base-policy"
  policy = data.aws_iam_policy_document.iot_base_policy.json
}

data "aws_iam_policy_document" "iot_base_policy" {
  statement {
    actions   = ["iot:Connect"]
    resources = ["arn:aws:iot:${var.region}:${var.account_name}:client/${var.things_base_name}-${var.things_number}"]
    effect    = "Allow"
  }

  statement {
    actions = ["iot:Publish"]
    resources = [
      "arn:aws:iot:${var.region}:${var.account_name}:topic/cmd/*/${var.things_base_name}-${var.things_number}*",
      "arn:aws:iot:${var.region}:${var.account_name}:topic/data/*/${var.things_base_name}-${var.things_number}*",
      "arn:aws:iot:${var.region}:${var.account_name}:topic/$aws/things/${var.things_base_name}-${var.things_number}/shadow/*",
    ]
    effect = "Allow"
  }

  statement {
    actions = ["iot:Receive"]
    resources = [
      "arn:aws:iot:${var.region}:${var.account_name}:topic/$aws/things/${var.things_base_name}-${var.things_number}/shadow/*",
    ]
    effect = "Allow"
  }

  statement {
    actions = ["iot:Subscribe"]
    resources = [
      "arn:aws:iot:${var.region}:${var.account_name}:topicfilter/cmd/*/${var.things_base_name}-${var.things_number}*",
      "arn:aws:iot:${var.region}:${var.account_name}:topicfilter/$aws/things/${var.things_base_name}-${var.things_number}/shadow/*",
    ]
    effect = "Allow"
  }

  statement {
    actions = ["iot:UpdateThingShadow"]
    resources = [
      "arn:aws:iot:${var.region}:${var.account_name}:thing/${var.things_base_name}-${var.things_number}*"
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "iot:Publish",
      "iot:Subscribe",
      "iot:Receive",
      "iot:Connect",
      "greengrass:*",
    ]
    resources = ["*"]
    effect    = "Allow"
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

resource "aws_ssm_parameter" "public_key" {
  name             = "/${var.env}/${var.things_base_name}/${var.things_number}/public"
  type             = "SecureString"
  value            = aws_iot_certificate.this.public_key
}

resource "aws_ssm_parameter" "private_key" {
  name             = "/${var.env}/${var.things_base_name}/${var.things_number}/private"
  type             = "SecureString"
  value            = aws_iot_certificate.this.private_key
}

resource "aws_ssm_parameter" "certificate_pem" {
  name             = "/${var.env}/${var.things_base_name}/${var.things_number}/certificate"
  type             = "SecureString"
  value            = aws_iot_certificate.this.certificate_pem
}

# Greengrass policy
resource "aws_iot_policy" "greengrass" {
  count  = var.enable_greengrass ? 1 : 0
  name   = "${var.things_base_name}-${var.things_number}-greengrass-policy"
  policy = data.aws_iam_policy_document.greengrass_core_thing_policy.json
}

data "aws_iam_policy_document" "greengrass_core_thing_policy" {
  statement {
    effect = "Allow"
    actions = [
      "iot:AssumeRoleWithCertificate",
    ]
    resources = ["arn:aws:iot:${var.region}:${var.account_name}:rolealias/${var.role_alias_name}"]
  }
}

resource "aws_iot_policy_attachment" "greengrass" {
  count  = var.enable_greengrass ? 1 : 0
  policy = aws_iot_policy.greengrass[0].name
  target = aws_iot_certificate.this.arn
}