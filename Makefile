#
# Makefile
# =============================================================================
# Customers API Lite microservice prototype (Crystal port). Version 0.1.1
# =============================================================================
# A daemon written in Crystal, designed and intended to be run
# as a microservice, implementing a special Customers API prototype
# with a smart yet simplified data scheme.
# =============================================================================
# (See the LICENSE file at the top of the source tree.)
#

BIN_DIR = bin
SRC_DIR = src

PREF = api-lite
EXEC = $(BIN_DIR)/$(PREF)d
DEPS = $(SRC_DIR)/$(PREF)-core.cr \
       $(SRC_DIR)/$(PREF)-controller.cr \
       $(SRC_DIR)/$(PREF)-helper.cr \
       shard.yml

DB_PATH = data/db
DB_FILE = customers-api-lite.db.xz

# Specify flags and other vars here.
SHARDS = shards
SFLAGS = build

RMFLAGS = -vR
UNXZ    = unxz

# Making the target (the microservice executable).
$(EXEC): $(DEPS)
	$(SHARDS) $(SFLAGS) && \
	if [ -f $(DB_PATH)/$(DB_FILE) ]; then \
	    $(UNXZ) $(DB_PATH)/$(DB_FILE); \
	fi

.PHONY: all clean

all: $(EXEC)

clean:
	$(RM) $(RMFLAGS) $(BIN_DIR)

# vim:set nu et ts=4 sw=4:
