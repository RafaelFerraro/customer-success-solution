class BalanceDto
  attr_reader :customer_success_id, :customers_total

  def initialize(customer_success_id:, customers_total:)
    @customer_success_id = customer_success_id
    @customers_total = customers_total
  end
end
