require 'minitest/autorun'
require 'timeout'
require_relative 'result'
require_relative 'customer_success_repository'
require_relative 'customers_repository'
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

class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    customer_success_repository = CustomerSuccessRepository.new(
      [
        { id: 1, score: 60 },
        { id: 2, score: 20 },
        { id: 3, score: 95 },
        { id: 4, score: 75 }
      ],
      [2, 4]
    )
    customers_repository = CustomersRepository.new(
      [
        { id: 1, score: 90 },
        { id: 2, score: 20 },
        { id: 3, score: 70 },
        { id: 4, score: 40 },
        { id: 5, score: 60 },
        { id: 6, score: 10}
      ]
    )

    balancer = CustomerSuccessBalancing.new(customer_success_repository, customers_repository)
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    customer_success_repository = CustomerSuccessRepository.new(
      array_to_map([11, 21, 31, 3, 4, 5]), []
    )
    customers_repository = CustomersRepository.new(array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]))
    balancer = CustomerSuccessBalancing.new(customer_success_repository, customers_repository)
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    customer_success = Array.new(1000, 0)
    customer_success[998] = 100
    customers = Array.new(10000, 10)
    customers_repository = CustomersRepository.new(array_to_map(customers))
    customer_success_repository = CustomerSuccessRepository.new(array_to_map(customer_success), [1000])

    balancer = CustomerSuccessBalancing.new(customer_success_repository, customers_repository)

    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 999, result
  end

  def test_scenario_four
    customers_repository = CustomersRepository.new(array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]))
    customer_success_repository = CustomerSuccessRepository.new(array_to_map([1, 2, 3, 4, 5, 6]), [])
    balancer = CustomerSuccessBalancing.new(customer_success_repository, customers_repository)
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    customers_repository = CustomersRepository.new(array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]))
    customer_success_repository = CustomerSuccessRepository.new(array_to_map([100, 2, 3, 3, 4, 5]), [])
    balancer = CustomerSuccessBalancing.new(customer_success_repository, customers_repository)
    assert_equal balancer.execute, 1
  end

  def test_scenario_six
    customers_repository = CustomersRepository.new(array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]))
    customer_success_repository = CustomerSuccessRepository.new(array_to_map([100, 99, 88, 3, 4, 5]), [1, 3, 2])
    balancer = CustomerSuccessBalancing.new(customer_success_repository, customers_repository)
    assert_equal balancer.execute, 0
  end

  def test_scenario_seven
    customers_repository = CustomersRepository.new(array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]))
    customer_success_repository = CustomerSuccessRepository.new(array_to_map([100, 99, 88, 3, 4, 5]), [4, 5, 6])
    balancer = CustomerSuccessBalancing.new(customer_success_repository, customers_repository)
    assert_equal balancer.execute, 3
  end

  def array_to_map(arr)
    out = []
    arr.each_with_index { |score, index| out.push({ id: index + 1, score: score }) }
    out
  end
end

Minitest.run
