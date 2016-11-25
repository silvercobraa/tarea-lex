#!/bin/bash

lex ./xml.lex
gcc ./lex.yy.c -o ./xml.out -lfl
./xml.out $1
