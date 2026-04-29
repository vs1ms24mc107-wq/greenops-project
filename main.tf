# DUMMY PROVIDER TO TRIGGER INFRACOST PRICING
provider "aws" {
  region = "us-east-1"
}

# DUMMY NODE GROUP (Infracost will see 20 expensive nodes)
resource "aws_eks_node_group" "expensive_nodes" {
  cluster_name    = "greenops-cluster"
  node_group_name = "over-budget-nodes"
  node_role_arn   = "arn:aws:iam::123456789012:role/eks-role"
  subnet_ids      = ["subnet-12345"]

  scaling_config {
    desired_size = 20
    max_size     = 20
    min_size     = 20
  }

  instance_types = ["m5.4xlarge"] # This is a VERY expensive instance type
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# Tell Terraform to use your local Minikube config
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

# Define a simple Nginx deployment
resource "kubernetes_deployment" "nginx_test" {
  metadata {
    name = "greenops-test-app"
    labels = {
      env = "dev" # We will use this label later to identify non-prod pods!
    }
  }

  spec {
    replicas = 20 # Let's start with 2 running pods

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
          env = "dev"
        }
      }

      spec {
        container {
          image = "nginx:latest"
          name  = "nginx-container"

          resources {
            limits = {
              cpu    = "32"
              memory = "128Gi"
            }
            requests = {
              cpu    = "22"
              memory = "64Gi"
            }
          }
        }
      }
    }
  }
}
