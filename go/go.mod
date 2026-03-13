module flap

go 1.25.0

replace fiatjaf.com/nostr => ./../../../../ngit/fiatjaf/nostrlib

require (
	connectrpc.com/connect v1.19.1
	fiatjaf.com/nostr v0.0.0-20260312140001-bb4093d834af
	github.com/1l0/go-wasmsqlite v0.0.0-20251123143527-81cad988c1e2
	github.com/1l0/nostr-sqlite v0.7.0
	github.com/aperturerobotics/protobuf-go-lite v0.11.0
	github.com/btcsuite/btcd/btcec/v2 v2.3.6
	golang.org/x/exp v0.0.0-20260312153236-7ab1446f8b90
	google.golang.org/protobuf v1.36.11
	marwan.io/wasm-fetch v0.1.0
	modernc.org/sqlite v1.33.1
)

require (
	fiatjaf.com/lib v0.3.6 // indirect
	github.com/FastFilter/xorfilter v0.2.1 // indirect
	github.com/ImVexed/fasturl v0.0.0-20230304231329-4e41488060f3 // indirect
	github.com/btcsuite/btcd v0.24.2 // indirect
	github.com/btcsuite/btcd/btcutil v1.1.6 // indirect
	github.com/btcsuite/btcd/chaincfg/chainhash v1.1.0 // indirect
	github.com/cespare/xxhash/v2 v2.3.0 // indirect
	github.com/coder/websocket v1.8.14 // indirect
	github.com/decred/dcrd/crypto/blake256 v1.1.0 // indirect
	github.com/decred/dcrd/dcrec/secp256k1/v4 v4.4.1 // indirect
	github.com/dgraph-io/ristretto/v2 v2.3.0 // indirect
	github.com/dustin/go-humanize v1.0.1 // indirect
	github.com/elnosh/gonuts v0.4.2 // indirect
	github.com/fxamacker/cbor/v2 v2.7.0 // indirect
	github.com/golang-migrate/migrate/v4 v4.19.0 // indirect
	github.com/google/uuid v1.6.0 // indirect
	github.com/hashicorp/errwrap v1.1.0 // indirect
	github.com/hashicorp/go-multierror v1.1.1 // indirect
	github.com/hashicorp/golang-lru/v2 v2.0.7 // indirect
	github.com/josharian/intern v1.0.0 // indirect
	github.com/json-iterator/go v1.1.12 // indirect
	github.com/mailru/easyjson v0.9.1 // indirect
	github.com/mattn/go-isatty v0.0.20 // indirect
	github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd // indirect
	github.com/modern-go/reflect2 v1.0.2 // indirect
	github.com/ncruces/go-strftime v0.1.9 // indirect
	github.com/puzpuzpuz/xsync/v3 v3.5.1 // indirect
	github.com/remyoudompheng/bigfft v0.0.0-20230129092748-24d4a6f8daec // indirect
	github.com/templexxx/cpu v0.1.1 // indirect
	github.com/templexxx/xhex v0.0.0-20200614015412-aed53437177b // indirect
	github.com/tidwall/gjson v1.18.0 // indirect
	github.com/tidwall/match v1.2.0 // indirect
	github.com/tidwall/pretty v1.2.1 // indirect
	github.com/x448/float16 v0.8.4 // indirect
	golang.org/x/crypto v0.43.0 // indirect
	golang.org/x/sync v0.20.0 // indirect
	golang.org/x/sys v0.37.0 // indirect
	modernc.org/gc/v3 v3.0.0-20240107210532-573471604cb6 // indirect
	modernc.org/libc v1.55.3 // indirect
	modernc.org/mathutil v1.6.0 // indirect
	modernc.org/memory v1.8.0 // indirect
	modernc.org/strutil v1.2.0 // indirect
	modernc.org/token v1.1.0 // indirect
)

tool (
	connectrpc.com/connect/cmd/protoc-gen-connect-go
	google.golang.org/protobuf/cmd/protoc-gen-go
)
