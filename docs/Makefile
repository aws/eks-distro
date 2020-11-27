AWS_REGION?=us-east-1

.PHONY: install
install:
	pip3 install -r requirements.txt

.PHONY: build
build: install
	mkdocs build --strict --verbose --clean

.PHONY: publish
publish: build
	# TODO: make publish script publish for launch
	bash ./publish.sh
