if defined?(Bullet)
  RSpec.configure do |config|
    config.before(:suite) do
      Bullet.enable = ENV["N_PLUS_ONE_DETECTION"] == "true"
      Bullet.raise = true
      Bullet.bullet_logger = true
      Bullet.n_plus_one_query_enable = true
      Bullet.unused_eager_loading_enable = true
      Bullet.counter_cache_enable = true
    end

    config.before(:each) do
      Bullet.start_request if Bullet.enable?
    end

    config.after(:each) do
      next unless Bullet.enable?

      Bullet.perform_out_of_channel_notifications
      Bullet.end_request
    end
  end
end
