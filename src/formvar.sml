
structure FormVar :> FORM_VAR = struct

  type quot = Quot.quot
  type ctx = Server.ctx

  type errs = quot list ref * ctx
  type 'a get = string * string * errs -> 'a

  val regExpMatch   = RegExp.match   o RegExp.fromString
  val regExpExtract = RegExp.extract o RegExp.fromString

  (* Update the following when Server includes a better possibility;
   * Currently, when the MissingConnection is raised, the server will
   * just continue as no keep-alive connection support is available.
   * Later, there will be a difference between MissingConnection and
   * TerminateScript, as a MissingConnection exception will have the
   * effect of going into an "accept" system call for establishing a
   * new socket connection... *)

  exception AbortHandler = Server.MissingConnection

  fun buildErrMsg es : string =
     (Quot.toString
      (`We had a problem processing your entry:
       <ul>` ^^
       Quot.concatFn (fn q => `<li>` ^^ q) (List.rev es) ^^ `
       </ul>
       Please back up using your browser, correct the form, and resubmit your entry.<p>
       Thank you.`)
      )

  fun errors ((r,_):errs) = rev (!r)

  fun anyErrors (e:errs) f =
      case errors e of
          nil => ()
        | es => ( f (#2 e) "Failure" (buildErrMsg es)
                ; raise AbortHandler
                )

  fun emptyErr (ctx:ctx) : errs = (ref nil, ctx)

  structure SS = Substring
  fun trimSS ss = SS.dropr Char.isSpace (SS.dropl Char.isSpace ss)
  fun trim s = SS.string(trimSS(SS.full s))

  fun int_of_string s =
      case Int.scan StringCvt.DEC SS.getc (trimSS(SS.full s)) of
          SOME (i,ss) =>
          if SS.size ss = 0 then SOME i
          else NONE
        | NONE => NONE

  fun real_of_string s =
      case Real.scan SS.getc (trimSS(SS.full s)) of
          SOME (i,ss) =>
          if SS.size ss = 0 then SOME i
          else NONE
        | NONE => NONE

  fun nat_of_string s =
      Option.mapPartial (fn i => if i>=0 then SOME i else NONE)
                        (int_of_string s)

  fun string_of_string s =
      if CharVector.all Char.isPrint s then SOME s
      else NONE

  fun addErr ((r,_):errs) (q:quot) : unit =
      r := (q :: !r)

  fun get (f : string -> 'a option) (typ:string) (h:string->quot) (def:'a) : 'a get =
      fn (k,l,errs) =>
         case Server.Req.getVar (#2 errs) k of
             NONE =>
             ( addErr errs `failed to find information about variable ^(l).`
             ; def )
           | SOME s =>
             case f s of
                 SOME v => v
               | NONE =>
                 let val s =
                         if s = "" then
                           "You must provide a proper " ^ typ ^
                           " for the field '" ^ l ^ "'."
                         else
                           "You must provide a valid " ^ typ ^ " for the field '" ^ l ^
                           "' - '<i>" ^ s ^ "</i>' is not one."
                 in addErr errs (h s)
                  ; def
                 end

  val getInt : int get = get int_of_string "integer" Quot.fromString 0
  val getNat : int get = get nat_of_string "positive number" Quot.fromString 0
  val getReal : real get = get real_of_string "real number" Quot.fromString 0.0

  val getString : string get = get string_of_string "string" Quot.fromString ""

  val getIntRange : int -> int -> int get =
   fn a => fn b => get (fn s => case int_of_string s of
                                    SOME i =>
                                    if a <= i andalso i <= b then SOME i
                                    else NONE
                                  | NONE => NONE)
                       ("integer in the range [" ^ Int.toString a ^ ";" ^
                        Int.toString b ^ "]") Quot.fromString a

  fun msgEmail s =
             `^s
	     <blockquote>A few examples of valid emails:
	     <ul>
	     <li>login@it-c.dk
	     <li>user@supernet.com
	     <li>FirstLastname@very.big.company.com
	     </ul></blockquote>`

  fun msgName s =
            `^s
	     <blockquote>
	     A name may contain the letters from the alphabet including: <b>'</b>, <b>\</b>,<b>-</b>,<b>æ</b>,
	     <b>ø</b>,<b>å</b>,<b>Æ</b>,<b>Ø</b>,<b>Å</b> and space.
	     </blockquote>`

  fun msgAddr s =
            `^s
	     <blockquote>
	     An address may contain digits, letters from the alphabet including:
	     <b>'</b>, <b>\\ </b>, <b>-</b>, <b>.</b>, <b>:</b>, <b>;</b>, <b>,</b>,
	     <b>æ</b>,<b>ø</b>,<b>å</b>,<b>Æ</b>,<b>Ø</b>,<b>Å</b>
	     </blockquote>`

  fun msgLogin s =
            `^s
	     <blockquote>
	     A login may contain lowercase letters from the alphabet and digits - the first
	     character must not be a digit. Special characters
	     like <b>æ</b>,<b>ø</b>,<b>å</b>,<b>;</b>,<b>^^</b>,<b>%</b> are not alowed.
	     A login must be no more than 10 characters and at least three characters.
	     </blockquote>`

  fun msgPhone s =
            `^s
	     <blockquote>
	     A telephone numer may contain numbers and letters from the alphabet
	     including <b>-</b>, <b>,</b> and <b>.</b>.
	     </blockquote>`

  fun msgURL s =
            `^s
	     <blockquote>
	     See <a href="http://www.w3.org/Addressing/">URL (Uniform Resource Locator)</a> -
	     only URL's with prefix <code>http://</code> are supported (e.g., <code>http://www.it.edu</code>).
	     </blockquote>`

  fun msgEnum enums s =
            `^s
	     You must choose among the following enumerations:
	     <blockquote>
	     ^(String.concatWith "," enums)
	     </blockquote>`

  fun email_of_string s : string option =
      if regExpMatch "[^@\t ]+@[^@.\t ]+(\\.[^@.\n ]+)+" (trim s)
      then SOME s
      else NONE

  val getEmail : string get =
      get email_of_string "email address" msgEmail ""

  fun chkEnum enums v =
      case List.find (fn enum => v = enum) enums
       of NONE => false
	| SOME _ => true

  fun get' p n m =
      get (fn s => if p s then SOME s else NONE) n m ""

  val getName = get' (regExpMatch "[a-zA-ZAÆØÅaæøå '\\-]+") "name" msgName
  val getAddr = get' (regExpMatch "[a-zA-Z0-9ÆØÅæøå '\\-.:;,]+") "address" msgAddr
  val getLogin = get' (fn login => regExpMatch "[a-z][a-z0-9\\-]+" login andalso
	                           String.size login >= 3 andalso String.size login <= 10)
                      "login" msgLogin

  val getPhone = get' (regExpMatch "[a-zA-Z0-9ÆØÅæøå '\\-.:;,]+") "phone number" msgPhone

  val getUrl = get' (regExpMatch "http://[0-9a-zA-Z/\\-\\\\._~]+(:[0-9]+)?") "URL" msgURL

  val getEnum =
   fn enums => get' (chkEnum enums) "enumeration" (msgEnum enums)

  val getYesNo =
      let val enums = ["Yes","No"]
      in get' (chkEnum ["t","f"]) "Yes/No" (msgEnum enums)
      end

end
