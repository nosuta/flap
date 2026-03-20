package nostr

import (
	"context"
	"crypto/sha256"
	"fmt"
	"log/slog"
	"sort"
	"strings"

	"flap/languages"
	"flap/nostr/eventstore/sqlite"
	"flap/pb"
	"flap/pusher"

	"fiatjaf.com/nostr"
	"fiatjaf.com/nostr/eventstore"
	"fiatjaf.com/nostr/nip05"
	"fiatjaf.com/nostr/nip19"
	"fiatjaf.com/nostr/sdk"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
)

var instance *nos

type nos struct {
	Pool  *nostr.Pool
	Store eventstore.Store

	System sdk.System

	TestRelays     []string
	TestIndexRelay string
}

func Nostr() *nos {
	if instance != nil {
		return instance
	}
	instance = &nos{
		TestRelays:     []string{"wss://relay.damus.io", "wss://yabu.me"},
		TestIndexRelay: "wss://user.kindpag.es",
	}
	return instance
}

func (n *nos) Init(databasePath, appEncryptionKey string) error {
	if len(databasePath) > 0 && n.Store == nil {
		store, err := sqlite.NewSQLite(databasePath)
		if err != nil {
			return err
		}
		if err := store.Init(); err != nil {
			return err
		}
		n.Store = store
	}
	if len(appEncryptionKey) > 0 {
		// TODO: use app encryption key in the system or nos
	}
	if n.Pool == nil {
		n.Pool = nostr.NewPool(nostr.PoolOptions{})
	}

	return nil
}

func (n *nos) Close() {
	if n.Store != nil {
		n.Store.Close()
	}
}

func (n *nos) GetProfiles(ctx context.Context, pubkey string) (*pb.Profile, error) {
	if r := recover(); r != nil {
		slog.Error("GetProfile recovered from panic: %v", r)
	}
	slog.Info("GetProfile", "pubkey", pubkey)
	if err := n.Init("", ""); err != nil {
		return nil, err
	}

	pk, err := nostr.PubKeyFromHex(pubkey)
	if err != nil {
		return nil, err
	}

	evt := n.Pool.QuerySingle(
		ctx,
		[]string{n.TestIndexRelay},
		nostr.Filter{
			Kinds:   []nostr.Kind{nostr.KindProfileMetadata},
			Authors: []nostr.PubKey{pk},
		},
		nostr.SubscriptionOptions{},
	)
	if evt == nil {
		return nil, fmt.Errorf("event is nil")
	}

	if err := n.Store.SaveEvent(evt.Event); err != nil {
		slog.Info("failed to save event", "err", err)
		return nil, err
	}

	meta := sdk.ProfileMetadata{}
	meta, err = sdk.ParseMetadata(evt.Event)
	if err != nil {
		return nil, err
	}
	name := meta.DisplayName
	if name == "" {
		name = meta.Name
	}
	dnsID := meta.NIP05
	nip5 := strings.Split(meta.NIP05, "@")
	if len(nip5) == 3 && nip5[0] == "_" {
		dnsID = nip5[2]
	}
	return &pb.Profile{
		Pubkey:  pubkey,
		Name:    name,
		DnsId:   dnsID,
		Picture: meta.Picture,
		Website: meta.Website,
		Banner:  meta.Banner,
		Lud16:   meta.LUD16,
	}, nil
}

func (n *nos) FetchSuperZap() {
	// TODO:
}

