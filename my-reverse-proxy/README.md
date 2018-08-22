# My Reverse Proxy

Just a basic Nginx server that proxies traffic to the app and webservers.

Currently building this by hand is not needed as Docker Compose builds the image from the path in `docker-compose.yml`.

In production it should use Let's Encrypt certificate with 90-day renewal crontab.