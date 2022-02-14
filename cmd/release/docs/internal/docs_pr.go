package internal

import (
	. "../../pull_request"
)

type docsPRRequest struct {
	branch, version string
	filesChanged    []string
	bot             bool
}

func OpenDocsPR(release *Release, docStatuses []DocStatus, isBot bool) error {
	prRequest := newDocsPRRequest(release, GetPaths(docStatuses), isBot)
	pr, err := NewPullRequestForDocs(&prRequest)
	if err != nil {
		return err
	}
	return pr.Open()
}

func newDocsPRRequest(release *Release, filesChanged []string, isBot bool) docsPRRequest {
	return docsPRRequest{
		branch:       release.Branch(),
		version:      release.Version(),
		filesChanged: filesChanged,
		bot:          isBot,
	}
}

func (prReq *docsPRRequest) Branch() string {
	return prReq.branch
}

func (prReq *docsPRRequest) Version() string {
	return prReq.version
}

func (prReq *docsPRRequest) FilePaths() []string {
	return prReq.filesChanged
}

func (prReq *docsPRRequest) IsBot() bool {
	return prReq.bot
}
