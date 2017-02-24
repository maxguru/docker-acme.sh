# docker-acme.sh

## acme.sh and docker-acme.sh
* [acme.sh](https://github.com/Neilpang/acme.sh) is a client for Let's Encrypt which is written in pure shell script.
* docker-acme.sh runs acme.sh in docker. That's it.

And, docker-acme.sh is following the version tag rather than master branch.

## Ways to issue a cert in acme.sh
acme.sh supports multiple way to issue a cert:

* webroot (It will put some files in the root directory of your websites, I think this is not a clean way for production environment)
* standalone server (Tcp 80 must be free to listen, so you need stop the web server which is using this port, that's not good for production environment)
* standalone tls server (Tcp 443 must be free to listen, so you need stop the web server which is using this port, that's also not good for production environment)
* apache mode (Required to interact with apache server. But it's not convinient to interact with docker container for the apache running on host)
* DNS mode (In my view, this is the best way to issue a cert, all the things you need to do is adding a DNS record)

In a nutshell, I think **the best way to issue a cert is DNS mode**.

## Ways to issue a cert in docker-acme.sh
In above section, I declared my opinion —— the best way to issue a cert is DNS mode.

So, the way to issue a cert in docker-acme.sh is DNS mode. Although other ways that are supported by
acme.sh is available, but are not usable.

In a nutshell, docker-acme.sh supports DNS mode only.

## How to use docker-acme.sh
I have already built a docker image —— `m31271n/acme.sh`.

Run a container:

```sh
shell> docker run
    -d \
    --name acme.sh \
    -v $(pwd)/certs:/certs \
    -v $(pwd)/account:/account \
    m31271n/acme.sh
```

Use above running container to issue a cert, take `m31271n.com` as an example:

```sh
shell> docker exec acme.sh acme.sh --issue --dns -d m31271n.com

[Sat Jul 16 03:15:44 UTC 2016] Add the following TXT record:
[Sat Jul 16 03:15:44 UTC 2016] Domain: _acme-challenge.m31271n.com
[Sat Jul 16 03:15:44 UTC 2016] TXT value: 536MSSmluCVasBvjoeRvoNFve8ISmUpk9iuzkfjiRbk
[Sat Jul 16 03:15:44 UTC 2016] Please be aware that you prepend _acme-challenge. before your domain
[Sat Jul 16 03:15:44 UTC 2016] so the resulting subdomain will be: _acme-challenge.m31271n.com
[Sat Jul 16 03:15:44 UTC 2016] Please add the TXT records to the domains, and retry again.
```

Add above **TXT value** to the DNS record of your domain. Waiting for the dns to take effect,
Then, renew the cert:

```sh
shell> docker exec acme.sh acme.sh --renew -d m31271n.com
```

OK, it's finished. The cert files is placed in `$(pwd)/certs/m31271n.com`.

## How to renew a cert
Renewing a cert is automatic.

There is a cron job running in the container, you have nothing to do.

## How to backup
Backup `$(pwd)/account` and `$(pwd)/certs`. That is it.

# LICENSE
GPL-3.0
