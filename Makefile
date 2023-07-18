SHELL = /bin/bash
PREFIX ?= /usr/local
BUILD_DIR ?= build
KEYRING_TARGET_DIR ?= $(PREFIX)/share/pacman/keyrings/
SCRIPT_TARGET_DIR ?= $(PREFIX)/bin
SYSTEMD_SYSTEM_UNIT_DIR ?= $(shell pkgconf --variable systemd_system_unit_dir systemd)
KEYRING_FILE=archwill.gpg
KEYRING_REVOKED_FILE=archwill-revoked
KEYRING_TRUSTED_FILE=archwill-trusted
SYSTEMD_TIMER_DIR=$(SYSTEMD_SYSTEM_UNIT_DIR)/timers.target.wants/
SOURCES := $(shell find keyring) $(shell find libkeyringctl -name '*.py' -or -type d) keyringctl

all: build

lint:
	black --check --diff keyringctl libkeyringctl tests
	isort --diff .
	flake8 keyringctl libkeyringctl tests
	mypy --install-types --non-interactive keyringctl libkeyringctl tests

fmt:
	black .
	isort .

check:
	./keyringctl -v check

test:
	coverage run
	coverage xml
	coverage report --fail-under=100.0

build: $(SOURCES)
	./keyringctl -v $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)

install: build
	install -vDm 644 build/{$(KEYRING_FILE),$(KEYRING_REVOKED_FILE),$(KEYRING_TRUSTED_FILE)} -t $(DESTDIR)$(KEYRING_TARGET_DIR)

uninstall:
	rm -fv $(DESTDIR)$(KEYRING_TARGET_DIR)/{$(KEYRING_FILE),$(KEYRING_REVOKED_FILE),$(KEYRING_TRUSTED_FILE)}
	rmdir -pv --ignore-fail-on-non-empty $(DESTDIR)$(KEYRING_TARGET_DIR)

.PHONY: all lint fmt check test clean install uninstall
