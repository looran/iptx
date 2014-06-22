iptablesx
=========

Iptables helper for your laptop


### Usage

```bash
iptablesx (clean | show | <service> | port/proto) [<interface>] [open | close]

Examples:
iptablesx ftp
iptablesx ftp close
iptablesx pyweb wifi
iptablesx pyweb wifi close
iptablesx pyweb eth3
iptablesx pyweb eth3 close
iptablesx 12345/tcp
iptablesx 12345/tcp close
iptablesx clean
```

