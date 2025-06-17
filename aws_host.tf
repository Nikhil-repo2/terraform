terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.54.1"
    }
    random = {
        source = "hashicorp/random"
        version = "3.6.2"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "random_id" "r_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "my_demo_bucket" {
  bucket = "my-demo-${random_id.r_id.hex}"
}

resource "aws_s3_object" "html_page" {
  bucket = aws_s3_bucket.my_demo_bucket.bucket
  source = "./index.html"
  key = "index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "css_page" {
  bucket = aws_s3_bucket.my_demo_bucket.bucket
  source = "./styles.css"
  key = "styles.css"
  content_type = "text/css"
}

#copy policy from aws documentation, values are false as we want to grant all access to access website
resource "aws_s3_bucket_public_access_block" "my_demo_bucket" {  
    bucket = aws_s3_bucket.my_demo_bucket.bucket

    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
}

#copy policy from aws documentation, remove double quotes and replace : with =, and put it in jasonencode block
resource "aws_s3_bucket_policy" "web_policy" {
  bucket = aws_s3_bucket.my_demo_bucket.bucket 
  policy = jsonencode(
    {
     Version = "2012-10-17",
     Statement = [
        {
            Sid = "PublicReadGetObject",
            Effect = "Allow",
            Principal = "*",
            Action = [
                "s3:GetObject"
            ],
            Resource = [
                "arn:aws:s3:::${aws_s3_bucket.my_demo_bucket.bucket}/*"
            ]
        }
    ]
    }
  )
}

resource "aws_s3_bucket_website_configuration" "name" {
  bucket = aws_s3_bucket.my_demo_bucket.id
   
   index_document {
    suffix = "index.html"
  }
}