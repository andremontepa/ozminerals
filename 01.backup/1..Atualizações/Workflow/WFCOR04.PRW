#include "rwmake.ch"
#include "fileio.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "protheus.ch"

#Define CLRF CHAR(13) + CHAR(10)
#DEFINE PROCESOWF "CARPETA"            //Nombre de la carpeta donde se guarda el archivo htm
#DEFINE HTMLPATH  "\web\ws\"           //Ruta hacia donde se debe mover el archivo htm

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WFCOR04   ºAutor  ³Ismael Junior       ºData  ³  23/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envia workflow ao superior do gestor do centro de custos.   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM 												      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User function WFCOR04( nOpcao, oProcess,cCcusto1,cItemco1,cClvl1,cConta1,cCcusto2,cItemco2,cClvl2,cConta2,cValor,cSlMotiv )
Private cSrver   :=Getmv("MV_WFSERVE")		// IP SERVIDOR EXTERNO 191.200.30.5
Private cSrvInt  :=Getmv("MV_WFSERVI")      // IP SERVIDOR INTERNO 192.168.0.200
Private cPrto    :=Getmv("MV_WFPORTA")		// PORTA EXEMPLO "10700"
Private nStart      := 0

bandera:=getmv("MV_WFACTI",,0)     //ativa o funcionamento do workflow
                                                           
if bandera == 1
	FwLogMsg("WFCOR04", /*cTransactionId*/, "WFCOR04", FunName(), "", "01",'Novo processo, a bandera de ativacao e 1', 0, (nStart - Seconds()), {})	
	If nOpcao == NIL
		nOpcao := 0
	ENDIF
	
	If oProcess == NIL
		oProcess := TWFProcess():New( "000002", "Solictação de transferência Recursos" )
	else
		
	ENDIF
	
	FwLogMsg("WFCOR04", /*cTransactionId*/, "WFCOR04", FunName(), "", "01",'Opção localizada, opção 0: '+str(nOpcao), 0, (nStart - Seconds()), {})
    Do Case
	  Case nOpcao == 0  // Envio
		FwLogMsg("WFCOR04", /*cTransactionId*/, "WFCOR04", FunName(), "", "01",'Inicia aprovação de nova solicitação', 0, (nStart - Seconds()), {})
		SRIniciar(nOpcao,oProcess,cCcusto1,cItemco1,cClvl1,cConta1,cCcusto2,cItemco2,cClvl2,cConta2,cValor,cSlMotiv )
	  Case nOpcao == 1  // Retorno
		FwLogMsg("WFCOR04", /*cTransactionId*/, "WFCOR04", FunName(), "", "01",'Solicitacao : opcao 1 selecionada', 0, (nStart - Seconds()), {})
		SRRetorno( oProcess )
      Case nOpcao == 2  // Timeout
		FwLogMsg("WFCOR04", /*cTransactionId*/, "WFCOR04", FunName(), "", "01",'Solicitacao : opcao 2 selecionada', 0, (nStart - Seconds()), {})
		SRTimeOut( oProcess )
	End	
	
	
Endif
RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SRIniciar º Autor ³ Ismael Junior      º Data ³  23/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para solicitação de transferência de recursos       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SRIniciar(nOpc,oProcess,cCcusto1,cItemco1,cClvl1,cConta1,cCcusto2,cItemco2,cClvl2,cConta2,cValor,cSlMotiv)
//Local cCadastro := "Envio de Email"
Local cMail     := " "
Local _cSol     := cUserName
Local cQuery    := ""
Local cSQL      := "TRA"
Local cAno      := Alltrim(Str(Year(Date())))

If Empty(cCcusto1) 
	MsgAlert("Campo Centro de custo origem não pode ser vazio!","Atenção")
	Return()
Elseif Empty(cItemco1) 
	MsgAlert("Campo Conta Contabíl origem não pode ser vazio!","Atenção")
	Return()
Elseif Empty(cClvl1) 
	MsgAlert("Campo Classe origem não pode ser vazio!","Atenção")
	Return() 	
Elseif Empty(cConta1) 
	MsgAlert("Campo Conta origem não pode ser vazio!","Atenção")
	Return() 
ElseIf Empty(cCcusto2) 
	MsgAlert("Campo Centro de custo destino não pode ser vazio!","Atenção")
	Return()
Elseif Empty(cItemco2) 
	MsgAlert("Campo Item Contabíl destino não pode ser vazio!","Atenção")
	Return()
Elseif Empty(cClvl2) 
	MsgAlert("Campo Conta destino não pode ser vazio!","Atenção")
	Return()	
Elseif Empty(cConta2) 
	MsgAlert("Campo Classe destino não pode ser vazio!","Atenção")
	Return()
Elseif Empty(cValor)
	MsgAlert("Campo Valor não pode ser vazio!","Atenção")
	Return()
Elseif cValor <= 0
	MsgAlert("Campo Valor não pode ser menor ou igual a zero!","Atenção")
	Return() 
Elseif Empty(cSlMotiv)
	MsgAlert("Campo Motivo não pode ser vazio!","Atenção")
	Return() 
Elseif cCcusto1 <> cCcusto2
	MsgAlert("Não é permitido a transferência entre centros de custos diferentes!","Atenção")
	Return()
Endif

//Verifica se saldo de origem e maior que zero
cQuery := " SELECT SUM(ZW2_PREANO) VALOR FROM "+RetSqlName("ZW2")+ " ZW2 " 
cQuery += " WHERE ZW2_CCUSTO = '"+Alltrim(cCcusto1)+"' "
cQuery += " AND ZW2_ITEMCO = '"+Alltrim(cItemco1)+"' "
cQuery += " AND ZW2_CLVL = '"+Alltrim(cClvl1)+"' "
cQuery += " AND ZW2_CONTA= '"+Alltrim(cConta1)+"' "
cQuery += " AND ZW2_ANO = '"+cAno+"' "
cQuery += " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
cQuery += " AND ZW2.D_E_L_E_T_ != '*' "  

If SELECT(cSQL) > 0
	(cSQL)->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSQL,.T.,.T.)

If (cSQL)->VALOR <= 0 
	MsgAlert("Saldo da origem não poder ser menor ou igual a zero! ","Atenção") 
	Return()
Endif

If cValor > (cSQL)->VALOR 
	MsgAlert("Valor de tranferência não pode ser maior do que o saldo da origem! ","Atenção") 
	Return()
Endif

//Verifica a existência do centro de custo na origem   
cQuery := " SELECT ZW1_CCUSTO AS ORIGEM FROM "+RetSqlName("ZW1")+" ZW1 "
cQuery += " INNER JOIN "+RetSqlName("ZW2")+" ZW2 ON ZW2_NUM = ZW1_NUM AND ZW2.D_E_L_E_T_ != '*' "
cQuery += " WHERE ZW1_CCUSTO = '"+cCcusto1+"' "
cQuery += " AND ZW1_ITEMCO = '"+cItemco1+"' "
cQuery += " AND ZW1_CLVL = '"+cClvl1+"' " 
cQuery += " AND ZW2_CONTA= '"+Alltrim(cConta1)+"' "
cQuery += " AND ZW1_ANO = '"+cAno+"' "
cQuery += " AND ZW1_FILIAL = '"+xFilial("ZW1")+"' "
cQuery += " AND ZW1.D_E_L_E_T_ != '*' "

If SELECT(cSQL) > 0
	(cSQL)->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSQL,.T.,.T.) 
If Empty((cSQL)->ORIGEM) 
MsgAlert("Centro de custo, Item Contabíl ou Clase de valor não encontrado na origem","Atenção") 
Return()
Endif

//Verifica a existência do centro de custo no destino 
cQuery := " SELECT ZW1_CCUSTO AS DESTINO FROM "+RetSqlName("ZW1")+" ZW1 "
cQuery += " INNER JOIN "+RetSqlName("ZW2")+" ZW2 ON ZW2_NUM = ZW1_NUM AND ZW2.D_E_L_E_T_ != '*' "
cQuery += " WHERE ZW1_CCUSTO = '"+cCcusto2+"' "
cQuery += " AND ZW1_ITEMCO = '"+cItemco2+"' "
cQuery += " AND ZW1_CLVL = '"+cClvl2+"' "
cQuery += " AND ZW2_CONTA= '"+Alltrim(cConta2)+"' "
cQuery += " AND ZW1_ANO = '"+cAno+"' "
cQuery += " AND ZW1_FILIAL = '"+xFilial("ZW1")+"' "
cQuery += " AND ZW1.D_E_L_E_T_ != '*' "

If SELECT(cSQL) > 0
	(cSQL)->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSQL,.T.,.T.) 
If Empty((cSQL)->DESTINO) 
MsgAlert("Centro de custo, Item Contabíl ou Clase de valor não encontrado no destino!","Atenção") 
Return()
Endif

PswOrder(2)    // ordenado pelo nome
If PswSeek(_cSol, .T. )
	aInfo := PswRet()
	cIDSolicit  := alltrim(aInfo[1][1])
	cEmailSoli  := Alltrim(aInfo[1][14])
