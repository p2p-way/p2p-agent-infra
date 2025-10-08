# Providers
provider "aws" {
  region = "us-east-1"

  skip_credentials_validation = var.skip_credentials_validation
  skip_requesting_account_id  = var.skip_requesting_account_id

  default_tags {
    tags = var.default_tags
  }
}

provider "archive" {
}

provider "cloudinit" {
}

provider "random" {
}

provider "time" {
}

provider "tls" {
}
