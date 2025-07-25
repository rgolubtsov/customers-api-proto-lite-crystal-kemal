#
# src/api-lite-helper.cr
# =============================================================================
# Customers API Lite microservice prototype (Crystal port). Version 0.0.9
# =============================================================================
# A daemon written in Crystal, designed and intended to be run
# as a microservice, implementing a special Customers API prototype
# with a smart yet simplified data scheme.
# =============================================================================
# (See the LICENSE file at the top of the source tree.)
#

# The helper module for the daemon --------------------------------------------

require "toml"

module Helper
    # Helper constants.
    EXIT_FAILURE =   1 #    Failing exit status.
    EXIT_SUCCESS =   0 # Successful exit status.
    EMPTY_STRING =  ""
    SPACE        = " "
    O_BRACKET    = "["
    C_BRACKET    = "]"

    # Common notification messages.
    MSG_SERVER_STARTED = "Server started on port "
    MSG_SERVER_STOPPED = "Server stopped"

    # Common error messages.
    ERR_CANNOT_START_SERVER =
        "FATAL: Cannot start server "
    ERR_ADDR_ALREADY_IN_USE =
        "due to address requested already in use. Quitting..."
    ERR_SERV_UNKNOWN_REASON =
        "for an unknown reason. Quitting..."

    # The path and filename of the daemon settings.
    SETTINGS = "./etc/settings.conf"

    # Daemon settings keys for the microservice daemon name.
    DAEMON_NAME_G = "daemon"
    DAEMON_NAME_S = "name"

    # Daemon settings keys for the server port number.
    SERVER_PORT_G = "server"
    SERVER_PORT_S = "port"

    # Daemon settings keys for the debug logging enabler.
    LOG_ENABLED_G  = "logger"
    LOG_ENABLED_S1 = "debug"
    LOG_ENABLED_S2 = "enabled"

    LOG_DIR = "./log/"
    LOGFILE = "customers-api-lite.log"
    LOGTIME = "[%F][%T]"
    LOGSRCS = "*"
    APPEND_ = "a+"

    SVRT_INFO = "INFO"
    SVRT_WARN = "WARN"

    # Daemon settings keys for the SQLite database path.
    DB_PATH_G  = "sqlite"
    DB_PATH_S1 = "database"
    DB_PATH_S2 = "path"

    # Helper function. Used to get the daemon settings.
    def _get_settings()
        settings = TOML.parse(File.read(SETTINGS))
    end

    # Helper func. Used to set log format for both console and logfile output.
    def _set_log_format(entry, io)
        logtime = Time::Format.new(LOGTIME)

        entry_severity = entry.severity.label()

        if ((entry_severity == SVRT_INFO) || (entry_severity == SVRT_WARN))
             entry_severity += SPACE
        end

        io << logtime.format(entry.timestamp)            + SPACE +
                O_BRACKET << entry_severity << C_BRACKET + SPACE <<
                             entry.message
    end

    # Helper function. Used to log messages for debugging aims in a free form.
    def _dbg(dbg, l, message)
        if (dbg)
                 l.debug{message}
            Syslog.debug(message)
        end
    end

    # Helper function. Makes final cleanups, closes streams, etc.
    def _cleanup()
        Syslog.info(MSG_SERVER_STOPPED)

        # Closing the system logger.
        # Calling <syslog.h> closelog();
        Syslog.close()
    end
end

# vim:set nu et ts=4 sw=4:
