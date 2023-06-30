resource "aws_iam_role" "codebuild_service_role" {
  name               = "${var.prefix}-build-svc-${local.name}-${local.suffix}"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : "sts:AssumeRole",
        Principal : {
          Service : "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_service_role" {
  name   = "${var.prefix}-build-svc-${local.name}-${local.suffix}"
  role   = aws_iam_role.codebuild_service_role.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_service_role_user_define" {
  for_each = toset(var.codebuild_build_policy_arn_list)

  role       = aws_iam_role.codebuild_service_role.id
  policy_arn = each.value
}
