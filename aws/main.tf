locals {
  prefix                       = var.resource_prefix
  owner                        = var.resource_owner
  vpc_cidr_range               = var.vpc_cidr_range
  private_subnets_cidr         = split(",", var.private_subnets_cidr)
  public_subnets_cidr          = split(",", var.public_subnets_cidr)
  firewall_subnets_cidr        = split(",", var.firewall_subnets_cidr)
  privatelink_subnets_cidr     = split(",", var.privatelink_subnets_cidr)
  sg_egress_ports              = [443, 3306, 6666]
  sg_ingress_protocol          = ["tcp", "udp"]
  sg_egress_protocol           = ["tcp", "udp"]
  availability_zones           = split(",", var.availability_zones)
  dbfsname                     = join("", [local.prefix, "-", var.region, "-", "dbfsroot"]) 
  uc_bucketname                = join("", [local.prefix, "-", var.region, "-", "unity-catalog"]) 
  firewall_allow_list          = split(",", var.firewall_allow_list)
  firewall_protocol_deny_list  = split(",", var.firewall_protocol_deny_list)
}

module "databricks_cmk" {
  source = "./modules/databricks_cmk"
  cross_account_role_arn = var.cross_account_role_arn
  resource_prefix        = local.prefix
  region                 = var.region
  cmk_admin              = var.cmk_admin
  databricks_account_id  =  var.databricks_account_id
}

module "databricks_mws_workspace" {
  source = "./modules/databricks_workspace"
  providers = {
    databricks = databricks.mws
  }

  databricks_account_id  = var.databricks_account_id
  resource_prefix        = local.prefix
  security_group_ids     = [aws_security_group.sg.id]
  subnet_ids             = aws_subnet.private[*].id
  vpc_id                 = aws_vpc.dataplane_vpc.id
  cross_account_role_arn = var.cross_account_role_arn
  bucket_name            = aws_s3_bucket.root_storage_bucket.id
  workspace_storage_cmk  = module.databricks_cmk.workspace_storage_cmk
  managed_services_cmk   = module.databricks_cmk.managed_services_cmk
  region                 = var.region
  backend_rest           = aws_vpc_endpoint.backend_rest.id
  backend_relay          = aws_vpc_endpoint.backend_relay.id
}

// create PAT token to provision entities within workspace
resource "databricks_token" "pat" {
  provider         = databricks.created_workspace
  comment          = "Terraform Provisioning"
  lifetime_seconds = 86400
}