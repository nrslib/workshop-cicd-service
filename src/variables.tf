locals {
  terraform_id         = "cicd-cross-account-codepipeline-deploy-service"
  name                 = "${var.codecommit_repository_name}-${replace(var.codecommit_branch_name, "/", "--")}"
  suffix               = substr(lower(sha256("${local.name}-${local.terraform_id}")), 0, 6)
  codecommit_arn       = "arn:aws:codecommit:${data.aws_region.self.name}:${data.aws_caller_identity.self.account_id}:${var.codecommit_repository_name}"
  container_image_path = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${var.container_image_name}"
  ecs_task_arn         = "arn:aws:ecs:${data.aws_region.self.name}:${data.aws_caller_identity.self.account_id}:task-definition/${var.ecs_task_name}"
}

# Basic
variable "aws_profile" { default = null }
variable "aws_region" { default = "ap-northeast-1" }
variable "git_version" {}

variable "prefix" {}
variable "owner" {}

# Main
variable "codecommit_repository_name" {}
variable "codecommit_branch_name" {}
variable "container_image_name" {}
variable "codebuild_build_policy_arn_list" {
  default = []
  type    = list(string)
}
variable "codedeploy_policy_arn" { default = null }
variable "ecs_cluster_name" {}
variable "ecs_service_name" {}
variable "ecs_task_name" {}
variable "codebuild_buildspec_file_name" { default = null }
variable "codedeploy_application_name" {}
variable "codedeploy_deployment_group_app_name" {}
