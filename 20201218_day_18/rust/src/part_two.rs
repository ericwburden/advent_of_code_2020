use crate::fileio::{mult, Expression, Op, Token};

pub fn evaluate_expression(expr: &Expression) -> u64 {
    let mult_op: Op = mult;
    let mut total = 0;
    let mut summed_nums = Vec::new();

    for t in expr {
        match t {
            Token::Value(v) => total += v,
            Token::Operator(o) => {
                if o == &mult_op {
                    summed_nums.push(total);
                    total = 0;
                }
            }
            Token::Expression(e) => total += evaluate_expression(e),
            Token::Break => panic!("Found a `Token::Break` while evaluating!"),
        }
    }
    summed_nums.push(total);

    summed_nums.iter().fold(1, |t, n| t * n)
}

pub fn solve(exprs: &Vec<Expression>) {
    let mut answer = 0;
    for e in exprs {
        answer += evaluate_expression(e);
    }
    println!("\nThe answer to part two is {}", answer);
}
