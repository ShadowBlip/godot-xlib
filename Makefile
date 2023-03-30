EXT_NAME := xlib
NUM_CPU := $(shell nproc)
ALL_CPP := $(shell find ./src -name '*.cpp')
ALL_HEADERS := $(shell find ./src -name '*.h')
RELEASE_TARGET := addons/$(EXT_NAME)/bin/lib$(EXT_NAME).linux.template_release.x86_64.so
DEBUG_TARGET := addons/$(EXT_NAME)/bin/lib$(EXT_NAME).linux.template_debug.x86_64.so

##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


.PHONY: build
build: $(RELEASE_TARGET) $(DEBUG_TARGET) ## Build release and debug binaries

.PHONY: clean
clean:
	rm -rf addons/$(EXT_NAME)/bin
	rm -rf dist

.PHONY: release
release: $(RELEASE_TARGET) ## Build release binary
$(RELEASE_TARGET): $(ALL_HEADERS) $(ALL_CPP)
	scons -Q compiledb
	scons platform=linux -j$(NUM_CPU) target=template_release

.PHONY: debug
debug: $(DEBUG_TARGET) ## Build binary with debug symbols
$(DEBUG_TARGET): $(ALL_HEADERS) $(ALL_CPP)
	scons -Q compiledb
	scons platform=linux -j$(NUM_CPU) target=template_debug


## Godot CPP

GODOT_CPP_FILES := $(shell find ./ -regex  '.*\(cpp\|h\|hpp\)$$')
godot-cpp/bin/libgodot-cpp.linux.template_debug.x86_64.a: $(GODOT_CPP_FILES)
	cd godot-cpp && scons platform=linux -j$(NUM_CPU) target=template_debug

godot-cpp/bin/libgodot-cpp.linux.template_release.x86_64.a: $(GODOT_CPP_FILES)
	cd godot-cpp && scons platform=linux -j$(NUM_CPU) target=template_release


##@ Distribution

.PHONY: dist
dist: dist/godot-$(EXT_NAME).tar.gz ## Build a redistributable archive of the project
dist/godot-$(EXT_NAME).tar.gz: $(RELEASE_TARGET) $(DEBUG_TARGET)
	mkdir -p dist
	tar cvfz $@ addons
