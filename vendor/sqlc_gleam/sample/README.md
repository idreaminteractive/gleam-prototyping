# Sample project for developing

## Setup

Your setup may differ from this, but this works.

- `sqlc` + `sqlc-gen-json` runnable from the CLI. Suggest you install via: 
```
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
go install github.com/sqlc-dev/sqlc/cmd/sqlc-gen-json@latest
```

- `sqlc.yaml` at root of the project with the setup as noted.
- A `migrations` folder with your migrations setup and ready to go. 
- A `sql` folder with all your queries in it. This will be used along with the migrations folder to do it up.
- `dbmate` installed to configure and run migrations.

- Be sure to goto the vendor folder + `gleam update` + `gleam build`


## Generating

For locally testing generation, when developing, I use the following commands. Use whatever you like to manage this (`make`, `Taskfile`, etc). Assume the db is located at `./data/sqlite.db`, and the migrations are in the `migrations` folder

- `rm -f ./data/*.db`
- `DATABASE_URL="sqlite:data/sqlite.db" dbmate -d "./migrations" up`
- `sqlc generate`
- `rm src/app/gen/sqlc_sqlite.gleam` (remove previously generated file)
- `gleam run --module sqlc_gleam` - Temporary only for now.  
