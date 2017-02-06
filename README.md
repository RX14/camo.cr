# camo.cr

A crystal version of [Camo](https://github.com/atmos/camo), faster and with better request lifecycle tracing. This is a drop-in replacement which mirrors original camo's configuration and behaviour as closely as possible.

Camo.cr proxies images with the intent of allowing insecure images to be used on sites with TLS without mixed-content warnings.

## Why?

The original nodejs camo code is fragile and hard to debug in production. As it's not a particularly long piece of code, I could write a replacement in a single day, with vastly better error handling and request tracing. Plus it's a fun challenge.

## Installation

Inside a checked-out version of this repo:

```
$ shards install
$ shards build --release
```

The resulting binary will be in `bin/camo`.

Alternatively, a docker container is available at [`rx14/camo.cr`](https://hub.docker.com/r/rx14/camo.cr/). This container is also a drop-in replacement for the `inventid/camo` docker container.

## Usage

See [atmos/camo's README](https://github.com/atmos/camo/blob/master/README.md).

## Development

After checking out the repo and running `shards install`, run specs using `crystal spec`.

## Contributing

1. Fork it ( https://github.com/RX14/camo.cr/fork )
2. Create your feature branch (`git checkout -b feature/foo`)
3. Commit your changes (`git gui`)
4. Push to the branch (`git push origin feature/foo`)
5. Create a new Pull Request

## Contributors

- [RX14](https://github.com/RX14) RX14 - creator, maintainer
