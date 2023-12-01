variable "service_name" {
  type = string
  description = "Name to assign to the service. It must be unique in the cloud."
}

variable "vip" {
  description = "VIP specification. The certificate assigned here will be exposed by the load balancer"
  sensitive = true
  type = object({
    ip = string
    ssl = object({
      private_key = string
      certificate = string
    })
  })
}

variable "https_monitor_request" {
  description = "HTTPs request to use to verify that the instances in the pool are ready"
  type = string
}

variable "cloud_id" {
  description = "Cloud ID in which the virtual service must be deployed"
  type = string
}

variable "pool_ips" {
  description = "IP addreses that are part of the loadbalancer backend"
  type = set(string)
}