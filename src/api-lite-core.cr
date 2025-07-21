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

        # Identifying whether debug logging is enabled.
        dbg = settings[LOG_ENABLED_G][LOG_ENABLED_S1][LOG_ENABLED_S2]
            .as_bool() rescue false

        # Creating and configuring the main logger of the daemon.
        logtime = Time::Format.new(LOGTIME); Log.setup(:debug,
            Log::IOBackend.new(formatter: Log::Formatter.new do |entry, io|
                entry_severity = entry.severity.label()
                if ((entry_severity == SVRT_INFO) ||
                    (entry_severity == SVRT_WARN))
                     entry_severity += SPACE
                end
                io << logtime.format(entry.timestamp) + SPACE + O_BRACKET <<
                                     entry_severity          << C_BRACKET +
                            SPACE << entry.message
            end)
        ); l = Log.for(EMPTY_STRING)

        daemon_name = settings[DAEMON_NAME_G][DAEMON_NAME_S].as_s()

        # Getting the port number used to run the Kemal web server.
        server_port = settings[SERVER_PORT_G][SERVER_PORT_S].as_i()

        # Getting the SQLite database path.
        database_path = settings[DB_PATH_G][DB_PATH_S1][DB_PATH_S2].as_s()

        return dbg, l, daemon_name, server_port
    end
end; include Core; dbg, l, daemon_name, server_port = core()

l.info{O_BRACKET + daemon_name + C_BRACKET}

_dbg(dbg, l, "#{MSG_SERVER_STARTED}#{server_port}")

# Starting up the Kemal web server.
Kemal.run(server_port)

# vim:set nu et ts=4 sw=4:
