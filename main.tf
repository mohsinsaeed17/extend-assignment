provider "aws" {
  region = "us-east-1"  
}


resource "aws_secretsmanager_secret" "extendd_interview" {
  name = "extendd-interview/mohsinsaeed"  
}

resource "aws_secretsmanager_secret_version" "extendd_interview_version" {
  secret_id     = aws_secretsmanager_secret.extendd_interview.id
  secret_string = formatdate("MM/DD/YYYY", timestamp())
}

resource "aws_iam_role" "interview_bot" {
  name               = "interview-bot"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "secretsmanager.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "secret_access_policy" {
  name        = "secret_access_policy"
  description = "Allow access to the interview secret"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "secretsmanager:GetSecretValue"
        ],
        "Resource": aws_secretsmanager_secret.extendd_interview.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secret_access_attachment" {
  role       = aws_iam_role.interview_bot.name
  policy_arn = aws_iam_policy.secret_access_policy.arn
}


