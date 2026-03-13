package sqlite

import (
	"slices"
	"testing"

	"fiatjaf.com/nostr"
)

func TestEventstoreSQLite(t *testing.T) {
	sqlite, err := NewSQLite("/tmp/testeventstore.db")
	if err != nil {
		panic(err)
	}
	defer sqlite.Close()

	err = sqlite.Init()
	if err != nil {
		panic(err)
	}

	sk := nostr.Generate()
	pk := sk.Public()

	ev := nostr.Event{
		CreatedAt: nostr.Now(),
		Kind:      nostr.KindTextNote,
		Content:   "test",
		PubKey:    pk,
	}
	if err := ev.Sign(sk); err != nil {
		t.Fatal(err)
	}
	if err := sqlite.SaveEvent(ev); err != nil {
		t.Fatal(err)
	}

	ev = nostr.Event{
		CreatedAt: nostr.Now(),
		Kind:      nostr.KindTextNote,
		Content:   "test2",
		PubKey:    pk,
	}
	if err := ev.Sign(sk); err != nil {
		t.Fatal(err)
	}
	if err := sqlite.SaveEvent(ev); err != nil {
		t.Fatal(err)
	}

	filter := nostr.Filter{
		Authors: []nostr.PubKey{pk},
	}
	count, err := sqlite.CountEvents(filter)
	if err != nil {
		t.Fatal(err)
	}
	t.Logf("count: %d\n", count)
	if count != 2 {
		t.Fatal("count != 2")
	}
	res := slices.Collect(sqlite.QueryEvents(filter, 100))
	t.Logf("res: %d\n", len(res))
	for _, r := range res {
		t.Logf("%+v\n", r)
	}
}
