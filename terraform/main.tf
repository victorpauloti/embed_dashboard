# gravar tfstate no s3
terraform {
  backend "s3" {
    bucket = "terraform-state-vpaulo"
    key    = "quicksight-embed/terraform.tfstate"
    region = "us-east-1"
  }
}