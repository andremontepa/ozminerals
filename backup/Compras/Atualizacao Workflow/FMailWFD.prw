#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EnvWfComD ºAutor  ³Microsiga           º Data ³  07/25/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função Que tem como Objetivo Enviar Workflow de Compra      º±±
±±º          ³que tem o Status = 02 Aguardando Liberação Diario.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ avanco                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FMailWFD()             
Local aArrayUsr    := {}
Local nX           := 0
Local cNameEmp     := ""
Private xProcesso  := ""
Private xUserMail  := ""
Private cAviso     := ''
Private cPulaLinha := Chr(13)+Chr(10)
Private oTabTemp	:= Nil 
Private nStart      := 0

//Prepare Environment Empresa "01" Filial "01"

Private aTables := {"SCR","SC7","SA1","SA2","SC1"}//seta o ambiente com a empresa 99 filial 01 com os direitos do usuario administrador, módulo CTB
RpcSetEnv( "01","01", "admin", "AVB#123", "COM", "CTBA102", aTables, , , ,  )/****** COMANDOS *************/

FwLogMsg("FMailWFD", /*cTransactionId*/, "FMailWFD", FunName(), "","WF ENVIA E-MAIL DIARIO Data: "+dtoc(ddatabase)+ "Hora: "+time()+" WorkFlow Iniciado ", 0, (nStart - Seconds()), {})

If(SELECT("TMP1") > 0)
	TMP1->(DBCLOSEAREA())
Endif

cQuery:= " SELECT DISTINCT(SC7.C7_FILIAL),SC7.C7_EMISSAO,SC7.C7_NUM,SC7.C7_FORNECE,SC7.C7_LOJA,SC7.C7_CC,SCR.CR_TOTAL TOTAL,SC7.C7_XWFID,SC7.C7_XWFMAIL,CR_STATUS,C7_XOBSFLU,"
cQuery+= " (CASE WHEN (SELECT distinct(SCRB.CR_FILIAL+SCRB.CR_NUM) FROM SCR010 SCRB WHERE SCRB.CR_FILIAL = SC7.C7_FILIAL AND SCRB.CR_NUM = SC7.C7_NUM AND SCRB.D_E_L_E_T_  = ' ' AND SCRB.CR_STATUS IN ('04') )  <> ' '  THEN 'Ped.Bloqueado'  ELSE 'Aguard.Liberacao' END) STATUS "
cQuery+= " ,'AVANCO' as EMPRESA "
cQuery+= " FROM  "
cQuery+= " SC7010 SC7, "
cQuery+= " SCR010 SCR  "
cQuery+= " WHERE SC7.D_E_L_E_T_= ' ' "
cQuery+= " AND SCR.D_E_L_E_T_ =  ' ' "
cQuery+= " AND SC7.C7_FILIAL  =  SCR.CR_FILIAL "
cQuery+= " AND SC7.C7_NUM 	  =  SCR.CR_NUM "
cQuery+= " AND SC7.C7_EMISSAO >= '20140702' "
cQuery+= " AND SCR.CR_STATUS  in ('02') "
cQuery+= " AND SC7.C7_CONAPRO = 'B' "                          
cQuery+= " AND C7_RESIDUO <> 'S' "
cQuery+= " AND ( SC7.C7_ITEM   = (SELECT MIN(SC7L.C7_ITEM) FROM SC7010 SC7L WHERE SC7.C7_FILIAL = SC7L.C7_FILIAL AND SC7.C7_NUM = SC7L.C7_NUM AND SC7L.D_E_L_E_T_ = ' ' )) "
cQuery+= " AND SC7.C7_FILIAL+SC7.C7_NUM NOT IN(SELECT DISTINCT(SCRB.CR_FILIAL+RTRIM(LTRIM(SCRB.CR_NUM))) FROM SCR010 SCRB WHERE SCRB.CR_FILIAL = SC7.C7_FILIAL AND SCRB.CR_NUM      = SC7.C7_NUM AND SCRB.D_E_L_E_T_   = ' ' AND SCRB.CR_STATUS  IN ('04') )  "
cQuery+= " AND C7_XWFID <> ' '  "

cQuery+= "	ORDER BY C7_XWFMAIL,C7_FILIAL,C7_NUM"

tcquery cQuery new alias "TMP1"
tcsetfield("TMP1","C7_EMISSAO" ,"D")

