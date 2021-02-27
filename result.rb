class Result
  def initialize(balance_report)
    @balance_report = balance_report
  end

  def customer_success_id
    @balance_report.fetch_by_maximum_values do |balances|
      balances.length > 1 ? 0 : balances.first.customer_success_id
    end
  end
end

