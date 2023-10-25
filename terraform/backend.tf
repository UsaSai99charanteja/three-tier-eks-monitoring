terraform {
  backend "s3" {
    bucket = "charan-demo-tfstate-bucket"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}