FROM crystallang/crystal:0.24.1

ADD . /app/
WORKDIR /app/

RUN shards install \
 && shards build camo

EXPOSE 8081
USER nobody
CMD ["/app/bin/camo"]
