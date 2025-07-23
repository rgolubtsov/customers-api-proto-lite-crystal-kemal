#
# src/api-lite-core.cr
# =============================================================================
# Customers API Lite microservice prototype (Crystal port). Version 0.0.5
# =============================================================================
# A daemon written in Crystal, designed and intended to be run
# as a microservice, implementing a special Customers API prototype
# with a smart yet simplified data scheme.
# =============================================================================
# (See the LICENSE file at the top of the source tree.)
#

# The main module of the daemon -----------------------------------------------

require "syslog"
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
        Dir.mkdir(LOG_DIR) if (!Dir.exists?(LOG_DIR))
        Log.setup do |s|
            cons_backend =
                Log::IOBackend.new(formatter: Log::Formatter.new do |entry, io|
                _set_log_format(entry, io)
            end)
            file_backend =
                Log::IOBackend.new(File.new(LOG_DIR + LOGFILE, APPEND_),
                                   formatter: Log::Formatter.new do |entry, io|
                _set_log_format(entry, io)
            end)
            s.bind(LOGSRCS, :debug, cons_backend)
            s.bind(LOGSRCS, :debug, file_backend)
        end
        l = Log.for(EMPTY_STRING)

        # Opening the system logger.
        # Calling <syslog.h> openlog(NULL, LOG_CONS | LOG_PID, LOG_DAEMON);
        Syslog.setup(Path[PROGRAM_NAME].basename(), Syslog::Facility::Daemon,
                                                    Syslog::Options::Console |
                                                    Syslog::Options::PID, 0xff)

        daemon_name = settings[DAEMON_NAME_G][DAEMON_NAME_S].as_s()

        # Getting the port number used to run the Kemal web server.
        server_port = settings[SERVER_PORT_G][SERVER_PORT_S].as_i()

        # Getting the SQLite database path.
        database_path = settings[DB_PATH_G][DB_PATH_S1][DB_PATH_S2].as_s()

        return dbg, l, daemon_name, server_port
    end
end; include Core; dbg, l, daemon_name, server_port = core()

_dbg(dbg, l, O_BRACKET + daemon_name + C_BRACKET)

     l.info{"#{MSG_SERVER_STARTED}#{server_port}"}
Syslog.info("#{MSG_SERVER_STARTED}#{server_port}")

# Starting up the Kemal web server.
Kemal.run(server_port)

Syslog.info(MSG_SERVER_STOPPED)

# Closing the system logger.
# Calling <syslog.h> closelog();
Syslog.close()

# vim:set nu et ts=4 sw=4:
