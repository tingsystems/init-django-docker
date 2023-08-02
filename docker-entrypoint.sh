#!/bin/bash
# add perms for execution file docker-entrypoint.sh
python manage.py migrate                  # Apply database migrations
# Start Gunicorn processes
echo Starting server
if [ "$PROCESS_TYPE" = "server" ]; then
  if [ "$DEBUG" = "1" ]; then
    exec uvicorn api.asgi:application \
      --log-level=info --host=0.0.0.0 --port=8080 \
      --workers 1
  else
    python manage.py runserver 0.0.0.0:8080
  fi
elif [ "$PROCESS_TYPE" = "worker" ]; then
  python manage.py rqworker
fi