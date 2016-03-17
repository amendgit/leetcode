/*
65. Valid Number

https://leetcode.com/problems/valid-number/

Validate if a given string is numeric.

Some examples:
"0" => true
" 0.1 " => true
"abc" => false
"1 a" => false
"2e10" => true
Note: It is intended for the problem statement to be ambiguous. You should gather all requirements up front before implementing one.

Update (2015-02-10):
*/

package main

import "fmt"

func isdigit(ch byte) bool {
	return ch >= '0' && ch <= '9'
}

func isspace(ch byte) bool {
	return ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r'
}

func isNumber(s string) bool {
	var b = []byte(s)
	var (
		hasE = false
		hasDot = false
	)

	var i = 0
	for i < len(b) && isspace(b[i]) {
		i++
	}
	if i == len(b) {
		return false
	}
	if s[i] == '+' || s[i] == '-' {
		i++
	}
	
	var head = i 
	for ; i < len(b); i++ {
		if b[i] == '.' {
			if hasDot || hasE {
				return false
			}
			// no : "." ".e" 
			// yes: ".3" "2.e3"
			if (i == head && i+1 < len(b) && !isdigit(b[i+1])) ||
				(i == head && i+1 >= len(b)) {
				return false
			}
			hasDot = true
			continue
		}
		if b[i] == 'e' {
			// no : "e" "e3"
			if hasE || i == head {
				return false
			}
			i++
			// yes : "2e+3" "2e-3"
			if i<len(b) && (b[i] == '+' || b[i] == '-') {
				i++
			}
			if (i<len(b) && !isdigit(b[i])) ||
				(i>=len(b)) {
				return false
			}
			hasE = true
			continue
		}
		if isspace(b[i]) {
			for ; i < len(b); i++ {
				if !isspace(b[i]) {
					return false
				}
			}
			return true 
		}
		if !isdigit(b[i]) {
			return false;
		}
	}

	return true
}

type tIsNumberTest struct {
	str string
	isNumber bool
} 

var isNumberTests = []tIsNumberTest{
	{
		"0",
		true,
	},
	{
		".",
		false,
	},
	{
		"e",
		false,
	},
	{
		"-.",
		false,
	},
	{
		"+.8",
		true,
	},
	{
		" ",
		false,
	},
	{
		" 0.1",
		true,
	},
	{
		"abc",
		false,
	},
	{
		"1 a",
		false,
	},
	{
		"2e10",
		true,
	},
	{
		"49.e3",
		true,
	},
	{
		".1",
		true,
	},
	{
		"3.",
		true,
	},
	{
		"123e+6",
		false,
	},
	{
		"1e2e3e",
		false,
	},
	{
		"1+3",
		false,
	},
	{
		"--3",
		false,
	},
	{
		"++3",
		false,
	},
}

func main() {
	for _, tt := range isNumberTests {
		var got = isNumber(tt.str)
		if got != tt.isNumber {
			fmt.Printf("isNumber(%v) got %v want %v\n", tt.str, got, tt.isNumber)
		}
	}
}