setup-mac:
	brew install balena-cli
	balena login

deploy:
	balena push $(app_name)
