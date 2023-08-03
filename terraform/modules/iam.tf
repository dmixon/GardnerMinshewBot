resource "aws_iam_role" "gardner_lambda" {
  name = "gardner-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "gardner_ssm_read" {
  name        = "gardner-ssm-readonly"
  path        = "/"
  description = "Allows the GardnerMinshewBot lambda function to read ssm parameters"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:ssm:*:*:parameter/*",
            "Sid": "VisualEditor0"
        },
        {
            "Action": "ssm:DescribeParameters",
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "VisualEditor1"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role_policy_attachment" "gardner-attach-cloudwatch" {
  role       = aws_iam_role.gardner_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "gardner-attach" {
  role       = aws_iam_role.gardner_lambda.name
  policy_arn = aws_iam_policy.gardner_ssm_read.arn
}

#user for CI/CD flow
resource "aws_iam_user" "gardner_uploader" {
  name = "gardner-uploader"
  path = "/"

  tags = {
    Name = "gardner-uploader"
  }
}

resource "aws_iam_policy" "gardner_uploader" {
  name        = "gardner-uploader"
  path        = "/"
  description = "Allows read and write access to discord-gardner-code bucket"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets"
            ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::discord-gardner-code"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::discord-gardner-code",
                "arn:aws:s3:::discord-gardner-code/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:ListFunctions",
                "lambda:ListLayerVersions",
                "lambda:ListLayers"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:UpdateFunctionCode",
                "lambda:ListProvisionedConcurrencyConfigs",
                "lambda:InvokeFunction",
                "lambda:GetFunction",
                "lambda:GetFunctionEventInvokeConfig",
                "lambda:ListAliases",
                "lambda:UpdateFunctionConfiguration",
                "lambda:GetFunctionConfiguration",
                "lambda:PublishVersion",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::*",
                "${aws_lambda_function.gardner_lambda.arn}"
            ]
        }
    ]
}
EOF

  tags = {
    Name = "gardner-uploader"
  }
}

resource "aws_iam_user_policy_attachment" "gardner_uploader_attach" {
  user       = aws_iam_user.gardner_uploader.name
  policy_arn = aws_iam_policy.gardner_uploader.arn
}
