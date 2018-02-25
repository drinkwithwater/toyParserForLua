.PHONY: all

TOP=/data/data/com.termux/files/home
INCLUDE_DIR=$(TOP)/skynet/3rd/lua/

CFLAGS = -g3 -O2 -rdynamic -Wall -I$(INCLUDE_DIR)
SHARED = -fPIC --shared
LDFLAGS =
# -L$(BUILD_DIR) -Wl,-rpath $(BUILD_DIR)

all: ../decoParser.so

../decoParser.so: yacc.c lex.c
	gcc $(CFLAGS) $(SHARED) $^ -o $@ $(LDFLAGS)

yacc.o: yacc.c
	gcc -c $^ -o $@

lex.o: lex.c
	gcc -I$(INCLUDE_DIR) -c $^ -o $@

yacc.c: yacc.y
	bison -y -d $^ -o $@

lex.c: lex.l
	flex -o $@ $^

clean:
	rm ../*.so
	rm -rf *.o *.a *.so
	rm yacc.c yacc.h
	rm lex.c