FATA002C("ALS_SC7",{{"C7_FILIAL","C",4,0},{"C7_NUM","C",6,0},{"C7_FORNECE","C",8,0},{"C7_LOJA","C",2,0},{"C7_NOME","C",60,0};
,{"C7_EMISSAO","D",8,0},{"C7_VALOR","N",14,2},{"C7_XWFID","C",30,0},{"C7_USUARIO","C",6,0},{"C7_ANEXO","C",200,0},{"C7_VENCTO","D",8,0},{"C7_EMPRESA","C",25,0}},"C7_USUARIO+C7_NUM")


While ! TMP1->(eof())
	xprocesso:= TMP1->C7_XWFID
	aArrayUsr:= STRTOKARR(TMP1->C7_XWFMAIL,";")
	
	For nX:=1 to Len(aArrayUsr)
		
		If !Empty(aArrayUsr[nX])  
		
			ALS_SC7->(DbSetOrder(1))
			Reclock("ALS_SC7",.T.)
				ALS_SC7->C7_FILIAL		:= TMP1->C7_FILIAL
				ALS_SC7->C7_NUM		    := TMP1->C7_NUM
				ALS_SC7->C7_FORNECE		:= TMP1->C7_FORNECE
				ALS_SC7->C7_LOJA		:= TMP1->C7_LOJA
				ALS_SC7->C7_NOME		:= Posicione("SA2",1,xFilial("SA2")+TMP1->C7_FORNECE+TMP1->C7_LOJA,"A2_NOME")
				ALS_SC7->C7_EMISSAO		:= TMP1->C7_EMISSAO
				ALS_SC7->C7_VALOR		:= TMP1->TOTAL
				ALS_SC7->C7_XWFID		:= Alltrim(xprocesso)
				ALS_SC7->C7_USUARIO     := aArrayUsr[nX]
				ALS_SC7->C7_ANEXO       := TMP1->C7_XOBSFLU
				//ALS_SC7->C7_VENCTO      := Posicione("ZZ5",1,TMP1->C7_FILIAL+TMP1->C7_NUM+'E'+'001',"ZZ5_VENC")
				//ALS_SC7->C7_EMPRESA	    := Alltrim(TMP1->EMPRESA)
			ALS_SC7->(MsUnlock())    
			
		EndIf
		
	Next Nx
	
	TMP1->(dbskip())
Enddo

cUsrMailWF := " "
nContador  := 1
cC7Anexo   := " "
nhandle    := ' ' 
		
ALS_SC7->(DbGoTop())
ALS_SC7->(DbSetOrder(1))
While ALS_SC7->(!EOF())
	
	//Cabecario
	
	if cUsrMailWF <> ALS_SC7->C7_USUARIO
		
		if nContador > 1
			
			nhandle +='</table>'
			nhandle +='</body> '
			nhandle +='</html> '
			
			nContador   := 1
						
 			cc    		:=  UsrRetMail(cUsrMailWF)  
									
			cAviso 		:= 'Solicitação de Aprovacao de Pedidos de compra que estão aguardando a liberação E-Mail Diario.'

     	  	cCopia      := ''
			cC7Anexo    := ''
			
