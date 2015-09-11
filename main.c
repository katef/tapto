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

#include "ast.h"

extern char *optarg;
extern int optind;

static void
range(const char *line, int *a, int *b)
{
	assert(line != NULL);
	assert(a != NULL);
	assert(b != NULL);

	if (*a != -1) {
		fprintf(stderr, "syntax error: duplicate range: %s\n", line);
		exit(1);
	}

	if (2 != sscanf(line, "%d..%d", a, b)) {
		fprintf(stderr, "syntax error: missing a..b\n");
		exit(1);
	}

	if (*a < 0 && *b < *a) {
		fprintf(stderr, "error: invalid range: %d..%d\n", *a, *b);
		exit(1);
	}
}

static void
yaml(struct ast_test *test, const char *line)
{
	assert(test != NULL);

	if (!ast_line(&test->line, line)) {
		perror("ast_line");
		exit(1);
	}
}

static void
starttest(struct ast_test **head, const char *line, int a, int b)
{
	struct ast_test *new;
	int ok, i;
	int n;

	assert(head != NULL);
	assert(line != NULL);
	assert(a <= b);

	if (0 == strncmp(line, "not ", 4)) {
		line += 4;
		ok = 0;
	} else {
		ok = 1;
	}

	if (1 != sscanf(line, "ok %d - %n", &i, &n)) {
		fprintf(stderr, "syntax error: expected 'ok - ': %s\n", line);
		exit(1);
	}

	line += n;

	if (i != a) {
		fprintf(stderr, "error: test %d out of order; expcted %d\n", i, a);
		exit(1);
	}

	new = ast_test(head, ok, line);
	if (new == NULL) {
		perror("ast_test");
		exit(1);
	}
}

void
usage(void)
{
	fprintf(stderr, "usage: tap2xml [-d <dir>]\n");
	fprintf(stderr, "       tap2xml [-h]\n");
}

int
main(int argc, char *argv[])
{
	struct ast_test *tests;
	const char *dir;
	int a, b;

	dir = ".";

	{
		int c;

		while (c = getopt(argc, argv, "d:h"), c != -1) {
			switch (c) {
			case 'd':
				dir = optarg;
				break;

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

	{
		char *line, *comment;
		size_t n;

		line = NULL;
		a = b = -1;
		n = 0;

		while (-1 != getline(&line, &n, stdin)) {
			line[strcspn(line, "\n")] = '\0';

			comment = strchr(line, '#');
			if (comment != NULL) {
				*comment++ = '\0';
			}

			if (comment != NULL) {
/* TODO: add as yaml line */
				printf("\t<!-- %s -->\n", comment);
			}

			switch (line[0]) {
			case '0': case '1': case '2': case '3':
			case '4': case '5': case '6': case '7':
			case '8': case '9':
				range(line, &a, &b);
				continue;

			case 'n':
			case 'o':
				starttest(&tests, line, a, b);
				a++;
				continue;

			case '\v': case '\t': case '\f':
			case '\r': case '\n': case ' ':
				yaml(tests, line);
				continue;
			}
		}

		if (a < b) {
printf("missing: %d..%d\n", a, b);
		}

	}

	{
		const struct ast_test *test;
		const struct ast_line *line;

		printf("<?xml version='1.0'?>\n");
		printf("<tap xmlns='http://xml.elide.org/tap'>\n");

		/* TODO: escape XML characters */
		for (test = tests; test != NULL; test = test->next) {
			printf("\t<test status='%s' name='%s'>\n",
				test->ok? "ok" : "not ok", test->name);

			if (test->line != NULL) {
				printf("\t\t<![CDATA[");

				for (line = test->line; line != NULL; line = line->next) {
					printf("%s%s",
						line->text,
						line->next != NULL ? "\n" : "");
				}

				printf("]]>\n");
			}

			printf("\t</test>\n");
		}

		printf("</tap>\n");
	}

	{
		if (-1 == mkdir(dir, 0777) && errno != EEXIST) {
			perror(dir);
			return 1;
		}

		if (-1 == chdir(dir)) {
			perror(dir);
			return -1;
		}
	}

	return 0;
}

