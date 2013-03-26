worker_processes 4

timeout 120
listen 8082
pid 'unicorn.pid'
stderr_path 'log/unicorn.log'
stdout_path 'log/unicorn.log'

