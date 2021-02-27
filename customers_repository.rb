require_relative 'customer'

class CustomersRepository
  def initialize(customers)
    @customers = customers.map { |customer| Customer.new(customer[:id], customer[:score]) }
  end

  def find_by_customer_success(customer_success)
    eligible_customers = @customers.select do |customer|
      customer.score <= customer_success.score
    end

    eligible_customers
  end

  def update_customers(updated_customers)
    @customers = @customers - updated_customers
  end
end

