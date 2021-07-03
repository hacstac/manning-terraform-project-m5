resource "aws_iam_user" "user" {
  name = "${var.name}-terraform"

  tags = {
    managed-by = "terraform"
  }
}
