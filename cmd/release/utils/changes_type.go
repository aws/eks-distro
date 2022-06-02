package utils

type ChangesType string

const (
	Dev  ChangesType = "development"
	Prod ChangesType = "production"
	Docs ChangesType = "docs"
)

func (ct ChangesType) String() string {
	return string(ct)
}

func (ct ChangesType) IsDevOrProd() bool {
	return ct == Dev || ct == Prod
}
