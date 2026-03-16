// Code as template. DO NOT EDIT.

//go:build js

package sqlite

import (
	"database/sql"
	"fmt"

	_ "github.com/nosuta/go-wasmsqlite"
)

func Open(path string) (*sql.DB, error) {
	f := fmt.Sprintf("file=%s&api=oo", path)
	return sql.Open("wasmsqlite", f)
}
