

In the `swarm` directory:
```bash
# just in case
export AWS_REGION=us-east-1

terraform init

terraform plan \
  -var "ssh_key_name=YOUR_KEYPAIR_NAME"

terraform apply \
  -var "ssh_key_name=YOUR_KEYPAIR_NAME"
```

After `apply`:
```bash


aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].{Name:Tags[?Key=='Name']|[0].Value, ID:InstanceId, IP:PublicIpAddress}" \
  --output text


# use the public ip
ssh -i ~/.ssh/YOUR_KEY.pem ec2-user@<public-ip>
```

On the box, confirm:
```bash
docker info | grep -i swarm
docker node ls
```

