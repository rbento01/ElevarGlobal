try 
        Dim codigo as Object = HttpContext.Current.Request.QueryString("codigo")
        Dim Descricao as Object = HttpContext.Current.Request.QueryString("Descricao")
        DIM tipo as Object = HttpContext.Current.Request.QueryString("tipo")
        DIM subtipo as Object = HttpContext.Current.Request.QueryString("subtipo")
        Dim id as Object = HttpContext.Current.Request.QueryString("id")
       
        Dim lInsert as String
        'webcontrollib.cdata.updatedata("Insert into u_logs (mensagem, date) values ('Erro novo jjjjjjjjjjjjj "", getdate())")
  
  
       lInsert = "UPDATE [dbo].[u_eqp] 
                  SET   
                        codigo = '" + codigo + "',
                        Descricao = '" + Descricao + "',
                        tipo = '" + tipo + "',
                        subtipo = '" + subtipo + "'
                  WHERE id = '" + id + "'"
                                    
                    webcontrollib.cdata.updatedata(lInsert)
        

        return ""
    Catch ex As Exception
        webcontrollib.cdata.updatedata("Insert into u_logs (mensagem, date) values ('Erro: " + ex.Message + "', getdate())")
        return ex.Message
    End Try