EndIf

oProcess:NewTask( "Solicitação ","\WORKFLOW\WfCor04.HTM" )
oProcess:cSubject := "Transferência de recursos: "+cCcusto1+" / "+cItemco1+" / "+cClvl1+" / "+cConta1+ " Para "+cCcusto2+" / "+cItemco2+" / "+cClvl2+" / "+cConta2    
oProcess:cBody	  := "Por favor verifique o arquivo anexado para aprovar ou rejeitr a solictação de transferência recursos: "
oProcess:bReturn  := "U_WFCOR04(1)"
oProcess:bTimeOut := {"U_WFCOR04(2)",30, 05, 50 }  // Para timeout {{"FUNCION()",DIAS, HORAS, MINUTOS }}
oHTML             := oProcess:oHTML

oHTML:ValByName( "empresa", Alltrim(SM0->M0_NOMECOM) )
oHTML:ValByName( "solicit", _cSol )
oHTML:ValByName( "emailsol", cEmailSoli )
oHtml:ValByName( "data", DTOC(Date()))

oHtml:ValByName( "ccusto1", Alltrim(cCcusto1))
oHtml:ValByName( "citemco1", Alltrim(cItemco1))
oHtml:ValByName( "cclvl1", Alltrim(cClvl1))
oHtml:ValByName( "cconta1", Alltrim(cConta1))

oHtml:ValByName( "ccusto2", Alltrim(cCcusto2))
oHtml:ValByName( "citemco2", Alltrim(cItemco2))
oHtml:ValByName( "cclvl2", Alltrim(cClvl2))
oHtml:ValByName( "cconta2", Alltrim(cConta2))
oHtml:ValByName( "cvalor", Transform(cValor,"@E 999,999,999.99"))

/*
///////////////////////////////////////////////////////////////////////////
///	BUSCA O E-MAIL DO GESTOR DO CENTRO DE CUSTOS                     	///
///////////////////////////////////////////////////////////////////////////
*/

//Busca os aprovadores selecionados
cQuery := " SELECT TOP 1 ZW4_MAILSU EMAIL "
cQuery += " FROM "+RetSqlName("ZW4")+" ZW4 "
cQuery += " INNER JOIN "+RetSqlName("ZW5")+" ZW5 ON ZW4_NUM = ZW5_NUM AND ZW5_FILIAL = '"+xFilial("ZW5")+"' AND ZW5.D_E_L_E_T_ != '*' "
cQuery += " WHERE ZW5_CCUSTO = '"+cCcusto1+"' "
cQuery += " AND ZW5_ITEMCO = '"+cItemco1+"' "
cQuery += " AND ZW4_FILIAL = '"+xFilial("ZW5")+"' "
cQuery += " AND ZW4.D_E_L_E_T_ != '*' "

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
If SELECT(cSQL) > 0
	(cSQL)->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSQL,.T.,.T.)

If !Empty((cSQL)->EMAIL)
cMail := (cSQL)->EMAIL
oHtml:ValByName( "cmotivo", Alltrim(cSlMotiv))
oProcess:ClientName( Subs(cUsuario,7,15) )
oProcess:cTo      := PROCESOWF
cMailID:=oProcess:Start()

////////////////////////////////////////////////////////////////////////////////////////////////////
FwLogMsg("WFCOR04", /*cTransactionId*/, "WFCOR04", FunName(), "", "01","ID WF: "+ cMailID, 0, (nStart - Seconds()), {})
cDirHttp := AllTrim(GetMV("MV_WFDHTTP"))

