#TestKey

resource "tls_private_key" "sshkeygen_execution" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "keyLocal" {
  content         = tls_private_key.sshkeygen_execution.private_key_pem
  filename        = "prometheus_key.pem"
  file_permission = 0400
}


# Below are the aws key pair
resource "aws_key_pair" "prometheus_key_pair" {
  depends_on = [tls_private_key.sshkeygen_execution]
  key_name   = "prometheus_key"
  public_key = tls_private_key.sshkeygen_execution.public_key_openssh
}
