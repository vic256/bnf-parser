import os

struct Expr {
mut:
	name   string
	tokens []string
}

fn main() {
	mut content := os.read_lines('./vlang.ebnf') or {
		println('Unable to open bnf')
		return
	}

	/*for i, line in content {
		if line == '' || line.starts_with("//") {
			content.delete(i)
		}
	}*/

	mut expr := []Expr{len: content.len}

	for i, line in content {
		if line == '' || line.starts_with('//') {
			continue
		}

		tokens := line.split_by_space()
		expr << Expr{
			name:   tokens[0]
			tokens: tokens[2..tokens.len]
		}
	}
}
