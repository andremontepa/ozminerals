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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWFCOR03   บAutor  ณIsmael Junior       บData  ณ  18/10/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnvia workflow ao gestor do centro de custos.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACOM 												      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User function WFCOR03( nOpcao, oProcess,cCusto,cItemco,cClvl,cConta,cValor,cSlMotiv )
Private cSrver   :=Getmv("MV_WFSERVE")		// IP SERVIDOR EXTERNO 191.200.30.5
Private cSrvInt  :=Getmv("MV_WFSERVI")      // IP SERVIDOR INTERNO 192.168.0.200
Private cPrto    :=Getmv("MV_WFPORTA")		// PORTA EXEMPLO "10700"

bandera:=getmv("MV_WFACTI",,0)     //ativa o funcionamento do workflow

if bandera == 1
	ConOut('Novo processo, a bandera de ativacao e 1')
	
	If nOpcao == NIL
		nOpcao := 0
	ENDIF
	
	If oProcess == NIL
		oProcess := TWFProcess():New( "000002", "Solicta็ใo de Recursos" )
	else
		
	ENDIF
	
	ConOut('Op็ใo localizada, op็ใo 0: '+str(nOpcao))
    Do Case
	  Case nOpcao == 0  // Envio
		ConOut('Inicia aprova็ใo de nova solicita็ใo')
		SRIniciar( oProcess,cCusto,cItemco,cClvl,cConta,cValor,cSlMotiv )
	  Case nOpcao == 1  // Retorno
		ConOut('Solicitacao : opcao 1 selecionada')
		SRRetorno( oProcess )
      Case nOpcao == 2  // Timeout
		ConOut('Solicitacao : opcao 2 selecionada')
		SRTimeOut( oProcess )
	End	
	
	
Endif
RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSRIniciar บ Autor ณ Ismael Junior      บ Data ณ  18/10/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para solicita็ใo de recursos or็amentarios          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACOM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function SRIniciar(oProcess,cCusto,cItemco,cClvl,cConta,cValor,cSlMotiv)
Local cCadastro := "Envio de Email"
Local cMail     := " "
Local _cSol     := cUserName
Local cQuery:= ""
Local cSQL:= "TRA"

If Empty(cCusto) 
	MsgAlert("Campo Centro de custo nใo pode ser vazio!","Aten็ใo")
	Return()
Elseif Empty(cItemco) 
	MsgAlert("Campo Item Contabํl nใo pode ser vazio!","Aten็ใo")
	Return()
Elseif Empty(cClvl) 
	MsgAlert("Campo Classe de Valor nใo pode ser vazio!","Aten็ใo")
	Return()	
Elseif Empty(cConta) 
	MsgAlert("Campo Conta nใo pode ser vazio!","Aten็ใo")
	Return()
Elseif Empty(cValor)
	MsgAlert("Campo Valor nใo pode ser vazio!","Aten็ใo")       
	Return()
Elseif Empty(cSlMotiv)
	MsgAlert("Campo Motivo nใo pode ser vazio!","Aten็ใo")      
	Return()
Endif

If cValor <= 0 
MsgAlert("Campo Valor nใo pode ser menor ou igual a zero!","Aten็ใo")       
Return()
Endif

cQuery := " SELECT * FROM "+RetSqlName("ZW1")+" ZW1 "
cQuery += " INNER JOIN "+RetSqlName("ZW2")+" ZW2 ON ZW2_NUM = ZW1_NUM AND ZW2.D_E_L_E_T_ != '*' "
cQuery += " WHERE ZW1_CCUSTO = '" + cCusto + "' "
cQuery += " AND ZW1_ITEMCO = '" + cItemco + "' "
cQuery += " AND ZW1_CLVL = '" + cClvl + "' "
cQuery += " AND ZW2_CONTA = '" + cConta + "' "
cQuery += " AND ZW1_FILIAL = '" + xFilial("ZW1") + "' "
cQuery += " AND ZW1.D_E_L_E_T_ != '*' "

