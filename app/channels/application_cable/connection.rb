module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      set_current_user || reject_unauthorized_connection
    end

    private
      def set_current_user
        self.current_user = Session.find_by(id: cookies.signed[:session_id])&.user
      end
  end
end
