iptx
====

Iptables helper for your laptop


### Usage

```bash
iptx (clean | show | <service> | port/proto) [<interface>] [open | close]

Examples:
iptx ftp                    # Open ftp port on ethernet interface
iptx ftp close              # Close ftp port on ethernet interface
iptx http                   # Open http port on ethernet interface
iptx http wifi              # Open http port on wireless interface
iptx http all close         # Close http port on both interfaces
iptx 12345/tcp eth3         # Open 12345/tcp on eth3
iptx 12345/tcp eth3 close   # Close 12345/tcp on eth3
iptx clean                  # Restore iptables defaults
```

