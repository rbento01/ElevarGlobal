try 
        Dim no as Object = HttpContext.Current.Request.QueryString("no")
        Dim nome as Object = HttpContext.Current.Request.QueryString("nome")
        Dim codigo as Object = HttpContext.Current.Request.QueryString("codigo")
        Dim descricao as Object = HttpContext.Current.Request.QueryString("descricao")
        Dim local as Object = HttpContext.Current.Request.QueryString("local")
        Dim email as Object = HttpContext.Current.Request.QueryString("email")
        Dim email2 as Object = HttpContext.Current.Request.QueryString("email2")
        Dim id as Object = HttpContext.Current.Request.QueryString("id")
       
        Dim lInsert as String
        'webcontrollib.cdata.updatedata("Insert into u_logs (mensagem, date) values ('Erro novo jjjjjjjjjjjjj "", getdate())")
  
  
       lInsert = "UPDATE [dbo].[u_obras] 
                  SET   
                        no = '" + no + "',
                        nome = '" + nome + "',
                        codigo = '" + codigo + "',
                        descricao = '" + descricao + "',
                        local = '" + local + "',
                        email = '" + email +"',
                        email2 = '" + email2 + "'
                  WHERE id = '" + id + "'"
                                    
                    webcontrollib.cdata.updatedata(lInsert)
        

        return ""
    Catch ex As Exception
        webcontrollib.cdata.updatedata("Insert into u_logs (mensagem, date) values ('Erro: " + ex.Message + "', getdate())")
        return ex.Message
    End Try