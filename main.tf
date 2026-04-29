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
    replicas = 2 # Let's start with 2 running pods

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
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}
