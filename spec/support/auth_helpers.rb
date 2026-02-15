module AuthHelpers
  def json_response
    JSON.parse(response.body)
  end

  def auth_headers_for(email:, password:)
    post "/api/v1/auth/login", params: { email: email, password: password }, as: :json
    token = json_response.fetch("token")

    { "Authorization" => "Bearer #{token}" }
  end
end
