require_relative 'customer_success'

class CustomerSuccessRepository
  def initialize(customer_success_list, customer_success_away_ids)
    @customer_success_list = customer_success_list.map do |customer_success|
      CustomerSuccess.new(customer_success[:id], customer_success[:score])
    end

    @customer_success_away_ids = customer_success_away_ids
  end

  def sorted_active_customer_success
    active_customer_success.sort_by do |customer_success|
      customer_success.score
    end
  end

  private

  def active_customer_success
    @customer_success_list.reject do |customer_success|
      @customer_success_away_ids.include?(customer_success.id)
    end
  end
end
