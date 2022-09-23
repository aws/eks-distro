package values

import "fmt"

const (
	IndexFileName               = "index.md"
	ReleaseAnnouncementFileName = "release-announcement.txt"
)

type ReleaseTag interface {
	Tag() string
}

func GetChangelogFileName(rt ReleaseTag) string {
	return fmt.Sprintf("CHANGELOG-%s.md", rt.Tag())
}
