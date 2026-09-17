variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"

  # Mirrors the IAM policy: fail at plan time instead of getting an AccessDenied from RunInstances.
  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "instance_type must be t2.micro or t3.micro (the only types the deploy role may launch)."
  }
}
