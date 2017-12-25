%{
    #include <stdio.h>
	#include <lua.h>
	#include <lauxlib.h>
    #include "tree.h"
    #include "yacc.h"
	lua_State* L_context=NULL;
	extern int col;
	extern int row;
    int yylex(void);
    void yyerror(char *);


	int lua_new_table();
	int lua_new_obj(char* type, char* subType);
	void lua_list_push(int listIndex, int childListIndex);
	void lua_table_set(int tableIndex, char * key, int subItemIndex);
	void lua_set_root(int tableIndex);

	int indexCount;
%}

%token
    EOFF 0

    DO "do"
    END "end"
    IF "if"
    THEN "then"
    ELSE "else"
    ELSEIF "elseif"
    LOCAL "local"
	FUNCTION "function"
    RETURN "return"
	WHILE "while"
	FOR "for"
	IN "in"
	BREAK "break"

    LEFT_PAREN "("
    RIGHT_PAREN ")"
    LEFT_BRACKET "["
    RIGHT_BRACKET "]"
	LEFT_BRACE "{"
	RIGHT_BRACE "}"


%token
    BITAND "&"
    BITOR "|"
    BITNOT "~"
    AND "and"
    OR "or"
    NOT "not"

    ADD "+"
    SUB "-"
    MUL "*"
    DIV "/"
    MOD "%"
	POWER "^"
    SHARP "#"

    EQ "=="
    NE "~="
    LE "<="
    GE ">="
    GT ">"
    LT "<"

    DOT "."
	COLON ":"
    EQA "="
    COMMA ","
    SEMICOLON ";"
    ;

%token ID STRING NUMBER
%token DOT3 DOT2
%token TRUE FALSE NIL
%token COMMENT DECO_NEXT DECO_PRE DECO_DECLARE

%%

chunk : block { lua_set_root($1); }

block : stmt_list { $$=$1; }

stmt_list : { $$=lua_new_obj("stmt_list",NULL); }
    | stmt_list stmt {
		lua_list_push($1, $2);
		$$=$1;
	}

stmt : DO block END { $$ = $2; }
    | while_head DO block END {
		int tableIndex = lua_new_obj("stmt", "while");
		$$ = tableIndex;
		lua_table_set(tableIndex, "head", $1);
		lua_table_set(tableIndex, "block", $3);
	}
    | for_head DO block END {
		int tableIndex = lua_new_obj("stmt", "for");
		$$ = tableIndex;
		lua_table_set(tableIndex, "head", $1);
		lua_table_set(tableIndex, "block", $3);
	}
    | if_stmt { $$ = $1; }
    | local_stmt { $$ = $1; }
	| assign_stmt { $$ = $1; }
    | function_stmt { $$ = $1; }
    | function_call { $$ = $1; }
    | ret_stmt { $$ = $1; }
    | BREAK {
		$$ = lua_new_obj("stmt", "break");
	}

assign_stmt : var_list EQA expr_list {
			int tableIndex = lua_new_obj("stmt", "assign");
			$$ = tableIndex;
			lua_table_set(tableIndex, "var_list", $1);
			lua_table_set(tableIndex, "expr_list", $3);
		}

ret_stmt : RETURN expr_list {
		 int tableIndex = lua_new_obj("stmt", "return");
		 $$ = tableIndex;
		 lua_table_set(tableIndex, "expr_list", $2);
	 }
	| RETURN {
		$$ = lua_new_obj("stmt","return");
	}

local_stmt : LOCAL id_list {
		 int tableIndex = lua_new_obj("stmt","local");
		 $$ = tableIndex;
		 lua_table_set(tableIndex, "id_list", $2);
	   }
	| LOCAL id_list EQA expr_list {
		 int tableIndex = lua_new_obj("stmt","local");
		 $$ = tableIndex;
		 lua_table_set(tableIndex, "id_list", $2);
		 lua_table_set(tableIndex, "expr_list", $4);
	}
	| LOCAL FUNCTION id LEFT_PAREN argv RIGHT_PAREN block END{
		 int tableIndex = lua_new_obj("stmt","local");
		 $$ = tableIndex;
		 lua_table_set(tableIndex, "id", $3);
		 lua_table_set(tableIndex, "argv", $5);
		 lua_table_set(tableIndex, "block", $7);
	}

while_head :
	WHILE LEFT_PAREN expr RIGHT_PAREN { $$ = $3; }
	| WHILE expr { $$ = $2; }

for_head : FOR id_list IN expr {
		 int tableIndex = lua_new_obj("for_head","in");
		 $$ = tableIndex;
		 lua_table_set(tableIndex, "id_list", $2);
		 lua_table_set(tableIndex, "expr", $4);
	}
	| FOR id EQA expr_list {
		 int tableIndex = lua_new_obj("for_head","eqa");
		 $$ = tableIndex;
		 lua_table_set(tableIndex, "id", $2);
		 lua_table_set(tableIndex, "expr_list", $4);
	}

