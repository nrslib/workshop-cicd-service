resource "aws_iam_role" "codedeploy_role" {
  name               = "${var.prefix}-pl-deploy-${local.name}-${local.suffix}"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          AWS : aws_iam_role.codepipeline.arn
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "codedeploy_role" {
  name = "${var.prefix}-pl-deploy-${local.name}-${local.suffix}"
  role = aws_iam_role.codedeploy_role.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "s3:Get*",
          "s3:Put*",
        ],
        Resource : "${aws_s3_bucket.codepipeline_bucket.arn}/*",
        Effect : "Allow"
      },
      {
        Action : [
          "s3:ListBucket",
        ],
        Resource : aws_s3_bucket.codepipeline_bucket.arn,
        Effect : "Allow"
      },
      {
        Action : [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*"
        ],
        Resource : aws_kms_key.codepipeline_key.arn,
        Effect : "Allow"
      },
      {
        Action : [
          "codedeploy:*"
        ],
        Resource : "*",
        Effect : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_role_user_define" {
  count = var.codedeploy_policy_arn != null ? 1 : 0

  role       = aws_iam_role.codedeploy_role.id
  policy_arn = var.codedeploy_policy_arn
}