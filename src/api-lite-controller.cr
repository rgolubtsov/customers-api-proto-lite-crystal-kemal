#
# src/api-lite-controller.cr
# =============================================================================
# Customers API Lite microservice prototype (Crystal port). Version 0.0.9
# =============================================================================
# A daemon written in Crystal, designed and intended to be run
# as a microservice, implementing a special Customers API prototype
# with a smart yet simplified data scheme.
# =============================================================================
# (See the LICENSE file at the top of the source tree.)
#

# The controller module of the daemon -----------------------------------------

module Controller
    get "/" do
        ret = ""; (1 .. 79).each() do ret += "-" end; ret += "\n"
    end
end

# vim:set nu et ts=4 sw=4:
