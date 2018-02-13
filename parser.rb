require 'minitest/autorun'
require 'minitest/pride'
require 'parslet'

class Demo < Parslet::Parser
  rule(:integer) { match('[0-9]').repeat(1) >> space? }

  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  rule(:identifier) {
    match('[a-zA-Z=*]') >> match('[a-zA-Z=*_]').repeat >> space?
  }

  rule(:sign) { str('+') | str('-') }

  rule(:int_literal) {
    (sign.maybe >> match("[0-9]").repeat(1)) >> space?
  }

  rule(:lpar) { str('(') }
  rule(:rpar) { str(')') }
  rule(:dot) { str('.') }

  rule(:bool_literal) { str('true') | str('false') }

  rule(:value) {
    int_literal | bool_literal| identifier
  }

  rule(:group_expr) { lpar >> expr >> rpar }

  rule(:non_and_expr) {
    group_expr | value
  }

  rule(:cmp_op) {
    str('<') | str('>') | str('==') | str('!=')
  }

  rule(:bool_bin_op) {
    str('&&') || str('||')
  }

  rule(:and_expr) {
    non_and_expr >> bool_bin_op >> non_cmp_expr
  }

  rule(:non_cmp_expr) {
    and_expr | non_and_expr
  }

  rule(:cmp_expr) {
    non_cmp_expr >> cmp_op >> non_acc_expr
  }

  rule(:non_acc_expr) {
    cmp_expr | non_cmp_expr
  }

  rule(:acc_expr) {
    non_acc_expr >> match('[+-]')  >> non_prod_expr
  }

  rule(:non_prod_expr) {
    acc_expr | non_acc_expr
  }

  rule(:prod_op) { str('*') | str('/') }

  rule(:prod_expr) {
    non_prod_expr >> prod_op >> non_prefix_expr
  }

  rule(:non_prefix_expr) {
    prod_expr | non_prod_expr
  }

  rule(:not_expr) { str('!') >> prefix_expr }

  rule(:prefix_expr) {
    not_expr
  }

  rule(:non_postfix_expr) {
    prefix_expr | non_prefix_expr
  }

  rule(:length_expr) {
    non_postfix_expr >> dot >> str('length')
  }

  rule(:arguments) {
    (expr >> ( str(',') >> expr).maybe).repeat
  }

  rule(:method_call_expr) {
    non_postfix_expr >> dot >> identifier >> lpar >> arguments >> rpar
  }

  rule(:index_expr) {
    non_postfix_expr >> str("[") >> expr >> str("]")
  }

  rule(:postfix_expr) {
    index_expr | method_call_expr | length_expr
  }

  rule(:expr) {
    postfix_expr | non_postfix_expr
  }

  root(:expr)
end

class DemoTest < MiniTest::Test
  def test_rule_integer
    Demo.new.parse("a[1]")
    Demo.new.parse("(1+2)")
    Demo.new.parse("1")
    Demo.new.parse("+1")
    Demo.new.parse("-1")
    Demo.new.parse("1*3+2")
    Demo.new.parse("true")
    Demo.new.parse("false")
    Demo.new.parse("a.foo(1)")
    Demo.new.parse("a.foo(3,3)")
    Demo.new.parse("1>2")
    Demo.new.parse("1&&2")
    Demo.new.parse("1==false")
    Demo.new.parse("4!=4")
  end
end
