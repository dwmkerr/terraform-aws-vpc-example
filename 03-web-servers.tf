//  The latest Amazon Linux 2 AMI.
data "aws_ami" "amazon-linux-2" {
 most_recent = true

 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

//  A keypair for SSH access to the instances.
resource "aws_key_pair" "keypair" {
  key_name   = "cluster"
  public_key = "${file(var.public_key_path)}"
}

//  Create the master userdata script.
data "template_file" "userdata" {
  template = "${file("${path.module}/files/userdata.sh")}"
  vars {
    region = "${var.region}"
  }
}

//  A Launch Configuration for cluster instances.
resource "aws_launch_configuration" "cluster_node" {

  name_prefix   = "cluster-node-"
  image_id                    = "${data.aws_ami.amazon-linux-2.id}"
  instance_type               = "${var.instance_size}"

  //  Recommended for auto-scaling groups and launch configurations.
  lifecycle {
    create_before_destroy = true
  }

  security_groups = [
    "${aws_security_group.intra_node_communication.id}",
    "${aws_security_group.public_ingress.id}",
    "${aws_security_group.public_egress.id}",
    "${aws_security_group.ssh_access.id}",
  ]
  associate_public_ip_address = "true"
  user_data                   = "${data.template_file.userdata.rendered}"
  key_name = "${aws_key_pair.keypair.key_name}"
}

resource "aws_autoscaling_group" "cluster_node" {
  name                        = "cluster_node"
  min_size                    = "${var.web_server_count}"
  max_size                    = "${var.web_server_count}"
  desired_capacity            = "${var.web_server_count}"
  vpc_zone_identifier         = ["${aws_subnet.public-subnet.*.id}"]
  launch_configuration        = "${aws_launch_configuration.cluster_node.name}"
  health_check_type           = "ELB"

  //  Recommended for auto-scaling groups and launch configurations.
  lifecycle {
    create_before_destroy = true
  }
}

# A load balancer for the cluster.
resource "aws_alb" "cluster-alb" {
    name                = "cluster-alb"
    security_groups     = [
      "${aws_security_group.public_ingress.id}",
      "${aws_security_group.intra_node_communication.id}"
    ]
    subnets             = ["${aws_subnet.public-subnet.*.id}"]
}

resource "aws_alb_target_group" "web" {
  name     = "web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.cluster.id}"
}

resource "aws_alb_listener" "web_listener" {  
  load_balancer_arn = "${aws_alb.cluster-alb.arn}"  
  port              = 80  
  protocol          = "HTTP"
  
  default_action {    
    target_group_arn = "${aws_alb_target_group.web.arn}"
    type             = "forward"  
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "web-attachment" {
  autoscaling_group_name = "${aws_autoscaling_group.cluster_node.id}"
  alb_target_group_arn   = "${aws_alb_target_group.web.arn}"
}