If SELECT(cSQL) > 0
	(cSQL)->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSQL,.T.,.T.) 
If Empty((cSQL)->ZW1_CCUSTO) 
MsgAlert("Centro de custo, Item Contabํl ou Clase de valor nใo encontrado","Aten็ใo") 
Return()
Endif

PswOrder(2)    // ordenado pelo nome
If PswSeek(_cSol, .T. )
	aInfo := PswRet()
	cIDSolicit  := alltrim(aInfo[1][1])
	cEmailSoli  := Alltrim(aInfo[1][14])
EndIf

oProcess:NewTask( "Solicita็ใo ","\WORKFLOW\WfCor03.HTM" )
oProcess:cSubject := "Solicita็ใo de Recursos: "+cCusto+" / "+ cItemco+" / "+ cClvl +" / "+ cConta
oProcess:cBody	  := "Por favor verifique o arquivo anexado para aprovar ou rejeitr a solicta็ใo de recursos: "+cCusto+" / "+ cItemco+" / "+ cConta
oProcess:bReturn  := "U_WFCOR03(1)"
oProcess:bTimeOut := {"U_WFCOR03(2)",30, 05, 50 }  // Para timeout {{"FUNCION()",DIAS, HORAS, MINUTOS }}
oHTML             := oProcess:oHTML

oHTML:ValByName( "empresa", Alltrim(SM0->M0_NOMECOM) )
oHTML:ValByName( "solicit", _cSol )
oHTML:ValByName( "emailsol", cEmailSoli )
oHtml:ValByName( "data", DTOC(Date()))

oHtml:ValByName( "ccusto", Alltrim(cCusto))
oHtml:ValByName( "citemco", Alltrim(cItemco))
oHtml:ValByName( "cclvl", Alltrim(cClvl))
oHtml:ValByName( "cconta", Alltrim(cConta))
oHtml:ValByName( "cvalor", Transform(cValor,"@E 999,999,999.99"))

/*
///////////////////////////////////////////////////////////////////////////
///	BUSCA O E-MAIL DO GESTOR DO CENTRO DE CUSTOS                     	///
///////////////////////////////////////////////////////////////////////////
*/

//Busca os aprovadores selecionados
cQuery := " SELECT TOP 1 ZW4_MAILSU EMAIL,ZW4_NOME AS NOME, ZW4_CODSUP "
cQuery += " FROM "+RetSqlName("ZW4")+" ZW4 "
cQuery += " INNER JOIN "+RetSqlName("ZW5")+" ZW5 ON ZW4_NUM = ZW5_NUM AND ZW5_FILIAL = '"+xFilial("ZW5")+"' AND ZW5.D_E_L_E_T_ != '*' "
cQuery += " WHERE ZW5_CCUSTO = '"+cCusto+"' "
cQuery += " AND ZW5_ITEMCO = '"+cItemco+"' "
cQuery += " AND ZW4_FILIAL = '"+xFilial("ZW4")+"' "
cQuery += " AND ZW4.D_E_L_E_T_ != '*' "

If SELECT(cSQL) > 0
	(cSQL)->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSQL,.T.,.T.)

If !Empty((cSQL)->EMAIL)
cMail := (cSQL)->EMAIL
oHTML:ValByName( "aprovador", UsrFullName(Alltrim((cSQL)->ZW4_CODSUP)) )
oHtml:ValByName( "cmotivo", Alltrim(cSlMotiv))
oProcess:ClientName( Subs(cUsuario,7,15) )
oProcess:cTo      := PROCESOWF
cMailID:=oProcess:Start()

////////////////////////////////////////////////////////////////////////////////////////////////////
ConOut("ID WF: "+ cMailID)
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
	oProcess:NewTask("Aprova็ใo de solicita็ใo de recursos", cHtmlModelo)
