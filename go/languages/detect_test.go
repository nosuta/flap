package languages

import (
	"testing"
)

func TestDetectLanguage(t *testing.T) {
	tests := []struct {
		content  string
		expected string
	}{
		{"これは日本語の文章です。", "ja"},
		{"这是中文句子。", "zh"},
		{"Ini adalah kalimat dalam bahasa Indonesia.", "id"},
		{"هذا جملة باللغة العربية.", "ar"},
		{"Это предложение на русском языке.", "ru"},
		{"이것은 한국어 문장입니다.", "ko"},
		{"Esta es una oración en español.", "es"},
		{"C'est une phrase en français.", "fr"},
		// {"Questo è una frase in italiano.", "it"},
		{"deutscher Satz. ein.", "de"},
		{"This is an English sentence.", "en"},
	}

	for _, test := range tests {
		result := DetectLanguage(test.content)
		if result != test.expected {
			t.Errorf("DetectLanguage(%q) = %q; want %q", test.content, result, test.expected)
		}
	}
}
