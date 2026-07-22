FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y curl

COPY app.txt .

CMD ["cat", "app.txt"]
