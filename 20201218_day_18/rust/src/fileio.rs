use std::fs::File;
use std::io::{BufRead, BufReader, Error};

pub type Op = fn(u64, u64) -> u64;

pub fn add(lhs: u64, rhs: u64) -> u64 {
    lhs + rhs
}

pub fn mult(lhs: u64, rhs: u64) -> u64 {
    lhs * rhs
}

#[derive(Debug)]
pub enum Token {
    Value(u64),
    Operator(Op),
    Break,
    Expression(Expression),
}

pub type Expression = Vec<Token>;

pub fn read_input(filename: &str) -> Result<Vec<Expression>, Error> {
    let file = File::open(filename);
    let br = BufReader::new(file?);
    let mut expressions = Vec::new();

    for line in br.lines() {
        let expression = parse_expression_string(&line?);
        expressions.push(expression);
    }

    Ok(expressions)
}

pub fn parse_expression_string(expr: &String) -> Expression {
    let mut expression = Vec::new();
    for e in expr.chars() {
        match e {
            '0'..='9' => expression.push(Token::Value(e.to_digit(10).unwrap().into())),
            '+' => expression.push(Token::Operator(add)),
            '*' => expression.push(Token::Operator(mult)),
            '(' => expression.push(Token::Break),
            ')' => {
                let mut buffer = Vec::new();
                loop {
                    match expression.pop() {
                        Some(Token::Break) | None => break,
                        Some(t) => buffer.push(t),
                    }
                }
                buffer.reverse();
                expression.push(Token::Expression(buffer));
            }
            _ => continue,
        }
    }
    expression
}
