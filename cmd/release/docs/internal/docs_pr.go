package internal

import (
	. "../../pull_request"
)

type docsPRRequest struct {
	branch, version string
	filesChanged    []string
}

func OpenDocsPR(release *Release, docStatuses []DocStatus) error {
	prRequest := newDocsPRRequest(release, GetPaths(docStatuses))
	pr, err := NewPullRequestForDocs(&prRequest)
	if err != nil {
		return err
	}
	return pr.Open()
}

func newDocsPRRequest(release *Release, filesChanged []string) docsPRRequest {
	return docsPRRequest{
		branch:       release.Branch(),
		version:      release.Version(),
		filesChanged: filesChanged,
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
