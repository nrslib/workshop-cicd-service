terraform {
  backend "s3" {
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region

  default_tags {
    tags = {
      TerraformId = local.terraform_id
      LocalName   = local.name
      Suffix      = local.suffix
      Environment = var.prefix
      Owner       = var.owner
      GitVersion  = var.git_version
      Repository  = var.codecommit_repository_name
      Branch      = var.codecommit_branch_name
    }
  }
}

data "aws_caller_identity" "self" {
}

data "aws_region" "self" {
}
