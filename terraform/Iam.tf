#creating the eks-cluster-policy
module "eks_cluster_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
            
  version = "5.3.1"

  name = "allow-eks-access"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = [
                "eks:*",
            ]
            Effect = "Allow"
            Resource = "*"
        },
    ]
  })
}


#Attaching the eks-cluster policy to the eks role
module "eks_admins_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.3.1"

  role_name         = "eks-admin"
  create_role       = true
  role_requires_mfa = false

  custom_role_policy_arns = [module.eks_cluster_policy.arn]
  trusted_role_arns = [
    "arn:aws:iam::${module.vpc.vpc_owner_id}:root"
  ]

}



#creating the users
module "adding_iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"

  version = "5.3.1"


  name          = "charan-eks-user"
  force_destroy = true
  create_iam_user_login_profile = false
  create_iam_access_key         = false
  
}

#
module "iam_assume_group_user_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.3.1"

  name = "eks_iam_assume_user_policy"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect = "Allow"
        Resource = moudule.eks_admins_iam_role.iam_role_arn
      },
    ]
  })

}

#eks-user-access-groups
module "eks_user-groups" {
  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "5.3.1"

  name = "eks-admin"
  attach_iam_self_management_policy = false
  create_group = true
  group_users = [module.adding_iam_user.iam_user_name]
  custom_group_policy_arns = [module.iam_assume_group_user_policy.arn]
  

}

#updated the required iam permissions to the user and created the group with the required permissions assigned, if any new is created just needed to add them to the group!
