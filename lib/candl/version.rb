module Candl
  VERSION = '0.1.14'
end

# NOTE(Schau):
# WARNING:
# To keep this gem working with travis ci one needs to:
# - increase the version number and
# - run bundler update.
# Then one is able to rake release the gem to rubygems and still have travis ci working.
# If not done in this way the increase in the version number and the execution of rake release will change the gemfile.lock in such a way that travis ci will not find a ffi version for a platform. (There could be a "bug" in rake release that deletes certain entries from the lockfile wich is quite unexpected.)