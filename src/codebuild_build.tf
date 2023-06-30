resource "aws_codebuild_project" "build" {
  name         = "${var.prefix}-build-project-${local.name}-${local.suffix}"
  service_role = aws_iam_role.codebuild_service_role.arn
  artifacts {
    packaging = "NONE"
    type      = "CODEPIPELINE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }
  source {
    type            = "CODEPIPELINE"
    git_clone_depth = 0
    buildspec       = var.codebuild_buildspec_file_name
  }
}
