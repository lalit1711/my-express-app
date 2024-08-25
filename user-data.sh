#!/bin/bash
# Update the package index
yum update -y

# Install Node.js and npm from NodeSource (using Node.js version 16.x)
curl -fsSL https://rpm.nodesource.com/setup_16.x | bash -
yum install -y nodejs

# Verify the installation
node -v
npm -v

# Install Git
yum install -y git

# Clone your Express application from a Git repository (replace <your-repo-url> with your Git repository URL)
git clone <your-repo-url> /home/ec2-user/express-app

# Change directory to the cloned repository
cd /home/ec2-user/express-app

# Install the application's dependencies
npm install

# Start the Express application using pm2 (process manager)
npm install -g pm2
pm2 start app.js  # or replace with your start file like "server.js" or whatever entry point your app uses
pm2 startup
pm2 save

# Optional: Start the Express application without pm2 (not recommended for production)
# node app.js > /dev/null 2>&1 &

# Install Nginx (optional step to set up reverse proxy)
amazon-linux-extras install nginx1 -y
systemctl start nginx
systemctl enable nginx

# Configure Nginx to reverse proxy to Node.js
cat > /etc/nginx/conf.d/express-app.conf <<EOF
server {
    listen 80;

    location / {
        proxy_pass http://localhost:3000; # Replace with your app's port
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Restart Nginx to apply changes
systemctl restart nginx
