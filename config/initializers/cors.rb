allowed_origins = ENV.fetch("CORS_ALLOWED_ORIGINS", "http://localhost:5173,http://127.0.0.1:5173")
  .split(",")
  .map(&:strip)
  .reject(&:empty?)

development_origin_patterns =
  if Rails.env.development? || Rails.env.test?
    [
      %r{\Ahttp://localhost:\d+\z},
      %r{\Ahttp://127\.0\.0\.1:\d+\z}
    ]
  else
    []
  end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*(allowed_origins + development_origin_patterns))

    resource "*",
      headers: :any,
      expose: [ "Authorization" ],
      methods: [ :get, :post, :patch, :put, :delete, :options, :head ]
  end
end
