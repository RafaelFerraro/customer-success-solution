class BalanceReport
  def initialize
    @balances = []
  end

  def add_balance(balance)
    @balances << balance
  end

  def fetch_by_maximum_values(&block)
    total = @balances.max_by { |balance| balance.customers_total }.customers_total

    balances = @balances.select { |balance| balance.customers_total == total }

    yield(balances)
  end
end
