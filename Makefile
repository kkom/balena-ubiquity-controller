.PHONY: install-pre-commit
install-pre-commit:
	pre-commit install

.PHONY: setup-mac
setup-mac:
	brew install balena-cli
	balena login

.PHONY: deploy
deploy:
	balena push $(app_name)