func (n *nos) FetchNotes(ctx context.Context, topic string, since, until *int64, push pusher.Pusher) (*pb.Notes, error) {
	if r := recover(); r != nil {
		slog.Error("RecentNote recovered from panic: %v", r)
	}
	if err := n.Init("", ""); err != nil {
		return nil, err
	}

	// test fetch and push
	if _, name, err := nip05.Fetch(ctx, "_@reishisaza.com"); err != nil {
		// if resp, err := fetch.Fetch(ctx, "https://reishisaza.com/.well-known/nostr.json"); err != nil {
		slog.Error("failed to test http", "err", err)
	} else {
		if err := push(pb.NewPushNip05(&pb.PushNip05{
			Id: fmt.Sprintf("fetched NIP-05 (%s)", name),
		})); err != nil {
			slog.Error("failed to test push", "err", err)
		}

	}

	// if err := push(&pb.Push{
	// 	Type: &pb.Push_Note{
	// 		Note: &pb.Note{
	// 			Id: "push push",
	// 		},
	// 	},
	// }); err != nil {
	// 	slog.Error("failed to test push", "err", err)
	// }

	tagmap := nostr.TagMap{}
	if len(topic) > 0 {
		tagmap = nostr.TagMap{"t": {topic}}
	}

	ev := n.Pool.FetchMany(ctx, n.TestRelays, nostr.Filter{
		Since: (nostr.Timestamp)(*since),
		Until: (nostr.Timestamp)(*until),
		Kinds: []nostr.Kind{nostr.KindTextNote},
		Tags:  tagmap,
		Limit: 500,
	}, nostr.SubscriptionOptions{})

	notes := &pb.Notes{}
	topics := make(map[string]int, 0)

	for evt := range ev {
		verified, err := n.verifyEvent(evt.Event)
		if err != nil {
			return nil, err
		}
		if !verified {
			// TODO: add the insecure relay to the list
			continue
		}

		nevent := nip19.EncodeNevent(evt.ID, []string{evt.Relay.URL}, evt.PubKey)
		npub := nip19.EncodeNpub(evt.PubKey)

		relay := ""
		if evt.Relay != nil {
			relay = evt.Relay.URL
		}
		subject := ""
		ht := make(map[string]int, 0)

		for _, tag := range evt.Tags {
			if len(tag) >= 2 && tag[0] == "subject" {
				subject = tag[1]
			}
			if len(tag) >= 2 && tag[0] == "t" {
				v, ok := ht[tag[1]]
				if ok {
					ht[tag[1]] = v + 1
				} else {
					ht[tag[1]] = 1
				}
			}
		}
		for k := range ht {
			v, ok := topics[k]
			if ok {
				topics[k] = v + 1
			} else {
				topics[k] = 1
			}
		}

		if subject != "" {
			slog.Info("found", "subject", subject)
		}

		// TODO: detect after parsing the content
		// lang := "en"
		// l, ok := langDetector.DetectLanguageOf(evt.Content)
		// if ok {
		// 	lang = strings.ToLower(l.IsoCode639_1().String())
		// }
		lang := languages.DetectLanguage(evt.Content)

		notes.Notes = append(notes.Notes, &pb.Note{
			Id:        evt.ID.Hex(),
			Nevent:    nevent,
			Pubkey:    evt.PubKey.Hex(),
			Lang:      lang,
			Npub:      npub,
			Subject:   subject,
			Content:   evt.Content,
			CreatedAt: int64(evt.CreatedAt),
			Relays:    []string{relay},
		})
	}

	// if len(notes.Notes) > 20 {
	// 	notes.Notes = notes.Notes[:20]
	// }

	// topicKeys := make([]string, 0, len(topics))
	// for key := range topics {
	// 	topicKeys = append(topicKeys, key)
	// }
	// sort.SliceStable(topicKeys, func(i, j int) bool {
	// 	return topics[topicKeys[i]] > topics[topicKeys[j]]
	// })

	sort.SliceStable(notes.Notes, func(i, j int) bool {
		return notes.Notes[i].CreatedAt > notes.Notes[j].CreatedAt
	})

	return notes, nil
}

func (n *nos) verifyEvent(evt nostr.Event) (bool, error) {
	pubkey, err := schnorr.ParsePubKey(evt.PubKey[:])
	if err != nil {
		return false, fmt.Errorf("event has invalid pubkey '%s': %w", evt.PubKey, err)
	}
	sig, err := schnorr.ParseSignature(evt.Sig[:])
	if err != nil {
		return false, fmt.Errorf("failed to parse signature: %w", err)
	}
	// check signature
	hash := sha256.Sum256(evt.Serialize())
	if evt.ID != hash {
		return false, nil
	}
	return sig.Verify(hash[:], pubkey), nil
}