Else
	ConOut("O arquivo (" + cHtmlModelo + ") nใo existe.")
	msgalert("O arquivo (" + cHtmlModelo + ") nใo existe.")
	Return
EndIf

oProcess:cSubject := "AVB - Solita็ใo de recursos"
oProcess:cTo := AllTrim(cMail)
oHTML:= oProcess:oHTML
oHTML:ValByName("proc_link","http://" + cSrver + ":" + cPrto + "/ws/emp" + cEmpAnt + "/" + cMailID + ".htm")
oHTML:ValByName("proc_link2","http://" + cSrvInt + ":" + cPrto + "/ws/emp" + cEmpAnt + "/" + cMailID + ".htm")
oHTML:ValByName("referente","ao : Centro de Custos: "+cCusto+" / Item Con: "+ cItemco+" / Conta: "+ cConta )

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
  cBody += '<p>Por Favor abrir ao seguinte link Para efetuar a analise da solicta็ใo de recursos. </p>'
   cBody += '<p>Link externo</p>'
  cBody += '<p><a href="http://' + cSrver + ':' + cPrto + '/ws/emp' + cEmpAnt + '/' + cMailID + '.htm" title="liga">!proc_link!</a></p>'
   cBody += '<p>Link interno</p>'
  cBody += '<a href="http://' + cSrvInt + ":" + cPrto + "/ws/emp" + cEmpAnt + "/" + cMailID + '.htm" title="liga">!proc_link2!</a>'
cBody += '</form>'
cBody += '</body>'
cBody += '</html>'
//oProcess:Start()
u_EnviEmail('','Solicitacao de recursos','AVB - Solitacao de recursos',cBody,.T.,AllTrim(cMail),'')
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
MsgInfo("E-mail enviado ao seguinte destinatario con exito!!"+CLRF+AllTrim(cMail))
ConOut("Rastreando:"+oProcess:fProcCode)
Else
MsgInfo("Para este Centro de Custo nใo foi encontrado Gestor"+chr(13)+chr(10)+"Solicite a amarra็ใo do gestor ao centro de custo","Aten็ใo")
Endif
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSRRetorno บ Autor ณ Ismael Junior      บ Data ณ  18/10/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para retorno da solicita็ใo de recursos or็amentarioบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACOM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC PROCEDURE SRRetorno( oProcess )
Local cCusto  := PADR( oProcess:oHtml:RetByName('ccusto'), TAMSX3("ZW2_CCUSTO")[1])
Local cItemco := PADR( oProcess:oHtml:RetByName('citemco'), TAMSX3("ZW2_ITEMCO")[1])
Local cClvl   := PADR( oProcess:oHtml:RetByName('cclvl'), TAMSX3("ZW2_CLVL")[1])
Local cConta  := PADR( oProcess:oHtml:RetByName('cconta'), TAMSX3("ZW2_CONTA")[1])
Local cObs    := Alltrim(oProcess:oHtml:RetbyName('lbmotivo'))
Local cValor  := Alltrim(oProcess:oHtml:RetByName('cvalor'))
Local cMailRet:= Alltrim(oProcess:oHtml:RetbyName('emailsol'))
Local cNamUser:= Alltrim(oProcess:oHtml:RetbyName('solicit'))
Local cAno    := Alltrim(Str(Year(Date())))
Local cCampo  := ""
Local cMes    := Month2Str(Date())
If (oProcess:oHtml:RetByName('RBAPROVA') == 'Si')
	ConOut('Autorizo a solicita็ใo No:'+oProcess:oHtml:RetByName('ccusto'))
	ConOut('cMes :'+cMes)
    cValor := StrTran(cValor,".","") 
    cValor := StrTran(cValor,",",".")
    
	cUpdate:= " UPDATE " + RetSqlName("ZW2")+" SET ZW2_PRE"+cMes+"=ZW2_PRE"+cMes+"+"+Alltrim(cValor)+" ,ZW2_PREANO = ZW2_PREANO+"+Alltrim(cValor) 
	cUpdate+= " WHERE ZW2_CCUSTO = '"+Alltrim(cCusto)+"' "
	cUpdate+= " AND ZW2_ITEMCO = '"+Alltrim(cItemco)+"' "
	cUpdate+= " AND ZW2_CLVL = '"+Alltrim(cClvl)+"' "
	cUpdate+= " AND ZW2_CONTA = '"+Alltrim(cConta)+"' "
	cUpdate+= " AND ZW2_ANO = '"+cAno+"' "
	cUpdate+= " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
	cUpdate+= " AND D_E_L_E_T_ != '*' "
	nFlag := TcSqlExec(cUpdate)

	cUpdate:= " UPDATE " + RetSqlName("ZW1")+" SET ZW1_TOTAL = ZW1_TOTAL+"+Alltrim(cValor) 
	cUpdate+= " WHERE ZW1_CCUSTO = '"+Alltrim(cCusto)+"' "
	cUpdate+= " AND ZW1_ITEMCO = '"+Alltrim(cItemco)+"' "
	cUpdate+= " AND ZW1_CLVL = '"+Alltrim(cClvl)+"' "
	cUpdate+= " AND ZW1_ANO = '"+cAno+"' "
	cUpdate+= " AND ZW1_FILIAL = '"+xFilial("ZW1")+"' "
	cUpdate+= " AND D_E_L_E_T_ != '*' "
	nFlag := TcSqlExec(cUpdate)

	//ConOut('Flag : '+STR(nFlag))
