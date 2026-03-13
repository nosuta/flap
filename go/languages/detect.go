package languages

import (
	"regexp"
)

var (
	japanese   = regexp.MustCompile(`[\p{Hiragana}\p{Katakana}]`)
	chinese    = regexp.MustCompile(`[\p{Han}]`)
	arabic     = regexp.MustCompile(`[\p{Arabic}]`)
	russian    = regexp.MustCompile(`[\p{Cyrillic}]`)
	korean     = regexp.MustCompile(`[\p{Hangul}]`)
	indonesian = regexp.MustCompile(`\b(?i)(saya|kamu|tidak|dan|ini|itu)\b`)
	spanish    = regexp.MustCompile(`(?i)[ñáéíóúü¡¿]`)
	french     = regexp.MustCompile(`(?i)[éèêëàâîïôûùçœ]`)
	// italian    = regexp.MustCompile(`\b(?i)(ciao|perché|grazie|buongiorno)\b`)
	german = regexp.MustCompile(`(?i)([äöüÄÖÜß]|\bdeis|ein\b)`)
)

// DetectLanguage is a lightweight language detector. It's not accurate.
func DetectLanguage(content string) string {
	lang := "en"
	if japanese.MatchString(content) {
		lang = "ja"
	} else if chinese.MatchString(content) {
		lang = "zh"
	} else if korean.MatchString(content) {
		lang = "ko"
	} else if arabic.MatchString(content) {
		lang = "ar"
	} else if spanish.MatchString(content) {
		lang = "es"
		// } else if italian.MatchString(content) {
		// 	lang = "it"
	} else if french.MatchString(content) {
		lang = "fr"
	} else if russian.MatchString(content) {
		lang = "ru"
	} else if indonesian.MatchString(content) {
		lang = "id"
	} else if german.MatchString(content) {
		lang = "de"
	}
	return lang
}
