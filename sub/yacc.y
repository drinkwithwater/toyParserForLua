%{
    #include <stdio.h>
	#include <lua.h>
	#include <lauxlib.h>
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

    LEFT_PAREN "("
    RIGHT_PAREN ")"
    LEFT_BRACKET "["
    RIGHT_BRACKET "]"
	LEFT_BRACE "{"
	RIGHT_BRACE "}"


%token
    BITOR "|"

    SUB "-"

    GT ">"
    LT "<"

    DOT "."
	COLON ":"
    EQA "="
    COMMA ","
    SEMICOLON ";"
    ;

%token VALUE_STRING VALUE_NUMBER
%token NIL BOOLEAN NUMBER STRING FUNCTION LIST MAP INTERFACE ENUM
%token ID

%%

chunk : block { lua_set_root($1); }

block : stmt_list { $$=$1; }

stmt_list : stmt {}
			 | stmt_list stmt{
			 }

stmt : declare {}
	 | deco_type SEMICOLON {}
declare : INTERFACE id LEFT_BRACE key_type_list RIGHT_BRACE { }

key_type_pair : id EQA deco_type {}

key_type_list : key_type_pair {}
			  | key_type_list COMMA key_type_pair{}

deco_type : ret_type {}
		  | function_type {}

ret_type : single_type {}
		  | map_type {}
		  | list_type {}
		  | class_type {}


type_list : ret_type {}
		  | type_list COMMA ret_type {}

single_type : NIL { }
			| BOOLEAN { }
			| NUMBER { }
			| STRING { }
			| FUNCTION { }

class_type : id {
		   }

enum_type : Enum id {
		  }


function_type : LEFT_PAREN RIGHT_PAREN { printf("function_type\n"); }
			  | LEFT_PAREN RIGHT_PAREN COLON ret_type {  printf("function_type\n"); }
			  | LEFT_PAREN type_list RIGHT_PAREN { printf("function_type\n"); }
			  | LEFT_PAREN type_list RIGHT_PAREN COLON ret_type{ printf("function_type\n");  }

map_type : MAP LT single_type COMMA class_type GT { printf("map_type\n");  }
		 | MAP LT single_type COMMA single_type GT {  printf("map_type\n");  }

list_type : LIST {  printf("list_type\n");  }
		  | LIST LT class_type GT { printf("list_type\n"); }
		  | LIST LT single_type GT { printf("list_type\n"); }

id : ID {}




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

int luaopen_sub(lua_State* L) {
    luaL_checkversion(L);
	indexCount = 0;

	lua_newtable(L);
    lua_setfield(L, LUA_REGISTRYINDEX, "node");

    luaL_newlib(L, l_methods);

    return 1;
}

