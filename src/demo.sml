
local

structure FormvarService : SERVICE = struct

  structure FV = FormVar

  fun send path ctx =
    Page.return ctx "Checking Form Variables"
     (Quot.toString
     `This example serves to demonstrate a flexible technique for
      form-variable checking.

      <form method=post action=^(path)/chk>
      <table>
      <tr><td>Type an integer <td><input type=text name=int>
      <tr><td>Type a positive integer <td><input type=text name=nat>
      <tr><td>Type a real <td><input type=text name=real><p>
      <tr><td>Type a string <td><input type=text name=str><p>
      <tr><td>Type a positive integer in the range [2,...,10] <td><input type=text name=range><p>
      <tr><td>Type an email <td><input type=text name=email><p>
      <tr><td>Type a name <td><input type=text name=name><p>
      <tr><td>Type a login <td><input type=text name=login><p>
      <tr><td>Type a phone number <td><input type=text name=phone><p>
      <tr><td>Type an URL <td><input type=text name=url><p>
      <tr><td>Choose sex <td><select name=sex>
      <option value="Female">Female</option>
      <option value="Male">Male</option>
      <option selected value="Unknown">Unknown</option>
      </select>
      </table>
      <input type=submit value="Submit Entry">
      </form>`)

  fun chk path ctx =
    let (* Collect All Errors in one final Error Page *)
        val sexEnum = ["Female","Male","Unknown"]
        val errs  = FV.emptyErr ctx
        val i     = FV.getInt           ("int",   "integer",          errs)
        val n     = FV.getNat           ("nat",   "positive integer", errs)
        val r     = FV.getReal          ("real",  "floating point",   errs)
        val str   = FV.getString        ("str",   "string",           errs)
        val range = FV.getIntRange 2 10 ("range", "range",            errs)
        val email = FV.getEmail         ("email", "an email",         errs)
        val name  = FV.getName          ("name",  "first name",       errs)
        val login = FV.getLogin         ("login", "personal login",   errs)
        val phone = FV.getPhone         ("phone", "Work Phone",       errs)
        val url   = FV.getUrl           ("url",   "Web page URL",     errs)
        val sex   = FV.getEnum sexEnum  ("sex",   "your sex",         errs)
        val _ = FV.anyErrors errs Page.return
    in
      Page.return ctx "Result of Checking Form Variables"
      (Quot.toString
       `You provided the following information:<p>

        The integer: ^(Int.toString i)<p>
        The positive integer: ^(Int.toString n)<p>
        The real: ^(Real.toString r)<p>
        The string: ^str<p>
        The range value: ^(Int.toString range)<p>
        The email is: ^email<p>
        The name is: ^name<p>
        The login is: ^login<p>
        The phone number is: ^phone<p>
        The URL is: ^url<p>
        The Sex is: ^sex<p>`
       )
    end

  fun service (path:path) : service_instance =
      {name = SOME "Checking form variables",
       handler = fn ["chk"] => chk path
                  | _ => send path}

end

structure GuestService : SERVICE = struct

  structure FV = FormVar
  structure Db = PgDb

  infix ^^
  fun a ^^ b = Quot.concat[a,b]

  fun mkForm path =
    `<form method=post action=^(path)/add>
       <table>
         <tr><td valign=top colspan=3>New comment<br>
             <textarea name=c cols=65 rows=3
                wrap=virtual>Fill in...</textarea></tr>
         <tr><td>Name<br><input type=text size=25 name=n>
             <td>Email<br><input type=text size=25 name=e>
             <td><br><input type=submit value="Add">
         </tr>
        </table>
       </form>`

  fun layoutRow (f,acc) =
      case (f "comments", f "name", f "email") of (c, n, e) =>
          (`<li> <i>^(c)</i>
            -- <a href="mailto:^(e)">^(n)</a>
            <p>` ^^ acc)

  fun send path (ctx:Server.ctx) =
      let val rows = Db.fold layoutRow ``
                        `select email,name,comments
                         from guest
                         order by name`
          val q = mkForm path ^^ `<h3>Comments</h3><ul>` ^^ rows ^^ `</ul>`
      in Page.return ctx "Guest Book" (Quot.toString q)
      end handle Db.DbError m => Page.return ctx "Error on page" m

  fun add path ctx =
      let val errs = FormVar.emptyErr ctx
          val n = FormVar.getString ("n", "Name", errs)
          val c = FormVar.getString ("c", "Comment", errs)
          val e = FormVar.getEmail ("e", "Email", errs)
          val _ = FormVar.anyErrors errs Page.return
      in Db.dml `insert into guest (gid,name,email,comments)
                 values (^(Db.seqNextvalExp "guest_seq"),^(Db.qqq n),^(Db.qqq e),^(Db.qqq c))`
       ; Server.Resp.sendRedirect ctx path
      end

  fun service (path:path) : service_instance =
      {name = SOME "Guests (DB)",
       handler = fn ["add"] => add path
                  | _ => send path}

end


structure Examples = ExamplesFn (Page)
open Examples

fun sendIndex links =
    let val s =
        String.concat ("<ul>"::foldr (fn (l,a) =>
                                         "<li>"::l::"</li>"::a)
                                     ["</ul>"]
                                     links)
    in fn ctx => Page.return ctx "SMLserver demos" s
    end

val services =
    [("/time",        TimeService.service),
     ("/guess",       GuessService.service),
     ("/count",       CountService.service),
     ("/recipe",      RecipeService.service),
     ("/server",      ServerInfoService.service),
     ("/cookie",      CookieService.service),
     ("/file_upload", FileUploadService.service),
     ("/guest",       GuestService.service),
     ("/formvar",     FormvarService.service)
    ]

fun find k nil = NONE
  | find k ((x,y)::rest) = if k=x then SOME y else find k rest

fun setup (services: (path*service) list) : path -> Server.ctx -> unit =
    let val instances =
            map (fn (p,s) => (p, s p)) services
        val links =
            List.mapPartial (fn (p,i) =>
                                case #name i of
                                    SOME t => SOME ("<a href='" ^ p ^ "'>" ^ t ^ "</a>")
                                  | NONE => NONE)
                       instances
        val index = sendIndex ("<a href=recipe.html>Recipe</a>" :: links)
    in fn (path:path) =>
          case String.tokens (fn c => c = #"/") path of
              p :: ps => (case find ("/" ^ p) instances of
                              SOME {name,handler} => handler ps
                            | NONE => index)
            | _ => index
    end

val handler = setup services

fun runHandler (conn,db) =
    let val ctx = Server.recvRequest conn
        val path = Server.Req.path ctx
    in case OS.Path.ext path of
           SOME "png" => Server.Resp.sendFile ctx path
         | SOME "svg" => Server.Resp.sendFile ctx path
         | SOME "ico" => Server.Resp.sendFile ctx path
         | SOME _ => Server.Resp.sendFile ctx path      (* is it safe to send all these? *)
         | NONE => handler path ctx
    end

fun dbConnect () = PgDb.doconnect "dbname=dbdemo"

in
val () = Server.startConnect dbConnect runHandler
end
