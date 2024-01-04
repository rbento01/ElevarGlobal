try
        Dim nomeContacto as Object = HttpContext.Current.Request.QueryString("nomeContacto")
        Dim noContacto as Object = HttpContext.Current.Request.QueryString("noContacto")
        DIM U_RESPCL as Object = HttpContext.Current.Request.QueryString("U_RESPCL")
        DIM U_RESPCLTL as Object = HttpContext.Current.Request.QueryString("U_RESPCLTL")
        DIM U_RESPCLEM as Object = HttpContext.Current.Request.QueryString("U_RESPCLEM")
        DIM codigo as Object = HttpContext.Current.Request.QueryString("codigo")
        DIM vendedor as Object = HttpContext.Current.Request.QueryString("vendedor")
        DIM novend as Object = HttpContext.Current.Request.QueryString("novend")
        DIM novo as Object = HttpContext.Current.Request.QueryString("novo")
       
        Dim lInsert as String
        'webcontrollib.cdata.updatedata("Insert into u_logs (mensagem, date) values ('Erro novo jjjjjjjjjjjjj "", getdate())")
  
        if novo = 0 then
            lInsert = "INSERT INTO [dbo].[ng]
                                    (
                                        [nocontacto]
                                        ,[contacto]
                                        ,[codigo]
                                        ,[vendedor]
                                        ,[novend]
                                        ,[ngstamp]
                                    )
                                VALUES
                                    (
                                        
                                        '" + noContacto +"'
                                        ,'" + nomeContacto + "'
                                        ,'" + codigo + "'
                                        ,'" + vendedor + "'
                                        ,'" + novend + "'
                                        ,left(newid(), 25)
                                    )"

            webcontrollib.cdata.updatedata(lInsert)
        else 
            lInsert = "INSERT INTO [dbo].[ng]
                                    (
                                        [nocontacto]
                                        ,[contacto]
                                        ,[codigo]
                                        ,[vendedor]
                                        ,[novend]
                                        ,[ngstamp]
                                    )
                                VALUES
                                    (
                                        
                                        '" + noContacto +"'
                                        ,'" + nomeContacto + "'
                                        ,'" + codigo + "'
                                        ,'" + vendedor + "'
                                        ,'" + novend + "'
                                        ,left(newid(), 25)
                                    )
                        INSERT INTO [dbo].[em]
                                    (
                                        [no]
                                        ,[nome]
                                        ,[u_respcl]
                                        ,[u_respcltl]
                                        ,[U_RESPCLEM]
                                        ,[emstamp]
                                    )
                                VALUES
                                    (
                                        '" + noContacto +"'
                                        ,'" + nomeContacto + "'
                                        ,'" + U_RESPCL + "'
                                        ,'" + U_RESPCLTL + "'
                                        ,'" + U_RESPCLEM + "'
                                        ,left(newid(), 25)
                                    )"
                                    
            webcontrollib.cdata.updatedata(lInsert)
        end if
        return ""
    Catch ex As Exception
        webcontrollib.cdata.updatedata("Insert into u_logs (mensagem, date) values ('Erro: " + ex.Message + "', getdate())")
        return ex.Message
    End Try