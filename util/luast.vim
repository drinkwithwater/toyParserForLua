if exists("b:current_syntax")
	finish
endif

"syn keyword stmt_type deco_declare stmt break do for while assign return local if

syn match number_key "\[\d\+\]"

syn match stmt_type  "\<stmt\,break\>"
syn match stmt_type  "\<stmt\,do\>"
syn match stmt_type  "\<stmt\,for\>"
syn match stmt_type  "\<stmt\,while\>"
syn match stmt_type  "\<stmt\,assign\>"
syn match stmt_type  "\<stmt\,return\>"
syn match stmt_type  "\<stmt\,local\>"
syn match stmt_type  "\<stmt\,if\>"
syn match stmt_type  "\<stmt\,deco_declare\>"
syn match stmt_type  "\<stmt\,function_call\>"
syn match stmt_type  "\<stmt\,function\>"

syn match var_type "\<var\,name\>"
syn match var_type "\<var\,\.name\>"
syn match var_type "\<var\,expr\>"

syn match  luaSpecial contained #\\[\\abfnrtv'"]\|\\[[:digit:]]\{,3}#
syn region luaString  start=+"+ end=+"+ skip=+\\\\\|\\"+ contains=luaSpecial,@Spell




"syn match syntaxElementMatch 'regexp' contain="dosth"

"syn region node_region start="{" end="}"

let b:current_syntax = "luast"

hi def link number_key Label
hi def link stmt_type Statement
hi def link var_type Identifier
hi def link luaString String
