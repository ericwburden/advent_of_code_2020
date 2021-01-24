# Welcome

2020 was my first year to be introduced to Advent of Code, and I'm officially in love! This repository houses my work/solutions to the Advent of Code 2020 puzzles. The structure is one folder per day, labled with that day's date/label. The initial implementation for each solution is in R, because that's the language I'm most comfortable with. Each folder contains the puzzle input in an `input.txt` file, and potentially some optional test inputs in `test_input{n}.txt` files. I've broken the R solutions into two files, `exercise_1.R` and `exercise_2.R`. There are one or two where I tried different approaches and so have an `exercise_1b.R` or some such.

## The Blog

I've blogged my approaches to the R version of each solution here: [Advent of Code Blog](https://www.ericburden.work/categories/advent-of-code-2020/). Each one includes not only the code but some commentary on the thinking behind the approach and my thoughts about the puzzles in general.

## Next Steps

I found these puzzles to be interesting and diverse enough, and at a reasonable enough difficulty level, to make a really good set of exercises for learning new languages. In particular, I'm working on picking up Rust, so each day is going to start being divided into an `R` and a `rust` folder. The `R` folder will look just like the days that haven't been converted, the `rust` folder will have a crate from `cargo new` with *.rs files containing the solution code.

### Update

I've finished implementing all 25 Days in Rust. As I suspected, this was a really good set of problems to work through as I learned the language. I now feel *competent* (if not exactly *excellent*) at writing Rust code. I [timed the code execution](rust_run_times.md) for all 25 days on my laptop, and Rust is able to chew through both parts of all 25 days in less that 1.14 seconds. This is a **vast** improvement over the R run times, though I do have to admit I find it much easier to reason through the puzzles in R (and a few of the days that I solved with R-specific features like matrices/arrays, environments, or data frames took some extra thought-work). In the end, I've learned a lot and feel like I can go and be productive with Rust, which is everything I could have hoped for.
