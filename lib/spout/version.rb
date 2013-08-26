module Spout
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 5
    TINY = 0
    BUILD = "beta2" # nil, "pre", "rc", "rc2"

    STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.')
  end
end
