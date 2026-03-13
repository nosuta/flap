package sqlite

import (
	"context"
	lite "flap/sqlite"
	"iter"
	"log/slog"
	"time"

	"fiatjaf.com/nostr"
	"fiatjaf.com/nostr/eventstore"
	nlite "github.com/1l0/nostr-sqlite"
)

var _ eventstore.Store = (*SQLite)(nil)

type SQLite struct {
	Store   *nlite.Store
	timeout time.Duration
}

func NewSQLite(path string) (*SQLite, error) {
	db, err := lite.Open(path)
	if err != nil {
		return nil, err
	}
	store, err := nlite.New(db)
	if err != nil {
		return nil, err
	}
	return &SQLite{
		Store:   store,
		timeout: time.Second * 10,
	}, nil
}

func (s *SQLite) Init() error {
	return nil
}

func (s *SQLite) Close() {
	s.Store.Close()
}

func (s *SQLite) QueryEvents(filter nostr.Filter, maxLimit int) iter.Seq[nostr.Event] {
	filter.Limit = maxLimit
	return func(yield func(nostr.Event) bool) {
		ctx, cancel := context.WithTimeout(context.Background(), s.timeout)
		defer cancel()
		events, err := s.Store.Query(ctx, filter)
		if err != nil {
			slog.Error("s.store.Query", "err", err)
			return
		}
		for _, evt := range events {
			if !yield(evt) {
				return
			}
		}
	}
}

func (s *SQLite) DeleteEvent(id nostr.ID) error {
	ctx, cancel := context.WithTimeout(context.Background(), s.timeout)
	defer cancel()
	_, err := s.Store.Delete(ctx, id.Hex())
	return err
}

func (s *SQLite) SaveEvent(event nostr.Event) error {
	ctx, cancel := context.WithTimeout(context.Background(), s.timeout)
	defer cancel()
	_, err := s.Store.Save(ctx, &event)
	return err
}

func (s *SQLite) ReplaceEvent(event nostr.Event) error {
	ctx, cancel := context.WithTimeout(context.Background(), s.timeout)
	defer cancel()
	_, err := s.Store.Replace(ctx, &event)
	return err
}

func (s *SQLite) CountEvents(filter nostr.Filter) (uint32, error) {
	ctx, cancel := context.WithTimeout(context.Background(), s.timeout)
	defer cancel()
	count, err := s.Store.Count(ctx, filter)
	if err != nil {
		return 0, err
	}
	return uint32(count), nil
}
