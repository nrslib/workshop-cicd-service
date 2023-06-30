resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket        = "${var.prefix}-pipeline-${local.name}-${local.suffix}"
  force_destroy = false
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.codepipeline_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  policy = jsonencode({
    Version : "2012-10-17",
    Id : "SSEAndSSLPolicy",
    Statement : [
      {
        Sid : "DenyUnEncryptedObjectUploads",
        Effect : "Deny",
        Principal : "*",
        Action : "s3:PutObject",
        Resource : "${aws_s3_bucket.codepipeline_bucket.arn}/*",
        Condition : {
          StringNotEquals : {
            "s3:x-amz-server-side-encryption" : "aws:kms"
          }
        }
      },
      {
        Sid : "DenyInsecureConnections",
        Effect : "Deny",
        Principal : "*",
        Action : "s3:*",
        Resource : "${aws_s3_bucket.codepipeline_bucket.arn}/*",
        Condition : {
          Bool : {
            "aws:SecureTransport" : "false"
          }
        }
      },
      {
        Sid : "CodePipelineBucketPolicy",
        Effect : "Allow",
        Principal : {
          AWS : [
            aws_iam_role.codepipeline_codecommit.arn,
            aws_iam_role.codebuild_service_role.arn,
            aws_iam_role.codedeploy_role.arn,
          ]
        },
        Action : [
          "s3:Get*",
          "s3:Put*"
        ],
        Resource : "${aws_s3_bucket.codepipeline_bucket.arn}/*",
      },
      {
        Sid : "CodePipelineBucketListPolicy",
        Effect : "Allow",
        Principal : {
          AWS : [
            aws_iam_role.codepipeline_codecommit.arn,
            aws_iam_role.codebuild_service_role.arn,
            aws_iam_role.codedeploy_role.arn
          ]
        },
        Action : "s3:ListBucket",
        Resource : aws_s3_bucket.codepipeline_bucket.arn,
      }
    ]
  })
}
