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

require "kemal"

require "./api-lite-helper";     include Helper
require "./api-lite-controller"; include Controller

module Core
    # The microservice "entry point".
    def core()
        # Getting the daemon settings.
        settings = _get_settings()

        daemon_name = settings[DAEMON_NAME_G][DAEMON_NAME_S].as_s()

        # Getting the port number used to run the Kemal web server.
        server_port = settings[SERVER_PORT_G][SERVER_PORT_S].as_i()

        # Identifying whether debug logging is enabled.
#       dbg = settings[LOG_ENABLED_G][LOG_ENABLED_S1][LOG_ENABLED_S2].as_bool()

        # Getting the SQLite database path.
        database_path = settings[DB_PATH_G][DB_PATH_S1][DB_PATH_S2].as_s()

        return daemon_name, server_port
    end
end; include Core; daemon_name, server_port = core()

puts(daemon_name)

# Starting up the Kemal web server.
Kemal.run(server_port)

# vim:set nu et ts=4 sw=4:
