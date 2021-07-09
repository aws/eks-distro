package internal

import (
	. "../../internal"
	. "../../pull_request"
)

func OpenPR(release *Release, filesChanged []string) {
	pr,_ := NewPullRequestForNumber(release, filesChanged)
	pr.Open()

}
