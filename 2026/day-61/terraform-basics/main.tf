terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.6.0"
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "terraweek-shraddha-2026"

  tags = {
    Name        = "TerraWeek-S3"
    Environment = "Learning"
    Day         = "Day61"
  }
}

resource "aws_instance" "terraform_ec2" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.micro"
  tags = {
    Name = "TerraWeek-Modified"
  }
}
