structure Page = struct

  fun return ctx t s =
      let val page =
              String.concat ["<html><head><title>", t, "</title></head>",
                             "<body><h2>",t,"</h2>",
                             s,
                             "<hr />",
                             "<p>",
                             "<span style='float:left'><i><a href='/'>Index page</a></span>",
                             "<span style='float:right'><a href='/'><img height=40 src='/images/poweredby_smlserver.svg' /></a></span>",
                             "</p>",
                             "</body></html>"]
      in Server.Resp.sendHtmlOK ctx page
      end

end
