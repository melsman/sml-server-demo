
# macos with homebrew:
POSTGRESQL_INCLUDEDIR ?= /usr/include/postgrresql
MLKIT_INCLUDEDIR ?= /usr/local/share/mlkit/include/

MLKIT ?= mlkit

SRCFILES = $(shell ls -1 *.sml *.sig)

.PHONY: all
all: demo.exe

demo.exe: demo.mlb $(SRCFILES) libsmlpq.a
	$(MLKIT) -quot -output $@ -libdirs "." -libs "smlpq,pq,m" $<

libsmlpq.a:
	MLKIT_INCLUDEDIR=$(MLKIT_INCLUDEDIR) $(MAKE) -C ../lib/github.com/melsman/mlkit-postgresql lib
	cp -p ../lib/github.com/melsman/mlkit-postgresql/libsmlpq.a $@

.PHONY: clean
clean:
	$(MAKE) -C ../lib/github.com/melsman/mlkit-postgresql clean
	$(MAKE) -C ../lib/github.com/diku-dk/sml-server clean
	find . -name 'MLB' | xargs rm -rf
	rm -rf *~ libsmlpq.a *.exe MLB
	dropdb --if-exists dbdemo

# create database
.PHONY: prepare
prepare:
	dropdb --if-exists dbdemo
	createdb dbdemo
	(cd ../pgsql && psql -f all.sql dbdemo)
