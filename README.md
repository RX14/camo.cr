# camo.cr

A crystal version of [Camo](https://github.com/atmos/camo), faster and with better request lifecycle tracing. This is a drop-in replacement which mirrors original camo's configuration and behaviour as closely as possible.

Camo.cr proxies images with the intent of allowing insecure images to be used on sites with tls without mixed-content warnings.

## Installation

Inside a checked-out version of this repo:

```
$ shards install
$ shards build --release
```

The resulting binary will be in `bin/camo`.

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
