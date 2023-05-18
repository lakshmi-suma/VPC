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

resource "ibm_container_vpc_cluster" "testcluster" {
  name              = "testcluster"
  vpc_id            = ibm_is_vpc.vpc1.id
  flavor            = "bx2.4x16"
  worker_count      = 3
  resource_group_id=var.resource_group_id
  kube_version      = "1.24.13"  
  update_all_workers     = true
  wait_for_worker_update = true
  depends_on = [ ibm_is_subnet.subnet3 ]
  zones {
    subnet_id = ibm_is_subnet.subnet3.id
    name      = "us-south-1"
    
  }
}