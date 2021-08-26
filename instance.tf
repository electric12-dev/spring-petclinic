#Get Linux AMI ID using SSM Parameter endpoint in us-east-2
data "aws_ssm_parameter" "JenkinsMasterAmi" {
  provider = aws.region-master
  name     = "us-east-2.console.aws.amazon.com/ec2/ami-0001378efdafd5401"
}

#Create key-pair for logging into EC2 in us-east-2
resource "aws_key_pair" "master-key" {
  provider   = aws.region-master
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}

#Create and bootstrap EC2 in us-east-2
resource "aws_instance" "jenkins-master" {
  provider                    = aws.region-master
  ami                         = var.ami
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.master-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-sg.id]
  subnet_id                   = aws_subnet.subnet.id
   provisioner "local-exec" {
    command = <<EOD
cat <<EOF > aws_hosts
[dev]
${aws_instance.jenkins-master.public_ip} 
EOF
EOD
  }

  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.jenkins-master.id} --region ${var.region-master}  && ansible-playbook -i aws_hosts ansible/install_jenkins.yaml --vault-password-file ~/.ansible_pass.txt"
  }

  tags = {
    Name = "jenkins_tf"
  }
    provisioner "local-exec" {
    command = "/bin/bash bash.sh ${aws_instance.jenkins-master.public_ip} var.cred"
  }
}