function_stmt : function_head block END {
				 int tableIndex = lua_new_obj("stmt","function");
				 $$ = tableIndex;
				 lua_table_set(tableIndex, "head", $1);
				 lua_table_set(tableIndex, "block", $2);
			  }

function_head : FUNCTION var LEFT_PAREN argv RIGHT_PAREN {
			 int tableIndex = lua_new_obj("function_head","var");
			 $$ = tableIndex;
			 lua_table_set(tableIndex, "var", $2);
			 lua_table_set(tableIndex, "argv", $4);
		  }
    | FUNCTION var COLON id LEFT_PAREN argv RIGHT_PAREN {
		 int tableIndex = lua_new_obj("function_head",":id");
		 $$ = tableIndex;
		 lua_table_set(tableIndex, "var", $2);
		 lua_table_set(tableIndex, "id", $4);
		 lua_table_set(tableIndex, "argv", $6);
	}

function_lambda : FUNCTION LEFT_PAREN argv RIGHT_PAREN block END{
			 int tableIndex = lua_new_obj("function_lambda",NULL);
			 $$ = tableIndex;
			 lua_table_set(tableIndex, "argv", $3);
			 lua_table_set(tableIndex, "block", $5);
		}

elseif_item : ELSEIF expr THEN block{
			int tableIndex = lua_new_obj("elseif_item",NULL);
			$$ = tableIndex;
			lua_table_set(tableIndex, "expr", $2);
			lua_table_set(tableIndex, "expr", $4);
		}

elseif_list : { $$=lua_new_obj("elseif_list",NULL); }
	| elseif_list elseif_item {
		lua_list_push($1, $2);
		$$ = $1;
	}
if_stmt : IF expr THEN block elseif_list END {
			int tableIndex = lua_new_obj("stmt","if");
			$$ = tableIndex;
			lua_table_set(tableIndex, "expr", $2);
			lua_table_set(tableIndex, "block", $4);
			lua_table_set(tableIndex, "elseif_list", $5);
		}
    | IF expr THEN block elseif_list ELSE block END {
			int tableIndex = lua_new_obj("stmt","if_else");
			$$ = tableIndex;
			lua_table_set(tableIndex, "expr", $2);
			lua_table_set(tableIndex, "block", $4);
			lua_table_set(tableIndex, "elseif_list", $5);
			lua_table_set(tableIndex, "else_block", $7);
		}

var_list : var {
		 int listIndex = lua_new_obj("var_list",NULL);
		 $$ = listIndex;
		 lua_list_push(listIndex, $1);
	 }
    | var_list COMMA var {
		lua_list_push($1, $3);
		$$ = $1;
	}

expr_list : expr {
		 int listIndex = lua_new_obj("expr_list",NULL);
		 $$ = listIndex;
		 lua_list_push(listIndex, $1);
	  }
    | expr_list COMMA expr {
		lua_list_push($1, $3);
		$$ = $1;
	}


prefix_exp : var { $$ = $1; }
		| function_call { $$ = $1; }
		| LEFT_PAREN expr RIGHT_PAREN { $$ = $2; }

var : id {
		int tableIndex = lua_new_obj("var", "id");
		$$ = tableIndex;
		lua_table_set(tableIndex, "id", $1);
	}
    | prefix_exp DOT id {
		int tableIndex = lua_new_obj("var", ".id");
		$$ = tableIndex;
		lua_table_set(tableIndex, "prefix_exp", $1);
		lua_table_set(tableIndex, "id", $3);
	}
    | prefix_exp LEFT_BRACKET expr RIGHT_BRACKET {
		int tableIndex = lua_new_obj("var", "[expr]");
		$$ = tableIndex;
		lua_table_set(tableIndex, "prefix_exp", $1);
		lua_table_set(tableIndex, "expr", $3);
	}

expr : unary_op expr {
		 int tableIndex = lua_new_obj("expr", "uop");
		 $$=tableIndex;
		 lua_table_set(tableIndex, "op", $1);
		 lua_table_set(tableIndex, "expr", $2);
	 }
	| expr binary_op expr {
		int tableIndex = lua_new_obj("expr", "bop");
		$$ = tableIndex;
		lua_table_set(tableIndex, "expr1", $1);
		lua_table_set(tableIndex, "op", $2);
		lua_table_set(tableIndex, "expr2", $3);
	}
    | DOT3 {
		int tableIndex = lua_new_obj("expr", "DOT3");
		$$ = tableIndex;
	}
    | value {
		int tableIndex = lua_new_obj("expr", "value");
		$$ = tableIndex;
		lua_table_set(tableIndex, "value", $1);
	}
    | table {
		int tableIndex = lua_new_obj("expr", "table");
		$$ = tableIndex;
		lua_table_set(tableIndex, "table", $1);
	}
    | function_lambda {
		int tableIndex = lua_new_obj("expr", "lambda");
		$$ = tableIndex;
		lua_table_set(tableIndex, "lambda", $1);
	}
	| prefix_exp {
		int tableIndex = lua_new_obj("expr", "prefix_exp");
		$$ = tableIndex;
		lua_table_set(tableIndex, "prefix_exp", $1);
	}

