AWS_REGION?=us-east-1

.PHONY: install
install:
	pip3 install -r requirements.txt

.PHONY: build
build: install
	mkdocs build --strict --verbose --clean

.PHONY: release
release: build
	# TODO: make publish script publish for launch
	bash ./publish.sh

.PHONY: clean
clean:
	rm -rf site/
