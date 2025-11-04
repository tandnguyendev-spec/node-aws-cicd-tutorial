module.exports = {
  apps: [{
    name: 'demo-node-app',
    script: './index.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: '/opt/demo-node-app/logs/error.log',
    out_file: '/opt/demo-node-app/logs/out.log',
    log_file: '/opt/demo-node-app/logs/combined.log',
    time: true,
    merge_logs: true
  }]
};