args : STRING {
		int tableIndex = lua_new_obj("args", "string");
		$$ = tableIndex;
		lua_table_set(tableIndex, "string", $1);
	 }
	| table {
		int tableIndex = lua_new_obj("args", "table");
		$$ = tableIndex;
		lua_table_set(tableIndex, "table", $1);
	}
	| LEFT_PAREN RIGHT_PAREN {
		$$ = lua_new_obj("args", "()");
	}
	| LEFT_PAREN expr_list RIGHT_PAREN {
		int tableIndex = lua_new_obj("args", "(expr_list)");
		$$ = tableIndex;
		lua_table_set(tableIndex, "expr_list", $1);
	}

function_call : prefix_exp args {
			  int tableIndex = lua_new_obj("stmt", "function_call");
			  $$ = tableIndex;
			  lua_table_set(tableIndex, "prefix_exp", $1);
			  lua_table_set(tableIndex, "args", $2);
		  }
	| prefix_exp COLON id args {
		  int tableIndex = lua_new_obj("stmt","function_call");
		  $$ = tableIndex;
		  lua_table_set(tableIndex, "prefix_exp", $1);
		  lua_table_set(tableIndex, "id", $3);
		  lua_table_set(tableIndex, "args", $4);
	}

unary_op: NOT { $$ = lua_new_obj("uop", "not"); }
    | SUB { $$ = lua_new_obj("uop","-"); }
    | SHARP { $$ = lua_new_obj("uop","#"); }
    | BITNOT { $$ = lua_new_obj("uop","~"); }

binary_op: OR  { $$ = lua_new_obj("bop","or"); }
	| AND { $$ = lua_new_obj("bop","and"); }
    | ADD { $$ = lua_new_obj("bop","+"); }
    | SUB { $$ = lua_new_obj("bop","-"); }
    | MUL { $$ = lua_new_obj("bop","*"); }
    | DIV { $$ = lua_new_obj("bop","/"); }
    | MOD { $$ = lua_new_obj("bop","%"); }
    | EQ { $$ = lua_new_obj("bop","=="); }
    | NE { $$ = lua_new_obj("bop","~="); }
    | LE { $$ = lua_new_obj("bop","<="); }
    | GE { $$ = lua_new_obj("bop",">="); }
    | GT { $$ = lua_new_obj("bop",">"); }
    | LT { $$ = lua_new_obj("bop","<"); }
    | BITOR { $$ = lua_new_obj("bop","|"); }
    | BITAND { $$ = lua_new_obj("bop","&"); }
    | BITNOT { $$ = lua_new_obj("bop","~"); }
    | DOT2 { $$ = lua_new_obj("bop",".."); }

value : STRING {$$=lua_new_obj("value","string");}
	| NUMBER {$$=lua_new_obj("value","number");}
	| TRUE {$$=lua_new_obj("value","true");}
	| FALSE {$$=lua_new_obj("value","false");}
	| NIL {$$=lua_new_obj("value","nil");}


argv : {$$=lua_new_obj("argv","()");}
	| DOT3 {$$ = lua_new_obj("argv","(...)");}
	| id_list {
		int tableIndex = lua_new_obj("argv","list");
		$$ = tableIndex;
		lua_table_set(tableIndex,"id_list", $1);
	}
	| id_list COMMA DOT3 {
		int tableIndex = lua_new_obj("argv","list,...");
		$$ = tableIndex;
		lua_table_set(tableIndex, "id_list", $1);
	}

id_list : id {
		int tableIndex = lua_new_obj("id_list",NULL);
		$$ = tableIndex;
		lua_list_push(tableIndex,$1);
	}
	| id_list COMMA id {
		lua_list_push($1, $3);
		$$ = $1;
	}

id : ID {$$ = $1;}

table : LEFT_BRACE RIGHT_BRACE { $$=lua_new_obj("key_value_list", NULL); }
	| LEFT_BRACE key_value_list RIGHT_BRACE { $$=$2; }
	| LEFT_BRACE key_value_list COMMA RIGHT_BRACE { $$=$2; }

key_value_list : key_value {
		int tableIndex = lua_new_obj("key_value_list",NULL);
		$$ = tableIndex;
		lua_list_push(tableIndex, $1);
	}
	| key_value_list COMMA key_value {
		lua_list_push($1, $3);
		$$=$1;
	}

