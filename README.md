# sml-server-demo [![CI](https://github.com/melsman/sml-server-demo/workflows/CI/badge.svg)](https://github.com/melsman/sml-server-demo/actions)

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

Help is available by passing the `--help` command-line option.

## Previos and Future work

This code base (together with
[sml-server](https://github.com/diku-dk/sml-server)) replaces the no-longer
supported old SMLserver code [1,2], which used a bytecode interpretation approach to
serve web pages [3].

The server is currently single-threaded and future work will investigate the
possibilities for crafting a multi-threaded server.

## Authors

Copyright (c) 2022-2026 Martin Elsman, University of Copenhagen.

## License

See [LICENSE](LICENSE) (MIT License).

## References

[1] Martin Elsman and Niels Hallenberg. __Web Programming with SMLserver__. In Fifth International Symposium on Practical Aspects of Declarative Languages (PADL ‘03). New Orleans, Louisiana, USA. January 2003. [pdf](https://elsman.com/pdf/padl2003.pdf).

[2] Martin Elsman, Niels Hallenberg, and Carsten Varming. __SMLserver — A Functional Approach to Web Publishing__ (Second Edition). IT University of Copenhagen, Denmark. April, 2007. [pdf](https://elsman.com/pdf/smlserver-book-20070410.pdf).

[3] Martin Elsman and Niels Hallenberg. __A Region-Based Abstract Machine for the ML Kit__. Royal Veterinary and Agricultural University of Denmark and IT University of Copenhagen. IT University Technical Report Series. TR-2002-18. August, 2002. [pdf](https://elsman.com/pdf/kam.pdf).
