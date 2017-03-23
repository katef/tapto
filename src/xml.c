/*
 * Copyright 2015-2017 Katherine Flavel
 *
 * See LICENCE for the full copyright terms.
 */

#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

#include "ast.h"
#include "out.h"

static int
escputc(int c, FILE *f)
{
	size_t i;

	const struct {
		int c;
		const char *s;
	} a[] = {
		{ '&',  "&amp;"  },
		{ '\"', "&quot;" },
		{ '\'', "&#x27;" },
		{ '<',  "&#x3C;" },
		{ '>',  "&#x3E;" },

		{ '\f', "&#x0C;" },
		{ '\n', "&#x0A;" },
		{ '\r', "&#x0D;" },
		{ '\t', "&#x09;" },
		{ '\v', "&#x0B;" }
	};

	assert(f != NULL);

	for (i = 0; i < sizeof a / sizeof *a; i++) {
		if (a[i].c == c) {
			return fputs(a[i].s, f);
		}
	}

	if (!isprint((unsigned char) c)) {
		return fprintf(f, "&#x%X;", (unsigned char) c);
	}

	return putc(c, f);
}

static int
escputs(const char *s, FILE *f)
{
	const char *p;
	int r;

	assert(f != NULL);
	assert(s != NULL);

	for (p = s; *p != '\0'; p++) {
		r = escputc(*p, f);
		if (r < 0) {
			return -1;
		}
	}

	return 0;
}

void
xml_out(FILE *f, const struct ast_test *tests)
{
	const struct ast_test *test;
	const struct ast_line *line;
	unsigned int n;

	assert(f != NULL);
	assert(tests != NULL);

	fprintf(f, "<?xml version='1.0'?>\n");
	fprintf(f, "<tap xmlns='http://xml.elide.org/tap'>\n");

	/* TODO: escape XML characters */
	for (test = tests, n = 1; test != NULL; test = test->next, n++) {
		fprintf(f, "\t<test status='%s'",
			ast_status(test->status));

		fprintf(f, " n='%u'", n);

		if (test->rep > 1) {
			fprintf(f, " rep='%u'", test->rep);
		}

		if (test->name != NULL) {
			fprintf(f, " name='");
			escputs(test->name, f);
			fprintf(f, "'");
		}

		fprintf(f, "%s>\n", test->line != NULL ? "" : "/");

		if (test->line == NULL) {
			continue;
		}

		fprintf(f, "<![CDATA[");

		for (line = test->line; line != NULL; line = line->next) {
			fprintf(f, "%s%s",
				line->text,
				line->next != NULL ? "\n" : "");
		}

		fprintf(f, "]]></test>\n");
	}

	fprintf(f, "</tap>\n");
}

