package internal

import (
	. "../../internal"
	. "../../pull_request"
)

type prRequest struct {
	branch, environment, version string
}

func OpenDevPR(release *Release, filesChanged []string) error {
	return openPR(
		&prRequest{
			branch:      release.Branch(),
			environment: Development.String(),
			version:     release.Version(),
		}, filesChanged)
}

func OpenProdPR(release *Release, filesChanged []string) error {
	return openPR(
		&prRequest{
			branch:      release.Branch(),
			environment: Production.String(),
			version:     release.Version(),
		}, filesChanged)
}

func openPR(prReq *prRequest, filesChanged []string) error {
	pr, err := NewPullRequestForNumber(prReq, filesChanged)
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
