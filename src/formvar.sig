(** Signature specifying structure for accessing form variables with
    support for simple multi-error reporting.

*)

signature FORM_VAR = sig

  type errs
  type 'a get = string * string * errs -> 'a

  exception AbortHandler

  val emptyErr     : Server.ctx -> errs

  val getInt       : int get
  val getNat       : int get
  val getReal      : real get
  val getString    : string get
  val getIntRange  : int -> int -> int get
  val getEmail     : string get
  val getName      : string get
  val getAddr      : string get
  val getLogin     : string get
  val getPhone     : string get
  val getUrl       : string get
  val getEnum      : string list -> string get
  val getYesNo     : string get

  val anyErrors    : errs -> (Server.ctx -> string -> string -> unit)
                     -> unit

  val errors       : errs -> quot list

end

(**

Discussion:

Checking form variables is an important part of implementing a secure
and stable web-site, but it is often a tedious job, because the same
kind of code is written in all files that verify form variables. This
module overcomes the tedious part by defining several functions that
may be used to test form variables consistently throughout a large
system.

The idea is to define a set of functions, corresponding to each type
of value used in forms. Each function is defined to access values
contained in form variables of the particular type. For instance, a
function is defined for accessing email addresses in a form. In case
the given form variable does not contain a valid email address, errors
are accumulated and can be presented to the user when all form
variables have been read. To deal with error accumulation properly,
each getter-function takes three arguments:

         (1) The name of the form-variable holding the value,
         (2) The name of the field in the form; the user may
	     be presented with an errorpage with more than one
	     error and it is important that the error message
	     refer to a given field in the form
         (3) An error container of type errs used to hold
	     the error messages sent back to the user

The functions are named getT, where T ranges over possible form
variable types (Int, Nat, Email, ...). For each collective use, when
all form variables have been checked using calls to particular getT
functions, a call to the function anyErrors can be arranged to returns
an error-page if any errors occurred and otherwise proceeds to handle
the request. When an error-page is returned, the handler is aborted by
raising the exception AbortHandler.

*)
