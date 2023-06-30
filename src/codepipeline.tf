resource "aws_codepipeline" "pipeline" {
  name     = "${var.prefix}-pl-${local.name}-${local.suffix}"
  role_arn = aws_iam_role.codepipeline.arn
  artifact_store {
    encryption_key {
      id   = aws_kms_key.codepipeline_key.arn
      type = "KMS"
    }
    location = aws_s3_bucket.codepipeline_bucket.id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      provider         = "CodeCommit"
      category         = "Source"
      configuration    = {
        BranchName           = var.codecommit_branch_name
        PollForSourceChanges = "false"
        RepositoryName       = var.codecommit_repository_name
      }
      name             = var.codecommit_repository_name
      owner            = "AWS"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      role_arn         = aws_iam_role.codepipeline_codecommit.arn
    }
  }

  stage {
    name = "Build"
    action {
      category         = "Build"
      configuration    = {
        ProjectName          = aws_codebuild_project.build.name
        EnvironmentVariables = jsonencode([
          {
            name = "AWS_ACCOUNT_ID_DEST",
            value = data.aws_caller_identity.self.account_id,
            type = "PLAINTEXT"
          },
          {
            name  = "DESTINATION_BUILD_SERVICE_ROLE_ARN"
            value = aws_iam_role.codebuild_service_role.arn
            type  = "PLAINTEXT"
          },
          {
            name  = "ECS_TASK_ARN"
            value = local.ecs_task_arn
            type  = "PLAINTEXT"
          },
          {
            name  = "IMAGE_NAME"
            value = local.container_image_path
            type  = "PLAINTEXT"
          },
          {
            name  = "PREFIX"
            value = var.prefix
            type  = "PLAINTEXT"
          }
        ])
      }
      input_artifacts  = ["SourceArtifact"]
      name             = aws_codebuild_project.build.name
      namespace        = "BUILD"
      provider         = "CodeBuild"
      output_artifacts = ["BuildArtifact"]
      owner            = "AWS"
      role_arn         = aws_iam_role.codepipeline_codebuild.arn
      version          = "1"
    }
  }

  stage {
    name = "Deploy"
    action {
      category        = "Deploy"
      configuration   = {
        ApplicationName                = var.codedeploy_application_name
        DeploymentGroupName            = var.codedeploy_deployment_group_app_name
        TaskDefinitionTemplateArtifact = "BuildArtifact"
        AppSpecTemplateArtifact        = "BuildArtifact"
        Image1ArtifactName             = "BuildArtifact"
        Image1ContainerName            = "IMAGE1_NAME"
      }
      input_artifacts = ["BuildArtifact"]
      name            = var.codedeploy_application_name
      owner           = "AWS"
      role_arn        = aws_iam_role.codedeploy_role.arn
      provider        = "CodeDeployToECS"
      version         = "1"
    }
  }
}
