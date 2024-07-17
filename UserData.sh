#!/bin/bash
set -e

GIT_REPO_URL="https://github.com/faiqrauf/notes-backend.git"

PROJECT_MAIN_DIR_NAME="notes-backend"

mkdir -p /home/ubuntu/django-notes-app
cd /home/ubuntu/django-notes-app

git clone "$GIT_REPO_URL" "/home/ubuntu/$PROJECT_MAIN_DIR_NAME"

cd "/home/ubuntu/$PROJECT_MAIN_DIR_NAME"

# chmod +x scripts/*.sh

# Execute scripts for OS dependencies, Python dependencies, Gunicorn, Nginx, and starting the application
# ./scripts/instance_os_dependencies.sh
# ./scripts/python_dependencies.sh
# ./scripts/gunicorn.sh
# ./scripts/nginx.sh
# ./scripts/start_app.sh

#!/bin/bash

# Update the package list and install necessary packages
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y python3-pip python3-dev libpq-dev nginx curl

# Create a directory for the Django project
# mkdir -p /home/ubuntu/django-notes-app
# cd /home/ubuntu/django-notes-app

# Install and create a virtual environment
sudo pip3 install virtualenv
virtualenv myenv
source myenv/bin/activate

# Install Django and Gunicorn
pip install django gunicorn psycopg2-binary

# Start a new Django project
django-admin startproject notes-backend .

# Apply migrations
python manage.py migrate

# Create a superuser (provide username, email, and password here or configure to prompt)
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'password')" | python manage.py shell

# Collect static files
python manage.py collectstatic --noinput

# Create a Gunicorn systemd service file
sudo tee /etc/systemd/system/gunicorn.service > /dev/null <<EOF
[Unit]
Description=gunicorn daemon
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/notes-backend
ExecStart=/home/ubuntu/notes-backend/venv/bin/gunicorn \
          --access-logfile - \
          --workers 3 \
          --bind unix:/run/gunicorn.sock \
          mynotesapp.wsgi:application

[Install]
WantedBy=multi-user.target
EOF

# Start and enable the Gunicorn service
sudo systemctl start gunicorn
sudo systemctl enable gunicorn

# Configure Nginx to proxy pass to Gunicorn
sudo tee /etc/nginx/sites-available/notes-backend > /dev/null <<EOF
server {
    listen 80 default_server;
    server_name _;

    location = /favicon.ico { access_log off }
    location /static/ {
        root /home/ubuntu/notes-backend;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/run/gunicorn.sock;
    }
}
EOF

# Enable the Nginx server block configuration by creating a symbolic link
sudo ln -s /etc/nginx/sites-available/notes-backend /etc/nginx/sites-enabled

# Test the Nginx configuration
sudo nginx -t

# Restart Nginx to apply the changes
sudo systemctl restart nginx

# Allow traffic on port 80
sudo ufw allow 'Nginx Full'

# Ensure Nginx is enabled to start on boot
sudo systemctl enable nginx

# Print completion message
echo "Django project setup complete."
