/*-
 * See the file LICENSE for redistribution information.
 *
 * Copyright (c) 1997-2006
 *	Oracle Corporation.  All rights reserved.
 *
 * $Id: ex_access.c,v 1.3 2006/10/25 05:33:05 cjlee Exp $
 */

#include <sys/types.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
extern int getopt(int, char * const *, const char *);
#else
#include <unistd.h>
#endif

#include <db.h>

#define	DATABASE	"/tmp/ramdisk0/access.db"
int main __P((int, char *[]));
int usage __P((void));

int
main(argc, argv)
	int argc;
	char *argv[];
{
	extern int optind;
	DB *dbp;
	DBC *dbcp;
	DBT key, data;
	size_t len;
	int ch, ret, rflag;
	int i;
	char *database, *p, *t, buf[1024], rbuf[1024];
	const char *progname = "TTT";		/* Program name. */

	rflag = 0;
	while ((ch = getopt(argc, argv, "r")) != EOF)
		switch (ch) {
		case 'r':
			rflag = 1;
			break;
		case '?':
		default:
			return (usage());
		}
	argc -= optind;
	argv += optind;

	/* Accept optional database name. */
	database = *argv == NULL ? DATABASE : argv[0];

	/* Optionally discard the database. */
	if (rflag)
		(void)remove(database);

	/* Create and initialize database object, open the database. */
	if ((ret = db_create(&dbp, NULL, 0)) != 0) {
		fprintf(stderr,
		    "%s: db_create: %s\n", progname, db_strerror(ret));
		return (EXIT_FAILURE);
	}
	
	dbp->set_errfile(dbp, stderr);
	dbp->set_errpfx(dbp, progname);

	if ((ret = dbp->set_pagesize(dbp, 1024)) != 0) {
		dbp->err(dbp, ret, "set_pagesize");
		goto err1;
	}
	if ((ret = dbp->set_cachesize(dbp, 0, 32 * 1024, 0)) != 0) {
		dbp->err(dbp, ret, "set_cachesize");
		goto err1;
	}
	if ((ret = dbp->open(dbp,
	    NULL, database, NULL, DB_BTREE, DB_CREATE, 0664)) != 0) {
		dbp->err(dbp, ret, "%s: open", database);
		goto err1;
	}

	/*
	 * Insert records into the database, where the key is the user
	 * input and the data is the user input in reverse order.
	 */
	memset(&key, 0, sizeof(DBT));
	memset(&data, 0, sizeof(DBT));
	for (i=200;i<=205;i++) {
		sprintf(buf,"%018d",i);
		key.data = buf;
		sprintf(rbuf,"%018d",i+1);
		data.data = rbuf;
		data.size = key.size = strlen(buf);;

		ret = dbp->put(dbp, NULL, &key, &data, DB_NOOVERWRITE);
		if(ret) {
			fprintf(stderr, "%s [%d] : ret %d\n",(char *) __FUNCTION__ ,i, ret);
			exit(0);
		} else {
			fprintf(stderr, "%s [%d] : ret %d\n",(char *) __FUNCTION__ ,i, ret);
		}
	}
	printf("\n");

#if 1
	/* Initialize the key/data pair so the flags aren't set. */
	memset(&key, 0, sizeof(key));
	memset(&data, 0, sizeof(data));
	sprintf(buf,"%018d",200);
	key.data = buf;
	key.size = strlen(buf);;
	ret = dbp->get(dbp, 0 , &key, &data, 0) ;
	fprintf(stderr,"ret %d : %d\n",ret ,data.size);
	fprintf(stderr,"ret %d : %.*s\n",ret , 20,data.data);
#endif

	/* Acquire a cursor for the database. */
	if ((ret = dbp->cursor(dbp, NULL, &dbcp, 0)) != 0) {
		dbp->err(dbp, ret, "DB->cursor");
		goto err1;
	}

#if 0
	/* Initialize the key/data pair so the flags aren't set. */
	memset(&key, 0, sizeof(key));
	memset(&data, 0, sizeof(data));
	sprintf(buf,"%018d",200);
	key.data = buf;
	data.data = rbuf;
	key.size = strlen(buf);;
	data.size = BUFSIZ;
	ret = dbcp->c_get(dbcp, 0 , &key, &data, 0) ;
	fprintf(stderr,"ret %d : \n",ret );
	fprintf(stderr,"ret %d : %.*s\n",ret , 20,rbuf);
#endif

	/* Initialize the key/data pair so the flags aren't set. */
	memset(&key, 0, sizeof(key));
	memset(&data, 0, sizeof(data));
	/* Walk through the database and print out the key/data pairs. */
	i = 0;
	while ((ret = dbcp->c_get(dbcp, &key, &data, DB_NEXT)) == 0)
		printf("[%d] %.*s : %.*s\n", i++,
		    (int)key.size, (char *)key.data,
		    (int)data.size, (char *)data.data);
	if (ret != DB_NOTFOUND) {
		dbp->err(dbp, ret, "DBcursor->get");
		goto err2;
	}

	/* Initialize the key/data pair so the flags aren't set. */
	memset(&key, 0, sizeof(key));
	memset(&data, 0, sizeof(data));
	for (i=200;i<=205;i++) {
		sprintf(buf,"%018d",i);
		key.data = buf;
		sprintf(rbuf,"%018d",i+1);
		data.data = rbuf;
		data.size = key.size = strlen(buf);

		ret = dbp->del(dbp, NULL, &key, 0);
	}
	printf("\n");

	/* Initialize the key/data pair so the flags aren't set. */
	memset(&key, 0, sizeof(key));
	memset(&data, 0, sizeof(data));
	/* Walk through the database and print out the key/data pairs. */
	i = 0;
	printf("\nNEW............\n");
	while ((ret = dbcp->c_get(dbcp, &key, &data, DB_NEXT)) == 0)
		printf("[%d] %.*s : %.*s\n", i++,
		    (int)key.size, (char *)key.data,
		    (int)data.size, (char *)data.data);
	if (ret != DB_NOTFOUND) {
		dbp->err(dbp, ret, "DBcursor->get");
		goto err2;
	}

	/* Close everything down. */
	if ((ret = dbcp->c_close(dbcp)) != 0) {
		dbp->err(dbp, ret, "DBcursor->close");
		goto err1;
	}
	if ((ret = dbp->close(dbp, 0)) != 0) {
		fprintf(stderr,
		    "%s: DB->close: %s\n", progname, db_strerror(ret));
		return (EXIT_FAILURE);
	}
	return (EXIT_SUCCESS);

err2:	(void)dbcp->c_close(dbcp);
err1:	(void)dbp->close(dbp, 0);
	return (EXIT_FAILURE);
}

int
usage()
{
	(void)fprintf(stderr, "usage: ex_access [-r] [database]\n");
	return (EXIT_FAILURE);
}
