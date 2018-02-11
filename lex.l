%{
    #include <stdio.h>
	#include <lua.h>
	#include <lauxlib.h>
    #include "yacc.h"

	extern lua_State* L_context;
	extern const char* inputStr;
    extern int col;
	extern int row;
    #undef yywrap

#define YY_INPUT(buf,result,max_size) \
	if ( inputStr!=NULL ) { \
		int n; \
		for ( n = 0; inputStr[n] != '\0' && n<max_size; n++) \
			buf[n] = (char) inputStr[n]; \
		if(inputStr=='\0') inputStr = NULL; \
		else inputStr = inputStr + n ; \
		result = n; \
	}else result = 0;  \

%}

blanks [ \t\v\h]+


%%

--\[\[\@([^\]])*(\]([^\]])+)*\]\] {
	for(int i=0;yytext[i]!='\0';i++){
		if(yytext[i]=='\n'){
			row++;
		}
	}
	int index = luaL_len(L_context, -1) + 1;
	int len = strlen(yytext);
	lua_pushlstring(L_context, yytext,len);
	lua_rawseti(L_context, -2, index);
	yylval = index;
	return DECO_DECLARE;
}

--\[\[([^\]])*(\]([^\]])+)*\]\] {
	for(int i=0;yytext[i]!='\0';i++){
		if(yytext[i]=='\n'){
			row++;
		}
	}
}


--@[^-\n]*->[^\n]* {
	int index = luaL_len(L_context, -1) + 1;
	int len = strlen(yytext);
	lua_pushlstring(L_context, yytext,len);
	lua_rawseti(L_context, -2, index);
	yylval = index;
	return DECO_PREFIX;
}

--@[^-\n]*-<[^\n]* {
	int index = luaL_len(L_context, -1) + 1;
	int len = strlen(yytext);
	lua_pushlstring(L_context, yytext,len);
	lua_rawseti(L_context, -2, index);
	yylval = index;
	return DECO_SUFFIX;
}

--[^\n]* ;

{blanks}  ;

"\n"  {
	row++;
}

[0-9]+ {
    return NUMBER;
}

[0-9]+\.[0-9]+ {
    return NUMBER;
}

0x[0-9a-fA-F]+ {
    return NUMBER;
}

\"(\\.|[^\\"])*\" {
	return STRING;
}

\'(\\.|[^\\'])*\' {
	return STRING;
}

"true" return TRUE;
"false" return FALSE;
"nil" return NIL;

  /* key word */
"do" return DO;
"end" return END;
"if" return IF;
"then" return THEN;
"else" return ELSE;
"elseif" return ELSEIF;
"local" return LOCAL;
"function" return FUNCTION;
"return" return RETURN;
"while" return WHILE;
"for" return FOR;
"in" return IN;
"break" return BREAK;


  /* quote */
"(" return LEFT_PAREN;
")" return RIGHT_PAREN;
"[" return LEFT_BRACKET;
"]" return RIGHT_BRACKET;
"{" return LEFT_BRACE;
"}" return RIGHT_BRACE;

  /* op */
"and" return AND;
"or" return OR;
"not" return NOT;

"+" return ADD;
"-" return SUB;
"*" return MUL;
"/" return DIV;
"%" return MOD;
"^" return POWER;
"#" return SHARP;
"|" return BITOR;
"&" return BITAND;
"~" return BITNOT;

">>" return SRR;
"<<" return SLL;

"==" return EQ;
"~=" return NE;
"<=" return LE;
">=" return GE;
">" return GT;
"<" return LT;


 /* single */
"." return DOT;
":" return COLON;
"=" return EQA;
"," return COMMA;
";" return SEMICOLON;



[a-zA-Z_][a-zA-Z0-9_]* {
	int index = luaL_len(L_context, -1) + 1;
	int len = strlen(yytext);
	lua_pushlstring(L_context, yytext,len);
	lua_rawseti(L_context, -2, index);
	yylval = index;
	return ID;
}


\.\.\. {
	return DOT3;
}

\.\. {
	return DOT2;
}

. {
}

<<EOF>> return EOFF;

%%
int yywrap(void) {
    return 1;
}

