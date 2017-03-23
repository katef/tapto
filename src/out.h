/*
 * Copyright 2015-2017 Katherine Flavel
 *
 * See LICENCE for the full copyright terms.
 */

#ifndef OUT_H
#define OUT_H

struct ast_test;

void
xml_out(FILE *f, const struct ast_test *tests);

#endif