/*
///////////////////////////////////////////////////////////////////////////
///Movemos o arquivo gerado ao diretorio do webservices	    			///
///para que se possa executar o HTTP POST corretamente  				///
///////////////////////////////////////////////////////////////////////////
*/
cHtmlTexto := wfloadfile(cDirHttp+"\messenger\emp"+cEmpAnt+"\" + PROCESOWF +"\"+cMailID + ".htm")
wfsavefile(HTMLPATH +"\emp"+cEmpAnt+"\"+cMailID + ".htm", cHtmlTexto)
cHtmlModelo := "\WORKFLOW\wflink.HTM"

If File(cHtmlModelo)
	oProcess:NewTask("Aprovação de solicitação para transferência de recursos", cHtmlModelo)
Else
	FwLogMsg("WFCOR04", /*cTransactionId*/, "WFCOR04", FunName(), "", "01","O arquivo (" + cHtmlModelo + ") não existe.", 0, (nStart - Seconds()), {})
	msgalert("O arquivo (" + cHtmlModelo + ") não existe.")
	Return
EndIf

oProcess:cSubject := "AVB - Solitação de transferência de recursos"
oProcess:cTo := AllTrim(cMail)
oHTML:= oProcess:oHTML
oHTML:ValByName("proc_link","http://" + cSrver + ":" + cPrto + "/ws/emp" + cEmpAnt + "/" + cMailID + ".htm")
oHTML:ValByName("proc_link2","http://" + cSrvInt + ":" + cPrto + "/ws/emp" + cEmpAnt + "/" + cMailID + ".htm")
oHTML:ValByName("referente","a transferência do : Centro de Custos: "+cCcusto1+" / Item Con: "+cItemco1+" / Conta: "+cConta1+" Para "+cCcusto2+" / Item Con: "+cItemco2+" / Conta: "+cConta2 )
cBody := '<html>'
cBody += '<head>'
cBody += '<title>Untitled Document</title>'
cBody += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
cBody += '</head>'
cBody += '<body bgcolor="#FFFFFF" bgproperties="fixed" background="C:\Microsiga\mp10root\Protheus_Data\workflow\fundo.JPG">'
cBody += '<body>'

cBody += '<form name="form1" method="post" action="mailto:%WFMailTo%">'
  cBody += '<p>&nbsp;</p>'
  cBody += '<p>&nbsp;</p>'
  cBody += '<p>Por Favor abrir ao seguinte link Para efetuar a analise da solictação de transferencia de recursos! </p>'
   cBody += '<p>Link externo</p>'
  cBody += '<p><a href="http://' + cSrver + ':' + cPrto + '/ws/emp' + cEmpAnt + '/' + cMailID + '.htm" title="liga">!proc_link!</a></p>'
   cBody += '<p>Link interno</p>'
  cBody += '<a href="http://' + cSrvInt + ":" + cPrto + "/ws/emp" + cEmpAnt + "/" + cMailID + '.htm" title="liga">!proc_link2!</a>'
cBody += '</form>'
cBody += '</body>'
cBody += '</html>'
//oProcess:Start()//cCcusto1,cItemco1,cConta1,cCcusto2,cItemco2,cConta2
u_EnviEmail('','Solicitacao para transferencia de recursos','AVB - Solitacao de transferencia de recursos',cBody,.T.,AllTrim(cMail),'')
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
MsgInfo("E-mail enviado ao seguinte destinatario con exito!!"+CLRF+AllTrim(cMail))
FwLogMsg("WFCOR04", /*cTransactionId*/, "WFCOR04", FunName(), "", "01","Rastreando:"+oProcess:fProcCode, 0, (nStart - Seconds()), {})
Else
MsgInfo("Para este Centro de Custo não foi encontrado Gestor superior"+chr(13)+chr(10)+"Solicite a amarração do gestor ao centro de custo e informe o superior do mesmo!","Atenção")
Endif
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SRRetorno º Autor ³ Ismael Junior      º Data ³  18/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para retorno da solicitação de recursos orçamentarioº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC PROCEDURE SRRetorno( oProcess )
Local cCusto1  := PADR( oProcess:oHtml:RetByName('ccusto1'), TAMSX3("ZW2_CCUSTO")[1])
Local cItemco1 := PADR( oProcess:oHtml:RetByName('citemco1'), TAMSX3("ZW2_ITEMCO")[1])
Local cClvl1   := PADR( oProcess:oHtml:RetByName('cclvl1'), TAMSX3("ZW2_CLVL")[1])
Local cConta1  := PADR( oProcess:oHtml:RetByName('cconta1'), TAMSX3("ZW2_CONTA")[1])
Local cCusto2  := PADR( oProcess:oHtml:RetByName('ccusto2'), TAMSX3("ZW2_CCUSTO")[1])
Local cItemco2 := PADR( oProcess:oHtml:RetByName('citemco2'), TAMSX3("ZW2_ITEMCO")[1])
Local cClvl2  := PADR( oProcess:oHtml:RetByName('cclvl2'), TAMSX3("ZW2_CLVL")[1])
Local cConta2  := PADR( oProcess:oHtml:RetByName('cconta2'), TAMSX3("ZW2_CONTA")[1])
//Local cObs    := Alltrim(oProcess:oHtml:RetbyName('lbmotivo'))
Local cValor  := Alltrim(oProcess:oHtml:RetByName('cvalor'))
Local cMailRet:= Alltrim(oProcess:oHtml:RetbyName('emailsol'))
Local cNamUser:= Alltrim(oProcess:oHtml:RetbyName('solicit'))
Local cAno    := Alltrim(Str(Year(Date())))
//Local cCampo  := ""
Local cMes    := Month2Str(Date())
If (oProcess:oHtml:RetByName('RBAPROVA') == 'Si')
	FwLogMsg("WFCOR04", /*cTransactionId*/, "WFCOR04", FunName(), "", "01",'Autorizo a transferencia de recursos entre contas:'+oProcess:oHtml:RetByName('cconta1')+" Para "+oProcess:oHtml:RetByName('cconta2'), 0, (nStart - Seconds()), {})
	FwLogMsg("WFCOR04", /*cTransactionId*/, "WFCOR04", FunName(), "", "01",'cMes :'+cMes, 0, (nStart - Seconds()), {})
    cValor := StrTran(cValor,".","") 
    cValor := StrTran(cValor,",",".")

 //********* Debita valor da conta de origem - Subtrai Cabeçalho   
	cUpdate:= " UPDATE " + RetSqlName("ZW1")+" SET ZW1_TOTAL = ZW1_TOTAL-"+Alltrim(cValor) 
	cUpdate+= " WHERE ZW1_CCUSTO = '"+Alltrim(cCusto1)+"' "
	cUpdate+= " AND ZW1_ITEMCO = '"+Alltrim(cItemco1)+"' "
	cUpdate+= " AND ZW1_CLVL = '"+Alltrim(cClvl1)+"' "
	cUpdate+= " AND ZW1_ANO = '"+cAno+"' "
	cUpdate+= " AND ZW1_FILIAL = '"+xFilial("ZW1")+"' "
	cUpdate+= " AND D_E_L_E_T_ != '*' "

	nFlag := TcSqlExec(cUpdate)

 //********* Debita valor da conta de origem   
	cUpdate:= " UPDATE " + RetSqlName("ZW2")+" SET ZW2_PRE"+cMes+" = ZW2_PRE"+cMes+"-"+Alltrim(cValor)+",ZW2_PREANO = ZW2_PREANO-"+Alltrim(cValor) 
	cUpdate+= " WHERE ZW2_CCUSTO = '"+Alltrim(cCusto1)+"' "
	cUpdate+= " AND ZW2_ITEMCO = '"+Alltrim(cItemco1)+"' "
	cUpdate+= " AND ZW2_CLVL = '"+Alltrim(cClvl1)+"' "
	cUpdate+= " AND ZW2_CONTA = '"+Alltrim(cConta1)+"' "
	cUpdate+= " AND ZW2_ANO = '"+cAno+"' "
	cUpdate+= " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
	cUpdate+= " AND D_E_L_E_T_ != '*' "

	nFlag := TcSqlExec(cUpdate)
	
 //*********** Credita valor na conta de destino - Soma Cabeçalho
	cUpdate:= " UPDATE " + RetSqlName("ZW1")+" SET ZW1_TOTAL = ZW1_TOTAL+"+Alltrim(cValor)  
	cUpdate+= " WHERE ZW1_CCUSTO = '"+Alltrim(cCusto2)+"' "
	cUpdate+= " AND ZW1_ITEMCO = '"+Alltrim(cItemco2)+"' "
	cUpdate+= " AND ZW1_CLVL = '"+Alltrim(cClvl2)+"' "
	cUpdate+= " AND ZW1_ANO = '"+cAno+"' "
	cUpdate+= " AND ZW1_FILIAL = '"+xFilial("ZW1")+"' "
	cUpdate+= " AND D_E_L_E_T_ != '*' "

	nFlag := TcSqlExec(cUpdate)

 //*********** Credita vaor na conta de destino
	cUpdate:= " UPDATE " + RetSqlName("ZW2")+" SET ZW2_PRE"+cMes+" = ZW2_PRE"+cMes+"+"+Alltrim(cValor)+",ZW2_PREANO = ZW2_PREANO+"+Alltrim(cValor) 
	cUpdate+= " WHERE ZW2_CCUSTO = '"+Alltrim(cCusto2)+"' "
	cUpdate+= " AND ZW2_ITEMCO = '"+Alltrim(cItemco2)+"' "
	cUpdate+= " AND ZW2_CLVL = '"+Alltrim(cClvl2)+"' "
	cUpdate+= " AND ZW2_CONTA = '"+Alltrim(cConta2)+"' "
	cUpdate+= " AND ZW2_ANO = '"+cAno+"' "
	cUpdate+= " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
	cUpdate+= " AND D_E_L_E_T_ != '*' "

	nFlag := TcSqlExec(cUpdate)	
		
DbSelectArea("ZW3")
ZW3->(DbSetOrder(2))
//Historico de debito na conta de origem
	dDate := Date()
	RecLock("ZW3",.T.)
	ZW3->ZW3_FILIAL := XFILIAL("ZW3")
	ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
	ZW3->ZW3_TIPO   := "D"
	ZW3->ZW3_CCUSTO := cCusto1
	ZW3->ZW3_ITEMCO := cItemco1
	ZW3->ZW3_CLVL  := cClvl1
	ZW3->ZW3_CONTA  := cConta1
	ZW3->ZW3_ANO    := cAno
	ZW3->ZW3_DATA   := dDate
	ZW3->ZW3_VALOR  := val(Alltrim(cValor))
	ZW3->ZW3_ORIGEM := "Transferencia"
	ZW3->ZW3_USUARI := cNamUser
	ZW3->ZW3_HISTOR := "Transferido p/ C.C "+Alltrim(cCusto2)+" / "+Alltrim(cItemco2)+" - "+Alltrim(cClvl2)+" - "+Alltrim(cConta2)
	ZW3->(MsUnLock())
	ConfirmSX8() 
	
// histórico de credito na conta de destino
	dDate := Date()
	RecLock("ZW3",.T.)
	ZW3->ZW3_FILIAL := XFILIAL("ZW3")
	ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
	ZW3->ZW3_TIPO   := "C"
	ZW3->ZW3_CCUSTO := cCusto2
	ZW3->ZW3_ITEMCO := cItemco2
	ZW3->ZW3_CLVL   := cClvl2
	ZW3->ZW3_CONTA  := cConta2
	ZW3->ZW3_ANO    := cAno
	ZW3->ZW3_DATA   := dDate
	ZW3->ZW3_VALOR  := val(Alltrim(cValor))
	ZW3->ZW3_ORIGEM := "Transferencia"
	ZW3->ZW3_USUARI := cNamUser
	ZW3->ZW3_HISTOR := "Transferido do C.C "+Alltrim(cCusto1)+" / "+Alltrim(cItemco1)+" - "+Alltrim(cClvl1)+" - "+Alltrim(cConta1)
	ZW3->(MsUnLock())
	ConfirmSX8()		
	
	/*
	///////////////////////////////////////////////////////////////////////////
	///							E-Mail de aviso de aprovação	   			///
	///////////////////////////////////////////////////////////////////////////
	*/
	
	oRet:= TWFProcess():New( "000002", "Retorno de aviso" )
	oRet:NewTask( "Aprovação ","\WORKFLOW\wfCor04_s.HTM" )
	oRet:cSubject	:= "Notificação WorkFlow | Solicitação de transferência de recursos Aprovada."
	oHtmD:= oRet:oHTML
	oHtmO:= oProcess:oHTML
	oHtmD:= u_genavi(oHtmD,oHtmO,"A")         //Genera o html de aviso da aprovação

cBody := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
cBody += '<html><head>'
cBody += '<title>Aprovação da solicitação de transferência</title><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
cBody += '<meta name="GENERATOR" content="Microsoft FrontPage Express 2.0"></head>'
cBody += '<noscript>'
cBody += '<body bgcolor="#FFFFFF">'
//cBody += '<b><font face="Arial" size=2 color="#FF0000">%WFAvisoJS%</font></b>'
cBody += '</noscript>'

cBody += '<body>'
cBody += '<form action="mailto:" method="post" name="FrontPage_Form1">'

cBody += '<h2><b><font color="#000080" face="Arial">Solicitação de transferência de Recursos &nbsp;&nbsp;&nbsp;</font></b></h2>'

cBody += '<p><b><font color="green" face="Arial">SOLICITAÇÃO APROVADA </font></b></p>  '

cBody += '<p><b><font color="#000080" face="Arial">EMPRESA: '+oHtmO:RetByName('empresa')+' </font></b></p>'
cBody += '<p><b><font color="#000080" face="Arial">Solicitante: '+oHtmO:RetByName('solicit')+' </font></b></p>'
cBody += '<p><b><font color="#000080" face="Arial">Data: '+oHtmO:RetByName('data')+' </font></b></p>'
cBody += '<p><b><font color="#000080" face="Arial">Dados da solicitação:</font></b></p>'
cBody += '<table style="width: 1362px; height: 59px;" border="0" cellpadding="2">'
cBody += '<tbody>'
cBody += '<tr>'
cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Origem</font></b></td>'
cBody += '</tr>'
cBody += '<tr>'
cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Centro de Custo</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Item Contábil</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="200"><b><font face="Arial" size="2">Classe de valor</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="200"><b><font face="Arial" size="2">Conta</font></b></td>'
cBody += '</tr>'
cBody += '<tr>'
cBody += '<td style="font-family: Arial;" bgcolor="#c0c0c0" width="100"><font size="2">'+oHtmO:RetByName('ccusto1')+'</font></td>'
cBody += '<td bgcolor="#c0c0c0" width="141"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('citemco1')+'</big></font></big></td>'
cBody += '<td bgcolor="#c0c0c0" width="241"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('cclvl1')+'</big></font></big></td>'
cBody += '<td bgcolor="#c0c0c0" width="241"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('cconta1')+'</big></font></big></td>'
cBody += '</tr>'
cBody += '<tr>'
cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Destino</font></b></td>'
cBody += '</tr>'
cBody += '<tr>'
cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Centro de Custo</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Item Contábil</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="200"><b><font face="Arial" size="2">Classe de valor</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="200"><b><font face="Arial" size="2">Conta</font></b></td>'
cBody += '</tr>'
cBody += '<tr>'
cBody += '<td style="font-family: Arial;" bgcolor="#c0c0c0" width="100"><font size="2">'+oHtmO:RetByName('ccusto2')+'</font></td>'
cBody += '<td bgcolor="#c0c0c0" width="141"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('citemco2')+'</big></font></big></td>'
cBody += '<td bgcolor="#c0c0c0" width="241"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('cclvl2')+'</big></font></big></td>'
cBody += '<td bgcolor="#c0c0c0" width="241"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('cconta2')+'</big></font></big></td>'
cBody += '</tr>'
cBody += '</tbody>'
cBody += '</table>'
cBody += '<table>'
cBody += '<tbody>'
cBody += '<tr>'
cBody += '<td align="center" bgcolor="#99ccff" width="250"><b><font face="Arial" size="2">Valor</font></b></td>'
cBody += '<td align="center" bgcolor="#c0c0c0" width="54"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('cvalor')+'</big></font></big></td>'
cBody += '</tr>'
cBody += '</tbody>'
cBody += '</table>'
cBody += '</form>'
cBody += '</body></html>'
//oProcess:Start()//cCcusto1,cItemco1,cConta1,cCcusto2,cItemco2,cConta2
u_EnviEmail('','WorkFlow | Transferencia de recursos Aprovada.','WorkFlow | Transferencia de recursos Aprovada',cBody,.T.,AllTrim(cMailRet),'')	
	
	
	oRet:cTo:= alltrim(cMailRet)
	
   //	oRet:Start()
	oRet:finish()
	
	///////////////////////////////////////////////////////////////////////////////////
	
ELSE		
	/*
	///////////////////////////////////////////////////////////////////////////
	///							E-Mail de aviso de rejeição					///
	///////////////////////////////////////////////////////////////////////////
	*/
		
	oRet:= TWFProcess():New( "000002", "Retorno de aviso" )
	oRet:NewTask( "Rejeição ","\WORKFLOW\wfCor04_n.HTM")
	oRet:cSubject := "Notificação WorkFlow | Solicitação de transferência de recursos Rejeitada."
	oHtmD:= oRet:oHTML
	oHtmO:= oProcess:oHTML
	oHtmD:= u_genavi2(oHtmD,oHtmO,"R")         //Genera o html de aviso de rejeição 
cBody := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
cBody += '<html><head>'
cBody += '<title>Aprovação da solicitação de transferência</title><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
cBody += '<meta name="GENERATOR" content="Microsoft FrontPage Express 2.0"></head>'
cBody += '<noscript>'
cBody += '<body bgcolor="#FFFFFF">'
//cBody += '<b><font face="Arial" size=2 color="#FF0000">%WFAvisoJS%</font></b>'
cBody += '</noscript>'

cBody += '<body>'
cBody += '<form action="mailto:" method="post" name="FrontPage_Form1">'

cBody += '<h2><b><font color="#000080" face="Arial">Solicitação de transferência de Recursos &nbsp;&nbsp;&nbsp;</font></b></h2>'

cBody += '<p><b><font color="red" face="Arial">SOLICITAÇÃO REJEITADA </font></b></p>  '

cBody += '<p><b><font color="#000080" face="Arial">EMPRESA: '+oHtmO:RetByName('empresa')+' </font></b></p>'
cBody += '<p><b><font color="#000080" face="Arial">Solicitante: '+oHtmO:RetByName('solicit')+' </font></b></p>'
cBody += '<p><b><font color="#000080" face="Arial">Data: '+oHtmO:RetByName('data')+' </font></b></p>'
cBody += '<p><b><font color="#000080" face="Arial">Dados da solicitação:</font></b></p>'
cBody += '<table style="width: 1362px; height: 59px;" border="0" cellpadding="2">'
cBody += '<tbody>'
cBody += '<tr>'
cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Origem</font></b></td>'
cBody += '</tr>'
cBody += '<tr>'
cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Centro de Custo</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Item Contábil</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="200"><b><font face="Arial" size="2">Classe de valor</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="200"><b><font face="Arial" size="2">Conta</font></b></td>'
cBody += '</tr>'
cBody += '<tr>'
cBody += '<td style="font-family: Arial;" bgcolor="#c0c0c0" width="100"><font size="2">'+oHtmO:RetByName('ccusto1')+'</font></td>'
cBody += '<td bgcolor="#c0c0c0" width="141"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('citemco1')+'</big></font></big></td>'
cBody += '<td bgcolor="#c0c0c0" width="241"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('cclvl1')+'</big></font></big></td>'
cBody += '<td bgcolor="#c0c0c0" width="241"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('cconta1')+'</big></font></big></td>'
cBody += '</tr>'
cBody += '<tr>'
cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Destino</font></b></td>'
cBody += '</tr>'
cBody += '<tr>'
cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Centro de Custo</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Item Contábil</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="200"><b><font face="Arial" size="2">Classe de valor</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="200"><b><font face="Arial" size="2">Conta</font></b></td>'
cBody += '</tr>'
cBody += '<tr>'
cBody += '<td style="font-family: Arial;" bgcolor="#c0c0c0" width="100"><font size="2">'+oHtmO:RetByName('ccusto2')+'</font></td>'
cBody += '<td bgcolor="#c0c0c0" width="141"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('citemco2')+'</big></font></big></td>'
cBody += '<td bgcolor="#c0c0c0" width="241"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('cclvl2')+'</big></font></big></td>'
cBody += '<td bgcolor="#c0c0c0" width="241"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('cconta2')+'</big></font></big></td>'
cBody += '</tr>'
cBody += '</tbody>'
cBody += '</table>'
cBody += '<table>'
cBody += '<tbody>'
cBody += '<tr>'
cBody += '<td align="center" bgcolor="#99ccff" width="250"><b><font face="Arial" size="2">Valor</font></b></td>'
cBody += '<td align="center" bgcolor="#c0c0c0" width="54"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('cvalor')+'</big></font></big></td>'
cBody += '</tr>'
cBody += '</tbody>'
cBody += '</table>'
cBody += '</form>'
cBody += '</body></html>'
//oProcess:Start()//cCcusto1,cItemco1,cConta1,cCcusto2,cItemco2,cConta2
u_EnviEmail('','WorkFlow | Transferencia de recursos Rejeitada','WorkFlow | Transferencia de recursos Rejeitada',cBody,.T.,AllTrim(cMailRet),'')		
	
	oRet:cTo:= cMailRet    //E-mail do solicitante
	//oRet:Start()
	oRet:finish()
ENDIF
Return

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////TIMEOUT                     																		//////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
STATIC PROCEDURE SRTimeOut( oProcess )
	FwLogMsg("WFCOR04", /*cTransactionId*/, "WFCOR04", FunName(), "", "01","Função de TIMEOUT executada", 0, (nStart - Seconds()), {})
Return

/*
///////////////////////////////////////////////////////////////////////////
///FUNÇÃO QUE GERA A MENSAGEM DE AVISO   								///
///////////////////////////////////////////////////////////////////////////
*/

User function genavi2(oDest, oOrig,cEst)

oDest:ValByName("empresa",oOrig:RetByName('empresa'))
oDest:ValByName("data",oOrig:RetByName('data'))
oDest:ValByName("ccusto1",oOrig:RetByName('ccusto1'))
oDest:ValByName("citemco1",oOrig:RetByName('citemco1'))
oDest:ValByName("cclvl1",oOrig:RetByName('cclvl1'))
oDest:ValByName("cconta1",oOrig:RetByName('cconta1'))
oDest:ValByName("ccusto2",oOrig:RetByName('ccusto2'))
oDest:ValByName("citemco2",oOrig:RetByName('citemco2'))
oDest:ValByName("cclvl2",oOrig:RetByName('cclvl2'))
oDest:ValByName("cconta2",oOrig:RetByName('cconta2'))
oDest:ValByName("cvalor",oOrig:RetByName('cvalor')) 
oDest:ValByName("solicit",oOrig:RetByName('solicit'))

if(cEst=="R")
	oDest:ValByName("lbmotivo",oOrig:RetByName('lbmotivo'))
endif

return oDest
