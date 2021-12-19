#!/bin/bash
yum install httpd -y

cat >/var/www/html/index.html <<EOF
<h1> Hello World !</h1>
<p> Database Address: ${db_address}</p>
<p> Database Port: ${db_port}</p>
EOF

nohup httpd -k start &