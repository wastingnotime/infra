output "swarm_asg_name" {
  value = aws_autoscaling_group.swarm_asg.name
}

output "swarm_launch_template_id" {
  value = aws_launch_template.swarm_node.id
}

# Tip: after first apply, use the EC2 console
# to get the public IP of the created instance.
