require_relative 'result'
require_relative 'balance_report_factory'

class CustomerSuccessBalancing
  def initialize(customer_success_repository, customers_repository)
    @customers_repository = customers_repository
    @customer_success_repository = customer_success_repository
  end

  def execute
    Result.new(balance_report).customer_success_id
  end

  private

  def balance_report
    BalanceReportFactory.new(@customer_success_repository, @customers_repository).create
  end
end