DbSelectArea("ZW3")
ZW3->(DbSetOrder(2))
	dDate := Date()
	RecLock("ZW3",.T.)
	ZW3->ZW3_FILIAL := XFILIAL("ZW3")
	ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
	ZW3->ZW3_TIPO   := "C"
	ZW3->ZW3_CCUSTO := cCusto
	ZW3->ZW3_ITEMCO := cItemco
	ZW3->ZW3_CLVL   := cClvl
	ZW3->ZW3_CONTA  := cConta
	ZW3->ZW3_ANO    := cAno
	ZW3->ZW3_DATA   := dDate
	ZW3->ZW3_VALOR  := val(Alltrim(cValor))
	ZW3->ZW3_ORIGEM := "Solicita็ใo de Recursos"
	ZW3->ZW3_USUARI := cNamUser
	ZW3->ZW3_HISTOR := "Valor autorizado pelo superior do gestor do centro de custo"
	ZW3->(MsUnLock())
	ConfirmSX8()	
	
	/*
	///////////////////////////////////////////////////////////////////////////
	///							E-Mail de aviso de aprova็ใo	   			///
	///////////////////////////////////////////////////////////////////////////
	*/
	
	oRet:= TWFProcess():New( "000002", "Retorno de aviso" )
	oRet:NewTask( "Aprova็ใo ","\WORKFLOW\wfCor03_s.HTM" )
	oRet:cSubject	:= "Notifica็ใo WorkFlow | Solicita็ใo de recursos Aprovada."
	oHtmD:= oRet:oHTML
	oHtmO:= oProcess:oHTML
	oHtmD:= u_genavi(oHtmD,oHtmO,"A")         //Genera o html de aviso da aprova็ใo
