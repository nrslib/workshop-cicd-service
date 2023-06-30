# Cross Account CI/CD Build

## Command

```shell
terraform init -backend-config={tfbackend-file}

terraform apply \
  -var="aws_profile={your-profile}" \
  -var="owner={your-id}" \
  -var="prefix=test" \
  -var="codecommit_repository_name={your-repository-name}" \
  -var="codecommit_branch_name=test" \
  -var="container_image_name=test-ecr-{your-service-name}" \
  -var="ecs_cluster_name=test-ecs-cluster-{your-service-name}" \
  -var="ecs_service_name=test-ecs-service-{your-service-name}" \
  -var="ecs_task_name=test-ecs-task-{your-service-name}" \
  -var="codebuild_buildspec_file_name=buildspec.yaml" \
  -var="codedeploy_application_name=test-deploy-{your-service-name}" \
  -var="codedeploy_deployment_group_app_name=test-group-{your-service-name}" \
  -var="git_version=$(git show --format='%H' --no-patch)"
```
