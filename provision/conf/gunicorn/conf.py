bind = 'unix:/tmp/gunicorn.sock'
workers = 3

# Pass error logs through to be written/rotated by supervisor
errorlog = '-'
