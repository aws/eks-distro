package internal

import (
	. "../../pull_request"
	. "../../utils"
)

type prRequest struct {
	branch, environment, version string
	filesChanged                 []string
	bot                          bool
}

func OpenDevPR(branch, number string, filesChanged []string, isBot bool) error {
	request := newPRRequest(branch, number, filesChanged, isBot, Development)
	return openNumberPR(&request)
}

func OpenProdPR(branch, number string, filesChanged []string, isBot bool) error {
	request := newPRRequest(branch, number, filesChanged, isBot, Production)
	return openNumberPR(&request)
}

func newPRRequest(branch, number string, files []string, isBot bool, environment ReleaseEnvironment) prRequest {
	return prRequest{
		branch:       branch,
		environment:  environment.String(),
		version:      GetBranchWithDotAndNumberWithDashFormat(branch, number),
		filesChanged: files,
		bot:          isBot,
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
