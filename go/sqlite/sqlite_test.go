// Code as template. DO NOT EDIT.

package sqlite

import (
	"fmt"
	"log/slog"
	"testing"
)

const test_sql_init = `
CREATE TABLE IF NOT EXISTS authors (
  id   INTEGER PRIMARY KEY,
  name text    NOT NULL,
  bio  text
);
INSERT INTO authors (name, bio) VALUES ('asdf', 'im asdf');
INSERT INTO authors (name, bio) VALUES ('fdsa', 'im fdsa');
INSERT INTO authors (name, bio) VALUES ('asdf', 'feels good');
`

const test_sql_query = `SELECT id, name, bio FROM authors WHERE name = ?;`

func TestDatabase(t *testing.T) {
	db, err := Open("testdb")
	if err != nil {
		t.Fatal(err)
	}
	result, err := db.Exec(test_sql_init)
	if err != nil {
		t.Fatal(err)
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		t.Fatal(err)
	}
	lastInsertId, err := result.LastInsertId()
	if err != nil {
		t.Fatal(err)
	}
	slog.Info("exec", "RowsAffected", rowsAffected, "LastInsertId", lastInsertId)

	_, err = db.Exec("UNKNOWN COMMAND")
	if err == nil {
		t.Fatal(fmt.Errorf("%s", "expected error"))
	}

	rows, err := db.Query(test_sql_query, "asdf")
	if err != nil {
		t.Fatal(err)
	}
	type author struct {
		ID   int64
		Name string
		Bio  string
	}
	authors := []author{}
	for rows.Next() {
		var i author
		if err := rows.Scan(
			&i.ID,
			&i.Name,
			&i.Bio,
		); err != nil {
			t.Fatal(err)
		}
		authors = append(authors, i)
	}
	if err := rows.Close(); err != nil {
		t.Fatal(err)
	}
	if err := rows.Err(); err != nil {
		t.Fatal(err)
	}
	t.Logf("authors: %+v\n", authors)
}
