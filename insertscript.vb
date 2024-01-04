try
        Dim data as Object = HttpContext.Current.Request.QueryString("data")
        Dim hora as Object = HttpContext.Current.Request.QueryString("hora")
        Dim duracao as Object = HttpContext.Current.Request.QueryString("duracao")
        Dim vendedorNo as Object = HttpContext.Current.Request.QueryString("vendedorNo")
        Dim vendedorNome as Object = HttpContext.Current.Request.QueryString("vendedorNome")
        Dim rel as Object = HttpContext.Current.Request.QueryString("rel")
        Dim status as Object = HttpContext.Current.Request.QueryString("status")
        Dim ngstamp as Object = HttpContext.Current.Request.QueryString("ngstamp")
        Dim negocio as Object = HttpContext.Current.Request.QueryString("negocio")
       
        Dim lInsert as String
  
        lInsert = "INSERT INTO [dbo].[vi]
                                    (
                                        [data],
                                        [hora],
                                        [duracao],
                                        [VENDEDOR],
                                        [VENDNM],
                                        [rel],
                                        [NGSTATUS],
                                        [ngstamp],
                                        [negocio],
                                        [VIID]
                                    )
                                VALUES
                                    (
                                        '" + data + "',
                                        '" + hora + "',
                                        '" + duracao + "',
                                        '" + vendedorNo + "',
                                        '" + vendedorNome + "',
                                        '" + rel + "',
                                        '" + status + "',
                                        '" + ngstamp + "',
                                        '" + negocio + "',
                                        left(newid(), 25)
                                    )"
                                    
                    webcontrollib.cdata.updatedata(lInsert)
  
        return ""
    Catch ex As Exception
        webcontrollib.cdata.updatedata("Insert into u_logs (mensagem, date) values ('Erro: " + ex.Message + "', getdate())")
        return ex.Message
    End Try