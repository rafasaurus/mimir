PREFIX  := ${HOME}/.local
PKG      = github.com/talal/mimir
VERSION := $(shell util/find_version.sh)

GOOS        ?= $(word 1, $(subst /, " ", $(word 4, $(shell go version))))
GO          := GOBIN=$(CURDIR)/build go
BUILD_FLAGS :=
LD_FLAGS    := -s -w

BINARY64  := mimir-$(GOOS)_amd64
RELEASE64 := mimir-$(VERSION)-$(GOOS)_amd64

################################################################################

all: build/mimir

build/mimir: FORCE
	$(GO) install $(BUILD_FLAGS) -ldflags '$(LD_FLAGS)' '$(PKG)'

install: FORCE all
	install -D build/mimir "$(DESTDIR)$(PREFIX)/bin/mimir"

ifeq ($(GOOS),windows)
release: FORCE release/$(BINARY64)
	cd release && cp -f $(BINARY64) mimir.exe && zip $(RELEASE64).zip mimir.exe
	cd release && rm -f mimir.exe
else
release: FORCE release/$(BINARY64)
	cd release && cp -f $(BINARY64) mimir && tar -czf $(RELEASE64).tar.gz mimir
	cd release && rm -f mimir
endif

release-all: FORCE clean
	GOOS=darwin make release
	GOOS=linux  make release

release/$(BINARY64): FORCE
	GOARCH=amd64 $(GO) build $(BUILD_FLAGS) -o $@ -ldflags '$(LD_FLAGS)' '$(PKG)'

clean: FORCE
	rm -rf -- build release

.PHONY: FORCE
