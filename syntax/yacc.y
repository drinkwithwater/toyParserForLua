%{
    #include <stdio.h>
	#include <lua.h>
	#include <lauxlib.h>
    #include "yacc.h"
	lua_State* L_context=NULL;		// lua state when parsing
	const char* inputStr=NULL;			// pointer for parsing string

	int col = 1;
	int row = 1;

    int yylex(void);
    void yyerror(char *);


	int new_table();
	int new_obj(char* type, char* subType);
	void list_push(int listIndex, int childListIndex);
	void table_set(int tableIndex, char * key, int subItemIndex);
	void set_root(int tableIndex);

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

	SRR ">>"
	SLL "<<"
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

%token NAME STRING NUMBER
%token DOT3 DOT2
%token TRUE FALSE NIL
%token COMMENT DECO_PREFIX DECO_SUFFIX DECO_DECLARE DECO_EMBED

%left EQ NE LE GE GT LT
%left ADD SUB
%left MUL DIV MOD
%left POWER
%left BITAND BITOR
%left SHARP
%left NOT BITNOT

%%

chunk : block { set_root($1); }

block : stmt_list { $$=$1; }

stmt_list : { $$=new_obj("stmt_list",NULL); }
    | stmt_list stmt {
		list_push($1, $2);
		$$=$1;
	}

stmt : DECO_DECLARE {
		 int tableIndex = new_obj("stmt", "deco_declare");
		 $$ = tableIndex;
		 table_set(tableIndex, "buffer", $1);
	 }
	| DECO_EMBED {
		 int tableIndex = new_obj("stmt", "deco_embed");
		 $$ = tableIndex;
		 table_set(tableIndex, "buffer", $1);
	 }
    | stmt SEMICOLON { $$ = $1; }
    | BREAK {
		$$ = new_obj("stmt", "break");
	}
	| DO block END {
		int tableIndex = new_obj("stmt", "do");
		$$ = tableIndex;
		table_set(tableIndex, "block", $2);
	}
    | for_head DO block END {
		int tableIndex = new_obj("stmt", "for");
		$$ = tableIndex;
		table_set(tableIndex, "head", $1);
		table_set(tableIndex, "block", $3);
	}
    | while_head DO block END {
		int tableIndex = new_obj("stmt", "while");
		$$ = tableIndex;
		table_set(tableIndex, "head", $1);
		table_set(tableIndex, "block", $3);
	}
    | local_stmt { $$ = $1; }
    | DECO_PREFIX local_stmt { table_set($2, "deco_buffer", $1); $$ = $2; }
    | local_stmt DECO_SUFFIX { table_set($1, "deco_buffer", $2); $$ = $1; }

	| assign_stmt { $$ = $1; }
	| DECO_PREFIX assign_stmt { table_set($2, "deco_buffer", $1); $$ = $2; }
	| assign_stmt DECO_SUFFIX { table_set($1, "deco_buffer", $2); $$ = $1; }

    | function_stmt { $$ = $1; }
	| DECO_PREFIX function_stmt { table_set($2, "deco_buffer", $1); $$ = $2; }
	| function_stmt DECO_SUFFIX { table_set($1, "deco_buffer", $2); $$ = $1; }

    | function_call { $$ = $1; }
    | if_stmt { $$ = $1; }
    | ret_stmt { $$ = $1; }

assign_stmt : var_list EQA expr_list {
			int tableIndex = new_obj("stmt", "assign");
			$$ = tableIndex;
			table_set(tableIndex, "var_list", $1);
			table_set(tableIndex, "expr_list", $3);
		}

ret_stmt : RETURN expr_list {
		 int tableIndex = new_obj("stmt", "return");
		 $$ = tableIndex;
		 table_set(tableIndex, "expr_list", $2);
	 }
	| RETURN {
		$$ = new_obj("stmt","return");
	}

local_stmt : LOCAL name_list {
		 int tableIndex = new_obj("stmt","local");
		 $$ = tableIndex;
		 table_set(tableIndex, "name_list", $2);
	   }
	| LOCAL name_list EQA expr_list {
		 int tableIndex = new_obj("stmt","local");
		 $$ = tableIndex;
		 table_set(tableIndex, "name_list", $2);
		 table_set(tableIndex, "expr_list", $4);
	}
	| LOCAL FUNCTION name LEFT_PAREN argv RIGHT_PAREN block END{
		 int tableIndex = new_obj("stmt","local");
		 $$ = tableIndex;
		 table_set(tableIndex, "name", $3);
		 table_set(tableIndex, "argv", $5);
		 table_set(tableIndex, "block", $7);
	}

while_head :
	WHILE LEFT_PAREN expr RIGHT_PAREN { $$ = $3; }
	| WHILE expr { $$ = $2; }

for_head : FOR name_list IN expr_list {
		 int tableIndex = new_obj("for_head","in");
		 $$ = tableIndex;
		 table_set(tableIndex, "name_list", $2);
		 table_set(tableIndex, "expr_list", $4);
	}
	| FOR name EQA expr_list {
		 int tableIndex = new_obj("for_head","eqa");
		 $$ = tableIndex;
		 table_set(tableIndex, "name", $2);
		 table_set(tableIndex, "expr_list", $4);
	}

function_stmt : FUNCTION var_function LEFT_PAREN argv RIGHT_PAREN block END {
				 int tableIndex = new_obj("stmt","function");
				 $$ = tableIndex;
				 table_set(tableIndex, "var_function", $2);
				 table_set(tableIndex, "argv", $4);
				 table_set(tableIndex, "block", $6);
			  }

name_dot_list : name {
		int tableIndex = new_obj("name_dot_list",NULL);
		$$ = tableIndex;
		list_push(tableIndex,$1);
	}
	| name_dot_list DOT name {
		list_push($1, $3);
		$$ = $1;
	}

var_function : name_dot_list {
				 int tableIndex = new_obj("var_function","var");
				 $$ = tableIndex;
				 table_set(tableIndex, "name_dot_list", $1);
			 }
			 | name_dot_list COLON name {
				 int tableIndex = new_obj("var_function",":name");
				 $$ = tableIndex;
				 table_set(tableIndex, "name_dot_list", $1);
				 table_set(tableIndex, "name", $3);
			 }

function_lambda : FUNCTION LEFT_PAREN argv RIGHT_PAREN block END{
			 int tableIndex = new_obj("function_lambda",NULL);
			 $$ = tableIndex;
			 table_set(tableIndex, "argv", $3);
			 table_set(tableIndex, "block", $5);
		}

elseif_item : ELSEIF expr THEN block{
			int tableIndex = new_obj("elseif_item",NULL);
			$$ = tableIndex;
			table_set(tableIndex, "expr", $2);
			table_set(tableIndex, "block", $4);
		}

elseif_list : { $$=new_obj("elseif_list",NULL); }
	| elseif_list elseif_item {
		list_push($1, $2);
		$$ = $1;
	}
if_stmt : IF expr THEN block elseif_list END {
			int tableIndex = new_obj("stmt","if");
			$$ = tableIndex;
			table_set(tableIndex, "expr", $2);
			table_set(tableIndex, "block", $4);
			table_set(tableIndex, "elseif_list", $5);
		}
    | IF expr THEN block elseif_list ELSE block END {
			int tableIndex = new_obj("stmt","if");
			$$ = tableIndex;
			table_set(tableIndex, "expr", $2);
			table_set(tableIndex, "block", $4);
			table_set(tableIndex, "elseif_list", $5);
			table_set(tableIndex, "else_block", $7);
		}

var_list : var {
		 int listIndex = new_obj("var_list",NULL);
		 $$ = listIndex;
		 list_push(listIndex, $1);
	 }
    | var_list COMMA var {
		list_push($1, $3);
		$$ = $1;
	}

expr_list : expr {
		 int listIndex = new_obj("expr_list",NULL);
		 $$ = listIndex;
		 list_push(listIndex, $1);
	  }
    | expr_list COMMA expr {
		list_push($1, $3);
		$$ = $1;
	}


prefix_exp : var {
			//int tableIndex = new_obj("prefix_exp", "var");
			//$$ = tableIndex;
			//table_set(tableIndex, "var", $1);
			$$=$1;
		   }
		| function_call {
			//int tableIndex = new_obj("prefix_exp", "function_call");
			//$$ = tableIndex;
			//table_set(tableIndex, "function_call", $1);
			$$=$1;
		}
		| LEFT_PAREN expr RIGHT_PAREN {
			//int tableIndex = new_obj("prefix_exp", "(expr)");
			//$$ = tableIndex;
			//table_set(tableIndex, "expr", $2);
			$$=$2;
		}

var : name {
		int tableIndex = new_obj("var", "name");
		$$ = tableIndex;
		table_set(tableIndex, "name", $1);
	}
    | prefix_exp DOT name {
		int tableIndex = new_obj("var", ".name");
		$$ = tableIndex;
		table_set(tableIndex, "prefix_exp", $1);
		table_set(tableIndex, "name", $3);
	}
    | prefix_exp LEFT_BRACKET expr RIGHT_BRACKET {
		int tableIndex = new_obj("var", "expr");
		$$ = tableIndex;
		table_set(tableIndex, "prefix_exp", $1);
		table_set(tableIndex, "expr", $3);
	}

expr : unary_op expr {
		 int tableIndex = new_obj("expr", "uop");
		 $$=tableIndex;
		 table_set(tableIndex, "op", $1);
		 table_set(tableIndex, "expr", $2);
	 }
	| expr binary_op expr {
		int tableIndex = new_obj("expr", "bop");
		$$ = tableIndex;
		table_set(tableIndex, "expr1", $1);
		table_set(tableIndex, "op", $2);
		table_set(tableIndex, "expr2", $3);
	}
    | DOT3 {
		int tableIndex = new_obj("expr", "DOT3");
		$$ = tableIndex;
	}
    | value {
		int tableIndex = new_obj("expr", "value");
		$$ = tableIndex;
		table_set(tableIndex, "value", $1);
	}
    | table {
		int tableIndex = new_obj("expr", "table");
		$$ = tableIndex;
		table_set(tableIndex, "table", $1);
	}
    | function_lambda {
		int tableIndex = new_obj("expr", "lambda");
		$$ = tableIndex;
		table_set(tableIndex, "lambda", $1);
	}
	| prefix_exp {
		int tableIndex = new_obj("expr", "prefix_exp");
		$$ = tableIndex;
		table_set(tableIndex, "prefix_exp", $1);
	}

args : STRING {
		int tableIndex = new_obj("args", "string");
		$$ = tableIndex;
		table_set(tableIndex, "string", $1);
	 }
	| table {
		int tableIndex = new_obj("args", "table");
		$$ = tableIndex;
		table_set(tableIndex, "table", $1);
	}
	| LEFT_PAREN RIGHT_PAREN {
		$$ = new_obj("args", "()");
	}
	| LEFT_PAREN expr_list RIGHT_PAREN {
		int tableIndex = new_obj("args", "(expr_list)");
		$$ = tableIndex;
		table_set(tableIndex, "expr_list", $2);
	}

function_call : prefix_exp args {
			  int tableIndex = new_obj("stmt", "function_call");
			  $$ = tableIndex;
			  table_set(tableIndex, "prefix_exp", $1);
			  table_set(tableIndex, "args", $2);
		  }
	| prefix_exp COLON name args {
		  int tableIndex = new_obj("stmt","function_call");
		  $$ = tableIndex;
		  table_set(tableIndex, "prefix_exp", $1);
		  table_set(tableIndex, "name", $3);
		  table_set(tableIndex, "args", $4);
	}

unary_op: NOT { $$ = new_obj("uop", "not"); }
    | SUB { $$ = new_obj("uop","-"); }
    | SHARP { $$ = new_obj("uop","#"); }
    | BITNOT { $$ = new_obj("uop","~"); }

binary_op: OR  { $$ = new_obj("bop","or"); }
	| AND { $$ = new_obj("bop","and"); }
    | ADD { $$ = new_obj("bop","+"); }
    | SUB { $$ = new_obj("bop","-"); }
    | MUL { $$ = new_obj("bop","*"); }
    | DIV { $$ = new_obj("bop","/"); }
    | MOD { $$ = new_obj("bop","%"); }
    | POWER { $$ = new_obj("bop","^"); }
    | SRR { $$ = new_obj("bop",">>"); }
    | SLL { $$ = new_obj("bop","<<"); }
    | EQ { $$ = new_obj("bop","=="); }
    | NE { $$ = new_obj("bop","~="); }
    | LE { $$ = new_obj("bop","<="); }
    | GE { $$ = new_obj("bop",">="); }
    | GT { $$ = new_obj("bop",">"); }
    | LT { $$ = new_obj("bop","<"); }
    | BITOR { $$ = new_obj("bop","|"); }
    | BITAND { $$ = new_obj("bop","&"); }
    | BITNOT { $$ = new_obj("bop","~"); }
    | DOT2 { $$ = new_obj("bop",".."); }

value : STRING {
		  int tableIndex=new_obj("value","string");
		  $$ = tableIndex;
		  table_set(tableIndex, "value", $1);
	  }
	| NUMBER {
		int tableIndex=new_obj("value","number");
		$$ = tableIndex;
		table_set(tableIndex, "value", $1);
	}
	| TRUE {$$=new_obj("value","true");}
	| FALSE {$$=new_obj("value","false");}
	| NIL {$$=new_obj("value","nil");}


argv : {$$=new_obj("argv","()");}
	| DOT3 {$$ = new_obj("argv","(...)");}
	| name_list {
		int tableIndex = new_obj("argv","list");
		$$ = tableIndex;
		table_set(tableIndex,"name_list", $1);
	}
	| name_list COMMA DOT3 {
		int tableIndex = new_obj("argv","list,...");
		$$ = tableIndex;
		table_set(tableIndex, "name_list", $1);
	}

name_list : name {
		int tableIndex = new_obj("name_list",NULL);
		$$ = tableIndex;
		list_push(tableIndex,$1);
	}
	| name_list COMMA name {
		list_push($1, $3);
		$$ = $1;
	}

name : NAME {
	   int tableIndex = new_obj("name", NULL);
	   $$ = tableIndex;
	   table_set(tableIndex, "name", $1);
   }

table : LEFT_BRACE RIGHT_BRACE { $$=new_obj("key_value_list", NULL); }
	| LEFT_BRACE key_value_list RIGHT_BRACE { $$=$2; }
	| LEFT_BRACE key_value_list COMMA RIGHT_BRACE { $$=$2; }

key_value_list : key_value {
		int tableIndex = new_obj("key_value_list",NULL);
		$$ = tableIndex;
		list_push(tableIndex, $1);
	}
	| key_value_list COMMA key_value {
		list_push($1, $3);
		$$=$1;
	}

key_value : name EQA expr {
		  int tableIndex = new_obj("kv","name=expr");
		  $$ = tableIndex;
		  table_set(tableIndex, "name", $1);
		  table_set(tableIndex, "expr", $3);
	  }
	| expr {
		  int tableIndex = new_obj("kv","name=expr");
		  $$ = tableIndex;
		  table_set(tableIndex, "expr", $1);
	}
	| LEFT_BRACKET expr RIGHT_BRACKET EQA expr {
		  int tableIndex = new_obj("kv","[value]=expr");
		  $$ = tableIndex;
		  table_set(tableIndex, "value", $2);
		  table_set(tableIndex, "expr", $5);
	}


%%

void yyerror(char *s) {
    fprintf(stderr, "row=%d, col=%d %s\n", row, col, s);
}


void set_root(int tableIndex){
	int index = luaL_len(L_context, -1) + 1;
	lua_pushinteger(L_context, tableIndex);
	lua_rawseti(L_context, -2, index);
}

int lua_new_stmt(char* type){
	int index = luaL_len(L_context, -1) + 1;
	// stmtTable = {}
	lua_newtable(L_context);

	// stmtTable.__type=type
	lua_pushlstring(L_context,"__type",6);
	lua_pushlstring(L_context,type,strlen(type));
	lua_rawset(L_context, -3);

	// node[index] = stmtTable
	lua_rawseti(L_context, -2, index);
	return index;
}

int new_obj(char* type, char* subType){
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

	//obj.__col = col;
	lua_pushlstring(L_context,"__col",5);
	lua_pushinteger(L_context,col);
	lua_rawset(L_context, -3);

	//obj.__row = row;
	lua_pushlstring(L_context,"__row",5);
	lua_pushinteger(L_context,row);
	lua_rawset(L_context, -3);

	// node[index] = obj
	lua_rawseti(L_context, -2, index);
	return index;
}

int new_table(){
	int index = luaL_len(L_context, -1) + 1;
	lua_newtable(L_context);
	lua_rawseti(L_context, -2, index);
	return index;
}

void list_push(int listIndex, int childListIndex){
	lua_rawgeti(L_context, -1, listIndex);

	// list[#list+1] =  childListIndex
	int index = luaL_len(L_context, -1) + 1;
	lua_pushinteger(L_context, childListIndex);
	lua_rawseti(L_context, -2, index);

	lua_pop(L_context,1);
}

void table_set(int tableIndex, char* key, int subItemIndex){
	lua_rawgeti(L_context, -1, tableIndex);

	// table[key] = subItemIndex;
	lua_pushlstring(L_context, key, strlen(key));
	lua_pushinteger(L_context, subItemIndex);
	lua_rawset(L_context, -3);

	lua_pop(L_context,1);
}

static int lparse(lua_State* L){
	L_context = L;
	size_t size = 0;
	col = 1;
	row = 1;
	// row = luaL_checkinteger(L, 1);
	inputStr = luaL_checklstring(L, 1, &size);
	yyparse();
	inputStr = NULL;
	L_context = NULL;
	return 0;
}

static const struct luaL_Reg l_methods[] = {
    { "parse" , lparse},
    {NULL, NULL},
};

int luaopen_decoParser(lua_State* L) {
    luaL_checkversion(L);
	indexCount = 0;

    luaL_newlib(L, l_methods);

    return 1;
}

