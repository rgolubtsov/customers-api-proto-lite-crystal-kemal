#
# src/api-lite-helper.cr
# =============================================================================
# Customers API Lite microservice prototype (Crystal port). Version 0.0.1
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
    EMPTY_STRING =  ""
    SPACE        = " "
    O_BRACKET    = "["
    C_BRACKET    = "]"

    # Common notification messages.
    MSG_SERVER_STARTED = "Server started on port "
    MSG_SERVER_STOPPED = "Server stopped"

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

    # Helper function. Used to log messages for debugging aims in a free form.
    def _dbg(dbg, l, message)
        l.debug{message} if (dbg)
    end
end

# vim:set nu et ts=4 sw=4:
