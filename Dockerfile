FROM crystallang/crystal:0.35.1-alpine

ADD . /app/
WORKDIR /app/

RUN shards install \
 && shards build camo

EXPOSE 8081
USER nobody
CMD ["/app/bin/camo"]
