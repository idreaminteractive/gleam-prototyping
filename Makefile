.PHONY: dev

dev:
	watchexec --restart --verbose --clear --wrap-process=session --stop-signal SIGTERM --exts gleam --watch src/ -- "gleam run"