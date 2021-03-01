require 'minitest/autorun'
require 'timeout'
require_relative 'balance_dto'
require_relative 'balance_report'
require_relative 'result'
require_relative 'eligible_customers'

class CustomerSuccessBalancing
  def initialize(customer_success, customers, customer_success_away)
    @customer_success = customer_success
    @customers = customers
    @customer_success_away = customer_success_away
  end

  def execute
    eligible_customers = EligibleCustomers.new(@customers)
    balance_report = generate_balance_report_for(eligible_customers)

    Result.new(balance_report).customer_success_id
  end

  private

  def generate_balance_report_for(eligible_customers)
    balance_report = BalanceReport.new

    sorted_active_customer_success.each do |customer_success|
      balance_report.add_balance(
        build_balance(customer_success, eligible_customers)
      )
    end

    balance_report
  end

  def build_balance(customer_success, eligible_customers)
    BalanceDto.new(
      customer_success_id: customer_success[:id],
      customers_total: eligible_customers.for_customer_success(customer_success).length
    )
  end

  def active_customer_success
    @customer_success.reject do |customer_success|
      @customer_success_away.include?(customer_success[:id])
    end
  end

  def sorted_active_customer_success
    active_customer_success.sort_by do |customer_success|
      customer_success[:score]
    end
  end
end

class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    css = [
      { id: 1, score: 60 },
      { id: 2, score: 20 },
      { id: 3, score: 95 },
      { id: 4, score: 75 }
    ]
    customers = [
      { id: 1, score: 90 },
      { id: 2, score: 20 },
      { id: 3, score: 70 },
      { id: 4, score: 40 },
      { id: 5, score: 60 },
      { id: 6, score: 10}
    ]

    balancer = CustomerSuccessBalancing.new(css, customers, [2, 4])
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    css = array_to_map([11, 21, 31, 3, 4, 5])
    customers = array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60])
    balancer = CustomerSuccessBalancing.new(css, customers, [])
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    customer_success = Array.new(1000, 0)
    customer_success[998] = 100
    customers = Array.new(10000, 10)

    balancer = CustomerSuccessBalancing.new(array_to_map(customer_success), array_to_map(customers), [1000])

    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 999, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(array_to_map([1, 2, 3, 4, 5, 6]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [])
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(array_to_map([100, 2, 3, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [])
    assert_equal balancer.execute, 1
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(array_to_map([100, 99, 88, 3, 4, 5]), array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]), [1, 3, 2])
    assert_equal balancer.execute, 0
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(
      array_to_map([100, 99, 88, 3, 4, 5]),
      array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [4, 5, 6])
    assert_equal balancer.execute, 3
  end

  def array_to_map(arr)
    out = []
    arr.each_with_index { |score, index| out.push({ id: index + 1, score: score }) }
    out
  end
end

Minitest.run
