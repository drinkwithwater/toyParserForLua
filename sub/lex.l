%{
    #include <stdio.h>
	#include <lua.h>
	#include <lauxlib.h>
    #include "yacc.h"

	extern lua_State* L_context;
    int col=1;
	int row=1;
    #undef yywrap
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
    return VALUE_NUMBER;
}

[0-9]+\.[0-9]+ {
    return VALUE_NUMBER;
}

0x[0-9a-fA-F]+ {
    return VALUE_NUMBER;
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
    lua_getfield(L_context, LUA_REGISTRYINDEX, "node");
	int index = luaL_len(L_context, -1) + 1;
	int len = strlen(yytext);
	lua_pushlstring(L_context, yytext,len);
	lua_rawseti(L_context, -2, index);
	yylval = index;
	lua_pop(L_context,1);
	printf("%d %s\n", row, yytext);
	return ID;
}


. {
}

<<EOF>> return EOFF;

%%
int yywrap(void) {
    return 1;
}

