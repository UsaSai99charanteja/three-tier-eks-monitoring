module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id = module.vpc.micro-service.id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_group_defaults = {
    disk_size = 50
  }


  eks_managed_node_groups = {
    general = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      labels = {
        role = "general"
      }

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"

    }

    spot = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      labels = {
        role = "SPOT"
      }

      taints = [{
        key    = "market"
        value  = "spot"
        effect = "NO_SCHEDULE"
      }]

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"
      
    }
      
  }

  node_security_group_additional_rules = {
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    }
    
  }
  
  tags = {
    Environment = "dev"
  }

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = module.eks_admins_iam_role.iam_role_arn
      username = module.eks_admins_iam_role.iam_user_name
      groups   = ["system:masters"]
    },
  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

  data "aws_eks_cluster" "default" {
    name = module.eks.cluster_id
  }
  
  data "aws_eks_cluster_auth" "default" {
    name = module.eks.cluster_id
  }

  provider "kubernetes" {
    host                   = data.aws_eks_cluster.default.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  # token                  = data.aws_eks_cluster_auth.default.token
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.default.id]
      command     = "aws"
    }
  }


    
  }
