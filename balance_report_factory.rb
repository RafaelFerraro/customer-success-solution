require_relative 'balance_dto'
require_relative 'balance_report'

class BalanceReportFactory
  def initialize(customer_success_repository, customers_repository)
    @customer_success_repository = customer_success_repository
    @customers_repository = customers_repository
  end

  def create
    BalanceReport.new.tap do |balance_report|
      @customer_success_repository.sorted_active_customer_success.each do |customer_success|
        customers = @customers_repository.find_by_customer_success(customer_success)

        balance_report.add_balance(
          build_balance(customer_success, customers)
        )

        @customers_repository.update_customers(customers)
      end
    end
  end

  def build_balance(customer_success, customers)
    BalanceDto.new(
      customer_success_id: customer_success.id,
      customers_total: customers.length
    )
  end
end
