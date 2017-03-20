.include "../share/mk/top.mk"

SRC += src/ast.c
SRC += src/main.c

PROG += tapto

.for src in ${SRC:Msrc/*.c}
${BUILD}/bin/tapto: ${BUILD}/${src:R}.o
.endfor

