variable "pjprefix" {
  type    = string
  default = ""
}
variable "tag_mutability" {
  type        = string
  description = "MUTABLE or IMMUTABLE."
  default     = "MUTABLE"
}
variable "scanning_enable" {
  type    = bool
  default = false
}


variable "is_create_lifecycle" {
  type    = bool
  default = false
}
variable "decoded_json_lifecycle_policy" {
  type    = string
  default = ""
}

variable "is_create_ecr_policy" {
  type    = bool
  default = false
}
variable "decoded_json_ecr_policy" {
  type    = string
  default = ""
}

locals {
  # デフォルトのECRのライフサイクル releaseタグがついたイメージを３０イメージまで保持
  default_policy = <<EOF
    {
        "rules: [
            {
                "rulePriotiry": 1,
                "description" "Keep last 30 release tagged image",
                "selection": {
                    "tagStatus": "tagged",
                    "tagPrefixList": ["release"],
                    "countType": "imageCountMoreThan",
                    "countNumber": 30
                },
                "action": {
                    "type": "expire"
                }
            }
        ]
    }
EOF
}



# Repository Create
resource "aws_ecr_repository" "main_ecr" {
  name                 = "ecr-${var.pjprefix}"
  image_tag_mutability = var.tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scanning_enable
  }
}

# Lifecycle
resource "aws_ecr_lifecycle_policy" "main_lifecycle" {
  count      = var.is_create_lifecycle ? 1 : 0
  repository = aws_ecr_repository.main_ecr.name
  policy     = var.decoded_json_lifecycle_policy == "" ? local.default_policy : var.decoded_json_lifecycle_policy
}

# Repository Policy 
resource "aws_ecr_repository_policy" "main_ecr_policy" {
  count      = var.is_create_ecr_policy ? 1 : 0
  repository = aws_ecr_repository.main_ecr.name
  policy     = var.decoded_json_ecr_policy
}


output "main_ecr_name" {
  value = aws_ecr_repository.main_ecr.name
}
