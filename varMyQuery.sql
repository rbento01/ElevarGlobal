const varMyQuery =
			`declare @ate date, @tipo nvarchar(55),@marca varchar(5);
		set @ate=cast('`+ ate + `' as date)
		set @tipo='`+ ordenacaoInp + `'
		set @marca='`+ marca + `'
		--Até (Conf.Cliente) : Data                     
		--Ordenação : Cliente,Data Confirmação ao Cliente
		--Marca : ,DME,MM,MF,VEGA,US,WR
		-- set @ate=getdate()
		-- set @tipo='Cliente'
		-- set @marca=''
		if @tipo='Data Confirmação ao Cliente'
			select		
		    clienteBloqueado=(
			    select count(ccstamp) 
				from cc (nolock)
					where cc.no=NumCli
					and dateadd(dd,(select cl.alimite as dias from cl(nolock) where cl.no=NumCli and cl.estab=0),cc.datalc)<getdate() 
					and  (case when cc.moeda='PTE OU EURO' or cc.moeda=space(11) then (cc.edeb-cc.edebf)-(cc.ecred-cc.ecredf) else (cc.debm-cc.debfm)-(cc.credm-cc.credfm) end) > (case when cc.moeda='PTE OU EURO' or cc.moeda=space(11) then 0.010000 else 0 end)	
			    ),
			'Até : '+ convert(varchar,convert(datetime,@ate,104),104) + '   Ordenação : '+ @tipo as ordenacao,
			case when u_DTCONFCL <=@ate then nome else '___'+ltrim(rtrim(nome)) end as Nome,
			Molde,
			nref,
			convert(varchar, PrazoPedCliente, 104) as PrazoPedCliente, 
			convert(varchar, u_DTCONFCL, 104) as u_DTCONFCL, 
			LocalEntrega,
			ClienteEntrega,
			case when pronto is null then '' else convert(char,pronto,104) end as pronto,
			case when Verif is null then '' else convert(char,Verif,104) end as Verif,
			HOLD,
			ed,
			pt,
			inf,
			Class,
			atrasado,
			entregarcom,
			u_obsproc,
			codprod,
			CASE 
				WHEN ClassData <  2 THEN '1'  
				WHEN ClassData >= 2 and ClassData < 5 THEN '2'  
				WHEN ClassData >= 5 and ClassData < 10 THEN '3'  
				WHEN ClassData >= 10 THEN '4'       
			end as ClassData,
			dtembarque,
			convert(varchar,cast(dtembarque as date),104) as dataembarqueVer,
			estosck
		from
			(
					select 
						bo.nome as Nome,
						bo.no as NumCli,
						bo2.u_RefCliMl as Molde,			
						'E' + Ltrim(str(bo.obrano)) + '-' + bo3.u_familia + '-'+bo.tabela1  as nref,
						bo.dataopen as PrazoPedCliente,
						bo3.u_DTCONFCL as u_DTCONFCL, --adicionei
						case when dateadd(day, 30, bo.dataopen) < getdate() then 1 else 0 end as atrasado,				
						(case when 
							(select count(*) FROM szadrs where ltrim(rtrim(szadrsdesc)) = ltrim(rtrim(bo2.descar))) > 0
						then 
							(select local FROM szadrs where szadrsdesc=bo2.descar)  
						else 					
							(case when 
								(ltrim(rtrim(bo2.descar)) = 'Morada do Cliente' or ltrim(rtrim(bo2.descar)) = 'É definido nos parâmetros ') 
							then 
								bo2.local 
							else 
								bo2.descar 
							end) 
						end)
						as LocalEntrega,
						(					
							(case when 
								(ltrim(rtrim(bo2.descar)) = ltrim(rtrim(bo.nome)) or ltrim(rtrim(bo2.descar)) = 'Morada do Cliente' or ltrim(rtrim(bo2.descar)) = 'É definido nos parâmetros ') 
							then 
								''
							else 
								bo2.descar 
							end) 
						)
						as ClienteEntrega,

						(case when (trf65.no is not null or trf65.no=65) then 
							(select max(trfvrf.Datafim) from u_tarefas as trfvrf where trfvrf.no=80 and trfvrf.fechada=1 and trfvrf.oristamp=bo.bostamp and trfvrf.repeticao=trf95.repeticao)
						else
							(select max(trfvrf.dataini) from u_tarefas as trfvrf where trfvrf.no=80 and trfvrf.fechada=0 and trfvrf.oristamp=bo.bostamp and trfvrf.repeticao=trf95.repeticao)
						end)
						as pronto,
						(case when (trf65.no is not null or trf65.no=65) then 
							(select max(trfrec.Datafim) from u_tarefas as trfrec where trfrec.no=70 and trfrec.fechada=1 and trfrec.oristamp=bo.bostamp and trfrec.repeticao=trf95.repeticao) 
						else
							(select max(trfvrf.datafim) from u_tarefas as trfvrf where trfvrf.no=80 and trfvrf.fechada=1 and trfvrf.oristamp=bo.bostamp and trfvrf.repeticao=trf95.repeticao)
						end)
						as Verif,
						(case when exists(select bi.u_direta from bi where bi.bostamp = bo.bostamp and bi.u_direta = 1) then 1 else 0 end) as ed,
						(case when exists(select * from u_tarefas where u_tarefas.no=900 and u_tarefas.oristamp=bo.bostamp and u_tarefas.fechada=0) then 1 else 0 end) as HOLD,				
			
						(case when 1 >= (select count(*) from u_tarefas as trfP where trfP.no=65 and trfP.oristamp=bo.bostamp ) then 'T' else (case when trf65.repeticao = (select max(trfP.repeticao) from u_tarefas as trfP where trfP.no=65 and trfP.oristamp=bo.bostamp ) then 'T' else 'P' end) end) as PT,
				
						(case when exists(select * from u_tarefas as trfinf where trfinf.no=81 and trfinf.oristamp=bo.bostamp and trfinf.fechada=1 and trfinf.repeticao=trf95.repeticao) then 1 else 0 end) as inf,
						SUBSTRING(cl.tipo,0, CHARINDEX('-',cl.tipo)) as Class,
						BO3.U_ENTRCOM as entregarcom,
						bo.marca as codprod,
						bo3.u_obsproc,
						DATEDIFF(day,getdate(),BO.dataopen) as ClassData,					
						isnull((case when ltrim(rtrim(trf65.resposta))='' then 
							convert(varchar,ltrim(rtrim(trf65.datafim)),112) 
							else 
							right(ltrim(rtrim(trf65.resposta)),4)+substring(ltrim(rtrim(trf65.resposta)),4,2)+left(ltrim(rtrim(trf65.resposta)),2) 
							end),isnull(convert(varchar,trf80.dataini,112),convert(varchar,trf95.dataini,112))) 
							as dtembarque,
						(case when (trf65.no is not null or trf65.no=65) then 0 else 1 end) as estosck
					from 
						bo(nolock) 
						left join bo2(nolock) on bo.bostamp=bo2.bo2stamp 
						left join bo3(nolock) on bo.bostamp=bo3.bo3stamp 
						left join cl(nolock) on bo.no=cl.no and cl.estab=0 
						left join u_tarefas(nolock) as trf95 on bo.bostamp=trf95.oristamp and trf95.no=(case when bo.no=619 then 80 else 95 end) 
						left join u_tarefas(nolock)  as trf65 on bo.bostamp=trf65.oristamp and trf65.no=65 and trf65.repeticao=(case when trf95.repeticao is null then 0 else trf95.repeticao end)	
						left join u_tarefas(nolock)  as trf80 on bo.bostamp=trf80.oristamp and trf80.no=80 and trf80.repeticao=(case when trf95.repeticao is null then 0 else trf95.repeticao end)	 
					where 
						bo.ndos=11 and (select count(tarefas2.trfstamp) from u_tarefas(nolock) as tarefas2 where tarefas2.oristamp=bo.bostamp and tarefas2.fechada=0)>0 and
						bo3.u_familia=(case when @marca <> '' then @marca else bo3.u_familia end) 
						and 0=(case when trf95.no is null then 0 else trf95.fechada end)
		
						and 1=(case when trf65.no is null then (case when (trf80.no is null or (trf80.no is not null)) then 1 else 0 end)  else trf65.fechada end) 
						and
						(
							bo.dataopen <= @ate
							or
							(bo.dataopen >= @ate
								and 
								(
										select 
											count(booutro.bostamp)
										from
											bo as booutro(nolock) 
											left join u_tarefas(nolock) as trf952 on booutro.bostamp=trf952.oristamp and trf952.no=(case when booutro.no=619 then 80 else 95 end)
											left join u_tarefas(nolock)  as trf652 on booutro.bostamp=trf652.oristamp and trf652.no=65 and trf652.repeticao=(case when trf952.repeticao is null then 0 else trf952.repeticao end)	
											left join u_tarefas(nolock)  as trf802 on bo.bostamp=trf802.oristamp and trf802.no=80 and trf802.repeticao=(case when trf952.repeticao is null then 0 else trf952.repeticao end)
										where
											booutro.ndos=11 and  (select count(tarefas2.trfstamp) from u_tarefas(nolock) as tarefas2 where tarefas2.oristamp=booutro.bostamp and tarefas2.fechada=0)>0 and
											booutro.no=bo.no and 
								
											0=(case when trf952.no is null then 0 else trf952.fechada end) 
								
											and 1=(case when trf652.no is null then (case when (trf802.no is null or (trf802.no is not null)) then 1 else 0 end)  else trf652.fechada end) 
											and booutro.dataopen <= @ate
								)>0
							)
						)

                union all

                --PATS
                select 
					pa.nome as Nome,
					pa.no as NumCli,
					pa.serie2 as Molde,			
					'R' + Ltrim(str(pa.nopat)) + '-' + pa.u_marca + '-'+pa.u_refprod  as nref
					,pa.u_dtfimcl as PrazoPedCliente,
					pa.u_dtfimcl as u_DTCONFCL,				
                    0 as atrasado,						
					'' as LocalEntrega,
					'' as ClienteEntrega
					,trf57.datafim as pronto,
					 trf57.datafim  as Verif,
					0 as ed,
					--tarefa 900 processos -HOLD  
					(case when exists(select * from u_tarefas where u_tarefas.no=900 and u_tarefas.oristamp=pa.pastamp and u_tarefas.fechada=0) then 1 else 0 end) as HOLD,	
					'T' as PT,
					--tarefa 81 processos -Informar o cliente
					--tarefa 80 pats - Informar cliente da reparação concluída  
					(case when exists(select * from u_tarefas as trfinf where trfinf.no=80 and trfinf.oristamp=pa.pastamp and trfinf.fechada=1 and trfinf.repeticao=0) then 1 else 0 end) as inf,
					SUBSTRING(cl.tipo,0, CHARINDEX('-',cl.tipo)) as Class,
					'' as entregarcom,
					'' as codprod,
					'TAREFA '
					+(case when trf40.no is null then '' else ltrim(str(trf40.no))+' '+ltrim(trf40.descricao) end)
					+(case when trf57.no is null then '' else ltrim(str(trf57.no))+' '+ltrim(trf57.descricao) end)
					+(case when trf79.no is null then '' else ltrim(str(trf79.no))+' '+ltrim(trf79.descricao) end)
					+(case when trf150.no is null then '' else ltrim(str(trf150.no))+' '+ltrim(trf150.descricao) end)
					+' OBS:' +cast(pa.solucao as varchar(200))
					as u_obsproc, 
					DATEDIFF(day,getdate(),pa.u_dtfimcl) as ClassData,					
					@ate as dtembarque,					
					0 as estosck
				from 
					pa(nolock) 
					left join cl(nolock) on pa.no=cl.no and cl.estab=0 
					--tarefa 40 pats - Envio para o fornecedor
					left join u_tarefas(nolock)  as trf40 on pa.pastamp=trf40.oristamp and trf40.no=40 and trf40.repeticao=0 and trf40.fechada=0
					--tarefa 79 pats - Envio de equipamento reparado ao cliente | tarefa 74 pats - Envio de equipamento não reparado ao cliente 
					left join u_tarefas(nolock)  as trf79 on pa.pastamp=trf79.oristamp and (trf79.no=79 or trf79.no=74)  and trf79.repeticao=0 and trf79.fechada=0
					--tarefa 57 pats - Receção de equipamento reparado do fornecedor | tarefa 59 pats - Receção de equipamento não reparado no fornecedor      
					left join u_tarefas(nolock)  as trf57 on pa.pastamp=trf57.oristamp and (trf57.no=57 or trf57.no=59) and trf57.repeticao=0 and trf57.fechada=0
					--tarefa 150 pats - Envio de material para testes                                                                       
					left join u_tarefas(nolock)  as trf150 on pa.pastamp=trf150.oristamp and trf150.no=150 and trf150.repeticao=0 and trf150.fechada=0
				where 
					(select count(tarefas2.trfstamp) from u_tarefas(nolock) as tarefas2 where tarefas2.oristamp=pa.pastamp and tarefas2.no in (40,57,59,74,79,150) and tarefas2.fechada=0)>0 
					and pa.U_MARCA=(case when @marca <> '' then @marca else pa.U_MARCA end) 
					and (
							0=(case when trf40.no is null then 1 else trf40.fechada end) 
							or
							0=(case when trf79.no is null then 1 else trf79.fechada end) 
							or 
							0=(case when trf57.no is null then 1 else trf57.fechada end) 
							or 
							0=(case when trf150.no is null then 1 else trf150.fechada end)
						)
				
					and
					(
						pa.u_dtfimcl <= @ate
						or
						(pa.u_dtfimcl >= @ate
							and 
							(
									select 
										count(paoutro.pastamp)
									from
										pa as paoutro(nolock) 										
										--tarefa 40 pats - Envio para o fornecedor
										left join u_tarefas(nolock)  as trf402 on paoutro.pastamp=trf402.oristamp and trf402.no=40 and trf402.repeticao=0 and trf402.fechada=0
										--tarefa 79 pats - Envio de equipamento reparado ao cliente | tarefa 74 pats - Envio de equipamento não reparado ao cliente 
										left join u_tarefas(nolock)  as trf792 on paoutro.pastamp=trf792.oristamp and (trf792.no=79 or trf792.no=74)  and trf792.repeticao=0 and trf792.fechada=0
										--tarefa 57 pats - Receção de equipamento reparado do fornecedor | tarefa 59 pats - Receção de equipamento não reparado no fornecedor      
										left join u_tarefas(nolock)  as trf572 on paoutro.pastamp=trf572.oristamp and (trf572.no=57 or trf572.no=59) and trf572.repeticao=0 and trf572.fechada=0
										--tarefa 150 pats - Envio de material para testes       
										left join u_tarefas(nolock)  as trf1502 on paoutro.pastamp=trf1502.oristamp and (trf1502.no=150) and trf1502.repeticao=0 and trf1502.fechada=0
									where
										(select count(tarefas2.trfstamp) from u_tarefas(nolock) as tarefas2 where tarefas2.oristamp=paoutro.pastamp and tarefas2.no in (40,57,59,74,79,150) and tarefas2.fechada=0)>0 and
										paoutro.no=pa.no 									
										and
										(
										0=(case when trf402.no is null then 1 else trf402.fechada end) 
										or 
										0=(case when trf792.no is null then 1 else trf792.fechada end) 
										or 
										0=(case when trf572.no is null then 1 else trf572.fechada end) 
										or 
										0=(case when trf1502.no is null then 1 else trf1502.fechada end) 
										)																		
										and paoutro.u_dtfimcl <= @ate
							)>0
						)
					)
				
		) as tabela1
	where	
		(tabela1.ClienteEntrega like '%` + ColFilter1 + `%' or tabela1.Nome like '%` + ColFilter1 + `%') and
		(tabela1.nref like '%` + ColFilter2 + `%' or tabela1.Molde like '%` + ColFilter2 + `%' or tabela1.codprod like '%` + ColFilter2 + `%') and
		(convert(varchar, u_DTCONFCL, 104) like '%` + ColFilter3 + `%' or convert(varchar, PrazoPedCliente, 104) like '%` + ColFilter3 + `%' or tabela1.localentrega like '%` + ColFilter3 + `%') and
		(convert(varchar,cast(dtembarque as date),104) like '%` + ColFilter4 + `%' or convert(varchar, pronto, 104) like '%` + ColFilter4 + `%' or tabela1.verif like '%` + ColFilter4 + `%' or tabela1.entregarCom like '%` + ColFilter4 + `%') and
		(tabela1.PT like '%` + ColFilter5 + `%' or tabela1.ed like '%` + ColFilter5 + `%' or tabela1.class like '%` + ColFilter5 + `%' or tabela1.inf like '%` + ColFilter5 + `%') and
		
	tabela1.dtembarque is not null and tabela1.dtembarque<>'19000101'
	order by 
	tabela1.u_DTCONFCL, 
	tabela1.dtembarque,
	tabela1.nome,		
	tabela1.nref
else
	select		
		(
			select count(ccstamp) 
			from cc (nolock)
			 where cc.no=NumCli
			 and dateadd(dd,(select cl.alimite as dias from cl(nolock) where cl.no=NumCli and cl.estab=0),cc.datalc)<getdate() 
			 and  (case when cc.moeda='PTE OU EURO' or cc.moeda=space(11) then (cc.edeb-cc.edebf)-(cc.ecred-cc.ecredf) else (cc.debm-cc.debfm)-(cc.credm-cc.credfm) end) > (case when cc.moeda='PTE OU EURO' or cc.moeda=space(11) then 0.010000 else 0 end)	
		 )as clienteBloqueado,
		case when u_DTCONFCL <=@ate then nome else '___'+ltrim(rtrim(nome)) end as Nome,
		'Até : '+ convert(varchar,convert(datetime,@ate,104),104) + '   Ordenação : '+ @tipo as ordenacao,
		Molde,
		nref,
		convert(varchar, PrazoPedCliente, 104) as PrazoPedCliente, 
		convert(varchar, u_DTCONFCL, 104) as u_DTCONFCL, 
		LocalEntrega,
		ClienteEntrega,
		case when pronto is null then '' else convert(char,pronto,104) end as pronto,
		case when Verif is null then '' else convert(char,Verif,104) end as Verif,
		HOLD,
		ed,
		pt,
		inf,
		Class,
		atrasado,
		entregarcom,
		u_obsproc,
		codprod,
		CASE 
			WHEN ClassData <  2 THEN '1'  
			WHEN ClassData >= 2 and ClassData < 5 THEN '2'  
			WHEN ClassData >= 5 and ClassData < 10 THEN '3'  
			WHEN ClassData >= 10 THEN '4'       
		end as ClassData,
		dtembarque,
        convert(varchar,cast(dtembarque as date),104) as dataembarqueVer,
        estosck
	from
	(
			--PROCESSOS
			select 
				bo.nome as Nome
				,bo.no as NumCli,
				bo2.u_RefCliMl as Molde,			
				'E' + Ltrim(str(bo.obrano)) + '-' + bo3.u_familia + '-'+bo.tabela1  as nref
				,bo.dataopen as PrazoPedCliente,
				bo3.u_DTCONFCL as u_DTCONFCL, 
				case when dateadd(day, 30, bo.dataopen) < getdate() then 1 else 0 end as atrasado,			
				(case when 
					(select count(*) FROM szadrs where ltrim(rtrim(szadrsdesc)) = ltrim(rtrim(bo2.descar))) > 0
				then 
					(select local FROM szadrs where szadrsdesc=bo2.descar)  
				else 					
					(case when 
						(ltrim(rtrim(bo2.descar)) = 'Morada do Cliente' or ltrim(rtrim(bo2.descar)) = 'É definido nos parâmetros ') 
					then 
						bo2.local 
					else 
						bo2.descar 
					end) 
				end)
				as LocalEntrega
				,(					
					(case when 
						(ltrim(rtrim(bo2.descar)) = ltrim(rtrim(bo.nome)) or ltrim(rtrim(bo2.descar)) = 'Morada do Cliente' or ltrim(rtrim(bo2.descar)) = 'É definido nos parâmetros ')  
					then 
						''
					else 
						bo2.descar 
					end) 
				)
				as ClienteEntrega
				
				,(case when (trf65.no is not null or trf65.no=65) then 
					(select max(trfvrf.Datafim) from u_tarefas as trfvrf where trfvrf.no=80 and trfvrf.fechada=1 and trfvrf.oristamp=bo.bostamp and trfvrf.repeticao=trf95.repeticao)
				else
					(select max(trfvrf.dataini) from u_tarefas as trfvrf where trfvrf.no=80 and trfvrf.fechada=0 and trfvrf.oristamp=bo.bostamp and trfvrf.repeticao=trf95.repeticao)
				end)
				as pronto,
				(case when (trf65.no is not null or trf65.no=65) then 
					(select max(trfrec.Datafim) from u_tarefas as trfrec where trfrec.no=70 and trfrec.fechada=1 and trfrec.oristamp=bo.bostamp and trfrec.repeticao=trf95.repeticao) 
				else
					(select max(trfvrf.datafim) from u_tarefas as trfvrf where trfvrf.no=80 and trfvrf.fechada=1 and trfvrf.oristamp=bo.bostamp and trfvrf.repeticao=trf95.repeticao)
				end)
				as Verif,
				(case when exists(select bi.u_direta from bi where bi.bostamp = bo.bostamp and bi.u_direta = 1) then 1 else 0 end) as ed,
				(case when exists(select * from u_tarefas where u_tarefas.no=900 and u_tarefas.oristamp=bo.bostamp and u_tarefas.fechada=0) then 1 else 0 end) as HOLD,				
				
				(case when 1 >= (select count(*) from u_tarefas as trfP where trfP.no=65 and trfP.oristamp=bo.bostamp ) then 'T' else (case when trf65.repeticao = (select max(trfP.repeticao) from u_tarefas as trfP where trfP.no=65 and trfP.oristamp=bo.bostamp ) then 'T' else 'P' end) end) as PT,
				
				(case when exists(select * from u_tarefas as trfinf where trfinf.no=81 and trfinf.oristamp=bo.bostamp and trfinf.fechada=1 and trfinf.repeticao=trf95.repeticao) then 1 else 0 end) as inf,
				SUBSTRING(cl.tipo,0, CHARINDEX('-',cl.tipo)) as Class,
				BO3.U_ENTRCOM as entregarcom,
				bo.marca as codprod,
				bo3.u_obsproc,
				DATEDIFF(day,getdate(),BO.dataopen) as ClassData,				
				isnull((case when ltrim(rtrim(trf65.resposta))=''
				     then convert(varchar,ltrim(rtrim(trf65.datafim)),112) 
					 else right(ltrim(rtrim(trf65.resposta)),4)+substring(ltrim(rtrim(trf65.resposta)),4,2)+left(ltrim(rtrim(trf65.resposta)),2) 
					 end),  isnull(convert(varchar,trf80.dataini,112),convert(varchar,trf95.dataini,112))
				 ) as dtembarque,
				 (case when (trf65.no is not null or trf65.no=65) then 0 else 1 end) as estosck
			from 
				bo(nolock) 
				left join bo2(nolock) on bo.bostamp=bo2.bo2stamp 
				left join bo3(nolock) on bo.bostamp=bo3.bo3stamp 
				left join cl(nolock) on bo.no=cl.no and cl.estab=0 
				left join u_tarefas(nolock) as trf95 on bo.bostamp=trf95.oristamp and trf95.no=(case when bo.no=619 then 80 else 95 end) 
				left join u_tarefas(nolock)  as trf65 on bo.bostamp=trf65.oristamp and trf65.no=65 and trf65.repeticao=(case when trf95.repeticao is null then 0 else trf95.repeticao end)
				left join u_tarefas(nolock)  as trf80 on bo.bostamp=trf80.oristamp and trf80.no=80 and trf80.repeticao=(case when trf95.repeticao is null then 0 else trf95.repeticao end)
				
			where 
				bo.ndos=11 and (select count(tarefas2.trfstamp) from u_tarefas(nolock) as tarefas2 where tarefas2.oristamp=bo.bostamp and tarefas2.fechada=0)>0 and
				bo3.u_familia=(case when @marca <> '' then @marca else bo3.u_familia end) 
				and 0=(case when trf95.no is null then 0 else trf95.fechada end)
				
				and 1=(case when trf65.no is null then (case when (trf80.no is null or (trf80.no is not null)) then 1 else 0 end)  else trf65.fechada end) 
				and
				(
					bo.dataopen <= @ate
					or
					(bo.dataopen >= @ate
						and 
						(
								select 
									count(booutro.bostamp)
								from
									bo as booutro(nolock) 
									left join u_tarefas(nolock) as trf952 on booutro.bostamp=trf952.oristamp and trf952.no=(case when booutro.no=619 then 80 else 95 end)
									left join u_tarefas(nolock)  as trf652 on booutro.bostamp=trf652.oristamp and trf652.no=65 and trf652.repeticao=(case when trf952.repeticao is null then 0 else trf952.repeticao end)	
									left join u_tarefas(nolock)  as trf802 on bo.bostamp=trf802.oristamp and trf802.no=80 and trf802.repeticao=(case when trf952.repeticao is null then 0 else trf952.repeticao end)
								where
									booutro.ndos=11 and (select count(tarefas2.trfstamp) from u_tarefas(nolock) as tarefas2 where tarefas2.oristamp=booutro.bostamp and tarefas2.fechada=0)>0 and
									booutro.no=bo.no and 
									
								    0=(case when trf952.no is null then 0 else trf952.fechada end) 
									
									and 1=(case when trf652.no is null then (case when (trf802.no is null or (trf802.no is not null)) then 1 else 0 end)  else trf652.fechada end)  
					                and booutro.dataopen <= @ate
						)>0
					)
				)

				union all

				--PATS
				select 
				pa.nome as Nome
				,pa.no as NumCli,
				pa.serie2 as Molde,			
				'R' + Ltrim(str(pa.nopat)) + '-' + pa.u_marca + '-'+pa.u_refprod  as nref
				,pa.u_dtfimcl as PrazoPedCliente,
				pa.u_dtfimcl as u_DTCONFCL,				
                0 as atrasado,
				'' as LocalEntrega,
				'' as ClienteEntrega				
				,trf57.datafim as pronto,				
				trf57.datafim  as Verif,
				0 as ed,
				--tarefa 900 processos -HOLD  
				(case when exists(select * from u_tarefas where u_tarefas.no=900 and u_tarefas.oristamp=pa.pastamp and u_tarefas.fechada=0) then 1 else 0 end) as HOLD,					
				'T' as PT,
				--tarefa 81 processos -Informar o cliente
				--tarefa 80 pats - Informar cliente da reparação concluída  
				(case when exists(select * from u_tarefas as trfinf where trfinf.no=80 and trfinf.oristamp=pa.pastamp and trfinf.fechada=1 and trfinf.repeticao=0) then 1 else 0 end) as inf,
				SUBSTRING(cl.tipo,0, CHARINDEX('-',cl.tipo)) as Class,
				'' as entregarcom,
				'' as codprod,
				'TAREFA '
				+(case when trf40.no is null then '' else ltrim(str(trf40.no))+' '+ltrim(trf40.descricao) end)
				+(case when trf57.no is null then '' else ltrim(str(trf57.no))+' '+ltrim(trf57.descricao) end)
				+(case when trf79.no is null then '' else ltrim(str(trf79.no))+' '+ltrim(trf79.descricao) end)
				+(case when trf150.no is null then '' else ltrim(str(trf150.no))+' '+ltrim(trf150.descricao) end)
				+' OBS:'+cast(pa.solucao as varchar(200))
				as u_obsproc, 
				DATEDIFF(day,getdate(),pa.u_dtfimcl) as ClassData,
				--tarefa 65 processos -Confirmação da data de embarque 				
				 @ate as dtembarque,				 
				 0 as estosck
			from 
				pa(nolock) 
				left join cl(nolock) on pa.no=cl.no and cl.estab=0 
				--tarefa 40 pats - Envio para o fornecedor
				left join u_tarefas(nolock)  as trf40 on pa.pastamp=trf40.oristamp and trf40.no=40 and trf40.repeticao=0 and trf40.fechada=0
				--tarefa 79 pats - Envio de equipamento reparado ao cliente | tarefa 74 pats - Envio de equipamento não reparado ao cliente 
				left join u_tarefas(nolock)  as trf79 on pa.pastamp=trf79.oristamp and (trf79.no=79 or trf79.no=74)  and trf79.repeticao=0 and trf79.fechada=0
				--tarefa 57 pats - Receção de equipamento reparado do fornecedor | tarefa 59 pats - Receção de equipamento não reparado no fornecedor      
				left join u_tarefas(nolock)  as trf57 on pa.pastamp=trf57.oristamp and (trf57.no=57 or trf57.no=59) and trf57.repeticao=0 and trf57.fechada=0
				--tarefa 150 pats - Envio de material para testes 
				left join u_tarefas(nolock)  as trf150 on pa.pastamp=trf150.oristamp and (trf150.no=150) and trf150.repeticao=0 and trf150.fechada=0
				
			where 
				(select count(tarefas2.trfstamp) from u_tarefas(nolock) as tarefas2 where tarefas2.oristamp=pa.pastamp and tarefas2.no in (40,57,59,74,79,150) and tarefas2.fechada=0)>0 and
				pa.U_MARCA=(case when @marca <> '' then @marca else pa.U_MARCA end) 				
				and (
				    0=(case when trf40.no is null then 1 else trf40.fechada end) 
					or
					0=(case when trf79.no is null then 1 else trf79.fechada end) 
					or 
					0=(case when trf57.no is null then 1 else trf57.fechada end) 
					or 
					0=(case when trf150.no is null then 1 else trf150.fechada end) 
					)
				and
				(
					pa.u_dtfimcl <= @ate
					or
					(pa.u_dtfimcl >= @ate
						and 
						(
								select 
									count(paoutro.pastamp)
								from
									pa as paoutro(nolock) 									
									--tarefa 40 pats - Envio para o fornecedor
									left join u_tarefas(nolock)  as trf402 on paoutro.pastamp=trf402.oristamp and trf402.no=40 and trf402.repeticao=0 and trf402.fechada=0
									--tarefa 79 pats - Envio de equipamento reparado ao cliente | tarefa 74 pats - Envio de equipamento não reparado ao cliente 
									left join u_tarefas(nolock)  as trf792 on paoutro.pastamp=trf792.oristamp and (trf792.no=79 or trf792.no=74)  and trf792.repeticao=0 and trf792.fechada=0
									--tarefa 57 pats - Receção de equipamento reparado do fornecedor | tarefa 59 pats - Receção de equipamento não reparado no fornecedor      
									left join u_tarefas(nolock)  as trf572 on paoutro.pastamp=trf572.oristamp and (trf572.no=57 or trf572.no=59) and trf572.repeticao=0 and trf572.fechada=0
									--tarefa 150 pats - Envio de material para testes 
									left join u_tarefas(nolock)  as trf1502 on paoutro.pastamp=trf1502.oristamp and (trf1502.no=57 or trf1502.no=59) and trf1502.repeticao=0 and trf1502.fechada=0
								where
									(select count(tarefas2.trfstamp) from u_tarefas(nolock) as tarefas2 where tarefas2.oristamp=paoutro.pastamp and tarefas2.no in (40,57,59,74,79,150) and tarefas2.fechada=0)>0 and
									paoutro.no=pa.no 
									
								    and
									(
									0=(case when trf402.no is null then 1 else trf402.fechada end) 
									or 
									0=(case when trf792.no is null then 1 else trf792.fechada end) 
									or
									0=(case when trf572.no is null then 1 else trf572.fechada end) 
									or
									0=(case when trf1502.no is null then 1 else trf1502.fechada end) 
									)
									
					                and paoutro.u_dtfimcl <= @ate
						)>0
					)
				)
				--order by pa.nopat
		) as tabela1
	where 
		(tabela1.ClienteEntrega like '%` + ColFilter1 + `%' or tabela1.Nome like '%` + ColFilter1 + `%') and
		(tabela1.nref like '%` + ColFilter2 + `%' or tabela1.Molde like '%` + ColFilter2 + `%' or tabela1.codprod like '%` + ColFilter2 + `%') and
		(convert(varchar, u_DTCONFCL, 104) like '%` + ColFilter3 + `%' or convert(varchar, PrazoPedCliente, 104) like '%` + ColFilter3 + `%' or tabela1.localentrega like '%` + ColFilter3 + `%') and
		(convert(varchar,cast(dtembarque as date),104) like '%` + ColFilter4 + `%' or convert(varchar, pronto, 104) like '%` + ColFilter4 + `%' or tabela1.verif like '%` + ColFilter4 + `%' or tabela1.entregarCom like '%` + ColFilter4 + `%') and
		(tabela1.PT like '%` + ColFilter5 + `%' or tabela1.ed like '%` + ColFilter5 + `%' or tabela1.class like '%` + ColFilter5 + `%' or tabela1.inf like '%` + ColFilter5 + `%') and

tabela1.dtembarque is not null and tabela1.dtembarque<>'19000101' 
order by 
	tabela1.nome,
	tabela1.u_DTCONFCL,
    tabela1.dtembarque,
	tabela1.nref`;