FROM ruby:2.5

WORKDIR /usr/src/app

COPY . .

CMD ["ruby", "tests/customer_success_balancing_test.rb"]