cBody := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
cBody += '<html><head><!-- saved from url=(0022)http://internet.e-mail -->'
cBody += '<title>Aprova็ใo de Pedido de Compra</title><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
cBody += '<meta name="GENERATOR" content="Microsoft FrontPage Express 2.0"></head>'
cBody += '<noscript>'
cBody += '<body bgcolor="#FFFFFF">'
//cBody += '<b><font face="Arial" size=2 color="#FF0000">%WFAvisoJS%</font></b>'
cBody += '</noscript>'
cBody += '<body>'
cBody += '<form action="mailto:%WFMailTo%" method="post" name="FrontPage_Form1">'
cBody += '<h2><b><font color="#000080" face="Arial">Solicita็ใo de Recursos &nbsp;&nbsp;&nbsp;</font></b></h2>'
cBody += '<p><b><font color="green" face="Arial">SOLICITAวรO APROVADA </font></b></p>  '
cBody += '<p><b><font color="#000080" face="Arial">EMPRESA: '+oHtmO:RetByName('empresa')+' </font></b></p>'
cBody += '<p><b><font color="#000080" face="Arial">Solicitante: '+oHtmO:RetByName('solicit')+' </font></b></p>' 
cBody += '<p><b><font color="#000080" face="Arial">Aprovador: '+oHtmO:RetByName('aprovador')+' </font></b></p>'
cBody += '<p><b><font color="#000080" face="Arial">Data: '+oHtmO:RetByName('data')+' </font></b></p>'
cBody += '<p><b><font color="#000080" face="Arial">Dados da solicita็ใo:</font></b></p>'
cBody += '<table style="width: 1362px; height: 59px;" border="0" cellpadding="2">'
cBody += '<tbody>'
cBody += '<tr>'
cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Centro de Custo</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Item Contแbil</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="200"><b><font face="Arial" size="2">Classe de Valor</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="200"><b><font face="Arial" size="2">Conta</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="250"><b><font face="Arial" size="2">Valor</font></b></td>'
cBody += '</tr>'
cBody += '<tr>'
cBody += '<td style="font-family: Arial;" bgcolor="#c0c0c0" width="100"><font size="2">'+oHtmO:RetByName('ccusto')+'</font></td>'
cBody += '<td bgcolor="#c0c0c0" width="141"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('citemco')+'</big></font></big></td>'
cBody += '<td bgcolor="#c0c0c0" width="241"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('cclvl')+'</big></font></big></td>'
cBody += '<td bgcolor="#c0c0c0" width="241"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('cconta')+'</big></font></big></td>'
cBody += '<td align="center" bgcolor="#c0c0c0" width="54"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('cvalor')+'</big></font></big></td>'
cBody += '</tbody>'
cBody += '</table>'
cBody += '</tr>'
cBody += '</form>'
cBody += '</body></html>'		
	
	oRet:cTo:= alltrim(cMailRet)
u_EnviEmail('','WorkFlow | Solicitacao de recursos Aprovada','AVB - Solitacao de recursos',cBody,.T.,AllTrim(cMailRet),'')	
	//oRet:Start()
	oRet:finish()
	
	///////////////////////////////////////////////////////////////////////////////////
	
ELSE		
	/*
	///////////////////////////////////////////////////////////////////////////
	///							E-Mail de aviso de rejei็ใo					///
	///////////////////////////////////////////////////////////////////////////
	*/
		
	oRet:= TWFProcess():New( "000002", "Retorno de aviso" )
	oRet:NewTask( "Rejei็ใo ","\WORKFLOW\wfCor03_n.HTM")
	oRet:cSubject := "Solicita็ใo Rejeitada "
	oHtmD:= oRet:oHTML
	oHtmO:= oProcess:oHTML
	oHtmD:= u_genavi(oHtmD,oHtmO,"R")         //Genera o html de aviso de rejei็ใo
