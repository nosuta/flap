// NIP-E5 engagement scores with decay
package nipe5

import (
	"math"
	"time"
)

const (
	HalfLifeDays = 14.0
	MinusFactor  = 3.0
)

// Event は新しい個別インタラクション
type Event struct {
	Weight    float64   // いいね=1.0, コメント=3.0, ブックマーク=5.0 など
	Timestamp time.Time // イベント発生時刻
}

// UserEngagementState はDBやRedisに保存される状態
type UserEngagementState struct {
	Snapshot          float64   // t0時点でdecay済みの累積スコア
	SnapshotTimestamp time.Time // DecayedSum が計算された基準時刻
	RecentEvents      []Event   // BaseTimestamp 以降のイベント（新しい順が望ましい）
}

// 現在のエンゲージメントスコアを計算（O(n)だがnは小さいのでOK）
func (s *UserEngagementState) CurrentScore(now time.Time) float64 {
	if s == nil {
		return 0.0
	}

	lambda := math.Ln2 / (HalfLifeDays * 24.0) // 1時間単位のdecay率

	// 1. 過去のDecayedSumに、BaseTimestamp→nowまでのdecayをかける
	factor := decayFactor(s.Snapshot, lambda, hoursSince(s.SnapshotTimestamp, now))
	score := s.Snapshot * factor

	// 2. 最近のイベントそれぞれに個別decay
	for _, ev := range s.RecentEvents {
		factor := decayFactor(ev.Weight, lambda, hoursSince(ev.Timestamp, now))
		decayed := ev.Weight * factor
		score += decayed
	}

	return score
}

func hoursSince(t, now time.Time) float64 {
	return now.Sub(t).Seconds() / 3600.0 // 時間を時間単位に変換
}

// 新しいイベントを追加（必要なら圧縮も可能）
func (s *UserEngagementState) AddEvent(weight float64, timestamp time.Time) {
	s.RecentEvents = append(s.RecentEvents, Event{
		Weight:    weight,
		Timestamp: timestamp,
	})
}

// （オプション）RecentEventsが多すぎたら、DecayedSumにマージして圧縮
func (s *UserEngagementState) Compact(threshold int, now time.Time) {
	if len(s.RecentEvents) < threshold {
		return
	}

	// すべてのRecentEventsを現在の価値にdecayさせて足す
	currentRecent := 0.0
	lambda := math.Ln2 / (HalfLifeDays * 24.0)
	for _, ev := range s.RecentEvents {
		currentRecent += ev.Weight * math.Exp(-lambda*hoursSince(ev.Timestamp, now))
	}

	// 過去のDecayedSumも現在価値に変換してからマージ
	currentPast := s.Snapshot * math.Exp(-lambda*hoursSince(s.SnapshotTimestamp, now))

	// 新しいDecayedSumと基準時刻で上書き
	s.Snapshot = currentPast + currentRecent
	s.SnapshotTimestamp = now
	s.RecentEvents = nil // リセット
}

// マイナス行動は減衰を遅くして「嫌い」を長く覚えておく
func decayFactor(weight float64, lambda float64, hours float64) float64 {
	if weight < 0 {
		// マイナスは半減期を3倍長く（例：90日で半減）
		return math.Exp(-lambda * hours / MinusFactor)
	}
	return math.Exp(-lambda * hours)
}
