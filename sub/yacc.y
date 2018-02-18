%{
    #include <stdio.h>
	#include <lua.h>
	#include <lauxlib.h>
    #include "yacc.h"
	lua_State* L_context=NULL;		// lua state when parsing
	char* inputStr=NULL;			// pointer for parsing string

	int col = 1;
	int row = 1;
    int yylex(void);
    void yyerror(char *);


	int new_obj();
	void list_push(int listIndex, int childListIndex);
	void table_set(int tableIndex, char * key, int subItemIndex);
	void set_type(int tableIndex, char * value);
	void set_root(int tableIndex);

	int indexCount;

	int REF_NIL = 1;
	int REF_BOOLEAN = 2;
	int REF_NUMBER = 3;
	int REF_STRING = 4;
	int REF_FUNCTION = 5;
	int REF_CLASS  = 6;
%}

%token
    EOFF 0

    LEFT_PAREN "("
    RIGHT_PAREN ")"
    LEFT_BRACKET "["
    RIGHT_BRACKET "]"
	LEFT_BRACE "{"
	RIGHT_BRACE "}"


%token
    BITOR "|"

	SUB_GT "->"
	SUB_LT "-<"

    GT ">"
    LT "<"

    DOT "."
	COLON ":"
    EQA "="
    COMMA ","
    SEMICOLON ";"
    ;

%token VALUE_INTEGER VALUE_FLOAT VALUE_STRING
%token NIL BOOLEAN NUMBER STRING FUNCTION LIST MAP INTERFACE ENUM CLASS TUPLE
%token ID

%%

chunk : block {
		  set_root($1);
	  }

block : declare_list {
		  $$=$1;
	  }
	  | deco_type SUB_GT {
		int tableIndex = new_obj();
		$$ = tableIndex;
		set_type(tableIndex, "deco_next");
		table_set(tableIndex, "deco_type", $1);
	  }
	  | deco_type SUB_LT {
		int tableIndex = new_obj();
		$$ = tableIndex;
		set_type(tableIndex, "deco_pre");
		table_set(tableIndex, "deco_type", $1);
	  }

declare_list : declare {
		    int tableIndex = new_obj();
			$$ = tableIndex;
			list_push(tableIndex, $1);
		  }
		 | declare_list declare{
			$$ = $1;
			list_push($1, $2);
		 }

declare : INTERFACE id LEFT_BRACE key_type_list RIGHT_BRACE {
		int tableIndex = new_obj();
		$$ = tableIndex;
		set_type($$, "declare");
		table_set(tableIndex, "name", $2);
		table_set(tableIndex, "key_type_list", $4);
	 }

key_type_pair : id EQA deco_type {
				int tableIndex = new_obj();
				$$ = tableIndex;
				table_set(tableIndex, "key", $1);
				table_set(tableIndex, "value", $3);
			  }

key_type_list : key_type_pair {
				int tableIndex = new_obj();
				$$ = tableIndex;
				list_push(tableIndex, $1);
			  }
			  | key_type_list COMMA key_type_pair{
				list_push($1, $3);
				$$=$1;
			  }

deco_type : ret_type { $$=$1; }
		  | function_type { $$=$1; }
		  | class_type { $$=$1; }
		  | CLASS {
			  int tableIndex = new_obj();
			  $$=tableIndex;
			  set_type(tableIndex, "CLASS");
		  }

ret_type : single_type {$$=$1;}
		  | map_type {$$=$1;}
		  | list_type {$$=$1;}
		  | class_type {$$=$1;}


type_list : ret_type { // TODO
			int tableIndex = new_obj();
			$$ = tableIndex;
			list_push(tableIndex, $1);
		  }
		  | type_list COMMA ret_type {
			list_push($1, $3);
			$$ = $1;
		  }

single_type : NIL {
				int tableIndex=new_obj();
				$$=tableIndex;
				set_type(tableIndex,"type");
				table_set(tableIndex,"type",REF_NIL);
			}
			| BOOLEAN {
				int tableIndex=new_obj();
				$$=tableIndex;
				set_type(tableIndex,"type");
				table_set(tableIndex,"type",REF_BOOLEAN);
			}
			| NUMBER {
				int tableIndex=new_obj();
				$$=tableIndex;
				set_type(tableIndex,"type");
				table_set(tableIndex,"type",REF_NUMBER);
			}
			| STRING {
				int tableIndex=new_obj();
				$$=tableIndex;
				set_type(tableIndex,"type");
				table_set(tableIndex,"type",REF_STRING);
			}

