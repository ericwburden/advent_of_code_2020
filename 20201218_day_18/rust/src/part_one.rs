use crate::fileio::{add, Expression, Op, Token};

pub fn evaluate_expression(expr: &Expression) -> u64 {
    let mut current_operation: Op = add;
    let mut total = 0;

    for t in expr {
        match t {
            Token::Value(v) => total = current_operation(total, *v),
            Token::Operator(o) => current_operation = *o,
            Token::Expression(e) => {
                let expr_value = evaluate_expression(e);
                total = current_operation(total, expr_value);
            }
            Token::Break => panic!("Found a `Token::Break` while evaluating!"),
        }
    }

    total
}

pub fn solve(exprs: &Vec<Expression>) {
    let mut answer = 0;
    for e in exprs {
        answer += evaluate_expression(e);
    }
    println!("\nThe answer to part one is {}", answer);
}
