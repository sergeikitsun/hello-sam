# Build the .NET Lambda for SAM. SAM invokes the `build-<LogicalId>` target
# with ARTIFACTS_DIR pointing at the function's output directory.
DOTNET ?= dotnet

build-HelloWorldFunction:
	$(DOTNET) publish -c Release -r linux-x64 --self-contained true -o $(ARTIFACTS_DIR)

.PHONY: build-HelloWorldFunction
