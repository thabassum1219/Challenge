#[webservers]
#172.31.4.72
##!/bin/bash
#terraform output -raw inventory > ansible/inventory
#!/bin/bash
cat << EOF
{
  "frontend": {
    "hosts": [
      "$(terraform output c8_public_ip)"
    ]
  },
  "backend": {
    "hosts": [
      "$(terraform output u21_public_ip)"
    ]
  }
}
EOF

