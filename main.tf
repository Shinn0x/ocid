terraform {
  # 1.10+ is required for S3-native state locking (use_lockfile), so no DynamoDB table is needed.
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend blocks cannot use variables, so these values must be literals.
  backend "s3" {
    bucket       = "shinn0x-ocid-tfstate"
    key          = "ocid/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region

  # Applied to every taggable resource; tagging at launch is covered by ec2:CreateTags.
  default_tags {
    tags = {
      Project   = "ocid"
      ManagedBy = "terraform"
    }
  }
}

# Uses ec2:DescribeImages rather than the SSM public parameter, because the role has no SSM permissions.
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    # "al2023-ami-2023.*" matches the standard image and excludes the "al2023-ami-minimal-*" variant.
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.al2023.id
  instance_type = var.instance_type

  # No subnet_id, vpc_security_group_ids, or key_name: EC2 falls back to the default VPC's
  # default subnet and default security group, and no key pair means no SSH key access.

  tags = {
    Name = "ocid-instance"
  }

  lifecycle {
    # most_recent picks up every new AL2023 release; without this, each release would
    # force a terminate-and-recreate of the instance on the next push.
    ignore_changes = [ami]
  }
}
