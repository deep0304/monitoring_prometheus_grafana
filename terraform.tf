terraform{
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
    backend "s3" {
    bucket = "prometheus-bucket-lakshya"
    key    = "prometheus-state/terraform.tfstate"
    region = "us-east-1"
  }
}
provider "aws" {
  # Configuration options
#   subsciption_id = "your_subscription_id"
    region = "us-east-1"
}