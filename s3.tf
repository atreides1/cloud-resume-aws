# create bucket
resource "aws_s3_bucket" "cloud_resume" {
    bucket = var.bucket_name
    tags = {
      Project = "CloudResumeChallenge"
    }
}

# uploading website resources

# "[template_files] gathers all of the files under a particular base directory"
# this makes it easier to upload a folder w/ nested folders to s3
# https://registry.terraform.io/modules/hashicorp/dir/template/latest

module "template_files" {
  source = "hashicorp/dir/template"

  base_dir = "${path.module}/src"
}

resource "aws_s3_object" "static_files" {
  bucket       = aws_s3_bucket.cloud_resume.id

  for_each = module.template_files.files
  key          = each.key
  content_type = each.value.content_type

  source  = each.value.source_path
  content = each.value.content
}

