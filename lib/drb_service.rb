require 'drb'

class DRbService
  def initialize(uri, service)
    @uri = uri
    @service = service
  end

  def start
    with_retries do
      DRb.start_service(@uri, @service)
      $logger&.info("service started on #{@uri}")
      yield(DRb.front) if block_given?
      DRb.thread.join
    end
  end

  private

  def with_retries
    attempts ||= 0
    yield
  rescue => e
    attempts += 1
    if attempts < 3
      $logger&.warn "Could not connect to service: #{@uri}, error: #{e} retrying..."
      sleep 5
      retry
    end
  end
end
