# Adding nested add_headers invalidates add_header directives in
# outer scopes. Avoid this by matching asset regexes with their
# corresponding cache control value and keep the structure flat.
map $uri $cache_control_header {
    default "public, max-age=0, must-revalidate";
    ~*\.(?:html)$ "public, max-age=0, must-revalidate";
    ~*/page\-data.json$ "public, max-age=0, must-revalidate";
    ~*/app\-data.json$ "public, max-age=0, must-revalidate";
    /sw.js$ "public, max-age=0, must-revalidate";
    /static/ "public, max-age=31536000, immutable";
    ~*\.(?:js|css)$ "public, max-age=31536000, immutable";
}

server {
    root /home/raspat/www/personal-site/gatsby/public;
    server_name raspatel.com www.raspatel.com;
    index index.html;

    # For Reporting CSP violations
    location = /_csp_log {
        access_log /var/log/nginx/report-to-csp.log CSP;
        proxy_pass https://127.0.0.1/health_check;
    }
    location = /_nel_log {
        access_log /var/log/nginx/report-to-nel.log CSP;
        proxy_pass https://127.0.0.1/health_check;
    }

    location = /health_check {
        access_log off;
        allow 127.0.0.1;
        return 204;
    }

    location /v1 {
        alias /home/raspat/www/personal-site/public/;
    }

    # Mail server auth file
    # location /mail {
    #     alias /home/raspat/www/personal-site/mail/public/;
    #     try_files auth.php =404;
    # }

    listen [::]:443 ssl http2 ipv6only=on; # managed by Certbot
    listen 443 ssl http2; # managed by Certbot

    ssl_certificate /etc/letsencrypt/live/raspatel.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/raspatel.com/privkey.pem; # managed by Certbot
    ssl_trusted_certificate /etc/letsencrypt/live/raspatel.com/fullchain.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    add_header Cache-Control $cache_control_header;
    add_header Strict-Transport-Security "max-age=31536000" always; # managed by Certbot
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    add_header Report-To '{"group": "csp", "max_age":31536000,"endpoints":[{"url":"https://$host/_csp_log"}]}';
    add_header Report-To '{"group": "nel", "max_age":31536000,"endpoints":[{"url":"https://$host/_nel_log"}], "include_subdomains": true}';
    add_header NEL '{"report_to":"default","max_age":31536000,"include_subdomains":true, "success_fraction": 1}';
    add_header Content-Security-Policy "default-src 'self'; style-src 'self' 'unsafe-inline'; font-src 'self' data:; img-src 'self' img.lekoarts.de; script-src 'self' 'unsafe-inline' https://www.googletagmanager.com; connect-src 'self' https://www.google-analytics.com; object-src 'none'; report-uri https://$host/_csp_log; report-to csp;";

    resolver 1.1.1.1 1.0.0.1 [2606:4700:4700::1111] [2606:4700:4700::1001] # cloudflare dns
             8.8.8.8 8.8.4.4 [2001:4860:4860::8888] [2001:4860:4860::8844] # google dns
             # 208.67.222.222 208.67.220.220 [2620:119:35::35] [2620:119:53::53] # opendns
             valid=60s;
    resolver_timeout 2s;
}

server {
    if ($host = www.raspatel.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    if ($host = raspatel.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    listen [::]:80;

    server_name raspatel.com www.raspatel.com;

    return 404; # managed by Certbot
}