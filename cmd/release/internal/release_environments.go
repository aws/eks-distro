package internal

type ReleaseEnvironment string

const (
	Development ReleaseEnvironment = "development"
	Production  ReleaseEnvironment = "production"
)

func (re ReleaseEnvironment) String() string {
	return string(re)
}
