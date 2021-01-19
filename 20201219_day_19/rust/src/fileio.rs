use onig::Regex;
use std::collections::HashMap;
use std::fs::File;
use std::io::{BufRead, BufReader, Error};

#[derive(Debug, PartialEq, Eq)]
pub enum Token {
    Val(u32),
    Str(String),
}

#[derive(Debug)]
pub enum ReadMode {
    Rule,
    Message,
}

pub type Rule = Vec<Token>;
pub type Rules = HashMap<u32, Rule>;
pub type Messages = Vec<String>;

pub fn read_input(filename: &str) -> Result<(Rules, Messages), Error> {
    let file = File::open(filename);
    let br = BufReader::new(file?);
    let mut rules = HashMap::new();
    let mut messages = Vec::new();
    let mut read_mode = ReadMode::Rule;

    for line in br.lines() {
        let line = line?;
        if line.is_empty() {
            read_mode = ReadMode::Message;
            continue;
        }
        match read_mode {
            ReadMode::Rule => {
                let line_parts: Vec<&str> = line.split(": ").collect();
                let rule_no: u32 = line_parts[0].parse().ok().unwrap();
                let rule = tokenize(&line_parts[1]);
                rules.insert(rule_no, rule);
            }
            ReadMode::Message => {
                messages.push(line);
            }
        }
    }
    Ok((rules, messages))
}

pub fn tokenize(s: &str) -> Rule {
    let mut rule = Vec::new();

    rule.push(Token::Str("(".to_string()));
    for rule_part in s.split(" ") {
        let token = if rule_part.parse::<u32>().is_ok() {
            Token::Val(rule_part.parse::<u32>().ok().unwrap())
        } else {
            Token::Str(rule_part.to_string().replace("\"", ""))
        };
        rule.push(token);
    }
    rule.push(Token::Str(")".to_string()));

    rule
}

pub fn expand_rule(rule_no: u32, rules: &Rules) -> Option<Regex> {
    let mut rule: Vec<&Token> = (*rules.get(&rule_no)?).iter().map(|x| x).collect();

    let expanded_rule = loop {
        let mut expanded_rule = Vec::new();
        let mut fully_expanded = true;
        for t in rule {
            match t {
                Token::Val(n) => {
                    expanded_rule.extend(rules.get(n)?);
                    fully_expanded = false;
                }
                Token::Str(_) => expanded_rule.push(t),
            };
        }
        if fully_expanded {
            break expanded_rule;
        }
        rule = expanded_rule;
    };

    let mut rule_string = String::new();
    rule_string.push('^');
    for s in expanded_rule {
        match s {
            Token::Str(x) => rule_string.extend(x.chars()),
            Token::Val(x) => panic!("Failed to expand value {:?}", x),
        }
    }
    rule_string.push('$');

    Some(Regex::new(&rule_string).unwrap())
}
