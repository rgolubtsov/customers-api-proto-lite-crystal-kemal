#
# src/api-lite-core.cr
# =============================================================================
# Customers API Lite microservice prototype (Crystal port). Version 0.0.1
# =============================================================================
# A daemon written in Crystal, designed and intended to be run
# as a microservice, implementing a special Customers API prototype
# with a smart yet simplified data scheme.
# =============================================================================
# (See the LICENSE file at the top of the source tree.)
#

# The main module of the daemon -----------------------------------------------

module Core
    VERSION = "0.0.1"

    def init()
        puts()
    end
end

include Core; init()

# vim:set nu et ts=4 sw=4:
