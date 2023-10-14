module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "my-app-cluster"
  cluster_version = "1.27"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id = module.vpc.micro-service.id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    
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

    
  }
