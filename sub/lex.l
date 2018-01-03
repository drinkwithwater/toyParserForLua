%{
    #include <stdio.h>
	#include <lua.h>
	#include <lauxlib.h>
    #include "yacc.h"

	extern lua_State* L_context;
	extern char* inputStr;
    int col=1;
	int row=1;
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
	printf("deco declare : %s\n", yytext);
	for(int i=0;yytext[i]!='\0';i++){
		if(yytext[i]=='\n'){
			row++;
		}
	}
	//return DECO_DECLARE;
}

--\[\[([^\]])*(\]([^\]])+)*\]\] {
	for(int i=0;yytext[i]!='\0';i++){
		if(yytext[i]=='\n'){
			row++;
		}
	}
}


--@[^-\n]*->[^\n]* {
	printf("deco next: %s\n", yytext);
	//return DECO_NEXT;
}

--@[^-\n]*-<[^\n]* {
	printf("deco pre: %s\n", yytext);
	//return DECO_PRE;
}

--[^\n]* ;

{blanks}  ;

"\n"  {
	row++;
}

[0-9]+ {
	int index = luaL_len(L_context, -1) + 1;
	int value = atoi(yytext);
	lua_pushinteger(L_context, value);
	lua_rawseti(L_context, -2, index);
	yylval = index;
	printf("integer : %d %s\n", row, yytext);
    return VALUE_INTEGER;
}

[0-9]+\.[0-9]+ {
    return VALUE_FLOAT;
}

\"(\\.|[^\\"])*\" {
	return VALUE_STRING;
}

\'(\\.|[^\\'])*\' {
	return VALUE_STRING;
}


"interface" return INTERFACE;

"Nil" return NIL;
"Boolean" return BOOLEAN;
"Number" return NUMBER;
"String" return STRING;
"Function" return FUNCTION;
"Enum" return ENUM;
"Class" return CLASS;

"List" return LIST;
"Map" return MAP;

  /* quote */
"(" return LEFT_PAREN;
")" return RIGHT_PAREN;
"[" return LEFT_BRACKET;
"]" return RIGHT_BRACKET;
"{" return LEFT_BRACE;
"}" return RIGHT_BRACE;

"|" return BITOR;

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
	printf("string : %d %s\n", row, yytext);
	return ID;
}


. {
}

<<EOF>> return EOFF;

%%
int yywrap(void) {
    return 1;
}

