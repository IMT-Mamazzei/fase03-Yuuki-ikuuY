package br.maua.cic303;

import java_cup.runtime.Symbol;

%%

%class Lexer
%public
%cup
%unicode
%type java_cup.runtime.Symbol
%line
%column

%{
    private Symbol token(int type) {
        return new Symbol(type, yyline, yycolumn);
    }

    private Symbol token(int type, Object value) {
        return new Symbol(type, yyline, yycolumn, value);
    }
%}

/* ========================================================================= */
/* MACROS (Expressões Regulares Auxiliares)                                  */
/* ========================================================================= */
LineTerminator = \r|\n|\r\n
WhiteSpace     = {LineTerminator} | [ \t\f]

/* TODO 1: Crie a macro para Número (Notação de Engenharia) */
/* Dica: Deve aceitar 7, 3.14, 6.02E23, 6.62e-34 */
Number = [0-9]+(\.[0-9]+)?([Ee][+-]?[0-9]+)?

/* TODO 2: Crie a macro para Identificador */
/* Dica: Letras, seguidas de letras, números ou _. MÁXIMO de 32 caracteres! */
/* Se a macro de max 32 for difícil, use {Letter}({Letter}|{Digit}|_)* e trate o tamanho na regra! */
Letter = [a-zA-Z]
Digit  = [0-9]
Identifier = {Letter}({Letter}|{Digit}|_){0,31}

%%
/* ========================================================================= */
/* REGRAS LÉXICAS                                                            */
/* ========================================================================= */

<YYINITIAL> {
    
    /* Regra para ignorar espaços em branco */
    {WhiteSpace}    { /* Não faz nada */ }

    /* TODO 3: Palavras Reservadas (if, then, else, while) */
    "if"            { return token(sym.IF); }
    "then"          { return token(sym.THEN); }
    /* Adicione as demais aqui... */
    "else"          { return token(sym.ELSE); }
    "while"         { return token(sym.WHILE); }

    /* TODO 4: Pontuação ( ) { } ; */
    "("             { return token(sym.LPAREN); }
    /* Adicione as demais aqui... */
    ")"             { return token(sym.RPAREN); }
    "{"             { return token(sym.LBRACE); }
    "}"             { return token(sym.RBRACE); }
    ";"             { return token(sym.SEMI); }    

    /* TODO 5: Operadores de Atribuição e Relacionais (=, ==, !=, <, >, <=, >=) */
    /* CUIDADO COM A ORDEM! O JFlex casa a regra que aparece primeiro se houver empate de tamanho. */
    /* Coloque os operadores duplos antes dos simples! */
    "="             { return token(sym.ASSIGN); }
    /* Adicione os relacionais aqui e retorne sym.REL_OP ... */
    "=="            { return token(sym.REL_OP, yytext()); }
    "!="            { return token(sym.REL_OP, yytext()); }
    "<="            { return token(sym.REL_OP, yytext()); }
    ">="            { return token(sym.REL_OP, yytext()); }
    "<"             { return token(sym.REL_OP, yytext()); }
    ">"             { return token(sym.REL_OP, yytext()); }

    /* TODO 6: Operadores Matemáticos (+, -, *, /, %) */
    /* Dica: "+" | "-" retornam sym.ADD_OP. Os outros retornam sym.MUL_OP */
    "+" | "-"       { return token(sym.ADD_OP, yytext()); }
    /* Adicione as multiplicações aqui... */
    "*" | "/" | "%" { return token(sym.MUL_OP, yytext()); }

    /* Regras para as Macros */
    {Identifier}    { return token(sym.ID, yytext()); }
    {Number}        { return token(sym.NUMBER, yytext()); }

    /* Identificadores grandes demais (Captura o erro) */
    {Letter}({Letter}|{Digit}|_){32} { 
        throw new RuntimeException("Erro Léxico: Identificador ultrapassou 32 caracteres -> " + yytext()); 
    }

    /* Fallback: Qualquer outro caractere não reconhecido gera um Erro */
    .               { throw new RuntimeException("Erro Léxico: Caractere Ilegal -> " + yytext()); }
}

/* Regra para o Final do Arquivo */
<<EOF>>             { return token(sym.EOF, ""); }