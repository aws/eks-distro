# 1-22 introduced seperate go.mod files for etcd server and etcdctl
# our build tooling around licenses + attribution is setup around go.mod files
# for 1-22+ we are going to create seperate attribution files
SOURCE_PATTERNS=. .
LICENSE_PACKAGE_FILTER=.
GO_MOD_PATHS=server etcdctl

# this changed between 1-21 and 1-22
ROOT_MODULE=go.etcd.io/etcd/api/v3

# to standardize final path locations and simplify implementation until it becomes neccessary
# to fully handle cases without a non named attribution/license folder
# tarballs $(call IMAGE_TARGETS_FOR_NAME,etcd): rename-attribution

# .PHONY: rename-attribution
# rename-attribution: $(LICENSES_TARGETS_FOR_PREREQ)
# 	@cp -rf $(OUTPUT_DIR)/etcd/LICENSES $(OUTPUT_DIR)
# 	@cp -rf $(OUTPUT_DIR)/ETCD_ATTRIBUTION.txt $(OUTPUT_DIR)/ATTRIBUTION.txt
