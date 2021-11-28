# EC2 Role to access S3 
resource "aws_iam_role" "ec2_S3_role" {
  name = "ec2_S3_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "ec2-s3-role-policy" {
    name = "ec2_S3_role_policy"
    role = aws_iam_role.ec2_S3_role.id

    policy = jsonencode (
        {
        "Version": "2012-10-17",
        "Statement": [
        {
          "Sid": "s3getandputobject001",
          "Action": [
          "s3:GetObject",
          "s3:PutObject"
         ],
          "Effect": "Allow",
          "Resource": "*"
        }
      ]
    }
   )
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "ec2_s3_instance_profile"
  role = aws_iam_role.ec2_S3_role.name

}

resource "aws_security_group" "allow_SSH" {
     name        = "allow_SSH"
     description = "Allow SSH inbound traffic"
     vpc_id      = "vpc-07d0e16f"

   ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }
   egress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

    tags = {
       Name = "allow_SSH"
  }
}

resource "aws_instance" "kajide_test_instance" {
    ami = "ami-0c0a1cc13a52a158f"
    instance_type = "t2.micro"
    key_name = "Connectkey"
    iam_instance_profile = aws_iam_instance_profile.instance_profile.name
    associate_public_ip_address = true
    vpc_security_group_ids =[aws_security_group.allow_SSH.id]
    tags = {
      "Name" = "kajide_test_instance"
    }
  
}