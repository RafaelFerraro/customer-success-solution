require 'minitest/autorun'
require 'timeout'
require_relative 'balance_dto'
require_relative 'balance_report'
require_relative 'result'
require_relative 'eligible_customers'

# Como você chegou na solução?
# - Primeiro eu tentei resolver o problema, fazer os testes passar. Depois me preocupei com a legibilidade do código. Pra fazer os testes passarem eu li o problema e o que era esperado e entendi os exemplos, depois eu fui olhar os testes e ver os cenários, eles me ajudaram a entender ainda mais o problema e o que eu tinha que fazer, pois eu vi o input e o output de forma mais clara, depois foi entender como eu iria trabalhar com esses inputs e por fim eu fui pensando e escrevendo em um papel em como eu chegaria nessa solução, passo a passo mesmo, por exemplo, acho que a primeira coisa foi remover os customer-success inativos e deixar só os elegiveis, ai pra cada um deles eu precisaria verificar qual cliente ele poderia atender, mas aí eu vi que se eu começasse com os css de maior score isso não iria funcionar, pois eu iria deixar os de menor score sem atendimento, então eu vi que tinha que ordenar essa lista e fui indo. Tentei jogar tudo no papel antes e aos poucos eu ia validando com alguns testes.
# Quando terminei vi que estava muito difícil para alguém ler, então eu comecei a refatorar. Fui separando algumas partes, dando nome a eles, jogando para classes específicas e sempre rodando os testes para ver se não havia quebrado nada.
# O que você melhoraria?
# Qual foi a melhor parte?
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
