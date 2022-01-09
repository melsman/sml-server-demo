
structure Server : SERVER = struct

open Server

structure Fetch = struct

open Http
structure SS = Substring

infix |>
fun x |> f = f x

fun sendVecAll (sock, slc) =
    let val i = SSLSocket.sendVec (sock, slc)
        val len = Word8VectorSlice.length slc
    in if i < len then
         sendVecAll (sock, Word8VectorSlice.subslice(slc, i, NONE))
       else ()
    end

fun fetchRawSSL {host:string, port:int, msg:string} : string option =
    case NetHostDB.getByName host of
        NONE => NONE
      | SOME e =>
        let val addr = INetSock.toAddr (NetHostDB.addr e, port)
            val bufsz = 2048
            val sock = SSLSocket.mkAndConnect addr
            fun loop acc =
                let val v = SSLSocket.recvVec(sock, bufsz)
                    val l = Word8Vector.length v
                in if l = 0
                   then rev acc
                            |> Word8Vector.concat
                            |> Byte.bytesToString
                   else loop (v::acc)
                end
          in ( sendVecAll (sock, Byte.stringToBytes msg
                                 |> Word8VectorSlice.full )
             ; SOME (loop nil) before SSLSocket.close sock
             ) handle _ => ( SSLSocket.close sock; NONE )
          end

val fetchRaw = Fetch.fetchRaw

fun fetch (arg as {scheme,...}) =
    let fun fetch0 fetchRaw {scheme,host,port,req} =
            let val msg = Request.toString req
            in case fetchRaw {host=host,port=port,msg=msg} of
                   NONE => NONE
                 | SOME s =>
                   case Response.parse SS.getc (SS.full s) of
                       SOME(r,sl) => SOME r
                     | NONE => NONE
            end
    in case scheme of
           "http" => fetch0 fetchRaw arg
         | "https" => fetch0 fetchRawSSL arg
         | _ => NONE
    end

fun fetchUrl url =
    case Uri.parse SS.getc (SS.full url) of
        SOME (Uri.URL{scheme,host,port,path,query}, sl) =>
        let val line = {method=Request.GET,
                        uri=Uri.PATH {path=path,query=query},
                        version=Version.HTTP_1_0}
            val req = {line=line, headers=[("Host",host)],
                       body=NONE}
            val port = case port of SOME p => p
                                  | NONE => if scheme = "https"
                                            then 443
                                            else 80
        in fetch {scheme=scheme,host=host,port=port,req=req}
        end
      | _ => NONE

end (* Fetch *)
end (* Server *)
