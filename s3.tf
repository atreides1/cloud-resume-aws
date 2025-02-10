# create bucket
resource "aws_s3_bucket" "cloud_resume" {
  bucket = var.bucket_name
  tags = {
    Project = "CloudResumeChallenge"
  }
}

# uploading website resources

# create main.js so it uses the correct api url
# use $$ to escape $
resource "local_file" "visitorCounterScript" {
  content  = <<EOF
visitorCount = 0;
const apiUrl = "${aws_apigatewayv2_api.http.api_endpoint}";
const route  = "/getVisitorCount"

fetch(apiUrl+route)
  .then((response) => {
    if (!response.ok) {
      throw new Error("Network response was not ok");
    }
    return response.json();
  })
  .then((data) => {
    console.log(data);
    visitorCount = Number(data["visitorCount"]);
    console.log("total visitor count: ", visitorCount);

    // change number suffix (eg 1st 2nd 3rd 4th 5th 6th)
    let suffix = "th";
    switch (visitorCount % 10) {
      case 1:
        if (visitorCount != 11) {
          suffix = "st";
        }
        break;
      case 2:
        if (visitorCount != 12) {
          suffix = "nd";
        }
        break;
      case 3:
        if (visitorCount != 13) {
          suffix = "rd";
        }
        break;
      default:
        suffix = "th";
    }

    document.getElementById(
      "visitorCount"
    ).innerText = `Fun fact, you're the $${visitorCount}$${suffix} visitor to this page`;
  })
  .catch((error) => {
    console.error("Error:", error);
  });
  EOF
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
