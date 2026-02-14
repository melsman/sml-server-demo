## sml-server-demo [![CI](https://github.com/melsman/sml-server-demo/workflows/CI/badge.svg)](https://github.com/melsman/sml-server-demo/actions)

Demonstration of [sml-server](github.com/diku-dk/sml-server) in
concert with a few MLKit extensions and libraries:

- Quotations for writing HTML and SQL queries.

- Database connectivity using a [Postgresql client API](https://github.com/melsman/mlkit-postgresql).

- Fetching of HTTPS pages using [OpenSSL](https://github.com/melsman/mlkit-ssl-socket).

## Assumptions

A working [MLKit installation](https://github.com/melsman/mlkit). Use
`brew install mlkit` on macOS or download a binary release from the
[MLKit github site](https://github.com/melsman/mlkit).

The package manager [smlpkg](https://github.com/diku-dk/smlpkg). Use
`brew install smlpkg` on macOS or download a binary release from the
[smlpkg site](https://github.com/diku-dk/smlpkg).

A Postgresql database installation.

### Testing

To test the library, first do as follows:

    $ cd src
	$ make prepare
	$ make
    ...
    $ ./demo.exe
    HTTP/1.1 server started on port 8000
    Use C-c to exit the server loop...

Notice that, dependent on the architecture, you may need first to set the
environment variable `MLKIT_INCLUDEDIR` to something different than
the default value `/usr/share/mlkit/include/`.

You may also need to set the environment variables `SSL_INCLUDEDIR`
and `SSL_LIBDIR` to something different from the default values
`/usr/include/ssl` and `/usr/lib/ssl`. You may also need to adjust the
environment variables `POSTGRESQL_INCLUDEDIR`, which by default is set
to `/usr/include/postgresql`.

For instance, if you use `brew` under macOS, you should do as follows:

    $ cd src
	$ make prepare
    $ export MLKIT_INCLUDEDIR=/usr/local/share/mlkit/include
    $ export SSL_INCLUDEDIR=/usr/local/opt/openssl/include
    $ export SSL_LIBDIR=/usr/local/opt/openssl/lib
    $ export POSTGRESQL_INCLUDEDIR=/usr/local/include/postgresql
    $ make
    ...
    $ ./demo.exe
    HTTP/1.1 server started on port 8000
    Use C-c to exit the server loop...

It may be necessary to tweak the file
[lib/github.com/melsman/sml-server-demo/Makefile](lib/github.com/melsman/sml-server-demo/Makefile)
to specify the location of the MLKit compiler binary, the MLKit
include files, and the MLKit basis library.

## Authors

Copyright (c) 2022 Martin Elsman, University of Copenhagen.

## License

See [LICENSE](LICENSE) (MIT License).
