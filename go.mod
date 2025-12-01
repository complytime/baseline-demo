module github.com/complytime/baseline-demo

go 1.24.4

require (
	github.com/complytime/gemara2oscal v0.0.0-20251027194523-4ead3ea25a6c
	github.com/defenseunicorns/go-oscal v0.7.0
	github.com/goccy/go-yaml v1.19.0
	github.com/spf13/cobra v1.10.1
)

require (
	github.com/google/uuid v1.6.0 // indirect
	github.com/oscal-compass/oscal-sdk-go v0.0.8 // indirect
	github.com/santhosh-tekuri/jsonschema/v6 v6.0.2 // indirect
	golang.org/x/text v0.28.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)

require (
	github.com/inconshreveable/mousetrap v1.1.0 // indirect
	github.com/ossf/gemara v0.12.1
	github.com/spf13/pflag v1.0.9 // indirect
)

replace (
	github.com/complytime/gemara2oscal => github.com/complytime/gemara2oscal v0.0.0-20251107222047-9887878c2711
	github.com/ossf/gemara => github.com/jpower432/sci v0.0.0-20251107221736-76054b25e204
)
