FROM crystallang/crystal:0.20.5

ADD . /app/
WORKDIR /app/

RUN shards install \
 && shards build --release camo

EXPOSE 8081
USER nobody
CMD ["/app/bin/camo"]
