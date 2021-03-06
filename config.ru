# Core
require "rake"             # CLI
require "unicorn"          # Server

# Storage
require "active_record"    # Database
require "redis"            # Cache

# Modules
require "rack-protection"  # Security
require "tilt"             # Template
require "redcarpet"        # Markdown
require "pygments"         # Highlighter
require "cane"             # Code quality

# Libraries
require "yaml"             # Yaml
require "time"             # Time

# Application
require "./app/netflam"    # Netflam

run Netflam