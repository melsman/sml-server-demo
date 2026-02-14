## sml-server-demo [![CI](https://github.com/melsman/sml-server-demo/workflows/CI/badge.svg)](https://github.com/melsman/sml-server-demo/actions)

Demonstration of [sml-server](https://github.com/diku-dk/sml-server) in
concert with a few MLKit extensions and libraries:

- Quotations for writing HTML and SQL queries.

- Database connectivity using a Postgresql client API ([mlkit-postgresql](https://github.com/melsman/mlkit-postgresql)).

- Fetching of HTTPS pages using OpenSSL ([mlkit-ssl-socket](https://github.com/melsman/mlkit-ssl-socket)).

## Assumptions

A working [MLKit installation](https://github.com/melsman/mlkit). You may
download a binary release from the [MLKit Github site](https://github.com/melsman/mlkit).

The package manager [smlpkg](https://github.com/diku-dk/smlpkg). Use
`brew install smlpkg` on macOS or download a binary release from the
[smlpkg site](https://github.com/diku-dk/smlpkg).

A Postgresql database installation.

For details, see the [Github Action file](.github/workflows/main.yml).

### Testing

To test the web server, first do as follows:

    $ cd src
	$ make prepare
	$ make
    ...
    $ ./demo.exe
    HTTP/1.1 server started on port 8000
    Use C-c to exit the server loop...

Now, request the location http://localhost:8000 using your favorite browser.

## Future work

The server is currently single-threaded.

## Authors

Copyright (c) 2022-2026 Martin Elsman, University of Copenhagen.

## License

See [LICENSE](LICENSE) (MIT License).
