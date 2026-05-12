terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Owner   = "jdavila.sandoval@iteso.mx"
      Team    = "team-1"
      Project = "YouTube-Clone"
    }
  }
}