class_type : CLASS DOT id {
			  int tableIndex = new_obj();
			  $$=tableIndex;
			  set_type(tableIndex, "type");
			  table_set(tableIndex, "type", REF_CLASS);
			  table_set(tableIndex, "name", $3);
		   }

enum_type : ENUM id {
		  }


function_type : argv DOT argv {
				  int tableIndex = new_obj();
				  $$=tableIndex;
				  set_type(tableIndex, "type");
				  table_set(tableIndex, "type", REF_FUNCTION);
				  table_set(tableIndex, "argv", $1);
				  table_set(tableIndex, "retv", $3);
			  }

argv : LEFT_PAREN type_list RIGHT_PAREN {$$=$2;}
	 | LEFT_PAREN RIGHT_PAREN {$$=new_obj();}


map_type : MAP LT single_type COMMA class_type GT {
			int tableIndex = new_obj();
			set_type(tableIndex, "map");
			$$ = tableIndex;
			table_set(tableIndex, "key_type", $3);
			table_set(tableIndex, "value_type", $5);
		 }
		 | MAP LT single_type COMMA single_type GT {
			int tableIndex = new_obj();
			set_type(tableIndex, "map");
			$$ = tableIndex;
			table_set(tableIndex, "key_type", $3);
			table_set(tableIndex, "value_type", $5);
		 }

list_type : LIST {
			int tableIndex = new_obj();
			set_type(tableIndex, "list");
			$$ = tableIndex;
		  }
		  | LIST LT class_type GT {
			int tableIndex = new_obj();
			set_type(tableIndex, "list");
			$$ = tableIndex;
			table_set(tableIndex, "node_type", $3);
		  }
		  | LIST LT single_type GT {
			int tableIndex = new_obj();
			set_type(tableIndex, "list");
			$$ = tableIndex;
			table_set(tableIndex, "node_type", $3);
		  }
		  | LIST LEFT_BRACKET VALUE_INTEGER RIGHT_BRACKET {
			int tableIndex = new_obj();
			set_type(tableIndex, "list");
			$$ = tableIndex;
			table_set(tableIndex, "size", $3);
		  }

id : ID {
	$$ = $1;
   }




%%

void yyerror(char *s) {
    fprintf(stderr, "col=%d, row=%d %s\n", col, row, s);
}

void set_root(int tableIndex){
	int index = luaL_len(L_context, -1) + 1;
	lua_pushinteger(L_context, tableIndex);
	lua_rawseti(L_context, -2, index);
}

int new_obj(){
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

void set_type(int tableIndex, char* value){
	lua_rawgeti(L_context, -1, tableIndex);

	// table.__type = value;
	lua_pushlstring(L_context, "__type", 6);
	lua_pushlstring(L_context, value, strlen(value));
	lua_rawset(L_context, -3);

	lua_pop(L_context,1);
}

static int initConstRef(lua_State* L){
	lua_pushlstring(L, "Nil", 3);
	lua_rawseti(L, -2, REF_NIL);

	lua_pushlstring(L, "Boolean", 7);
	lua_rawseti(L, -2, REF_BOOLEAN);

	lua_pushlstring(L, "Number", 6);
	lua_rawseti(L, -2, REF_NUMBER);


	lua_pushlstring(L, "String", 6);
	lua_rawseti(L, -2, REF_STRING);

	lua_pushlstring(L, "Function", 8);
	lua_rawseti(L, -2, REF_FUNCTION);

	lua_pushlstring(L, "Class", 5);
	lua_rawseti(L, -2, REF_CLASS);
}

static int lparse(lua_State* L){
	initConstRef(L);

	L_context = L;
	size_t size = 0;
	row = luaL_checkinteger(L, 1);
	inputStr = luaL_checklstring(L, 2, &size);
	yyparse();
	inputStr = NULL;
	L_context = NULL;
}

static const struct luaL_Reg l_methods[] = {
    { "parse" , lparse},
    {NULL, NULL},
};

int luaopen_sub(lua_State* L) {
    luaL_checkversion(L);
	indexCount = 0;

	lua_newtable(L);
    lua_setfield(L, LUA_REGISTRYINDEX, "node");

    luaL_newlib(L, l_methods);

    return 1;
}

