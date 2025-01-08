#include "rwmake.ch"
#include "fileio.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "protheus.ch"

#Define CLRF CHAR(13) + CHAR(10)
#DEFINE PROCESOWF "CARPETA"            //Nombre de la carpeta donde se guarda el archivo htm
#DEFINE HTMLPATH  "\web\ws\"           //Ruta hacia donde se debe mover el archivo htm

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �WF050IN   �Autor  �Ismael Junior       �Data  �  11/06/21   ���
�������������������������������������������������������������������������͹��
���Desc.     �Envia workflow para libera��o da inclus�o do contas a pagar.���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIN 												      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User function WF050INC( nOpcao, oProcess,cprefixo,cnumero,cparcela,ctipo,cfornece,cloja )
Private cSrver   :=Getmv("MV_WFSERVE")		// IP SERVIDOR EXTERNO 191.200.30.5
Private cSrvInt  :=Getmv("MV_WFSERVI")      // IP SERVIDOR INTERNO 192.168.0.200
Private cPrto    :=Getmv("MV_WFPORTA")		// PORTA EXEMPLO "10700"
Private nStart   := 0

bandera:=getmv("MV_WF050IN",,0)     //ativa o funcionamento do workflow

if bandera == 1
	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01","Novo processo, a bandera de ativacao e 1" , 0, (nStart - Seconds()), {})
	
	If nOpcao == NIL
		nOpcao := 0
	ENDIF
	
	If oProcess == NIL
		oProcess := TWFProcess():New( "000002", "Solicta��o contas a pagar" )
	else
		
	ENDIF
	
	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01",'Op��o localizada, op��o 0: '+str(nOpcao), 0, (nStart - Seconds()), {})

    Do Case
	  Case nOpcao == 0  // Envio
    	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01","Inicia aprova��o de nova solicita��o" , 0, (nStart - Seconds()), {})

		SRIniciar( oProcess,cprefixo,cnumero,cparcela,ctipo,cfornece,cloja )
	  Case nOpcao == 1  // Retorno
    	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01","Solicitacao : opcao 1 selecionada" , 0, (nStart - Seconds()), {})

		SRRetorno( oProcess )
      Case nOpcao == 2  // Timeout
    	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01","Solicitacao : opcao 2 selecionada" , 0, (nStart - Seconds()), {})

		SRTimeOut( oProcess )
	End	
	
	
