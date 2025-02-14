# create bucket
resource "aws_s3_bucket" "cloud_resume" {
  bucket = var.bucket_name
  tags = {
    Project = "CloudResumeChallenge"
  }
}

# uploading website resources

# create main.js with the correct api url
locals {
  script_file_content = file("${path.module}/src/scripts/template.js")
}

resource "local_file" "main_js" {
  content  = replace(local.script_file_content, "API_URL_HERE", "\"${aws_apigatewayv2_api.http.api_endpoint}\"")
  filename = "${path.module}/src/scripts/main.js"
}

# "[template_files] gathers all of the files under a particular base directory"
# this makes it easier to upload a folder w/ nested folders to s3
# https://registry.terraform.io/modules/hashicorp/dir/template/latest

module "template_files" {
  source = "hashicorp/dir/template"

  base_dir = "${path.module}/src"
}

resource "aws_s3_object" "static_files" {
  bucket = aws_s3_bucket.cloud_resume.id

  for_each     = module.template_files.files
  key          = each.key
  content_type = each.value.content_type

  source      = each.value.source_path
  source_hash = filemd5(each.value.source_path)
  content     = each.value.content
}