key_value : id EQA expr {
		  int tableIndex = lua_new_obj("kv","id=expr");
		  $$ = tableIndex;
		  lua_table_set(tableIndex, "id", $1);
		  lua_table_set(tableIndex, "expr", $3);
	  }
	| expr {
		  int tableIndex = lua_new_obj("kv","id=expr");
		  $$ = tableIndex;
		  lua_table_set(tableIndex, "expr", $1);
	}
	| LEFT_BRACKET value RIGHT_BRACKET EQA expr {
		  int tableIndex = lua_new_obj("kv","[value]=expr");
		  $$ = tableIndex;
		  lua_table_set(tableIndex, "value", $2);
		  lua_table_set(tableIndex, "expr", $5);
	}


%%

void yyerror(char *s) {
    fprintf(stderr, "col=%d, row=%d %s\n", col, row, s);
}


void lua_set_root(int tableIndex){
	lua_pushinteger(L_context, tableIndex);
    lua_setfield(L_context, LUA_REGISTRYINDEX, "root");
}

int lua_new_stmt(char* type){
    lua_getfield(L_context, LUA_REGISTRYINDEX, "node");
	int index = luaL_len(L_context, -1) + 1;
	// stmtTable = {}
	lua_newtable(L_context);

	// stmtTable.__type=type
	lua_pushlstring(L_context,"__type",6);
	lua_pushlstring(L_context,type,strlen(type));
	lua_rawset(L_context, -3);

	// node[index] = stmtTable
	lua_rawseti(L_context, -2, index);
	lua_pop(L_context,1);
	return index;
}

int lua_new_obj(char* type, char* subType){
    lua_getfield(L_context, LUA_REGISTRYINDEX, "node");
	int index = luaL_len(L_context, -1) + 1;
	// obj = {}
	lua_newtable(L_context);

	// obj.__type=type
	lua_pushlstring(L_context,"__type",6);
	lua_pushlstring(L_context,type,strlen(type));
	lua_rawset(L_context, -3);

	if(subType!=NULL){
		// obj.__subtype=subType
		lua_pushlstring(L_context,"__subtype",9);
		lua_pushlstring(L_context,subType,strlen(subType));
		lua_rawset(L_context, -3);
	}

	//obj.col = col;
	lua_pushlstring(L_context,"col",3);
	lua_pushinteger(L_context,col);
	lua_rawset(L_context, -3);

	//obj.row = row;
	lua_pushlstring(L_context,"row",3);
	lua_pushinteger(L_context,row);
	lua_rawset(L_context, -3);

	// node[index] = obj
	lua_rawseti(L_context, -2, index);
	lua_pop(L_context,1);
	return index;
}

int lua_new_table(){
    lua_getfield(L_context, LUA_REGISTRYINDEX, "node");
	int index = luaL_len(L_context, -1) + 1;
	lua_newtable(L_context);
	lua_rawseti(L_context, -2, index);
	lua_pop(L_context,1);
	return index;
}

void lua_list_push(int listIndex, int childListIndex){
    lua_getfield(L_context, LUA_REGISTRYINDEX, "node");
	lua_rawgeti(L_context, -1, listIndex);

	// list[#list+1] =  childListIndex
	int index = luaL_len(L_context, -1) + 1;
	lua_pushinteger(L_context, childListIndex);
	lua_rawseti(L_context, -2, index);

	lua_pop(L_context,2);
}

void lua_table_set(int tableIndex, char* key, int subItemIndex){
    lua_getfield(L_context, LUA_REGISTRYINDEX, "node");
	lua_rawgeti(L_context, -1, tableIndex);

	// table[key] = subItemIndex;
	lua_pushlstring(L_context, key, strlen(key));
	lua_pushinteger(L_context, subItemIndex);
	lua_rawset(L_context, -3);

	lua_pop(L_context,2);
}

int main(void) {
	tree_init();

    yyparse();

	tree_destroy();
	printf("\n");
    return 0;
}

static int lparse(lua_State* L){
	L_context = L;
	yyparse();
	L_context = NULL;
}

static int get(lua_State* L) {
    lua_getfield(L, LUA_REGISTRYINDEX, "node");
	return 1;
}

static int getRoot(lua_State* L) {
    lua_getfield(L, LUA_REGISTRYINDEX, "root");
	return 1;
}

static const struct luaL_Reg l_methods[] = {
    { "get" , get},
    { "getRoot" , getRoot},
    { "parse" , lparse},
    {NULL, NULL},
};

int luaopen_decoParser(lua_State* L) {
    luaL_checkversion(L);
	indexCount = 0;

	lua_newtable(L);
    lua_setfield(L, LUA_REGISTRYINDEX, "node");

    luaL_newlib(L, l_methods);

	tree_init();
    return 1;
}

