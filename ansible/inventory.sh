#[webservers]
#172.31.4.72
#!/bin/bash
terraform output -raw inventory > ansible/inventory

