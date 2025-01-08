#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} WFSendPC 
Função responsavel por montar o processo de Envio do Workflow.
@author 	Ricardo Tavares Ferreira
@since 		08/06/2019
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	User Function WFSendPC(cFilDoc,cPedDoc,cTipoDoc)
//==========================================================================================================

	Local aAreaSC7  	:= SC7->(GetArea())
	Local aAreaSCR  	:= SCR->(GetArea())
	Local oProcess		:= Nil
	Local cWfDir    	:= AllTrim( "/workflow/") //Alltrim(GetNewPar("MV_WFDIRWF","\workflow"))
	Local nX		    := 0
	Local cFunc  	 	:= "WFSendPC"
	Local aDirHtml   	:= {}
	Local cDirHtml   	:= "html\"
	Local cDirPasta  	:= "aprovpc\"
	Local cDescProd  	:= ""
	Local aMail 		:= {}
	Local cSituacao		:= ""
	Local cAssunto		:= ""
	Local nIdSCR		:= 0
	Local texto1		:= ""
	Local texto2		:= ""
	Local texto3		:= ""
	Local texto4		:= ""
	Local xHTM			:= ""
	Local aRecMail		:= {}
	Local nTotal		:= 0
	Local cCopia		:= ""
	Local lOkWF			:= .F.
	Local cNameEmp 		:= ""
	Local cWFHTTP    	:= Iif ( Right(RTrim(GetNewPar("MV_XWFHTTP","http://10.106.10.20:6060/workflow/")),1)=="/",;
							GetNewPar("MV_XWFHTTP","http://10.106.10.20:6060/workflow/"),;
							GetNewPar("MV_XWFHTTP","http://10.106.10.20:6060/workflow/") + "/" )

	Private oHTML		:= Nil
	Default cFilDoc 	:= ""
	Default cPedDoc 	:= ""
	Default cTipoDoc	:= ""
	
	cFilAnt := cFilDoc
	DbSelectArea("SCR")
	SCR->(DbSetOrder(1))
	
	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	
	Conout("[60]  ["+cFunc+"] [" + Dtoc(DATE()) +" "+ Time()+ "] Inicio do Processo Workflow para o Documento {"+cFilDoc+" | "+cPedDoc+" | "+cTipoDoc+"}...")
	
	cAssunto := "Aprovação do Pedido de Compra " + Alltrim(cPedDoc)+ " - " + Alltrim(cFilDoc)
	oProcess := TWFProcess():New("PEDCOM","Pedido de Compras")
	oProcess:NewTask("000001",cWfDir+"wfw120pv.htm")
	oProcess:cSubject := cAssunto
	oProcess:bReturn  := "U_XRetSC()"
	//oProcess:UserSiga := TMP3->C7_USER //- Alterado FSW
	//oProcess:NewVersion(.T.)
	oHTML   := oProcess:oHTML
	
	If GetSC7(cFilDoc,cPedDoc,cTipoDoc)
		
		oHTML:ValByName( "empresa_filial"   , FWEmpName(Alltrim(cEmpAnt)))
		oHTML:ValByName( "nome_empfil"    	, FWFilName(Alltrim(cEmpAnt),cFilDoc))
		oHTML:ValByName( "fornecedor"     	, Alltrim(TMP3->C7_FORNECE) +"/"+Alltrim(TMP3->C7_LOJA))
		oHTML:ValByName( "lb_nome"    		, Posicione('SA2',1,xFilial('SA2')+Alltrim(TMP3->C7_FORNECE)+Alltrim(TMP3->C7_LOJA),'A2_NOME'))
		oHTML:ValByName( "filial" 			, Alltrim(cFilDoc)) //UsrRetname(SCR->CR_USER)  ) - Alterado FSW
		oHTML:ValByName( "pedido"   		, Alltrim(TMP3->C7_NUM))
		oHTML:ValByName( "emissao"   		, Dtoc(Stod(TMP3->C7_EMISSAO)))
		oHTML:ValByName( "lb_cond"   		, Posicione('SE4',1,xFilial('SE4')+TMP3->C7_COND,'E4_DESCRI'))
		oHTML:ValByName( "lb_comprador"    	, UsrRetName(TMP3->C7_USER))
		
		While !TMP3->(Eof())
			SC7->(DbGoTo(TMP3->R_E_C_N_O_))
			Conout("[84]  ["+cFunc+"] [" + Dtoc(DATE()) +" "+ Time()+ "] Processando Item do PC Filial | PC No | Item: ....: {"+Alltrim(TMP3->C7_FILIAL)+" | "+Alltrim(TMP3->C7_NUM)+" | "+Alltrim(TMP3->C7_ITEM)+"}...")		

			DbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(XFilial("SB1")+TMP3->C7_PRODUTO))

			cDescProd  := Posicione("SB1",1,FWXFilial("SB1")+SB1->B1_COD,"B1_DESC")
			DbSelectArea("SB1")

			AAdd( (oHTML:ValByName( "produto.item"    	)) , Alltrim(TMP3->C7_ITEM))
			AAdd( (oHTML:ValByName( "produto.codigo"    )) , Alltrim(TMP3->C7_PRODUTO))
			AAdd( (oHTML:ValByName( "produto.descricao" )) , Iif(Empty(TMP3->C7_DESCRI),Alltrim(cDescProd),Alltrim(TMP3->C7_DESCRI))) //pesquisa Desc. 1o. pelo SB5 e depois no SB1
			AAdd( (oHTML:ValByName( "produto.unid"      )) , Alltrim(TMP3->C7_UM))
			AAdd( (oHTML:ValByName( "produto.quant"   	)) , TRANSFORM( TMP3->C7_QUANT,'@E 999,999,999.99' ))
			AAdd( (oHTML:ValByName( "produto.preco"  	)) , TRANSFORM( TMP3->C7_PRECO,'@E 999,999,999.99' ))
			AAdd( (oHTML:ValByName( "produto.total" 	)) , TRANSFORM( TMP3->C7_TOTAL,'@E 999,999,999.99' ))
			AAdd( (oHTML:ValByName( "produto.ccusto" 	)) , Alltrim(TMP3->C7_CC))
			AAdd( (oHTML:ValByName( "produto.itemcta" 	)) , Alltrim(TMP3->C7_ITEMCTA))
						
			oHtml:ValByName( "lb_observacao", Alltrim(SC7->C7_XOBS))

			nTotal += TMP3->C7_TOTAL
			TMP3->(DbSkip())
		Enddo
		TMP3->(DbCloseArea())
		
		If GetSCR(cFilDoc,cPedDoc,cTipoDoc,"FULL") 
			While .not. TMP2->(Eof())
				SCR->(DbGoTo(TMP2->R_E_C_N_O_))

				cSituacao := ""
				If TMP2->CR_STATUS == "01"
					cSituacao := OemToAnsi("Aguardando Nivel/Usuario")
				ElseIf TMP2->CR_STATUS == "02"
					cSituacao := OemToAnsi("Em Aprovacao")
				ElseIf TMP2->CR_STATUS == "03"
					cSituacao := "Solicitação Aprovada"
				ElseIf TMP2->CR_STATUS == "04"
					cSituacao := "Solicitação Bloqueada"
				ElseIf TMP2->CR_STATUS == "05"
					cSituacao := OemToAnsi("Nivel Liberado ")
				EndIf
				
				cNomeUsu := UsrRetName(TMP2->CR_USERLIB)
			
				AAdd( (oHTML:ValByName( "histori.item" ))		, Alltrim(TMP2->CR_NIVEL))
				AAdd( (oHTML:ValByName( "histori.usuario" ))	, Alltrim(TMP2->CR_USER))
				AAdd( (oHTML:ValByName( "histori.nomeuse" ))	, Alltrim(cNomeUsu))
				AAdd( (oHTML:ValByName( "histori.status" ))		, cSituacao)
				AAdd( (oHTML:ValByName( "histori.aprov" ))		, Alltrim(TMP2->CR_APROV))
				AAdd( (oHTML:ValByName( "histori.datalib" ))	, Dtoc(Stod(TMP2->CR_DATALIB)))
				AAdd( (oHTML:ValByName( "histori.observ" ))		, Alltrim(SCR->CR_OBS) )
	
				TMP2->(DbSkip())
			Enddo
			TMP2->(DbCloseArea())
			
			If GetSCR(cFilDoc,cPedDoc,cTipoDoc,"")
				While .not. TMP2->(Eof())
					nIdSCR := TMP2->R_E_C_N_O_
					SCR->(DbGoTo(nIdSCR))
					If ! Empty(UsrRetMail(TMP2->CR_USER))
						aadd(aMail,{UsrRetName(TMP2->CR_USER),UsrRetMail(TMP2->CR_USER),TMP2->CR_USER})
					Else
						Conout("[146] ["+cFunc+"] [" + Dtoc(DATE()) +" "+ Time()+ "] Email do Aprovador ("+Alltrim(TMP2->CR_USER)+"-"+UsrRetName(TMP2->CR_USER)+") vazio, nao sera enviado o email para o documento ....: {"+cFilDoc+" | "+cPedDoc+" | "+cTipoDoc+"}...")				
					EndIf

					aadd(aRecMail,nIdSCR)
					oHTML:ValByName( "lb_aprovado" , TMP2->CR_USER)
					
					TMP2->(DbSkip())
				Enddo
				TMP2->(DbCloseArea())	
			Else 
				Conout("[154] ["+cFunc+"] [" + Dtoc(DATE()) +" "+ Time()+ "] Nao foi encontrado os dados do Documento (SCR-A) ....: {"+cFilDoc+" | "+cPedDoc+" | "+cTipoDoc+"}...")				
			EndIf
		
			oHTML:ValByName("lbvalor",TRANSFORM(nTotal,'@E 999,999,999.99'))
			oHTML:ValByName("lbtotal",TRANSFORM(nTotal,'@E 999,999,999.99'))
			oProcess:cTo :=  "pedcom"
			
			// Verifica e cria, se necessario, o diretorio para gravacao do HTML
			aDirHtml := Directory(cWfDir+"emp"+cEmpAnt+"\*.*", "D",Nil,.T.)
			If aScan( aDirHtml, {|aDir| aDir[1] == Upper( Iif(Right(cDirHtml,1)=="\", Left(cDirHtml,Len(cDirHtml)-1), cDirHtml))}) == 0
				If MakeDir(cWfDir+"emp"+cEmpAnt+"\"+cDirHtml) == 0
					Conout("[161] ["+cFunc+"] [" + Dtoc(DATE()) +" "+ Time()+ "]  Diretorio dos HTML's criado com sucesso. -> "+cWfDir+"emp"+cEmpAnt+"\"+cDirHtml)		
				Else
					Conout("[163] ["+cFunc+"] [" + Dtoc(DATE()) +" "+ Time()+ "]  Erro na criacao do diretorio dos HTML's! -> "+cWfDir+"emp"+cEmpAnt+"\"+cDirHtml)		
					cDirHtml := "temp\"
				EndIf
			EndIf

			// Verifica e cria, se necessario, a pasta especifica do Workflow para gravacao do HTML
			aDirHtml := Directory(cWfDir+"emp"+cEmpAnt+"\"+cDirHtml+"*.*", "D",Nil,.T.)
			If aScan( aDirHtml, {|aDir| aDir[1] == Upper(Iif(Right(cDirPasta,1)=="\", Left(cDirPasta,Len(cDirPasta)-1), cDirPasta) ) } ) == 0
				If MakeDir(cWfDir+"emp"+cEmpAnt+"\"+cDirHtml+cDirPasta) == 0
					Conout("[172] ["+cFunc+"] [" + Dtoc(DATE()) +" "+ Time()+ "]  Diretorio de Pasta dos HTML's criado com sucesso. -> "+cWfDir+"emp"+cEmpAnt+"\"+cDirHtml+cDirPasta)		
				Else
					Conout("[174] ["+cFunc+"] [" + Dtoc(DATE()) +" "+ Time()+ "]  Erro na criacao do diretorio dos HTML's! -> "+cWfDir+"emp"+cEmpAnt+"\"+cDirHtml+cDirPasta)		
					cDirPasta := ""
				EndIf
			EndIf
			
			cDirHtml2  := "emp"+cEmpAnt+"\" + cDirHtml + cDirPasta
			cMailID    := oProcess:Start(cWfDir+cDirHtml2,.T.)
			
			If File(cWfDir+cDirHtml2+cMailID+".htm")
				SCR->(DbGoTo(nIdSCR))
				Conout("[188] ["+cFunc+"] [" + Dtoc(DATE()) +" "+ Time()+ "]  Arquivo HTML copiado com sucesso: "+cWfDir+cDirHtml2+cMailID+".htm")		
			Else
				Conout("[190] ["+cFunc+"] [" + Dtoc(DATE()) +" "+ Time()+ "]  ATENCAO! Arquivo HTML NAO copiado: "+cWfDir+cDirHtml2+cMailID+".htm")		
			EndIf
			
			If Len(aMail) > 0
				For nX := 1 To Len(aMail)
					If SM0->M0_CODIGO = '01'
						cNameEmp := "AVB"
					ElseIf SM0->M0_CODIGO = '02'
						cNameEmp := "VDM"
					ElseIf SM0->M0_CODIGO = '03'
						cNameEmp := "SLM"
					ElseIf SM0->M0_CODIGO = '04'
						cNameEmp := "ARM"
					ElseIf SM0->M0_CODIGO = '05'
						cNameEmp := "ACG"
					ElseIf SM0->M0_CODIGO = '06'
						cNameEmp := "MCT"
					ElseIf SM0->M0_CODIGO = '07'
						cNameEmp := "MAB"
					EndIf

					cAviso	  := "Solicitação de Aprovacao de Pedido de Compra - Pedido No "+oProcess:oHtml:RetByName('Pedido')+' - Empresa '+ cNameEmp +' - Filial '+cFilDoc
					cDestino  := aMail[nX,2]
					cLink	  := StrTran(cWFHTTP+cDirHtml2+cMailID+".htm","\","/")
					texto1    := 'Você está recebendo um Link de aprovacao de Pedido de Compra - Pedido No '+oProcess:oHtml:RetByName('Pedido')+' - Empresa '+ cNameEmp +' - Filial '+cFilDoc+' em '+dtoc(date())+'&nbsp;&nbsp;&nbsp;'+time()+'.'
					texto2	  := " "
					texto3	  := " "
					texto4    := 'O processo aguarda sua resposta.'
					
					xHTM :='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
					xHTM +='<html xmlns="http://www.w3.org/1999/xhtml"> '
					xHTM +='<head>'
					xHTM +='	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
					xHTM +='	<title>'+cAviso+'</title>'
					xHTM +='</head>'
					xHTM +='<body bgcolor="#FFFFFF"> '
					xHTM +='	<TABLE WIDTH=100%>'
					xHTM +='		<TR>'
					xHTM +='			<TH ALIGN="right" BGCOLOR="#FFFFFF">'
					xHTM +='				<FONT  SIZE="5" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >'
					xHTM +='  				<img id="_x0000_i1025" src="https://sites.google.com/a/equilibrioti.com.br/equilibrioti/logoavb/logo-avanco-oz.png" border="0" width="263" height="123"></span></b></td>'
					xHTM +='			</TH>'
					xHTM +='		</TR>'
					xHTM +='	</TABLE>'
					xHTM +='	<TABLE WIDTH=100%>'
					xHTM +='		<TR>'
					xHTM +='			<TH ALIGN="Center" BGCOLOR="#FFFFFF"> '
					xHTM +='				<FONT  SIZE="5" COLOR="#005151" FACE="verdana, arial, helvetica, times" >'
					xHTM +='                <BR/>'
					xHTM +='                '+cAviso+' '
					xHTM +='                <BR/>'
					xHTM +='                <BR/>'
					xHTM +='                </FONT>'
					xHTM +='			</TH> '
					xHTM +='		</TR>'
					xHTM +='		<TR>'
					xHTM +='        	<TD align="left" BGCOLOR="#FFFFFF"> '
					xHTM +='            	<FONT  SIZE="3" COLOR="#005151" FACE="verdana, arial, helvetica, times" > '
					xHTM +='                <br/> '
					xHTM +='                Prezado(a):'+capital(aMail[nX,1])+' '
					xHTM +='                <br/>'
					xHTM +='                '+texto1+''
					xHTM +='                <br/>'
					xHTM +='                '+texto2+''
					xHTM +='                <br/>'
					xHTM +='                '+texto3+''
					xHTM +='                <br/>'
					xHTM +='                '+texto4+''
					xHTM +='                <br/>'
					xHTM +='                </FONT>'
					xHTM +='			</TD> '
					xHTM +='		</TR> '
					xHTM +='	</TABLE>'
					xHTM +='	<br />'
					xHTM +='	<TABLE WIDTH=100%>'
					xHTM +='		<TR> '
					xHTM +='		  <td>'
					xHTM +='			  <FONT  SIZE="-1" COLOR="#000000" FACE="verdana, arial, helvetica, times" >&nbsp;</FONT>'
					xHTM +='			  <p><font color="#005151" size="-1" face="verdana, arial, helvetica, times">Clique <a href="'+cLink+"?user="+aMail[nX,3]+'">aqui</a> para aprovar o pedido de compra. </font></p>'
					xHTM +='		  </td>'
					xHTM +='		</TR>'
			//		xHTM +='	</TABLE> '
			//		xHTM +='	<TABLE WIDTH=100%>'
			//		xHTM +='		<TR>'
			//		xHTM +='		  <td>'
			//		xHTM +='			  <br/>'
			//		xHTM +='			  <p><font color="#000000" size="-1" face="verdana, arial, helvetica, times">Clique <a href="'+cLink+"?user="+aMail[i,3]+'">aqui</a> para aprovar. </font></p>'
			//		xHTM +='		  </td>'
			//		xHTM +='		</TR>'
			//		xHTM +='	</TABLE>'
					xHTM +='	<hr width=100% />'
					xHTM +='	<table WIDTH=100%>'
					xHTM +='		<tr>'
					xHTM +='			<th height=30>'
					xHTM +='			</th>'
					xHTM +='		</tr>'
					xHTM +='		<tr>'
					xHTM +='			<TD align="center" BGCOLOR="#FFFFFF">'
					xHTM +='            	<FONT  SIZE="-1" COLOR="#005151" FACE="verdana, arial, helvetica, times" >'
					xHTM +='				Workflow '
					xHTM +='				</FONT>'
					xHTM +='			</td>'
					xHTM +='		</tr>'
					xHTM +='	</table>'
					xHTM +='<body>'
					xHTM +='</body>'
					xHTM +='</html>'

					lOkWF := u_EnviEmail("",'Aviso'+cAviso+'','Aviso : '+cAviso+'',xHTM,.t.,cDestino,cCopia) 		//Envia email de Aviso
					//cCdUserMail+= aMail[nX,3]+';'	
				Next nX
				
				If lOkWF
					For nX := 1 To Len(aRecMail)
						SCR->(DbGoTo(aRecMail[nX]))
						Reclock("SCR",.F.)
							SCR->CR_WF		:= "1"  //--Enviado
							SCR->CR_XENVMAI	:= "S"   //--Campo CR_WFID deve estar com tamanho 20
						MSUnlock()
					Next nX

					Conout("[287] ["+cFunc+"] [" + Dtoc(DATE()) +" "+ Time()+ "] Email enviado para Aprovacao para os dados ....: {"+cFilDoc+" | "+cPedDoc+" | "+cTipoDoc+"}...")							
					
					if len(aMail) > 0 
						cQuery := "  UPDATE  "+RetSqlName("SC7")+" "
						cQuery += "  SET  C7_XWFID  = '" +cMailID+ "'"// , C7_XWFMAIL  = '" +cCdUserMail+ "'  "
						cQuery += "  WHERE D_E_L_E_T_ = ' ' "
						cQuery += "  AND C7_FILIAL  =  '" +cFilDoc+ "' "
						cQuery += "  AND C7_NUM  =  '" +cPedDoc+ "' "
						
						Begin Transaction
							TcSqlExec(cQuery)
						End Transaction		
					EndIf
				Else
					Conout("[310] ["+cFunc+"] [" + Dtoc(DATE()) +" "+ Time()+ "] Falha ao Enviar o email para o aprovador sobre os dados ....: {"+cFilDoc+" | "+cPedDoc+" | "+cTipoDoc+"}...")							
				EndIf
			Else
				Conout("[313] ["+cFunc+"] [" + Dtoc(DATE()) +" "+ Time()+ "] Nao foi encontrado o email do aprovador para os dados ....: {"+cFilDoc+" | "+cPedDoc+" | "+cTipoDoc+"}...")							
			EndIF
		Else 
			Conout("[316] ["+cFunc+"] [" + Dtoc(DATE()) +" "+ Time()+ "] Nao foi encontrado os dados do Documento (SCR-B) ....: {"+cFilDoc+" | "+cPedDoc+" | "+cTipoDoc+"}...")				
		EndIf		
	Else
		Conout("[319] ["+cFunc+"] [" + Dtoc(DATE()) +" "+ Time()+ "] Nao foi encontrado os dados do Documento (SC7) ....: {"+cFilDoc+" | "+cPedDoc+" | "+cTipoDoc+"}...")	
	EndIf
	
	oProcess:Free()
	RestArea(aAreaSC7)
	RestArea(aAreaSCR)
Return Nil

/*/{Protheus.doc} GetSCR 
Função responsavel por buscar o documento de aprovacao na SCR.
@author 	Ricardo Tavares Ferreira
@since 		07/07/2019
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function GetSCR(cFilDoc,cNumDoc,cTipoDoc,cTpReq)
//==========================================================================================================

	Local cQuery	:= ""
	Local QbLinha	:= chr(13)+chr(10)
	Local nQtdReg	:= 0
	Default cFilDoc	:= ""
	Default cNumDoc	:= ""
	Default cTipoDoc:= ""
	
	cQuery := " SELECT * "+QbLinha
    cQuery += " FROM "
	cQuery +=   RetSqlName("SCR") + " SCR "+QbLinha 
	cQuery += " WHERE "+QbLinha 
	cQuery += " SCR.D_E_L_E_T_ = ' ' "+QbLinha 
	cQuery += " AND CR_FILIAL = '"+cFilDoc+"' "+QbLinha
	cQuery += " AND CR_NUM = '"+cNumDoc+"' "+QbLinha 
	cQuery += " AND CR_TIPO = '"+cTipoDoc+"' "+QbLinha

	If cTpReq <> "FULL"
		cQuery += " AND CR_STATUS = '02' "+QbLinha
	EndIf

	cQuery += " ORDER BY CR_NUM, CR_NIVEL "+QbLinha 
	
	MemoWrite("C:/ricardo/GetSCR.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP2",.F.,.T.)
		
	DbSelectArea("TMP2")
	TMP2->(DbGoTop())
	Count TO nQtdReg
	TMP2->(DbGoTop())
		
	If nQtdReg <= 0
		TMP2->(DbCloseArea())
		Return .F.
    EndIf
Return .T.

/*/{Protheus.doc} GetSC7 
Função responsavel por buscar o documento de aprovacao na SC7.
@author 	Ricardo Tavares Ferreira
@since 		07/07/2019
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function GetSC7(cFilDoc,cNumDoc,cTipoDoc)
//==========================================================================================================

	Local cQuery	:= ""
	Local QbLinha	:= chr(13)+chr(10)
	Local nQtdReg	:= 0
	Default cFilDoc	:= ""
	Default cNumDoc	:= ""
	Default cTipoDoc:= ""

	cQuery := " SELECT * "+QbLinha
    cQuery += " FROM "
	cQuery +=   RetSqlName("SC7") + " SC7 "+QbLinha 
	cQuery += " WHERE "+QbLinha 
	cQuery += " SC7.D_E_L_E_T_ = ' ' "+QbLinha 
	cQuery += " AND C7_FILIAL = '"+cFilDoc+"' "+QbLinha
	cQuery += " AND C7_NUM = '"+cNumDoc+"' "+QbLinha 
	cQuery += " ORDER BY C7_NUM, C7_ITEM "+QbLinha
	
	MemoWrite("C:/ricardo/GetSC7.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP3",.F.,.T.)
		
	DbSelectArea("TMP3")
	TMP3->(DbGoTop())
	Count TO nQtdReg
	TMP3->(DbGoTop())
		
	If nQtdReg <= 0
		TMP3->(DbCloseArea())
		Return .F.
    EndIf
Return .T.

/*/{Protheus.doc} XRetSC 
Função responsavel por montar o processo de Envio do Workflow.
@author 	Ricardo Tavares Ferreira
@since 		08/06/2019
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	User Function XRetSC(oProcess)
//==========================================================================================================

	Local cTipo		:= "PC"
	Local cNum		:= oProcess:oHtml:RetByName('pedido')
	Local cxFilial	:= oProcess:oHtml:RetByName('FILIAL')
	Local cResp		:= oProcess:oHtml:RetByName('RBAPROVA')
	Local cJusti	:= oProcess:oHtml:RetByName('lbmotivo')
	Local codAprov	:= oProcess:oHtml:RetByName("lb_aprovado")
	Local xLReprova := .F.
	Local nTotal	:= 0   
	Local cAprov	:= ""   
	Local cCodLiber	:= ""
    Local cGrupo	:= "" 
	Local lLiberou	:= .F.
	
	Conout("INICIO DE RETORNO WF APROVAÇÃO ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Iniciando 1002 ")
	Conout("INICIO DE RETORNO WF APROVAÇÃO ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" codAprov1: "+ codAprov)

	codAprov:= codAprov  	      

	DbSelectArea("SC7")
	SC7->(dbSetOrder(1))
	SC7->(dbgotop())                                      	
	If SC7->(dbSeek(cxFilial+cNum))
		cGrupo 		:= SC7->C7_APROV
		cPCLib 		:= SC7->C7_NUM
		cPCUser		:= SC7->C7_USER
		Conout("RETORNO WF APROVAÇÃO ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Grupo"+cGrupo+" cPCLib: "+ cPCLib +" cPCUser: "+cPCUser)
	Else
  		Conout("ERRO NAO ACHOU SC7")
	EndIf

	If Select("SC7") > 0
		SC7->(dbCloseArea())
	EndIf

	Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" cResp: " + cResp)

	if cResp == '1'
		nOpc:=2 //Libera
	else
		nOpc:=3 //Bloqueia
	endif   

	Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" cResp: " + cResp+" nOpc: "+alltrim(str(nOpc)))
	Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Vai entrar no WHILE DO SCR CHAVE:"+cxFilial+cTipo+cNum+codAprov)	  

	DbSelectArea("SCR")
	SCR->(dbSetOrder(2))
	SCR->(dbgotop())
	if SCR->(dbSeek(cxFilial+cTipo+cNum))
		Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Vai entrar no if SCR->(dbSeek(cxFilial+cTipo+cNum)):"+cxFilial+cTipo+cNum)
		Conout("RETORNO WF APROVAÇÃO ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Entrou no !SCR->(EOF()) .AND. cxFilial == SCR->CR_FILIAL .AND. cNum == SCR->CR_NUM"+ cxFilial+"X"+SCR->CR_FILIAL+"X"+cNum+"X"+SCR->CR_NUM )
		
		While !SCR->(EOF()) .AND. alltrim(cxFilial) == alltrim(SCR->CR_FILIAL) .AND. alltrim(cNum) == alltrim(SCR->CR_NUM)
			
			Conout("RETORNO WF APROVAÇÃO ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Entrou no while !SCR->(EOF()) .AND. cxFilial == SCR->CR_FILIAL .AND. cNum == SCR->CR_NUM" )
			Conout("RETORNO WF APROVAÇÃO ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Entrou no codAprov == SCR->CR_USER"+codAprov == SCR->CR_USER )
			
			if codAprov == SCR->CR_USER
				
				Conout("RETORNO WF APROVAÇÃO ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Entrou no if codAprov == SCR->CR_USER" )
				
				nTotal    	:= 	SCR->CR_TOTAL
				cAprov    	:= 	SCR->CR_APROV
				cCodLiber	:=	SCR->CR_USER
				cNivelApr	:=	SCR->CR_NIVEL
														
				if (SCR->CR_STATUS = "03" .or. SCR->CR_STATUS = "04") // Caso o Pedido de Compra Ja Esteja Liberado pelo Aprovador  Exemplo Sistema. Náo Ocorre nenhuma Reacao.
					 Return(.F.)
				EndIf
				
				Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Iniciando a função de Liberação/Bloqueio ")
				Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Aprovado:  "+cAprov+" Grupo: "+cGrupo+" Justificativa: "+cJusti)
				
				lLiberou := U_MaAlcDocL({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,cAprov,,cGrupo,,,,,cJusti},date(),If(nOpc==2,4,6))
				
				if lLiberou
					Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Fim da função de Liberação/Bloqueio (LIBEROU)")
				Else
					xLReprova := .T.
					Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Fim da função de Liberação/Bloqueio (BLOQUEOU)")
				Endif	
				Exit	
			Else
				Conout("RETORNO WF APROVAÇÃO ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" não e o liberador não e o liberador" )
			EndIf	
			SCR->(dbskip())
		Enddo
	Else
		Conout("RETORNO WF APROVAÇÃO ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Não achou SCR(xxx): "+ cxFilial+cTipo+cNum+codAprov)
	Endif	
	
	If lLiberou
		If Select("SC7") > 0
			SC7->(dbCloseArea())
		EndIf
		Dbselectarea("SC7")
		SC7->(dbSetOrder(1))                   	
		SC7->(dbgotop())
		SC7->(dbseek(cxFilial+cNum))	
		While !SC7->(Eof()) .AND. SC7->C7_FILIAL+SC7->C7_NUM  == cxFilial+cNum
			if SC7->C7_FILIAL+SC7->C7_NUM  == cxFilial+cNum
				
				Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Iniciando a Execução o Reclock(SC7,.F.) ")
							
				Reclock("SC7",.F.)
					SC7->C7_CONAPRO	:= "L"
					SC7->C7_OBS		:= AllTrim(SC7->C7_OBS)+"/"+cJusti
				SC7->(MsUnlock())                                  
				
				Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+"Filial:" +SC7->C7_FILIAL+" Pedido:"+SC7->C7_NUM+" Valor do SC7->C7_CONAPRO: "+SC7->C7_CONAPRO )
				Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Valor do SC7->C7_OBS: "+alltrim(SC7->C7_OBS)+" Valor do SC7->C7_CONAPRO: "+alltrim(SC7->C7_CONAPRO))			
				Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Gravou SC7->(MsUnlock())")	
			Endif	
			SC7->(dbSkip())	
		EndDo
		ConOut("( WF APROVAÇÃO) Filial: "+ cxFilial+ "Aprovando o Pedido: "+cNum )
		oProcess:Finish()
		Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Fim a oProcess:Finish() ")	
	EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MaAlcDoc ³ Autor ³ Aline Correa do Vale  ³ Data ³07.08.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controla a alcada dos documentos (SCS-Saldos/SCR-Bloqueios)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MaAlcDoc(ExpA1,ExpD1,ExpN1,ExpC1,ExpL1)               	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com informacoes do documento                 ³±±
±±³          ³       [1] Numero do documento                              ³±±
±±³          ³       [2] Tipo de Documento                                ³±±
±±³          ³       [3] Valor do Documento                               ³±±
±±³          ³       [4] Codigo do Aprovador                              ³±±
±±³          ³       [5] Codigo do Usuario                                ³±±
±±³          ³       [6] Grupo do Aprovador                               ³±±
±±³          ³       [7] Aprovador Superior                               ³±±
±±³          ³       [8] Moeda do Documento                               ³±±
±±³          ³       [9] Taxa da Moeda                                    ³±±
±±³          ³      [10] Data de Emissao do Documento                     ³±±
±±³          ³      [11] Grupo de Compras                                 ³±±
±±³          ³ ExpD1 = Data de referencia para o saldo                    ³±±
±±³          ³ ExpN1 = Operacao a ser executada                           ³±±
±±³          ³       1 = Inclusao do documento                            ³±±
±±³          ³       2 = Transferencia para Superior                      ³±±
±±³          ³       3 = Exclusao do documento                            ³±±
±±³          ³       4 = Aprovacao do documento                           ³±±
±±³          ³       5 = Estorno da Aprovacao                             ³±±
±±³          ³       6 = Bloqueio Manual da Aprovacao                     ³±±
±±³          ³ ExpC1 = Chave(Alternativa) do SF1 para exclusao SCR        ³±±
±±³          ³ ExpL1 = Eliminacao de Residuos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MaAlcDocL(aDocto,dDataRef,nOper,cDocSF1,lResiduo)

Local cDocto	:= aDocto[1]
Local cTipoDoc	:= aDocto[2]
Local nValDcto	:= aDocto[3]
Local cAprov	:= If(aDocto[4]==Nil,"",aDocto[4])
Local cUsuario	:= If(aDocto[5]==Nil,"",aDocto[5])
Local nMoeDcto	:= If(Len(aDocto)>7,If(aDocto[8]==Nil, 1,aDocto[8]),1)
Local nTxMoeda	:= If(Len(aDocto)>8,If(aDocto[9]==Nil, 0,aDocto[9]),0)
Local cObs      := If(Len(aDocto)>10,If(aDocto[11]==Nil, "",aDocto[11]),"")
Local aArea		:= GetArea()
Local aAreaSC7  := {}
Local aAreaSCS	:= SCS->(GetArea())
Local aAreaSCR	:= SCR->(GetArea())
Local aRetPe	:= {}
Local nSaldo	:= 0
Local cGrupo	:= If(aDocto[6]==Nil,"",aDocto[6])
Local lFirstNiv:= .T.
Local cAuxNivel:= ""
Local cNextNiv := ""
Local cNivIgual:= ""
Local cStatusAnt:= ""
Local cAprovOri := ""    
Local cUserOri  := ""
Local lAchou	:= .F.
Local nRec		:= 0
Local lRetorno	:= .T.
Local aSaldo	:= {} 
Local aMTALCGRU := {}
Local lDeletou  := .F.
Local dDataLib  := IIF(dDataRef==Nil,dDataBase,dDataRef)
Local QbLinha	:= chr(13)+chr(10)
Local cQuery	:= ""
Local nQtdReg	:= 0
Local cAliasXAL	:= GetNextAlias()
DEFAULT dDataRef:= dDataBase
DEFAULT cDocSF1 := cDocto
DEFAULT lResiduo := .F.

Private cAliasSAL	:= GetNextAlias()

cDocto := cDocto+Space(Len(SCR->CR_NUM)-Len(cDocto))
cDocSF1:= cDocSF1+Space(Len(SCR->CR_NUM)-Len(cDocSF1))

If ExistBlock("MT097GRV")
	lRetorno := (Execblock("MT097GRV",.F.,.F.,{aDocto,dDataRef,nOper,cDocSF1,lResiduo}))
	If Valtype( lRetorno ) <> "L"
		lRetorno := .T.
	EndIf
Endif

If lRetorno

	If Empty(cUsuario) .And. (nOper != 1 .And. nOper != 6) //nao e inclusao ou estorno de liberacao
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSeek(xFilial()+cAprov)
		cUsuario :=	AK_USER
		nMoeDcto :=	AK_MOEDA
		nTxMoeda	:=	0
	EndIf
	If nOper == 1  //Inclusao do Documento
		cGrupo := If(!Empty(aDocto[6]),aDocto[6],cGrupo)

		If GetGrpAprov(FWXFilial("SAL"),cGrupo)
			dbSelectArea("SAL")
			SAL->(dbSetOrder(2))
			//If !Empty(cGrupo) .And. SAL->(dbSeek(xFilial("SAL")+cGrupo))

			cQuery := " SELECT SAL.R_E_C_N_O_ IDSAL "+QbLinha
			cQuery += " FROM "+QbLinha 
   			cQuery +=   RetSqlName("SAL") + " SAL "+QbLinha
			cQuery += " WHERE SAL.D_E_L_E_T_ = ' ' "+QbLinha
			cQuery += " AND SAL.AL_FILIAL = '"+FWXFilial("SAL")+"' "+QbLinha
			cQuery += " AND SAL.AL_COD = '"+cGrupo+"' "+QbLinha
			cQuery += " ORDER BY SAL.AL_COD, SAL.AL_NIVEL "

			MemoWrite("C:/ricardo/U_Maalcdoc_SAL.sql",cQuery)			     
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasXAL,.F.,.T.)
					
			DbSelectArea(cAliasXAL)
			(cAliasXAL)->(DbGoTop())
			Count To nQtdReg
			(cAliasXAL)->(DbGoTop())

			While .not. (cAliasXAL)->(Eof()) // .And. xFilial("SAL")+cGrupo == SAL->AL_FILIAL+SAL->AL_COD
				SAL->(DbGoTo((cAliasXAL)->IDSAL))
                If cTipoDoc <> "NF"  
					If SAL->AL_AUTOLIM == "S" .And. !MaAlcLim(SAL->AL_APROV,nValDcto,nMoeDcto,nTxMoeda)
						//dbSelectArea("SAL")
						(cAliasXAL)->(dbSkip())
						Loop
					EndIf	
                EndIf
                 
				If lFirstNiv
					cAuxNivel := SAL->AL_NIVEL
					lFirstNiv := .F.
				EndIf

				Do Case
				Case cTipoDoc == "NF"
					SF1->(FkCommit())
				Case cTipoDoc == "PC" .Or.cTipoDoc == "AE"
					SC7->(FkCommit())
				Case cTipoDoc == "CP"
					SC3->(FkCommit())
				Case cTipoDoc == "SC"
					SC1->(FkCommit())
				Case cTipoDoc == "CO"
					SC8->(FkCommit())
				Case cTipoDoc == "MD"
					CND->(FkCommit())
				//Case cTipoDoc == "CT"
				//	CN9->(FkCommit())
				//Case cTipoDoc == "RV"
				//	CN9->(FkCommit())
				EndCase

				Reclock("SCR",.T.)
				SCR->CR_FILIAL	:= xFilial("SCR")
				SCR->CR_NUM		:= cDocto
				SCR->CR_TIPO	:= cTipoDoc
				SCR->CR_NIVEL	:= SAL->AL_NIVEL
				SCR->CR_USER	:= SAL->AL_USER
				SCR->CR_APROV	:= SAL->AL_APROV
				SCR->CR_STATUS	:= IIF(SAL->AL_NIVEL == cAuxNivel,"02","01")
				SCR->CR_TOTAL	:= nValDcto
				SCR->CR_EMISSAO := aDocto[10]
				SCR->CR_MOEDA	:= nMoeDcto
				SCR->CR_TXMOEDA := nTxMoeda
				SCR->CR_GRUPO   := cGrupo
				//SCR->CR_ITGRP	:= SAL->AL_ITEM
				SAL->(MsUnlock())
				//dbSelectArea("SAL")
				(cAliasXAL)->(dbSkip())
			EndDo
			(cAliasXAL)->(DbCloseArea())
		EndIf
		lRetorno := lFirstNiv
	EndIf
	
	If nOper == 2  //Transferencia da Alcada para o Superior
		//dbSelectArea("SCR")
		//dbSetOrder(1)
		//dbSeek(xFilial("SCR")+cTipoDoc+cDocto)
		// O SCR deve estar posicionado, para que seja transferido o atual para o Superior
		If !Eof() .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM == xFilial("SCR")+cTipoDoc+cDocto
			// Carrega dados do Registro a ser tranferido e exclui
			cTipoDoc := SCR->CR_TIPO
			cAuxNivel:= SCR->CR_STATUS
			nValDcto := SCR->CR_TOTAL
			nMoeDcto :=	SCR->CR_MOEDA
			cNextNiv := SCR->CR_NIVEL
			nTxMoeda := SCR->CR_TXMOEDA
			dDataRef := SCR->CR_EMISSAO
			cAprovOri:= SCR->CR_APROV
			cUserOri := SCR->CR_USER
			Reclock("SCR",.F.,.T.)
			dbDelete()
			MsUnlock()
			// Inclui Registro para Aprovador Superior
			Reclock("SCR",.T.)
			SCR->CR_FILIAL	:= xFilial("SCR")
			SCR->CR_NUM		:= cDocto
			SCR->CR_TIPO	:= cTipoDoc
			SCR->CR_NIVEL	:= cNextNiv
			SCR->CR_USER	:= cUsuario
			SCR->CR_APROV	:= cAprov
			SCR->CR_STATUS	:= cAuxNivel
			SCR->CR_TOTAL	:= nValDcto
			SCR->CR_EMISSAO:= dDataRef
			SCR->CR_MOEDA	:=	nMoeDcto
			SCR->CR_TXMOEDA:= nTxMoeda
			SCR->CR_OBS 	:= cObs            
			
			//Aplicar UPDCOM10 se não existir campos na base //
			If !Empty(SCR->(FieldPos("CR_APRORI"))) .And. !Empty(SCR->(FieldPos("CR_USERORI")))
				SCR->CR_APRORI  := cAprovOri	
				SCR->CR_USERORI := cUserOri
			EndIf
			MsUnlock()
		EndIf
		lRetorno := .T.
	EndIf
	
	If nOper == 3  //exclusao do documento
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSelectArea("SCR")
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+cTipoDoc+cDocto)		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua uma nova busca caso o cDocto nao for encontrado no SCR³
		//³ pois seu conteudo em caso de NF foi alterado para chave unica³
		//³ do SF1, o cDocSF1 sera a busca alternativa com o conteudo ori³
		//³ ginal do lancamento da versao que poderia causar duplicidades³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SCR->( Eof() ) .And. cTipoDoc == "NF"
			dbSeek(xFilial("SCR")+cTipoDoc+cDocSF1)
			cDocto := cDocSF1
		EndIf

		While !Eof() .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM == xFilial("SCR")+cTipoDoc+cDocto
			If SCR->CR_STATUS == "03"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Reposiciona o usuario aprovador.               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SAK")
				dbSeek(xFilial("SAK")+SCR->CR_LIBAPRO)
				dbSelectArea("SAL")
				dbSetOrder(3)
				dbSeek(xFilial("SAL")+cGrupo+SAK->AK_COD)
				If SAL->AL_LIBAPR == "A"
					dbSelectArea("SCS")
					dbSetOrder(2)
					If dbSeek(xFilial("SCS")+SAK->AK_COD+DTOS(MaAlcDtRef(SCR->CR_LIBAPRO,SCR->CR_DATALIB,SCR->CR_TIPOLIM)))
						RecLock("SCS",.F.)
						SCS->CS_SALDO := SCS->CS_SALDO + SCR->CR_VALLIB
						MsUnlock()
					EndIf
				EndIf
			EndIf
			Reclock("SCR",.F.,.T.)
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf
	
	If nOper == 4 //Aprovacao do documento
		dbSelectArea("SCS")
		dbSetOrder(2)
		aSaldo := MaSalAlc(cAprov,dDataRef,.T.)
		nSaldo 	:= aSaldo[1]
		dDataRef	:= aSaldo[3]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o saldo do aprovador.                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSeek(xFilial("SAK")+cAprov)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona a Tabela SAL pelo Aprovador de Origem caso o Documento tenha sido ³
		//| transferido por Ausência Temporária ou Transferência superior e o aprovador |
		//| de destino não fizer parte do Grupo de Aprovação.                           |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SAL")
		dbSetOrder(3)
		dbSeek(xFilial("SAL")+cGrupo+cAprov) 
	    If !Empty(SCR->(FieldPos("CR_USERORI"))) .And. !Empty(SCR->(FieldPos("CR_APRORI"))) .And. !Empty(SCR->CR_APRORI)
    		dbSeek(xFilial("SAL")+cGrupo+SCR->CR_APRORI) 
    	EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para alterar o Aprovador 	 												³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   	If ExistBlock("MTALCGRU")
			aMTALCGRU := If(ValType(aRetPe:=ExecBlock("MTALCGRU",.F.,.F.,{cAprov,cGrupo}))=="A",aRetPe,aMTALCGRU)
			If Len(aMTALCGRU) >= 1 .And. ValType(aMTALCGRU[1]) == "C"
				cAprov := aMTALCGRU[1]
			EndIf
			If Len(aMTALCGRU) >= 2 .And. ValType(aMTALCGRU[2]) == "C"
				cGrupo := aMTALCGRU[2]
			EndIf	
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Libera o pedido pelo aprovador.                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SCR")
		cAuxNivel := CR_NIVEL
		Reclock("SCR",.F.)
		dbSetOrder(1)
		CR_STATUS	:= "03"
		CR_OBS		:= If(Len(aDocto)>10,aDocto[11],"")
		CR_DATALIB	:= dDataLib
		CR_USERLIB	:= SAK->AK_USER
		CR_LIBAPRO	:= SAK->AK_COD
		CR_VALLIB	:= nValDcto
		CR_TIPOLIM	:= SAK->AK_TIPO
		MsUnlock()
		dbSeek(xFilial("SCR")+cTipoDoc+cDocto+cAuxNivel)
		nRec := RecNo()
		While !Eof() .And. xFilial("SCR")+cDocto+cTipoDoc == CR_FILIAL+CR_NUM+CR_TIPO
			If cAuxNivel == CR_NIVEL .And. CR_STATUS != "03" .And. SAL->AL_TPLIBER$"U "
				Exit
			EndIf
			If cAuxNivel == CR_NIVEL .And. CR_STATUS != "03" .And. SAL->AL_TPLIBER$"NP"
				Reclock("SCR",.F.)
				CR_STATUS	:= "05"
				CR_DATALIB	:= dDataLib
				CR_USERLIB	:= SAK->AK_USER
				CR_APROV	:= cAprov
				CR_OBS		:= ""
				MsUnlock()
			EndIf
			If CR_NIVEL > cAuxNivel .And. CR_STATUS != "03" .And. !lAchou
				lAchou := .T.
				cNextNiv := CR_NIVEL
			EndIf
			If lAchou .And. CR_NIVEL == cNextNiv .And. CR_STATUS != "03"
				Reclock("SCR",.F.)
				CR_STATUS := If(SAL->AL_TPLIBER=="P","05",;
					If(( Empty(cNivIgual) .Or. cNivIgual == CR_NIVEL ) .And. cStatusAnt <> "01" ,"02",CR_STATUS))

				If CR_STATUS == "05"
					CR_DATALIB	:= dDataLib
				EndIf
				MsUnlock()
				cNivIgual := CR_NIVEL					
				lAchou    := .F.
			Endif

			cStatusAnt := SCR->CR_STATUS

			dbSkip()
		EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Reposiciona e verifica se ja esta totalmente liberado.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbGoto(nRec)
		While !Eof() .And. xFilial("SCR")+cTipoDoc+cDocto == CR_FILIAL+CR_TIPO+CR_NUM
			If CR_STATUS != "03" .And. CR_STATUS != "05"
				lRetorno := .F.
			EndIf
			dbSkip()
		EndDo
		If SAL->AL_LIBAPR == "A"
			dbSelectArea("SCS")
			If dbSeek(xFilial()+cAprov+dToS(dDataRef))
				Reclock("SCS",.F.)
			Else
				Reclock("SCS",.T.)                                    
			EndIf
			CS_FILIAL:= xFilial("SCS")
			CS_SALDO := CS_SALDO - nValDcto
			CS_APROV := cAprov
			CS_USER	 := cUsuario
			CS_MOEDA := nMoeDcto
			CS_DATA	 := dDataRef
			MsUnlock()
		EndIf
	EndIf
	
	If nOper == 5  //Estorno da Aprovacao
		cGrupo := If(!Empty(aDocto[6]),aDocto[6],cGrupo)
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSelectArea("SCR")
		dbSetOrder(1)
		dbSeek(xFilial("SCR")+cTipoDoc+cDocto)
		nMoeDcto := SCR->CR_MOEDA
		nTxMoeda := SCR->CR_TXMOEDA
		While !Eof() .And. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM == xFilial("SCR")+cTipoDoc+cDocto
			If SCR->CR_STATUS == "03"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Reposiciona o usuario aprovador.               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SAK")
				dbSeek(xFilial("SAK")+SCR->CR_LIBAPRO)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona a Tabela SAL pelo Aprovador de Origem caso o Documento tenha sido ³
				//| transferido por Ausência Temporária ou Transferência superior e o aprovador |
				//| de destino não fizer parte do Grupo de Aprovação.                           |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SAL")
				dbSetOrder(3)
				dbSeek(xFilial("SAL")+cGrupo+SAK->AK_COD)
				If Eof()
				    If !Empty(SCR->(FieldPos("CR_USERORI")))
			    		dbSeek(xFilial("SAL")+cGrupo+SCR->CR_APRORI) 
	    			EndIf
	   			EndIf
	   			
				If SAL->AL_LIBAPR == "A"
					dbSelectArea("SCS")
					dbSetOrder(2)
					If dbSeek(xFilial("SCS")+SAK->AK_COD+DTOS(MaAlcDtRef(SAK->AK_COD,SCR->CR_DATALIB)))
						RecLock("SCS",.F.)
						SCS->CS_SALDO := SCS->CS_SALDO + If(nValDcto>0 .And. nValDcto < SCR->CR_VALLIB,nValDcto,SCR->CR_VALLIB)
						If SCS->CS_SALDO > SAK->AK_LIMITE
							SCS->CS_SALDO := SAK->AK_LIMITE
						EndIf
						MsUnlock()
					EndIf
				EndIf
			EndIf
			Reclock("SCR",.F.,.T.)
			If nValDcto > 0 .And. nValDcto < SCR->CR_TOTAL
				SCR->CR_TOTAL	:= SCR->CR_TOTAL - nValDcto
				SCR->CR_VALLIB	:= SCR->CR_VALLIB - nValDcto
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³A variavel lResiduo informa se devera ou nao reconstituir um  ³
				//³novo bloqueio SCR  se ainda houver saldo apos a eliminacao de ³
				//³residuos, em caso da opcao de estorno a recosntituicao do SCR ³
				//³e obrigatoria, apos a delecao.                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				If lResiduo
					lDeletou := IF(SCR->CR_TOTAL - nValDcto > 0,.T.,.F.)
				Else
					lDeletou := .T.
				EndIf
				dbDelete()
			EndIf
			MsUnlock()
			dbSkip()
		EndDo

		dbSelectArea("SAL")
		SAL->(dbSetOrder(2))
		If	(!Empty(cGrupo) .And. dbSeek(xFilial("SAL")+cGrupo) .And. nValDcto > 0 .And. lDeletou) .Or. ;
			(!Empty(cGrupo) .And. dbSeek(xFilial("SAL")+cGrupo) .And. cTipoDoc == "NF" .And. lDeletou)
			
			While !Eof() .And. xFilial("SAL")+cGrupo == AL_FILIAL+AL_COD

                If cTipoDoc <> "NF"  
					If SAL->AL_AUTOLIM == "S" .And. !MaAlcLim(SAL->AL_APROV,nValDcto,nMoeDcto,nTxMoeda)
						dbSelectArea("SAL")
						dbSkip()
						Loop
					EndIf             	
                EndIf
                 				
				If lFirstNiv
					cAuxNivel := SAL->AL_NIVEL
					lFirstNiv := .F.
				EndIf
				Reclock("SCR",.T.)
				SCR->CR_FILIAL	:= xFilial("SCR")
				SCR->CR_NUM		:= cDocto
				SCR->CR_TIPO	:= cTipoDoc
				SCR->CR_NIVEL	:= SAL->AL_NIVEL
				SCR->CR_USER	:= SAL->AL_USER
				SCR->CR_APROV	:= SAL->AL_APROV
				SCR->CR_STATUS	:= IIF(SAL->AL_NIVEL == cAuxNivel,"02","01")
				SCR->CR_TOTAL	:= nValDcto
				SCR->CR_EMISSAO:= dDataRef
				SCR->CR_MOEDA	:=	nMoeDcto
				SCR->CR_TXMOEDA:= nTxMoeda
				MsUnlock()
				dbSelectArea("SAL")
				dbSkip()
			EndDo
		EndIf
		lRetorno := lFirstNiv
	EndIf
	
	If nOper == 6  //Bloqueio manual
		dbSelectArea("SAK")
		dbSetOrder(1)
		dbSeek(xFilial("SAK")+cAprov)
	
		Reclock("SCR",.F.)
		CR_STATUS   := "04"
		CR_OBS	    := If(Len(aDocto)>10,aDocto[11],"")
		CR_DATALIB  := dDataRef
		CR_USERLIB	:= SAK->AK_USER
		CR_LIBAPRO	:= SAK->AK_COD
		cAuxNivel   := CR_NIVEL
		MsUnlock()
		lRetorno 	:= .F.
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Bloqueia todos os Aprovadores do Nível  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSeek(xFilial("SCR")+cTipoDoc+cDocto+cAuxNivel)
		nRec := RecNo()
		While !Eof() .And. xFilial("SCR")+cDocto+cTipoDoc+cAuxNivel == CR_FILIAL+CR_NUM+CR_TIPO+CR_NIVEL
			If CR_STATUS != "04" 
				Reclock("SCR",.F.)
				CR_STATUS	:= "05"
				// Toni Aguiar - TOTVS STARSOFT Em 15/08/2017
				// CR_OBS	    := STR0061+SAK->AK_COD
				CR_OBS	    := SAK->AK_COD
				CR_DATALIB	:= dDataRef
				CR_USERLIB	:= SAK->AK_USER
				CR_LIBAPRO	:= SAK->AK_COD
				MsUnlock()
			EndIf             
			                                           
			dbSkip()
		EndDo
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao ACC envia aprovacao do pedido            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. cTipoDoc == "PC" .And. (nOper == 1 .Or. nOper == 4) .And. If(FindFunction("WebbConfig"),WebbConfig(),.F.)
		aAreaSC7 := SC7->(GetArea())
		
		SC7->(dbSetOrder(1))
		If SC7->(dbSeek(xFilial("SC7")+AllTrim(cDocto))) .And. !Empty(SC7->C7_ACCNUM)	
			If IsBlind()
				Webb533(SC7->C7_NUM)
			Else
				MsgRun("Aguarde, comunicando aprovação ao portal...","Portal ACC",{|| Webb533(SC7->C7_NUM)})	//Aguarde, comunicando aprovação ao portal... ## Portal ACC
			EndIf
		EndIf
		
		dbSelectArea("SC7")
		RestArea(aAreaSC7)
	EndIf
	
	If ExistBlock("MTALCDOC")
		Execblock("MTALCDOC",.F.,.F.,{aDocto,dDataRef,nOper})
	Endif	
EndIf

If ExistBlock("MTALCFIM")
	lCalculo := Execblock("MTALCFIM",.F.,.F.,{aDocto,dDataRef,nOper,cDocSF1,lResiduo})
	If Valtype( lCalculo ) == "L"
		lRetorno := lCalculo
	EndIf
Endif

dbSelectArea("SCR")
RestArea(aAreaSCR)
dbSelectArea("SCS")
RestArea(aAreaSCS)
RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} GetGrpAprov
Busca Grupos de Aprovação.
@type function 
@author Ricardo Tavares Ferreira
@version 12.1.27
@return array, Array com os dados da entidade contabil.
@since 13/04/2022
@history 13/04/2022, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//=============================================================================================================================
    Static Function GetGrpAprov(xFil,cCodGrp)
//=============================================================================================================================

	Local QbLinha	:= chr(13)+chr(10)
	Local cQuery	:= ""
	Local nQtdReg  	:= 0
    Local lRet      := .T.

    cQuery := " SELECT SAL.R_E_C_N_O_ IDSAL, SAL.* "+QbLinha
    cQuery += " FROM "+QbLinha 
    cQuery +=   RetSqlName("SAL") + " SAL "+QbLinha
    cQuery += " WHERE "+QbLinha 
    cQuery += " SAL.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND AL_FILIAL = '"+xFil+"' "+QbLinha
    cQuery += " AND AL_COD = '"+cCodGrp+"' "+QbLinha
        
	MemoWrite("C:/ricardo/ValidaGrupoAprovacao_CNZ.sql",cQuery)			     
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSAL,.F.,.T.)
            
    DbSelectArea(cAliasSAL)
    (cAliasSAL)->(DbGoTop())
    Count To nQtdReg
    (cAliasSAL)->(DbGoTop())
            
    If nQtdReg <= 0
        lRet := .F.
        (cAliasSAL)->(DbCloseArea())
	EndIf  
Return lRet
