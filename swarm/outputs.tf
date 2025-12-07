output "swarm_manager_instance_id" {
  value = aws_instance.swarm_manager.id
}

output "swarm_manager_eip" {
  value = aws_eip.swarm_manager.public_ip
}

output "swarm_asg_name" {
  value = aws_autoscaling_group.swarm_asg.name
}

output "swarm_launch_template_id" {
  value = aws_launch_template.swarm_node.id
}
