# docker-compose/dokuwiki
=========================

Docker compose container image with [DokuWiki](https://www.dokuwiki.org/dokuwiki) and nginx.

Based on istepanov/dokuwiki https://github.com/istepanov/docker-dokuwiki
and modifications done by damoon https://github.com/damoon/docker-dokuwiki

## Installation

First, clone this repository:

```bash
$ git clone https://github.com/lachouettecoop/coops-wiki.git
```

Create your instance of docker-compose.yml

```bash
$ cp docker-compose.yml.dist docker-compose.yml
```

With your favorite text editor edit 'docker-compose.yml' and do the following changes

* `VIRTUAL_HOST`: put your domain name here

## Execution

```bash
$ docker-compose up -d
```

## Bonus

If you have [nginx-proxy](https://github.com/jwilder/nginx-proxy) the website will be accessible on your VIRTUAL_HOST domain.

## Licence

[MIT](LICENSE)
Copyright (c) 2014-2015 Ilya Stepanov
