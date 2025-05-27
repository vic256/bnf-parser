import os

type BnfValue = Ref | string | None
type BnfToken = Bloc | Ref | string | None

enum Op {
	op_default
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
		new_value := (value + '\n')

		mut bnf_expr := BnfExpr{} 
		bnf_expr.key = key

		mut current_bnf_bloc := Bloc{} // Parent bloc 
		mut current_bnf_value := BnfValue(None{})

		mut default_bnf_bloc := create_default_bnf_bloc()

		mut entry := ''
		mut i := 0
		for i < new_value.len {
			token := new_value[i]

			if token == ` ` {
				for new_value[i] == ` ` {
					i++
				}
				if !(new_value[i] in op_associations.keys()) {
					if current_bnf_bloc.operator == Op.op_default { 
						current_bnf_bloc.operator = Op.op_and 
					}
					if !(default_bnf_bloc.tokens[0] is None) {
						current_bnf_bloc.tokens << default_bnf_bloc
						default_bnf_bloc = create_default_bnf_bloc()
						entry = ''
					} else if entry != '' {
						default_bnf_bloc.tokens[0] = Ref{entry}
						current_bnf_bloc.tokens << default_bnf_bloc
						default_bnf_bloc = create_default_bnf_bloc()
						entry = ''
					}
				}
			} else if token == `'` {
				if default_bnf_bloc.tokens[0] is None {
					default_bnf_bloc.tokens[0] = ''
					entry = ''
				} else if default_bnf_bloc.tokens[0] is string {
					default_bnf_bloc.tokens[0] = entry
					entry = ''
				}
				i++
			} else if token == `|` {
				if current_bnf_bloc.operator == Op.op_default { current_bnf_bloc.operator = Op.op_or }
				i++
			} else if token == `*` {
				if default_bnf_bloc.operator == Op.op_default { default_bnf_bloc.operator = Op.op_multiply }
				i++
			} else if token == `\n` {
				if !(default_bnf_bloc.tokens[0] is None) {
					current_bnf_bloc.tokens << default_bnf_bloc
					default_bnf_bloc = create_default_bnf_bloc()
				} else if entry != '' {
					default_bnf_bloc.tokens[0] = Ref{entry}
					current_bnf_bloc.tokens << default_bnf_bloc
					default_bnf_bloc = create_default_bnf_bloc()
					entry = ''
				}
				i++
			} else {
				entry += token.ascii_str()
				i++
			}
		}
		println(current_bnf_bloc)
	}
}

fn create_default_bnf_bloc() Bloc {
	return Bloc{[None{}], Op.op_default}
}