.PHONY: run
run:
	@echo  "Running generation"
	rm -f ./data/*.db
	mkdir -p data
	DATABASE_URL="sqlite:data/sqlite.db" dbmate -d "./migrations" up
	sqlc generate	
	gleam run --module sqlc_gleam
	gleam run
	gleam format