Endif
RETURN

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SRIniciar � Autor � Ismael Junior      � Data �  14/06/21   ���
�������������������������������������������������������������������������͹��
���Descricao � Retorno da aprova��o ou rejei��o                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACOM                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function SRIniciar(oProcess,cprefixo,cnumero,cparcela,ctipo,cfornece,cloja)
Local cMail     := " "
Local _cSol     := cUserName
Local cQuery:= ""
Local cSQL:= "TRA"
Local cNomeAprov  := ""
Local cEmailAprv  := ""
Local cIDSolicit  := ""
Local cEmailSoli  := ""
Local cDirHttp    := AllTrim(GetMV("MV_WFDHTTP"))

	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01","consulta os dados da inclus�o do titulo" , 0, (nStart - Seconds()), {})

    cQuery := " SELECT TOP 1 E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE, "
    cQuery += " E2_LOJA,SA2.A2_NOME E2_NOMFOR,E2_NATUREZ,E2_EMISSAO,E2_VENCTO,E2_VALOR,E2_HIST, "
    cQuery += " ZC_GRUPO,ZC_APROVA,ZC_NIVEL "
    cQuery += " FROM " + RetSqlName("SE2") + " SE2 "
    cQuery += " INNER JOIN " + RetSqlName("SZC") + " SZC ON ZC_FILIAL+ZC_PREFIXO+ZC_NUM+ZC_PARCELA+ZC_TIPO+ZC_FORNECE+ZC_LOJA = E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA AND SZC.D_E_L_E_T_ = ' '  "
    cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 ON SA2.D_E_L_E_T_ = ' ' AND SA2.A2_COD = SZC.ZC_FORNECE AND SA2.A2_LOJA = SZC.ZC_LOJA "
    cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
    cQuery += " AND E2_PREFIXO = '" + cprefixo + "' "
    cQuery += " AND E2_NUM = '" + cnumero + "' "
    //cQuery += " AND E2_PARCELA = '" + cparcela + "' "
    cQuery += " AND E2_TIPO = '" + ctipo + "' "
    cQuery += " AND E2_FORNECE = '" + cfornece + "' "
    cQuery += " AND E2_LOJA = '" + cloja + "' "
    cQuery += " AND ZC_LIBERA <> 'OK' "
    cQuery += " AND SE2.D_E_L_E_T_ = ' ' " 
    cQuery += " ORDER BY ZC_NIVEL " 		
		
    If SELECT(cSQL) > 0
        (cSQL)->(DbCloseArea())
    Endif
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSQL,.T.,.T.) 
    cNum := (cSQL)->E2_NUM
	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01","Busca informa��es do solicitante" , 0, (nStart - Seconds()), {})

    PswOrder(2)    // ordenado pelo nome
    If PswSeek(_cSol, .T. )
        aInfo := PswRet()
        cIDSolicit  := alltrim(aInfo[1][1])
        cEmailSoli  := Alltrim(aInfo[1][14])
    EndIf
    oProcess:NewTask( "Solicita��o ","\WORKFLOW\Wf050inc.HTM" )
    oProcess:cSubject := "Inclus�o Contas a Pagar: "+cNum
    oProcess:cBody	  := "Por favor verifique o arquivo anexado para aprovar a inclus�o no contas a pagar: "
    oProcess:bReturn  := "U_WF050INC(1)"
    oProcess:bTimeOut := {"U_WF050INC(2)",30, 05, 50 }  // Para timeout {{"FUNCION()",DIAS, HORAS, MINUTOS }}
    oHTML             := oProcess:oHTML

    oHTML:ValByName( "empresa", Alltrim(SM0->M0_NOMECOM) )
    oHTML:ValByName( "solicit", _cSol )
    oHTML:ValByName( "emailsol", cEmailSoli )
    oHtml:ValByName( "data", DTOC(Date()))
    oHTML:ValByName( "cnivel", (cSQL)->ZC_NIVEL )
    Do While (cSQL)->(!Eof())
        oHtml:ValByName( "cfillib", Alltrim((cSQL)->E2_FILIAL))
        oHtml:ValByName( "cprefixo", Alltrim((cSQL)->E2_PREFIXO))
        oHtml:ValByName( "cnumero", Alltrim((cSQL)->E2_NUM))
        oHtml:ValByName( "cparcela", Alltrim((cSQL)->E2_PARCELA))
        oHtml:ValByName( "ctipo", Alltrim((cSQL)->E2_TIPO))
        oHtml:ValByName( "cfornece", Alltrim((cSQL)->E2_FORNECE))
        oHtml:ValByName( "cloja", Alltrim((cSQL)->E2_LOJA))
        oHtml:ValByName( "cnomefor", Alltrim(Posicione("SA2",1,xFilial("SA2")+(cSQL)->E2_FORNECE+(cSQL)->E2_LOJA,"A2_NOME")))
        //oHtml:ValByName( "cnomefor", Alltrim((cSQL)->E2_NOMFOR))
        oHtml:ValByName( "dvencime", Alltrim(DTOC(StoD((cSQL)->E2_VENCTO))))
        oHtml:ValByName( "cvalor", Transform((cSQL)->E2_VALOR,"@E 999,999,999.99"))
        oHtml:ValByName( "cobs", Alltrim((cSQL)->E2_HIST))
        (cSQL)->(dbSkip())
    EndDo 
	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01",'Filial: ' + (cSQL)->E2_FILIAL, 0, (nStart - Seconds()), {})

    /*
    ///////////////////////////////////////////////////////////////////////////
    ///	BUSCA O E-MAIL DOS APROVADORES                     	///
    ///////////////////////////////////////////////////////////////////////////
    */
    (cSQL)->(DbGoTop())
    Do While (cSQL)->(!Eof())
    	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01",'Busca e-mail do aprovador: ' + (cSQL)->ZC_APROVA, 0, (nStart - Seconds()), {})

        PswOrder(1)    // ordenado pelo codigo
        If PswSeek((cSQL)->ZC_APROVA, .T. )
            aInfo := PswRet()
            cNomeAprov  := Alltrim(aInfo[1][2])
            cEmailAprv  := Alltrim(aInfo[1][14])
        EndIf

        If !Empty(cEmailAprv)
        	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01",'E-mail do aprovador selecionado: ' + cEmailAprv, 0, (nStart - Seconds()), {})

            cMail := cEmailAprv
            oProcess:ClientName( Subs(cUsuario,7,15) )
            oProcess:cTo      := PROCESOWF
            cMailID:=oProcess:Start()

            ////////////////////////////////////////////////////////////////////////////////////////////////////
        	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01","ID WF: "+ cMailID, 0, (nStart - Seconds()), {})

            /*
            ///////////////////////////////////////////////////////////////////////////
            ///Movemos o arquivo gerado ao diretorio do webservices	    			///
            ///para que se possa executar o HTTP POST corretamente  				///
            ///////////////////////////////////////////////////////////////////////////
            */
            cHtmlTexto := wfloadfile(cDirHttp+"\messenger\emp"+cEmpAnt+"\" + PROCESOWF +"\"+cMailID + ".htm")
            wfsavefile(HTMLPATH +"\emp"+cEmpAnt+"\"+cMailID + ".htm", cHtmlTexto)
            cHtmlModelo := "\WORKFLOW\wflink.HTM"
            oProcess:NewTask("Aprova��o de inclus�o no conta a pagar", cHtmlModelo)

            oProcess:cSubject := "AVB - Solita��o Contas a pagar"
            oProcess:cTo := AllTrim(cMail)
            oHTML:= oProcess:oHTML
            oHTML:ValByName("proc_link","http://" + cSrver + ":" + cPrto + "/ws/emp" + cEmpAnt + "/" + cMailID + ".htm")
            oHTML:ValByName("proc_link2","http://" + cSrvInt + ":" + cPrto + "/ws/emp" + cEmpAnt + "/" + cMailID + ".htm")
            oHTML:ValByName("referente","ao : Titulo numero: "+cNum ) 

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
            cBody += '<p>Por Favor abrir ao seguinte link Para efetuar a Libera��o da inclus�o no contas a pagar. </p>'
            cBody += '<p>Link</p>'
            cBody += '<a href="http://' + cSrvInt + ":" + cPrto + "/ws/emp" + cEmpAnt + "/" + cMailID + '.htm" title="liga">!proc_link2!</a>'
            cBody += '</form>'
            cBody += '</body>'
            cBody += '</html>'
            //oProcess:Start()
            u_EnviEmail('','Inclus�o no conta a pagar','AVB - Inclus�o no conta a pagar ' + cNum,cBody,.T.,AllTrim(cMail),'')
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //MsgInfo("E-mail enviado ao seguinte destinatario con exito!!"+CLRF+AllTrim(cMail),"Envio")
        Else
            MsgInfo("Para este aprovador: " + (cSQL)->ZC_APROVA + " n�o foi encontrado E-mail Cadastrado: ","Aten��o")
        Endif
        (cSQL)->(dbSkip())
    EndDo    
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SRRetorno � Autor � Ismael Junior      � Data �  15/06/21   ���
�������������������������������������������������������������������������͹��
���Descricao � Envia emais para demais aprovadores���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACOM                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC PROCEDURE SRRetorno( oProcess )
Local _cFilial := PADR( oProcess:oHtml:RetByName('cfillib'), TAMSX3("E2_FILIAL")[1]) 
Local cprefixo := PADR( oProcess:oHtml:RetByName('cprefixo'), TAMSX3("E2_PREFIXO")[1])
Local cnumero := PADR( oProcess:oHtml:RetByName('cnumero'), TAMSX3("E2_NUM")[1])   
Local cparcela := PADR( oProcess:oHtml:RetByName('cparcela'), TAMSX3("E2_PARCELA")[1]) 
Local ctipo := PADR( oProcess:oHtml:RetByName('ctipo'), TAMSX3("E2_TIPO")[1]) 
Local cfornece := PADR( oProcess:oHtml:RetByName('cfornece'), TAMSX3("E2_FORNECE")[1]) 
Local cloja := PADR( oProcess:oHtml:RetByName('cloja'), TAMSX3("E2_LOJA")[1])
//Local cObs    := Alltrim(oProcess:oHtml:RetbyName('lbmotivo'))
//Local cValor  := Alltrim(oProcess:oHtml:RetByName('cvalor'))
Local cMailRet := Alltrim(oProcess:oHtml:RetbyName('emailsol'))
Local cNamUser := Alltrim(oProcess:oHtml:RetbyName('solicit'))
Local cNnivel  := Alltrim(oProcess:oHtml:RetbyName('cnivel'))
//Local cAno     := Alltrim(Str(Year(Date())))
Local cMes     := Month2Str(Date())
FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01",'Entrou na rotina ' + cnumero, 0, (nStart - Seconds()), {})

If (oProcess:oHtml:RetByName('RBAPROVA') == 'Si')
	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01",'Autorizo o conta a pagar N: '+ cnumero, 0, (nStart - Seconds()), {})
	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01",'cMes :'+cMes, 0, (nStart - Seconds()), {})

    cUpdate := "UPDATE " + RetSqlName("SZC") + " SET ZC_DATALIB = '" + DTOS(Date()) + "', ZC_LIBERA = 'OK'  "
    cUpdate += "WHERE ZC_FILIAL = '" + _cFilial + "' "
    cUpdate += "AND ZC_PREFIXO = '" + cprefixo + "' "
    cUpdate += "AND ZC_NUM = '" + cnumero + "' "
    //cUpdate += "AND ZC_PARCELA = '" + cparcela + "' "
    cUpdate += "AND ZC_TIPO = '" + ctipo + "' "
    cUpdate += "AND ZC_FORNECE = '" + cfornece + "' "
    cUpdate += "AND ZC_LOJA = '" + cloja + "' "
    cUpdate += "AND ZC.D_E_L_E_T_ = ' ' " 
    cUpdate += "AND ZC_NIVEL = '" + cNnivel + "' "
	nFlag := TcSqlExec(cUpdate)

	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01",'Flag da libera��o' + str(nFlag) + ' Nivel ' + cNnivel, 0, (nStart - Seconds()), {})

    cQuery := " SELECT TOP 1 ZC_NIVEL,ZC_APROVA,ZC_FILIAL,ZC_PREFIXO,ZC_NUM,ZC_PARCELA,ZC_TIPO,ZC_FORNECE,ZC_LOJA "
    cQuery += " FROM " + RetSqlName("SZC") + " "
    cQuery += " WHERE ZC_FILIAL = '" + _cFilial + "' "
    cQuery += " AND ZC_PREFIXO = '" + cprefixo + "' "
    cQuery += " AND ZC_NUM = '" + cnumero + "' "
    //cQuery += " AND ZC_PARCELA = '" + cparcela + "' "
    cQuery += " AND ZC_TIPO = '" + ctipo + "' "
    cQuery += " AND ZC_FORNECE = '" + cfornece + "' "
    cQuery += " AND ZC_LOJA = '" + cloja + "' "
    cQuery += " AND ZC_LIBERA = ''"
    cQuery += " AND ZC.D_E_L_E_T_ = ' ' " 
    cQuery += " ORDER BY ZC_NIVEL"

    If SELECT("SZCTB") > 0
        SZCTB->(DbCloseArea())
    Endif
    ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SZCTB",.T.,.T.)
	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01",'Verifica se exitem mais aprovadores', 0, (nStart - Seconds()), {})

    iF !Empty(SZCTB->ZC_NIVEL) 
    	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01",'mais aprovadores encontrados' , 0, (nStart - Seconds()), {})

        oProcess := TWFProcess():New( "000002", "Solicta��o contas a pagar" )   
        RetIniciar( oProcess ,cprefixo,cnumero,cparcela,ctipo,cfornece,cloja,_cFilial,cNamUser ) 
    Else 
        cUpdate := "UPDATE " + RetSqlName("SE2") + " SET E2_DATALIB = '" + DTOS(date()) + "' "
        cUpdate += "WHERE E2_FILIAL = '" + _cFilial + "' ""
        cUpdate += "AND E2_PREFIXO = '" + cprefixo + "' "
        cUpdate += "AND E2_NUM = '" + cnumero + "' "
        //cUpdate += "AND E2_PARCELA = '" + cparcela + "' "
        cUpdate += "AND E2_TIPO = '" + ctipo + "' "
        cUpdate += "AND E2_FORNECE = '" + cfornece + "' "
        cUpdate += "AND E2_LOJA = '" + cloja + "' "
        cUpdate += "AND D_E_L_E_T_ = ' ' "
        nFlag := TcSqlExec(cUpdate)
        //************************************ LIBERA OS IMPOSTOS
        cUpdate := "UPDATE " + RetSqlName("SE2") + " SET E2_DATALIB = '" + DTOS(date()) + "' "
        cUpdate += "WHERE E2_FILIAL = '" + _cFilial + "' "
        cUpdate += "AND E2_PREFIXO = '" + cprefixo + "' "
        cUpdate += "AND E2_NUM = '" + cnumero + "' "
        cUpdate += "AND E2_TIPO IN ('TX','INS','ISS') "
        //cUpdate += "AND E2_FORNECE = 'UNIAO' "
        //cUpdate += "AND E2_LOJA = '00' "
        cUpdate += "AND D_E_L_E_T_ = ' ' "
        nFlag := TcSqlExec(cUpdate)                
    	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01",'Flag da libera��o SE2 ' + str(nFlag) + ' Nivel ' + cNnivel, 0, (nStart - Seconds()), {})

            		
        /*
        ///////////////////////////////////////////////////////////////////////////
        ///							E-Mail de aviso de aprova��o	   			///
        ///////////////////////////////////////////////////////////////////////////
        */
        
        cBody := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
        cBody += '<html><head><!-- saved from url=(0022)http://internet.e-mail -->'
        cBody += '<title>Aprova��o conta a pagar</title><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
        cBody += '<meta name="GENERATOR" content="Microsoft FrontPage Express 2.0"></head>'
        cBody += '<noscript>'
        cBody += '<body bgcolor="#FFFFFF">'
        cBody += '</noscript>'
        cBody += '<body>'
        cBody += '<form action="mailto:%WFMailTo%" method="post" name="FrontPage_Form1">'
        cBody += '<h2><b><font color="#000080" face="Arial">Solicita��o contas a pagar &nbsp;&nbsp;&nbsp;</font></b></h2>'
        cBody += '<p><b><font color="green" face="Arial">SOLICITA��O APROVADA </font></b></p>  '
        //cBody += '<p><b><font color="#000080" face="Arial">EMPRESA: '+oHtmO:RetByName('empresa')+' </font></b></p>'
        //cBody += '<p><b><font color="#000080" face="Arial">Solicitante: '+oHtmO:RetByName('solicit')+' </font></b></p>' 
        //cBody += '<p><b><font color="#000080" face="Arial">Aprovador: '+oHtmO:RetByName('aprovador')+' </font></b></p>'
        //cBody += '<p><b><font color="#000080" face="Arial">Data: '+oHtmO:RetByName('data')+' </font></b></p>'
        cBody += '<p><b><font color="#000080" face="Arial">Dados da solicita��o:</font></b></p>'
        cBody += '<table style="width: 1362px; height: 59px;" border="0" cellpadding="2">'
        cBody += '<tbody>'
        cBody += '<tr>'
        cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Numero</font></b></td>'
        cBody += '</tr>'
        cBody += '<tr>'
        cBody += '<td style="font-family: Arial;" bgcolor="#c0c0c0" width="100"><font size="2">'+ cnumero +'</font></td>'
        cBody += '</tbody>'
        cBody += '</table>'
        cBody += '</tr>'
        cBody += '</form>'
        cBody += '</body></html>'		
            
        u_EnviEmail('','WorkFlow | Solicitacao Aprovada','AVB - Solitacao Aprovada ' + cnumero ,cBody,.T.,AllTrim(cMailRet),'')	

    Endif            
ELSE		
        /*
        ///////////////////////////////////////////////////////////////////////////
        ///							E-Mail de aviso de rejei��o					///
        ///////////////////////////////////////////////////////////////////////////
        */            
    cBody := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
    cBody += '<html><head><!-- saved from url=(0022)http://internet.e-mail -->'
    cBody += '<title>Aprova��o Contas a Pagar</title><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
    cBody += '<meta name="GENERATOR" content="Microsoft FrontPage Express 2.0"></head>'
    cBody += '<noscript>'
    cBody += '<body bgcolor="#FFFFFF">'
    cBody += '</noscript>'
    cBody += '<body>'
    cBody += '<form action="mailto:%WFMailTo%" method="post" name="FrontPage_Form1">'
    cBody += '<h2><b><font color="#000080" face="Arial">Solicita��o contas a pagar &nbsp;&nbsp;&nbsp;</font></b></h2>'
    cBody += '<p><b><font color="red" face="Arial">SOLICITA��O REJEITADO </font></b></p>'
    cBody += '<p><b><font color="#000080" face="Arial">Motivo: '+oHtmO:RetByName('lbmotivo')+' </font></b></p>'
    cBody += '<p><b><font color="#000080" face="Arial">EMPRESA: '+oHtmO:RetByName('empresa')+' </font></b></p>'
    cBody += '<p><b><font color="#000080" face="Arial">Solicitante: '+oHtmO:RetByName('solicit')+' </font></b></p>'
    cBody += '<p><b><font color="#000080" face="Arial">Data: '+oHtmO:RetByName('data')+' </font></b></p>'
    cBody += '<p><b><font color="#000080" face="Arial">Dados da solicita��o:</font></b></p>'
    cBody += '<table style="width: 1362px; height: 59px;" border="0" cellpadding="2">'
    cBody += '<tbody>'
    cBody += '<tr>'
    cBody += '<td align="center" bgcolor="#99ccff" width="141"><b><font face="Arial" size="2">Numero</font></b></td>'
    cBody += '</tr>'
    cBody += '<tr>'
    cBody += '<td style="font-family: Arial;" bgcolor="#c0c0c0" width="100"><font size="2">'+oHtmO:RetByName('cnumero')+'</font></td>'
    cBody += '</tbody>'
    cBody += '</table>'
    cBody += '</tr>'
    cBody += '</form>'
    cBody += '</body></html>'		
        
    u_EnviEmail('','WorkFlow | Solicitacao Negada','AVB - Solitacao recusada',cBody,.T.,AllTrim(cMailRet),'')	
ENDIF 
Return

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////TIMEOUT                     																		//////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
STATIC PROCEDURE SRTimeOut( oProcess )
    FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01","Fun��o de TIMEOUT executada", 0, (nStart - Seconds()), {})
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RetIniciar � Autor � Ismael Junior      � Data �  18/10/17   ���
�������������������������������������������������������������������������͹��
���Descricao � envio de e-mail para segundo aprovador                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACOM                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function RetIniciar(oProcess,cprefixo,cnumero,cparcela,ctipo,cfornece,cloja,_cxFilial,cNamUsr)
Local cMail         := " "
Local _cSol         := cNamUsr
Local cQuery        := ""
Local cSQL          := "TRA"
Local cNomeAprov    := ""
Local cEmailAprv    := ""
Local cIDSolicit    := ""
Local cEmailSoli    := ""
Local cDirHttp      := AllTrim(GetMV("MV_WFDHTTP"))

	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01",'Proximo aprovador:  consulta os dados da inclus�o do titulo *************', 0, (nStart - Seconds()), {})

    cQuery := " SELECT TOP 1 E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE, "
    cQuery += " E2_LOJA,SA2.A2_NOME E2_NOMFOR,E2_NATUREZ,E2_EMISSAO,E2_VENCTO,E2_VALOR,E2_HIST, "
    cQuery += " ZC_GRUPO,ZC_APROVA,ZC_NIVEL "
    cQuery += " FROM " + RetSqlName("SE2") + " SE2 "
    cQuery += " INNER JOIN " + RetSqlName("SZC") + " SZC ON ZC_FILIAL+ZC_PREFIXO+ZC_NUM+ZC_PARCELA+ZC_TIPO+ZC_FORNECE+ZC_LOJA = E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA AND SZC.D_E_L_E_T_ = ' '  "
    cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 ON SA2.D_E_L_E_T_ = ' ' AND SA2.A2_COD = SZC.ZC_FORNECE AND SA2.A2_LOJA = SZC.ZC_LOJA "
    cQuery += " WHERE E2_FILIAL = '" + _cxFilial + "' "
    cQuery += " AND E2_PREFIXO = '" + cprefixo + "' "
    cQuery += " AND E2_NUM = '" + cnumero + "' "
    //cQuery += " AND E2_PARCELA = '" + cparcela + "' "
    cQuery += " AND E2_TIPO = '" + ctipo + "' "
    cQuery += " AND E2_FORNECE = '" + cfornece + "' "
    cQuery += " AND E2_LOJA = '" + cloja + "' "
    cQuery += " AND ZC_LIBERA <> 'OK' "
    cQuery += " AND SE2.D_E_L_E_T_ = ' ' " 
    cQuery += " ORDER BY ZC_NIVEL " 		
    If SELECT(cSQL) > 0
        (cSQL)->(DbCloseArea())
    Endif
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSQL,.T.,.T.) 
    cNum := (cSQL)->E2_NUM
	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01",'Busca informa��es do solicitante ' + _cSol, 0, (nStart - Seconds()), {})

    PswOrder(2)    // ordenado pelo nome
    If PswSeek(_cSol, .T. )
        aInfo := PswRet()
        cIDSolicit  := alltrim(aInfo[1][1])
        cEmailSoli  := Alltrim(aInfo[1][14])
    EndIf
    oProcess:NewTask( "Solicita��o ","\WORKFLOW\Wf050inc.HTM" )
    oProcess:cSubject := "Inclus�o Contas a Pagar: "+cNum
    oProcess:cBody	  := "Por favor verifique o arquivo anexado para aprovar a inclus�o no contas a pagar: "
    oProcess:bReturn  := "U_WF050INC(1)"
    oProcess:bTimeOut := {"U_WF050INC(2)",30, 05, 50 }  // Para timeout {{"FUNCION()",DIAS, HORAS, MINUTOS }}
    oHTML             := oProcess:oHTML

    oHTML:ValByName( "empresa", Alltrim(SM0->M0_NOMECOM) )
    oHTML:ValByName( "solicit", _cSol )
    oHTML:ValByName( "emailsol", cEmailSoli )
    oHtml:ValByName( "data", DTOC(Date()))
    oHTML:ValByName( "cnivel", (cSQL)->ZC_NIVEL )
    Do While (cSQL)->(!Eof())
        oHtml:ValByName( "cfillib", Alltrim((cSQL)->E2_FILIAL))
        oHtml:ValByName( "cprefixo", Alltrim((cSQL)->E2_PREFIXO))
        oHtml:ValByName( "cnumero", Alltrim((cSQL)->E2_NUM))
        oHtml:ValByName( "cparcela", Alltrim((cSQL)->E2_PARCELA))
        oHtml:ValByName( "ctipo", Alltrim((cSQL)->E2_TIPO))
        oHtml:ValByName( "cfornece", Alltrim((cSQL)->E2_FORNECE))
        oHtml:ValByName( "cloja", Alltrim((cSQL)->E2_LOJA))
       // oHtml:ValByName( "cnomefor", Alltrim((cSQL)->E2_NOMFOR))
        oHtml:ValByName( "cnomefor", Alltrim(Posicione("SA2",1,xFilial("SA2")+(cSQL)->E2_FORNECE+(cSQL)->E2_LOJA,"A2_NOME")))
        oHtml:ValByName( "dvencime", Alltrim(DTOC(StoD((cSQL)->E2_VENCTO))))
        oHtml:ValByName( "cvalor", Transform((cSQL)->E2_VALOR,"@E 999,999,999.99"))
        oHtml:ValByName( "cobs", Alltrim((cSQL)->E2_HIST))
        (cSQL)->(dbSkip())
    EndDo
	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "",'Filial: ' + (cSQL)->E2_FILIAL, 0, (nStart - Seconds()), {})

    /*
    ///////////////////////////////////////////////////////////////////////////
    ///	BUSCA O E-MAIL DOS APROVADORES                     	///
    ///////////////////////////////////////////////////////////////////////////
    */
    (cSQL)->(DbGoTop())
    Do While (cSQL)->(!Eof())
    	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01",'Busca e-mail do aprovador: ' + (cSQL)->ZC_APROVA , 0, (nStart - Seconds()), {})

        PswOrder(1)    // ordenado pelo codigo
        If PswSeek((cSQL)->ZC_APROVA, .T. )
            aInfo := PswRet()
            cNomeAprov  := Alltrim(aInfo[1][2])
            cEmailAprv  := Alltrim(aInfo[1][14])
        EndIf

        If !Empty(cEmailAprv)
    	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01",'E-mail do aprovador selecionado: ' + cEmailAprv, 0, (nStart - Seconds()), {})

        cMail := cEmailAprv
        oProcess:ClientName( Subs(cUsuario,7,15) )
        oProcess:cTo      := PROCESOWF
        cMailID:=oProcess:Start()

        ////////////////////////////////////////////////////////////////////////////////////////////////////
    	FwLogMsg("WF050INC", /*cTransactionId*/, "WF050INC", FunName(), "", "01","ID WF: "+ cMailID, 0, (nStart - Seconds()), {})

        /*
        ///////////////////////////////////////////////////////////////////////////
        ///Movemos o arquivo gerado ao diretorio do webservices	    			///
        ///para que se possa executar o HTTP POST corretamente  				///
        ///////////////////////////////////////////////////////////////////////////
        */
        cHtmlTexto := wfloadfile(cDirHttp+"\messenger\emp"+cEmpAnt+"\" + PROCESOWF +"\"+cMailID + ".htm")
        wfsavefile(HTMLPATH +"\emp"+cEmpAnt+"\"+cMailID + ".htm", cHtmlTexto)
        cHtmlModelo := "\WORKFLOW\wflink.HTM"
        oProcess:NewTask("Aprova��o de inclus�o no conta a pagar", cHtmlModelo)

        oProcess:cSubject := "AVB - Aprova��o de inclus�o no contas a pagar"
        oProcess:cTo := AllTrim(cMail)
        oHTML:= oProcess:oHTML
        oHTML:ValByName("proc_link","http://" + cSrver + ":" + cPrto + "/ws/emp" + cEmpAnt + "/" + cMailID + ".htm")
        oHTML:ValByName("proc_link2","http://" + cSrvInt + ":" + cPrto + "/ws/emp" + cEmpAnt + "/" + cMailID + ".htm")
        oHTML:ValByName("referente","ao : Titulo numero: "+cNum ) 

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
        cBody += '<p>Por Favor abrir ao seguinte link Para efetuar a Libera��o da inclus�o no contas a pagar. </p>'
        cBody += '<p>Link</p>'
        cBody += '<a href="http://' + cSrvInt + ":" + cPrto + "/ws/emp" + cEmpAnt + "/" + cMailID + '.htm" title="liga">!proc_link2!</a>'
        cBody += '</form>'
        cBody += '</body>'
        cBody += '</html>'
        //oProcess:Start()
        u_EnviEmail('','Inclus�o no conta a pagar','AVB - Inclus�o no conta a pagar ' + cNum ,cBody,.T.,AllTrim(cMail),'')
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //MsgInfo("E-mail enviado ao seguinte destinatario con exito!!"+CLRF+AllTrim(cMail),"Envio")
        Else
            MsgInfo("Para este aprovador n�o foi encontrado E-mail Cadastrado: ","Aten��o")
        Endif
        (cSQL)->(dbSkip())
    EndDo    
Return
