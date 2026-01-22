resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  description = "Allow Web traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# This something important for windows to connect via RDP
# but we should restrict this to our ip address
  ingress {
    description = "RDP from my IP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

data "aws_ami" "windows" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["devops-exercise-windows-*"]
  }
}

data "aws_ami" "linux" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["devops-exercise-nginx-*"]
  }
}

}

resource "aws_instance" "windows_web" {
  ami           = data.aws_ami.windows.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  
  key_name      = var.key_name 

  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "${var.project_name}-windows-web"
  }
}

resource "aws_instance" "linux_web" {
  ami           = data.aws_ami.linux.id
  instance_type = "t2.micro" # Linux works fine on micro
  subnet_id     = aws_subnet.public.id
  
  key_name      = var.key_name 

  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "${var.project_name}-linux-web"
  }
}
