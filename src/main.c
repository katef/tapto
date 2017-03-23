/*
 * Copyright 2015-2017 Katherine Flavel
 *
 * See LICENCE for the full copyright terms.
 */

#define _POSIX_C_SOURCE 200809L

#include <sys/stat.h>
#include <sys/types.h>

#include <assert.h>
#include <unistd.h>
#include <limits.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>

#include <strings.h>

#include "ast.h"
#include "out.h"

extern char *optarg;
extern int optind;

static void
plan(const char *line, int *a, int *b)
{
	assert(line != NULL);
	assert(a != NULL);
	assert(b != NULL);

	if (*b != -1) {
		fprintf(stderr, "syntax error: duplicate plan: %s\n", line);
		exit(1);
	}

	if (2 != sscanf(line, "%d..%d", a, b)) {
		fprintf(stderr, "syntax error: missing a..b\n");
		exit(1);
	}

	if (*a < 0 && *b < *a) {
		fprintf(stderr, "error: invalid plan: %d..%d\n", *a, *b);
		exit(1);
	}
}

static void
yaml(struct ast_test *test, const char *line)
{
	assert(test != NULL);

	while (test->next != NULL)
		test = test->next;

	if (!ast_line(&test->line, line)) {
		perror("ast_line");
		exit(1);
	}
}

static void
missingtests(struct ast_test **head, int a, int b)
{
	int i;
	struct ast_test *new;

	assert(head != NULL);
	assert(a <= b);

	for (i = a; i <= b; i++) {
		new = ast_test(head, AST_MISSING, NULL);
		if (new == NULL) {
			perror("ast_test");
			exit(1);
		}
	}
}

static void
starttest(struct ast_test **head, const char *line, int a, int b)
{
	struct ast_test *new;
	enum ast_status status;
	int i;
	int n;

	assert(head != NULL);
	assert(line != NULL);
	assert(b == -1 || a <= b);

	if (0 == strncmp(line, "not ", 4)) {
		line += 4;
		status = AST_NOTOK;
	} else {
		status = AST_OK;
	}

	if (1 != sscanf(line, "ok %d - %n", &i, &n)) {
		fprintf(stderr, "syntax error: expected 'ok - ': %s\n", line);
		exit(1);
	}

	line += n;

	if (i < a || (b != -1 && i > b)) {
		fprintf(stderr, "error: test %d out of order; expected %d\n", i, a);
		exit(1);
	}

	if (a < i) {
		missingtests(head, a, i - 1);
	}

	new = ast_test(head, status, line);
	if (new == NULL) {
		perror("ast_test");
		exit(1);
	}
}

static void
usage(void)
{
	fprintf(stderr, "usage: tap2xml [-d]\n");
	fprintf(stderr, "       tap2xml [-h]\n");
}

int
main(int argc, char *argv[])
{
	struct ast_test *tests;
	int a, b;
	int fold;

	fold = 0;

	{
		int c;

		while (c = getopt(argc, argv, "dh"), c != -1) {
			switch (c) {
			case 'd': fold = 1; break;

			case 'h':
				usage();
				return 0;

			default:
				usage();
				return 1;
			}
		}

		argc -= optind;
		argv += optind;
	}

/* TODO: loop through all arguments instead; can pass a set of .tap files
...but as an extension we can easily permit multiple .tap files catted together */
	if (argc != 0) {
		usage();
		return 1;
	}

	tests = NULL;

	{
		char *line, *comment;
		size_t n;

		line = NULL;
		a =  1;
		b = -1; /* no plan */
		n = 0;

		while (-1 != getline(&line, &n, stdin)) {
			line[strcspn(line, "\n")] = '\0';

			comment = strchr(line, '#');
			if (comment != NULL) {
				*comment++ = '\0';
			}

			if (comment != NULL) {
				comment += strspn(comment, " \t");

/* TODO: only if we're actually in a test */

				if (0 == strncasecmp(comment, "todo", 4)) {
					tests->status = AST_TODO;
				}

				if (0 == strncasecmp(comment, "skip", 4)) {
					tests->status = AST_SKIP;
				}

				/* TODO: add comment line anyway */
/* TODO: add as yaml line
				printf("\t<!-- %s -->\n", comment);
*/
			}

			switch (line[0]) {
			case '0': case '1': case '2': case '3':
			case '4': case '5': case '6': case '7':
			case '8': case '9':
				plan(line, &a, &b);
				continue;

			case 'n':
			case 'o':
				starttest(&tests, line, a, b);
				a++;
				continue;

			case '\v': case '\t': case '\f':
			case '\r': case '\n': case ' ':
				if (tests == NULL) {
					fprintf(stderr, "stray text: %s\n", line);
					continue;
				}

				yaml(tests, line);
				continue;
			}
		}

		if (a + 1 < b) {
			missingtests(&tests, a + 1, b);
		}

	}

	/* TODO: only if -v */
	{
		const struct ast_test *test;
		int i;

		/* TODO: print range style: 4,5,8..9 */
		for (test = tests, i = 0; test != NULL; test = test->next, i++) {
			if (test->status == AST_MISSING) {
				fprintf(stderr, "missing test %d\n", b - i);
			}
		}
	}

	if (fold) {
		struct ast_test *test, *next;

		for (test = tests; test != NULL; test = next) {
			next = test->next;

			if (next == NULL) {
				continue;
			}

			if (0 != strcmp(test->name, next->name)) {
				continue;
			}

			if (test->status != next->status) {
				continue;
			}

			if (test->line != NULL || next->line != NULL) {
				continue;
			}

			test->rep++;

			test->next = next->next;
			next = test;

			/* TODO: free next */
		}
	}

	/* TODO: for -v, warn about duplicate test names */

	xml_out(stdout, tests);

	return 0;
}

