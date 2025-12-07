### swarm

In the root directory:
```bash
# just in case
export AWS_REGION=us-east-1
# only for swarm
export TF_VAR_ssh_key_name=wnt-lab-keypair

make init
make plan
make apply
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

### iam

In the root directory:
```bash
# just in case
export AWS_REGION=us-east-1

make init-iam
make plan-iam 
make apply-iam 

```


### ecr

In the root directory:
```bash
# just in case
export AWS_REGION=us-east-1

make init-ecr
make plan-ecr 
make apply-ecr 
```


### enable/disable ssh for manager
```bash
make ssh-enable SSH_CIDR=1.2.3.4/32
make ssh-disable
```

# todo