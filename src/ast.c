#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <string.h>

#include "ast.h"

const char *
ast_status(enum ast_status status)
{
	switch (status) {
	case AST_OK:      return "ok";
	case AST_NOTOK:   return "not ok";
	case AST_MISSING: return "missing";
	case AST_TODO:    return "todo";
	case AST_SKIP:    return "skip";

	default:
		return "?";
	}
}

struct ast_line *
ast_line(struct ast_line **head, const char *text)
{
	struct ast_line **tail, *new;
	size_t z;

	assert(head != NULL);
	assert(text != NULL);

	z = strlen(text);

	new = malloc(sizeof *new + z + 1);
	if (new == NULL) {
		return NULL;
	}

	new->text = strcpy((char *) new + sizeof *new, text);

	for (tail = head; *tail != NULL; tail = &(*tail)->next)
		;

	new->next = *tail;
	*tail = new;

	return new;
}

struct ast_test *
ast_test(struct ast_test **head, enum ast_status status, const char *name)
{
	struct ast_test **tail, *new;

	assert(head != NULL);

	new = malloc(sizeof *new +
		(name == NULL ? 0 : strlen(name) + 1));
	if (new == NULL) {
		return NULL;
	}

	if (name == NULL) {
		new->name = NULL;
	} else {
		new->name = strcpy((char *) new + sizeof *new, name);
	}

	new->rep    = 1;
	new->line   = NULL;
	new->status = status;

	for (tail = head; *tail != NULL; tail = &(*tail)->next)
		;

	new->next = *tail;
	*tail = new;

	return new;
}

