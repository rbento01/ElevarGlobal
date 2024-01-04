try
        Dim id as Object = HttpContext.Current.Request.QueryString("id")
        Dim codigo as Object = HttpContext.Current.Request.QueryString("codigo")
        Dim descricao as Object = HttpContext.Current.Request.QueryString("descricao")
        
       
        Dim lInsert as String
        
  
        if codigo<>"" and descricao<>""  
        lInsert = "INSERT INTO [dbo].[u_fxComp]
                        (
                            [codigo],
                            [descricao]
                        )
                    VALUES
                        (
                            
                            '" + codigo + "',
                            '" + descricao + "'
                            
                        )"       
        webcontrollib.cdata.updatedata(lInsert)
        end if

        if id<>"" and codigo="" 
        lInsert = "DELETE FROM [dbo].[u_fxComp] where id = "+ id +""     
        webcontrollib.cdata.updatedata(lInsert)
        end if

        if id<>"" and codigo<>"" and descricao<>"" 
        lInsert = "UPDATE [dbo].[u_fxComp] 
                   set 
                        [codigo] = '" + codigo + "',
                        [descricao] = '" + descricao + "'
                       where
                            id= "+id+"
                        "         
        webcontrollib.cdata.updatedata(lInsert)
        end if

        return ""
    Catch ex As Exception
        webcontrollib.cdata.updatedata("Insert into u_logs (mensagem, date) values ('Erro: " + ex.Message + "', getdate())")
        return ex.Message
    End Try