# Bank 00 bootstrap build.
#
# This stage assembles the reconstructed HOME source as one RGBDS object for
# every preserved Silver/Gin release. Reference submodules provide only the
# pinned regional constants/macros/charmaps while those support files are being
# vendored into this repository. No ROM image is read or required.

RGBDS ?=
RGBASM ?= $(RGBDS)rgbasm

BUILD_DIR := build/bank00
RGBASM_COMMON := -Weverything -Wtruncation=1 -Q8

WEST_REF := reference/pokegold
JP_REF := reference/pokesilver
KR_REF := reference/pokegold-kr

BANK00_RELEASES := \
	US-EU-REV0 \
	JP-REV0 \
	JP-REVA \
	KR-REV0 \
	DE-REV0 \
	FR-REV0 \
	IT-REV0 \
	ES-REV0

BANK00_OBJECTS := $(addprefix $(BUILD_DIR)/,$(addsuffix .o,$(BANK00_RELEASES)))

.PHONY: all bank00 clean bank00-check-refs $(addprefix bank00-,$(BANK00_RELEASES))

all: bank00

bank00: bank00-check-refs $(BANK00_OBJECTS)

bank00-check-refs:
	@test -f $(WEST_REF)/includes.asm || { echo "missing $(WEST_REF); run: git submodule update --init --recursive"; exit 1; }
	@test -f $(JP_REF)/includes.asm || { echo "missing $(JP_REF); run: git submodule update --init --recursive"; exit 1; }
	@test -f $(KR_REF)/includes.asm || { echo "missing $(KR_REF); run: git submodule update --init --recursive"; exit 1; }

$(BUILD_DIR):
	mkdir -p $@

# $(1) release id
# $(2) reference source root
# $(3) regional/revision defines
define BANK00_RULE
$(BUILD_DIR)/$(1).o: home.asm | $(BUILD_DIR)
	$(RGBASM) $(RGBASM_COMMON) -I $(2)/ -P $(2)/includes.asm -D _SILVER $(3) -o $$@ $$<

bank00-$(1): bank00-check-refs $(BUILD_DIR)/$(1).o
endef

$(eval $(call BANK00_RULE,US-EU-REV0,$(WEST_REF),))
$(eval $(call BANK00_RULE,JP-REV0,$(JP_REF),-D _JAPANESE -D _REV0))
$(eval $(call BANK00_RULE,JP-REVA,$(JP_REF),-D _JAPANESE))
$(eval $(call BANK00_RULE,KR-REV0,$(KR_REF),-D _KOREAN))
$(eval $(call BANK00_RULE,DE-REV0,$(WEST_REF),-D _GERMAN))
$(eval $(call BANK00_RULE,FR-REV0,$(WEST_REF),-D _FRENCH))
$(eval $(call BANK00_RULE,IT-REV0,$(WEST_REF),-D _ITALIAN))
$(eval $(call BANK00_RULE,ES-REV0,$(WEST_REF),-D _SPANISH))

clean:
	rm -rf build
