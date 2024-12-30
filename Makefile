.PHONY: dev
dev:
	watchexec --restart --verbose --clear --wrap-process=session --stop-signal SIGTERM --exts gleam --watch src/ -- "gleam run"

.PHONY: docker-build
docker-build:
	docker build -f Dockerfile . -t latest

.PHONY: docker-run
docker-run: 
	docker  run -it -p 8080:8080 latest 


.PHONY: ex 
ex:
	gleam run --module exercism/ex

