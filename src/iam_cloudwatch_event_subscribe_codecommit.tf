resource "aws_iam_role" "event_subscribe_codecommit" {
  name               = "${var.prefix}-sub-commit-${local.name}-${local.suffix}"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : "sts:AssumeRole",
        Principal : {
          Service : "events.amazonaws.com"
        },
      }
    ]
  })
}

resource "aws_iam_role_policy" "event_subscribe_codecommit" {
  name   = "${var.prefix}-sub-commit-${local.name}-${local.suffix}"
  role   = aws_iam_role.event_subscribe_codecommit.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "codepipeline:StartPipelineExecution",
        Resource : aws_codepipeline.pipeline.arn,
        Effect : "Allow"
      }
    ]
  })
}
