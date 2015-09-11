#ifndef AST_H
#define AST_H

struct ast_line {
	/* TODO: comment flag */
	const char *text;
	struct ast_line *next;
};

struct ast_test {
	/* TODO: "TODO" flag */
	/* TODO: store test number? */
	const char *name;
	int ok;
	struct ast_line *line;
	struct ast_test *next;
};

struct ast_line *
ast_line(struct ast_line **head, const char *text);

struct ast_test *
ast_test(struct ast_test **head, int ok, const char *name);

#endif

