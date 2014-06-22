PREFIX=/usr/local
BINDIR=$(PREFIX)/bin

all:
	@echo "Run \"sudo make install\" to install iptablesx"

install:
	install -m 0755 iptablesx.sh $(BINDIR)/iptablesx

