resource "ibm_is_vpc" "vpc1" {
  name = "vpc1"
  resource_group=var.resource_group

}

resource "ibm_is_subnet" "subnet3" {
  name                     = "subnet3"
  vpc                      = ibm_is_vpc.vpc1.id
  zone                     = "us-south-1"
  total_ipv4_address_count = 256
  resource_group=var.resource_group
  # public_gateway = true
}
resource "ibm_is_public_gateway" "gateway" {
  name = "gateway"
  vpc  = ibm_is_vpc.vpc1.id
  zone = "us-south-1"
  resource_group=var.resource_group
  timeouts {
    create = "90m"
  }
}

resource "ibm_is_subnet_public_gateway_attachment" "subatt" {
  subnet                = ibm_is_subnet.subnet3.id
  public_gateway         = ibm_is_public_gateway.gateway.id
  # resource_group_name=IaC-dev
}

data "ibm_container_vpc_cluster" "cluster" {
  name  = "testcluster"
  # depends_on = [ ibm_container_vpc_cluster.cluster ]
  
}
# Print the id's of the workers
locals  {
  value1 = data.ibm_container_vpc_cluster.cluster.workers
  # depends_on = [ data.ibm_container_vpc_cluster.cluster ]
  
}

resource "ibm_container_vpc_cluster" "testcluster" {
  name              = "testcluster"
  vpc_id            = ibm_is_vpc.vpc1.id
  flavor            = "bx2.4x16"
  worker_count      = 2
  resource_group_id=var.resource_group_id
  kube_version      = "1.25.9"  
  update_all_workers     = true
  wait_for_worker_update = true
  depends_on = [ ibm_is_subnet.subnet3,data.ibm_container_vpc_cluster.cluster ]
  zones {
    subnet_id = ibm_is_subnet.subnet3.id
    name      = "us-south-1"
    
  }
}

data "ibm_container_vpc_cluster" "cluster1" {
  name  = "testcluster"
  depends_on = [ ibm_container_vpc_cluster.testcluster ]
  
}
# Print the id's of the workers
locals {
  value2 = data.ibm_container_vpc_cluster.cluster1.workers
  # depends_on = [ data.ibm_container_vpc_cluster.cluster1 ]
  
}

locals {
  validation{
    condition=local.value1!=local.value2
    error_message="Please chane the ip_address in the bluefringe"
  }
}