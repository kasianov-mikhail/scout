#!/usr/bin/env bash
# Bring up the server's default Fluent config: user scout, password scout,
# database scout on localhost:5432.

brew install postgresql@17
pgbin="$(brew --prefix postgresql@17)/bin"
brew services start postgresql@17
for _ in $(seq 1 30); do
  if "$pgbin/pg_isready" -q -h 127.0.0.1; then
    break
  fi
  sleep 1
done
if ! "$pgbin/pg_isready" -q -h 127.0.0.1; then
  echo "PostgreSQL did not become ready on 127.0.0.1:5432"
  exit 1
fi
"$pgbin/psql" -h 127.0.0.1 -d postgres -c "CREATE ROLE scout LOGIN PASSWORD 'scout'"
"$pgbin/createdb" -h 127.0.0.1 -O scout scout
