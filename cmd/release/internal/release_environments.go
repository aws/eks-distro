package internal

// TODO: replace all uses of strings with ReleaseEnvironment types
type ReleaseEnvironment string

const (
	DevelopmentRelease ReleaseEnvironment = "development"
	ProductionRelease  ReleaseEnvironment = "production"
)

func (re ReleaseEnvironment) String() string {
	return string(re)
}
