variable "resource_group_id" {
    type = string
  
}
variable "resource_group" {
    type = string
  
}
variable "old" {
    type = list()
    default = local.value1
  
}