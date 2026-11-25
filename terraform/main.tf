terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

variable "web_count" {
  description = "Number of nginx web containers to run"
  type        = number
  default     = 1
}

resource "docker_image" "nginx" {
  name         = "nginx:alpine"
  keep_locally = true
}

resource "docker_container" "web" {
  count = var.web_count
  name  = count.index == 0 ? "lab3-terraform-web" : "lab3-terraform-web-${count.index + 1}"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8085 + count.index
  }
}

output "web_urls" {
  value = [for c in docker_container.web : "http://localhost:${c.ports[0].external}"]
}
