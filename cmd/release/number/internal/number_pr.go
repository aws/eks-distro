package internal

import (
	. "../../internal"
	. "../../pull_request"
)

type prRequest struct {
	branch, environment, version string
	filesChanged                 []string
	bot                          bool
}

func OpenDevPR(release *Release, filesChanged []string, isBot bool) error {
	request := newPRRequest(release, filesChanged, isBot, Development)
	return openNumberPR(&request)
}

func OpenProdPR(release *Release, filesChanged []string, isBot bool) error {
	request := newPRRequest(release, filesChanged, isBot, Production)
	return openNumberPR(&request)
}

func newPRRequest(release *Release, files []string, isBot bool, environment ReleaseEnvironment) prRequest {
	return prRequest{
		branch:      release.Branch(),
		environment: environment.String(),
		version:     release.Version(),
		filesChanged: files,
		bot:         isBot,
	}
}

func openNumberPR(prReq *prRequest) error {
	pr, err := NewPullRequestForNumber(prReq)
	if err != nil {
		return err
	}
	return pr.Open()
}

func (prReq *prRequest) Branch() string {
	return prReq.branch
}

func (prReq *prRequest) Environment() string {
	return prReq.environment
}

func (prReq *prRequest) Version() string {
	return prReq.version
}

func (prReq *prRequest) FilePaths() []string {
	return prReq.filesChanged
}

func (prReq *prRequest) IsBot() bool {
	return prReq.bot
}
