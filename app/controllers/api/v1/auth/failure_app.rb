module Api
  module V1
    module Auth
      class FailureApp < Devise::FailureApp
        def respond
          json_api_error_response
        end

        private

        def json_api_error_response
          self.status = :unauthorized
          self.content_type = "application/json"
          self.response_body = { error: i18n_message || "Unauthorized" }.to_json
        end
      end
    end
  end
end
