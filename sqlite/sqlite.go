// Code as template. DO NOT EDIT.

//go:build !js

package sqlite

import (
	"database/sql"

	_ "modernc.org/sqlite"
)

func Open(path string) (*sql.DB, error) {
	return sql.Open("sqlite", path)
}
