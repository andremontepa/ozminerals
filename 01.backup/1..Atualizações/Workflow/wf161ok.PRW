#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WF161ok   ºAutor  ³Ismael Junior       ºData  ³  24/06/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envia workflow ao gestor do centro de custos.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM 												      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User function WF161ok(aDados)
Local oHTML
Local _cSol     := cUserName
Local nX        := 0
PswOrder(2)    // ordenado pelo nome
If PswSeek(_cSol, .T. )
	aInfo := PswRet()
	cIDSolicit  := alltrim(aInfo[1][1])
	cEmailSoli  := Alltrim(aInfo[1][14])
EndIf
For nX := 1 To Len(aDados)
//Busca os aprovadores selecionados
cQuery := " SELECT TOP 1 ZW4_EMAIL EMAIL "
cQuery += " FROM "+RetSqlName("ZW4")+" ZW4 "
cQuery += " INNER JOIN "+RetSqlName("ZW5")+" ZW5 ON ZW4_NUM = ZW5_NUM AND ZW5_FILIAL = '"+xFilial("ZW5")+"' AND ZW5.D_E_L_E_T_ != '*' "
cQuery += " WHERE ZW5_CCUSTO = '"+aDados[nX][1]+"' " 
cQuery += " AND ZW5_ITEMCO = '"+aDados[nX][6]+"' "
cQuery += " AND ZW4_FILIAL = '"+xFilial("ZW5")+"' "
cQuery += " AND ZW4.D_E_L_E_T_ != '*' "

If SELECT("TRB") > 0
	TRB->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)

DbSelectArea("TRB")
TRB->(dbGoTop())

cBody := '<html>'
cBody += '<head>'
cBody += '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
cBody += '<meta name="GENERATOR" content="Microsoft FrontPage Express 2.0">'
cBody += '<title>SOLICITAÇÃO DE COMPRA SEM SALDO</title>'
cBody += '</head>'
cBody += '<body bgcolor="#FFFFFF">'
cBody += '<form action="mailto:%WFMailTo%" method="POST" name="FrontPage_Form1">'
cBody += '<p>Solicitação de compra sem saldo</p>'
cBody += '<p>Data        : '+DTOC(dDataBase)+'</p>'
cBody += '<p>Solicitante : '+_cSol+'</p>'
cBody += '<p>Email solici: '+cEmailSoli+'</p>'
cBody += '<p>Pedido      : '+aDados[nX][4]+'</p>'
cBody += '<table border="2">'
cBody += '<tr>'
cBody += '<td colspan="5" rowspan="1" style="font-size: 12px; text-align: center; width: 65px; background-color: rgb(165, 42, 42);"><big style="color: rgb(255, 255, 255);"><strong>Centro de custo, item, nº da conta, valor Pedido e saldo da conta</strong></big><strong></strong>/td>'
cBody += '<tr>'
cBody += '<td width="450">C. Custo, item e conta</td>'
cBody += '<td width="200">Valor Pedido</td>'
cBody += '<td width="200">Saldo conta</td>'
cBody += '</tr>'
cBody += '<tr>'
cBody += '<td>'+aDados[nX][2]+'</td> '
cBody += '<td>'+Transform(aDados[nX][3],"@E 999,999,999.99")+'</td>'
cBody += '<td>'+Transform(aDados[nX][5],"@E 999,999,999.99")+'</td>'
cBody += '</tr>'
cBody += '</tr>'
cBody += '</table>'
cBody += '</form>'
cBody += '<p>&nbsp;</p>'
cBody += '<p>&nbsp;</p>'
cBody += '</body>'
cBody += '</html>'
//Inicio o Processo, enviando o e-mail.
u_EnviEmail('','WorkFlow | Aviso solicitacao sem saldo','Solicitacao sem recursos disponiveis',cBody,.T.,AllTrim(TRB->EMAIL),'')
//oProcess:Start()
Next nX
Return .T.