terraform {
  backend "s3" {
    bucket = "Charan-demo-tfstate-bucket"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}