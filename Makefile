PREFIX=/usr/local
BINDIR=$(PREFIX)/bin

all:
	@echo "Run \"sudo make install\" to install iptx"

install:
	install -m 0755 iptx.sh $(BINDIR)/iptx

