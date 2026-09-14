module Imports
  class ProgressBroadcaster
    def self.stream_for(import) = "import:#{import.id}"

    def self.call(import)
      ActionCable.server.broadcast(stream_for(import), { type: "import.changed", id: import.id })
    end
  end
end
