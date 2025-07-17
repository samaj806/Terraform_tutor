#!/bin/bash
sudo apt-get update -y
sudo apt install -y busybox

mkdir -p /var/www/html
sudo chown www-data:www-data /var/www/html

cat > /var/www/html/index.html <<EOF
<h1>Hello World, it's me again....</h1>
<p>DB address: ${DB_ADDRESS}</p>
<p>DB port: ${DB_PORT}</p>
EOF

nohup busybox httpd -f -p ${SERVER_PORT} -h /var/www/html &