cBody := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
cBody += '<html><head><!-- saved from url=(0022)http://internet.e-mail -->'
cBody += '<title>Aprova็ใo de Pedido de Compra</title><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
cBody += '<meta name="GENERATOR" content="Microsoft FrontPage Express 2.0"></head>'
cBody += '<noscript>'
cBody += '<body bgcolor="#FFFFFF">'
//cBody += '<b><font face="Arial" size=2 color="#FF0000">%WFAvisoJS%</font></b>'
cBody += '</noscript>'
cBody += '<body>'
cBody += '<form action="mailto:%WFMailTo%" method="post" name="FrontPage_Form1">'
cBody += '<h2><b><font color="#000080" face="Arial">Solicita็ใo de Recursos &nbsp;&nbsp;&nbsp;</font></b></h2>'
cBody += '<p><b><font color="red" face="Arial">SOLICITAวรO REJEITADO </font></b></p>'
cBody += '<p><b><font color="#000080" face="Arial">Motivo: '+oHtmO:RetByName('lbmotivo')+' </font></b></p>'
cBody += '<p><b><font color="#000080" face="Arial">EMPRESA: '+oHtmO:RetByName('empresa')+' </font></b></p>'
cBody += '<p><b><font color="#000080" face="Arial">Solicitante: '+oHtmO:RetByName('solicit')+' </font></b></p>'
cBody += '<p><b><font color="#000080" face="Arial">Data: '+oHtmO:RetByName('data')+' </font></b></p>'
cBody += '<p><b><font color="#000080" face="Arial">Dados da solicita็ใo:</font></b></p>'
cBody += '<table style="width: 1362px; height: 59px;" border="0" cellpadding="2">'
cBody += '<tbody>'
cBody += '<tr>'
cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Centro de Custo</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Item Contแbil</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="200"><b><font face="Arial" size="2">Classe de Valor</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="200"><b><font face="Arial" size="2">Conta</font></b></td>'
cBody += '<td align="center" bgcolor="#99ccff" width="250"><b><font face="Arial" size="2">Valor</font></b></td>'
cBody += '</tr>'
cBody += '<tr>'
cBody += '<td style="font-family: Arial;" bgcolor="#c0c0c0" width="100"><font size="2">'+oHtmO:RetByName('ccusto')+'</font></td>'
cBody += '<td bgcolor="#c0c0c0" width="141"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('citemco')+'</big></font></big></td>'
cBody += '<td bgcolor="#c0c0c0" width="241"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('cclvl')+'</big></font></big></td>'
cBody += '<td bgcolor="#c0c0c0" width="241"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('cconta')+'</big></font></big></td>'
cBody += '<td align="center" bgcolor="#c0c0c0" width="54"><big><font face="Arial" size="1"><big>'+oHtmO:RetByName('cvalor')+'</big></font></big></td>'
cBody += '</tbody>'
cBody += '</table>'
cBody += '</tr>'
cBody += '</form>'
cBody += '</body></html>'		
	
	oRet:cTo:= alltrim(cMailRet)
u_EnviEmail('','WorkFlow | Solicitacao de recursos Aprovada','AVB - Solitacao de recursos',cBody,.T.,AllTrim(cMailRet),'')	
	//oRet:Start()
	oRet:finish()
ENDIF
Return

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////TIMEOUT                     																		//////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
STATIC PROCEDURE SRTimeOut( oProcess )
ConOut("Fun็ใo de TIMEOUT executada")
Return

/*
///////////////////////////////////////////////////////////////////////////
///FUNวรO QUE GERA A MENSAGEM DE AVISO   								///
///////////////////////////////////////////////////////////////////////////
*/

User function genavi(oDest, oOrig,cEst)

oDest:ValByName("empresa",oOrig:RetByName('empresa'))
oDest:ValByName("data",oOrig:RetByName('data'))
oDest:ValByName("ccusto",oOrig:RetByName('ccusto'))
oDest:ValByName("citemco",oOrig:RetByName('citemco'))
oDest:ValByName("cclvl",oOrig:RetByName('cclvl'))
oDest:ValByName("cconta",oOrig:RetByName('cconta'))
oDest:ValByName("cvalor",oOrig:RetByName('cvalor')) 
oDest:ValByName("solicit",oOrig:RetByName('solicit'))

if(cEst=="R")
	oDest:ValByName("lbmotivo",oOrig:RetByName('lbmotivo'))
endif

return oDest
