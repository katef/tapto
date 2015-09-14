#ifndef AST_H
#define AST_H

enum ast_status {
	AST_OK,
	AST_NOTOK
	/* TODO: "missing" flag */
	/* TODO: "TODO" flag */
	/* TODO: "skip" flag */
};

struct ast_line {
	/* TODO: comment flag */
	const char *text;
	struct ast_line *next;
};

struct ast_test {
	const char *name;
	enum ast_status status;
	struct ast_line *line;
	struct ast_test *next;
};

struct ast_line *
ast_line(struct ast_line **head, const char *text);

struct ast_test *
ast_test(struct ast_test **head, int ok, const char *name);

#endif

