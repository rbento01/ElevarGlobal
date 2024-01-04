try
        Dim id as Object = HttpContext.Current.Request.QueryString("id")
       
        Dim lInsert as String
        'webcontrollib.cdata.updatedata("Insert into u_logs (mensagem, date) values ('Erro novo jjjjjjjjjjjjj "", getdate())")
  
        lInsert = "DELETE FROM [dbo].[u_eqp] WHERE id = " + id
                                    
                    webcontrollib.cdata.updatedata(lInsert)
  
        return ""
    Catch ex As Exception
        webcontrollib.cdata.updatedata("Insert into u_logs (mensagem, date) values ('Erro: " + ex.Message + "', getdate())")
        return ex.Message
    End Try