//			cc          := "adrianogtitec@gmail.com"
			
			u_EnviEmail(cC7Anexo,'Aviso - '+cAviso+'','Aviso - '+cAviso+'',nhandle,.t.,cc,cCopia)
			
			cC7Anexo  := " "
			
		EndIf
		
		nhandle :='<html>' 
		nhandle +='<body bgcolor="#FFFFFF" >'
		nhandle +='</script><noscript>'		
		nhandle +='<pre><font color="#FF0000" size="2" face="Verdana"><b></b></font></pre>'
		nhandle +='</noscript>'
		nhandle +='    <table border="0" width="100%"> '
		nhandle +='      <tr> '
		nhandle +='        <td width="9%"> '
		nhandle +='		<img border="0" src="http://avancoresources.com/wp-content/uploads/AvancoLogo.png" border="0" width="263" height="123"></td>'
		nhandle +='        <td width="64%">'
		nhandle +='          <p align="center"><b><font face="Verdana" size="5">Prezado(a): '+&('capital(UsrFullName(ALS_SC7->C7_USUARIO))')+' Segue relação de'
		nhandle +='			pedidos</font></b>'
		nhandle +='		  <p align="center"><b><font face="Verdana" size="5">que estão aguardando liberação.</font></b>'
		nhandle +='        </td>  '
		nhandle +='        <td width="27%"></td> '
		nhandle +='      </tr>'
		nhandle +='    </table>'
		nhandle +='  <p><font color="Black" face="Verdana" size="2"><b>Lista de Pedidos de Compras:</b></font>   '
		nhandle +='	<font color="Green" size="2" face="Verdana">   '
		nhandle +='    <table border="1" width="1100"">      '
		//nhandle +='  <tr>                    '
		
		
		//	nhandle :='<table border="1">'
		nhandle +='<tr>'
		nhandle +='<td width="75"  bgcolor="#000080"><font size="2"face="Verdana" color="White"><b>FILIAL</b></font></td>
		nhandle +='<td width="75"  bgcolor="#000080"><font size="2"face="Verdana" color="White"><b>PEDIDO</font></b></td>'
		nhandle +='<td width="75"  bgcolor="#000080"><font size="2"face="Verdana" color="White"><b>FORNECEDOR</font></b></td>'
		nhandle +='<td width="75"  bgcolor="#000080"><font size="2"face="Verdana" color="White"><b>LOJA</font></b></td>'
		nhandle +='<td width="75"  bgcolor="#000080"><font size="2"face="Verdana" color="White"><b>NOME</font></b></td>'
		nhandle +='<td width="75"  bgcolor="#000080"><font size="2"face="Verdana" color="White"><b>EMISSAO</font></b></td>'
		nhandle +='<td width="75"  bgcolor="#000080"><font size="2"face="Verdana" color="White"><b>VALOR</font></b></td>'
	 	nhandle +='<td width="75"  bgcolor="#000080"><font size="2"face="Verdana" color="White"><b>EMPRESA</font></b></td>'
		nhandle +='<td width="500" bgcolor="#000080"><font size="2"face="Verdana" color="White"><b>LINK APROVACAO</font></b></td>'
		nhandle +='</tr>'
		
	EndIf
	
	//Itens
	
	nhandle +='<tr>'//começo da linha
	nhandle +='<td width="60"><font  size="2" face="Arial">'+ALS_SC7->C7_FILIAL+'</font></td>'
	nhandle +='<td width="60"><font  size="2" face="Arial">'+ALS_SC7->C7_NUM+'</font></td>'
	nhandle +='<td width="60"><font  size="2" face="Arial">'+ALS_SC7->C7_FORNECE+'</font></td>'
	nhandle +='<td width="60"><font  size="2" face="Arial">'+ALS_SC7->C7_LOJA+'</font></td>'
	nhandle +='<td width="550"><font size="2" face="Arial">'+ALS_SC7->C7_NOME+'</font></td>'
	nhandle +='<td width="60"><font  size="2" face="Arial">'+Dtoc(ALS_SC7->C7_EMISSAO)+'</font></td>'
	nhandle +='<td width="60"><font  size="2" face="Arial">'+Transform(ALS_SC7->C7_VALOR,"@E 999,999,999.99")+'</font></td>'

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

	nhandle +='<td width="60"><font  size="2" face="Arial">'+cNameEmp+'</font></td>'


	nhandle +='<td width="500"><font size="2" face="Arial"><p><a href="http://10.106.10.20:9090/messenger/emp01/pedcom/'+Alltrim(ALS_SC7->C7_XWFID)+'.htm?user='+Alltrim(ALS_SC7->C7_USUARIO)+'">Acesso Interno</a></p></font></td>'
		
	
	nhandle +='</tr>'
	
	nContador++      
	
	cUsrMailWF := ALS_SC7->C7_USUARIO
	cC7Anexo   += Alltrim(ALS_SC7->C7_ANEXO)
	
	ALS_SC7->(DbSkip())
	
EndDo

if nContador > 1	

	nhandle +='</table>'
	nhandle +='</body> '
	nhandle +='</html> '
	
	nContador   := 1	

	cc    		:= UsrRetMail(cUsrMailWF)  

	cAviso 		:= 'Solicitação de Aprovacao de Pedidos de compra que estão aguardando a liberação E-Mail Diario.'

	cCopia      := ''
	
//	cc			:= "adrianogtitec@gmail.com"
	
	u_EnviEmail('','Aviso - '+cAviso+'','Aviso - '+cAviso+'',nhandle,.t.,cc,cCopia)	

EndIf
		
FwLogMsg("FMailWFD", /*cTransactionId*/, "FMailWFD", FunName(), "","( WF ENVIA E-MAIL DIARIO Data: "+dtoc(ddatabase)+ "Hora: "+time()+" E-mail Enviado com Sucesso ", 0, (nStart - Seconds()), {})

//Reset Environment
RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões
oTabTemp:Delete()
Return Nil               

Static Function FATA002C(cAlias,aCampos,cIndice)

Local cIndTemp	:= cIndice
Local cAliasTemp:= cAlias
Local _stru		:= aClone(aCampos)

oTabTemp := FWTemporaryTable():New(cAliasTemp, _stru)
oTabTemp:AddIndex("01",cIndTemp)
oTabTemp:Create()

Return Nil
