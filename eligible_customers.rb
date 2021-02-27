class EligibleCustomers
  def initialize(customers)
    @customers = customers
  end

  def for_customer_success(customer_success)
    eligible_customers = @customers.select do |customer|
      customer[:score] <= customer_success[:score]
    end

    @customers = @customers - eligible_customers

    eligible_customers
  end
end
