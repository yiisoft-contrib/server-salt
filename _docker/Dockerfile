FROM python:3.9-bookworm

RUN pip install --no-cache-dir "salt==3006.30" requests PyMySQL
COPY --chmod=400 ssh/id_rsa /root/.ssh/id_rsa

WORKDIR /app
