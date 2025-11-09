#!/bin/bash
set -e

yum update -y
yum install -y nginx

cat > /usr/share/nginx/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>AWS ALB Demo</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            padding: 40px;
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        h1 { font-size: 2.5em; margin-bottom: 20px; }
        .info { background: rgba(0, 0, 0, 0.2); padding: 20px; border-radius: 5px; margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>AWS Application Load Balancer Demo</h1>
        <p>Successfully deployed with Terraform!</p>
        <div class="info">
            <p><strong>Instance ID:</strong> <span id="instance-id">Loading...</span></p>
            <p><strong>Availability Zone:</strong> <span id="az">Loading...</span></p>
            <p><strong>Private IP:</strong> <span id="private-ip">Loading...</span></p>
        </div>
    </div>
    <script>
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(r => r.text())
            .then(data => document.getElementById('instance-id').textContent = data)
            .catch(() => document.getElementById('instance-id').textContent = 'N/A');
        
        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone')
            .then(r => r.text())
            .then(data => document.getElementById('az').textContent = data)
            .catch(() => document.getElementById('az').textContent = 'N/A');
        
        fetch('http://169.254.169.254/latest/meta-data/local-ipv4')
            .then(r => r.text())
            .then(data => document.getElementById('private-ip').textContent = data)
            .catch(() => document.getElementById('private-ip').textContent = 'N/A');
    </script>
</body>
</html>
EOF

systemctl enable nginx
systemctl start nginx
