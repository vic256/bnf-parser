import os

type BnfValue = Ref | string | None
type BnfToken = Bloc | BnfValue

enum Op {
	invalid_op
	op_or
	op_multiply
	op_and
	op_optional
}

struct Bloc {
mut: 
	tokens []BnfToken 
	operator Op
}

const op_associations = {
	`|`: Op.op_or
	`*`: Op.op_multiply
	`?`: Op.op_optional
}

struct None {}

struct Ref {
	key string // Same key as BnfExpr key 
}

struct BnfExpr {
mut:
	key string
	children []BnfToken
}

fn main() {
	mut content := os.read_lines('./vlang_2.ebnf') or {
		println('Unable to open bnf')
		return
	}

	mut expr := map[string]string{}

	for _, line in content {
		if line == '' || line.starts_with('//') {
			continue
		}

		tokens := line.split_by_space()

		expr[tokens[0]] = tokens[2..tokens.len].clone().join(' ')
	}

	mut bnf_expressions := []BnfExpr{}
	for key, value in expr {
		mut bnf_expr := BnfExpr{} 
		bnf_expr.key = key

		mut current_bnf_bloc := Bloc{}
		mut current_bnf_value := BnfValue(None{})

		mut entry := ''
		for _, token in (value + '\n') {
			if entry != '' && entry[entry.len - 1] == ` ` 
				&& !(token in op_associations.keys()) // Token is not an operator
				&& !(current_bnf_value is None) {
				if current_bnf_bloc.operator == Op.invalid_op { current_bnf_bloc.operator = Op.op_and }
				if current_bnf_bloc.operator == Op.op_and {
					current_bnf_bloc.tokens << current_bnf_value
					current_bnf_value = BnfValue(None{})
					entry = ''
				}
			}

			if token == `'` {
				if current_bnf_value.type_name() == 'None' {
					current_bnf_value = BnfValue('')
					entry = ''
					continue
				}
				if current_bnf_value.type_name() == 'string' {
					current_bnf_value = BnfValue(entry)
					entry = ''
					continue
				}
			}
			
			if token == `|` && !(current_bnf_value is None) {
				current_bnf_bloc.tokens << current_bnf_value
				if current_bnf_bloc.operator == Op.invalid_op { current_bnf_bloc.operator = Op.op_or }
				current_bnf_value = BnfValue(None{})
				entry = ''
				continue
			}


			if token.ascii_str() == '\n' {
				current_bnf_bloc.tokens << current_bnf_value
				continue
			}

			/*if token == ` ` && current_bnf_bloc.operator == Op.invalid_op && current_bnf_value.type_name() != 'None' {
				current_bnf_bloc.tokens << current_bnf_value
				if current_bnf_bloc.operator == Op.invalid_op { current_bnf_bloc.operator = Op.op_and }
				current_bnf_value = BnfValue(None{})
				entry = ''
				continue
			}*/


			/*if op_associations[token] != Op.invalid_op && current_bnf_token.type_name() == 'None' {
				bnf_expr.children << current_bnf_token
				current_bnf_token = BnfToken(op_associations[token])
				continue
			}

			if token == ` ` {
				bnf_expr.children << current_bnf_token
				current_bnf_token = BnfToken(None{})
				entry = ''
				continue
			}*/
			entry += token.ascii_str()

			/*match token {
				`'` {
					if current_bnf_token.type_name() == 'None' {
						current_bnf_token = BnfToken('')
						continue
					}
					current_bnf_token = BnfToken(entry)
				}
				`|` {
					if current_bnf_token.type_name() == 'string' { 
						entry += token.ascii_str()
						continue
					 }
					current_bnf_token = BnfToken(Op.op_or)
				}
				`*` {
					if current_bnf_token.type_name() == 'string' {
						entry += token.ascii_str()
						continue
					}
					bnf_expr.children << BnfToken(Ref{entry})
					current_bnf_token = BnfToken(Op.op_multiply)
				}
				` `{
					bnf_expr.children << current_bnf_token
					current_bnf_token = BnfToken(None{})
					entry = ''
				}
				else {
					entry += token.ascii_str()
				}
			}*/
		}
		println(current_bnf_bloc)
		//bnf_expr.children << current_bnf_token
		//bnf_expressions << bnf_expr
	}
			//println(bnf_expressions)
}
