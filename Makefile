all: dorsum-twitch

lib:
	shards

spec: lib main.cr src/**/*.cr
	crystal spec

dorsum-twitch: lib main.cr src/**/*.cr
	crystal build --error-trace -o dorsum-twitch main.cr
	@strip dorsum-twitch
	@du -sh dorsum-twitch

release: lib main.cr src/**/*.cr
	crystal build --release -o dorsum-twitch main.cr
	@strip dorsum-twitch
	@du -sh dorsum-twitch

clean:
	rm -rf .crystal dorsum-twitch .deps .shards libs lib *.dwarf build

PREFIX ?= /usr/local

install: release
	install -d $(PREFIX)/bin
	install dorsum-twitch $(PREFIX)/bin
