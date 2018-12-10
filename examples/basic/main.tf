//  Setup the core provider information.
provider "aws" {
  region  = "ap-northeast-2"
}

//  Create the ECS cluster using our module.
module "cluster" {
  source           = "../../"
  region           = "ap-northeast-2"
  vpc_cidr         = "10.0.0.0/16"
  subnets          = {
    ap-northeast-2a = "10.0.1.0/24"
    ap-northeast-2c = "10.0.3.0/24"
  }
  web_server_count       = "3"
  public_key_path  = "~/.ssh/id_rsa.pub"
}

output "alb_dns" {
    value = "${module.cluster.alb_dns}"
}
