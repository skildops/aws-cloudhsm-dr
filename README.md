## aws-cloudhsm-dr

![License](https://img.shields.io/github/license/skildops/aws-cloudhsm-dr?style=for-the-badge) ![CodeQL](https://img.shields.io/github/workflow/status/skildops/aws-cloudhsm-dr/codeql/main?label=CodeQL&style=for-the-badge) ![Commit](https://img.shields.io/github/last-commit/skildops/aws-cloudhsm-dr?style=for-the-badge) ![Release](https://img.shields.io/github/v/release/skildops/aws-cloudhsm-dr?style=for-the-badge)

This helps you achieve DR for your CloudHSM cluster by automatically copying the cluster backup to another region(s) periodically.

### Prerequisites:
- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)

### AWS Services Involved:
- Lambda
- CloudWatch Event
- IAM
