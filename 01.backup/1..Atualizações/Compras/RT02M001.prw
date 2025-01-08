#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} RT02M001
Fonte Executado no ponto de Entrada MT110STTS
@type function
@author Ricardo Tavares Ferreira
@since 25/06/2021
@version 12.1.27
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6085449
@obs Executado na Exclusão da Solicitação de Compras.
@history 25/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//=============================================================================================================================
    User Function RT02M001(xNumSC)
//=============================================================================================================================

    Local aArea     := GetArea()

    Private cObsSC      := ""
    Private oObsSC      := Nil 
    Private oDlg        := Nil 
    Private oBtnConf    := Nil
    Private cNumSC      := ""

    Default xNumSC      := ""

    cNumSC := xNumSC

    Define Font oFont1 Name "Consolas" Size 07 , 17
    Define MsDialog oDlg Title OemToAnsi("Motivo da Exclusão da Solicitação de Compras") style 128 From 000 , 000 To 200 , 650 Pixel
	
	oDlg:lEscClose := .F. 

    @ 006 , 008 Say "Motivo da Exclusão:"	                     Size 070 , 010 Of Odlg Pixel COLOR CLR_HBLUE	
    @ 014 , 008 Get oObsSC Var cObsSC Multiline Text Font oFont1 Size 311 , 65 Valid ValMotivo() Pixel Of oDlg
	@ 083 , 143 BUTTON oBtnConf PROMPT "Confirmar"	             Size 050 , 013 Of oDlg Action(ProcMot()) Pixel

    Activate MsDialog oDlg Centered 

    RestArea(aArea)
Return Nil

/*/{Protheus.doc} ProcMot
Processa os Dados Encontrados.
@type function
@author Ricardo Tavares Ferreira
@since 25/06/2021
@version 12.1.27
@return logical, Retorna verdadeiro se validou o campo.
@history 25/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//=============================================================================================================================
    Static Function ProcMot()
//=============================================================================================================================

    Local cMsgHtml  := ""
    Local cPara     := ""

    cMsgHtml := GetHtml()
    cPara    := UsrRetMail(SC1->C1_USER)

    if Empty(cPara)
        MSGALERT( "Solicitante não possui e-mail cadastrado! SC foi excluida sem envio de e-mail.", "ATENÇÃO" )
    elseif .not. Empty(cMsgHtml)
        //EnviarEmail(cPara,"Exclusão da Solicitação de Compras - "+Alltrim(cNumSC),cMsgHtml,"")
        U_EnviEmail("",AllTrim(cFilAnt)+" - Exclusão da Solicitação de Compras - "+Alltrim(cNumSC),AllTrim(cFilAnt)+" - Exclusão da Solicitação de Compras - "+Alltrim(cNumSC),cMsgHtml,.F.,cPara,"")
    EndIf 
    oDlg:End()
Return Nil 

/*/{Protheus.doc} GetHtml
Função que monta o Html que vai ser enviado para o Usuario.
@type function
@author Ricardo Tavares Ferreira
@since 25/06/2021
@version 12.1.27
@return logical, Retorna verdadeiro se validou o campo.
@param cHtml, character, Variavel que salva o corpo do email.
@history 25/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//=============================================================================================================================
    Static Function GetHtml()
//=============================================================================================================================

    Local cHtml     := ""
    Local cQuery	:= ""
	Local QbLinha	:= chr(13)+chr(10)
	Local nQtdReg	:= 0
    Local cAliasSC  := GetNextAlias()

    cQuery := " SELECT SC1.* "+QbLinha 
    cQuery += " FROM "
	cQuery +=   RetSqlName("SC1") + " SC1 "+QbLinha 
    cQuery += " WHERE "+QbLinha  
    cQuery += " SC1.D_E_L_E_T_ <> ' ' "+QbLinha  
    cQuery += " AND C1_NUM = '"+Alltrim(cNumSC)+"' "+QbLinha 

    MemoWrite("C:/ricardo/RT02M001_GetHtml.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC,.F.,.T.)
		
	DbSelectArea(cAliasSC)
	(cAliasSC)->(DbGoTop())
	Count TO nQtdReg
	(cAliasSC)->(DbGoTop())
		
	If nQtdReg <= 0
		(cAliasSC)->(DbCloseArea())
		Return cHtml
    Else 
        cHtml := '  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"> '+QbLinha 
        cHtml += '  <html><head> '+QbLinha 
        cHtml += '  	<script></script> '+QbLinha 
        cHtml += '  	<title>Mot. da Exclusão da SC</title> '+QbLinha 
        cHtml += '  	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"> '+QbLinha 
        cHtml += '  	<link href="https://sitenethomologa.serasa.com.br/elementos_estrutura/transacional/css/style.css" rel="stylesheet" type="text/css"> '+QbLinha 
        cHtml += '  	<link href="https://sitenethomologa.serasa.com.br/elementos_estrutura/transacional/mensagens/css/mensagens.css" rel="stylesheet" type="text/css"> '+QbLinha 
        cHtml += '  	<style media="all"> '+QbLinha 
        cHtml += '  		body{ '+QbLinha 
        cHtml += '  			font-family:Arial; '+QbLinha 
        cHtml += '  			font-size:90%; '+QbLinha 
        cHtml += '  			background-color:#ffffff; '+QbLinha 
        cHtml += '  			padding: 0 10px; '+QbLinha 
        cHtml += '  		} '+QbLinha 
        cHtml += '  		table{ '+QbLinha 
        cHtml += '  			width:80%; '+QbLinha 
        cHtml += '  		} '+QbLinha 
        cHtml += '  		.NaoImprimir{ '+QbLinha 
        cHtml += '  			padding-top:10px; '+QbLinha 
        cHtml += '  		} '+QbLinha 
        cHtml += '  		.BotoesFuncoes{ '+QbLinha 
        cHtml += '  			text-align:right; '+QbLinha 
        cHtml += '  		} '+QbLinha 
        cHtml += '  		.BotoesFuncoes input{ '+QbLinha 
        cHtml += '  			text-align:right; '+QbLinha 
        cHtml += '  			font-size:14px; '+QbLinha 
        cHtml += '  			padding:4px; '+QbLinha 
        cHtml += '  		} '+QbLinha 
  		cHtml += '  		td,th,.trBlue1{  '+QbLinha 
		cHtml += '  			text-align:center;  '+QbLinha 
		cHtml += '  		}  '+QbLinha 
		cHtml += '  		.Caixa { '+QbLinha 
		cHtml += '  			width:80%; '+QbLinha 
		cHtml += '  			font-family:calibri; '+QbLinha 
		cHtml += '  			font-size: 18px; '+QbLinha 
		cHtml += '  			text-align: justify; '+QbLinha 
		cHtml += '  			font-color: #1C1C1C; '+QbLinha 
		cHtml += '  			font-weight: bold; '+QbLinha 
		cHtml += '  		} '+QbLinha 
		cHtml += '  		.Cabec { '+QbLinha 
		cHtml += '  			width:80%; '+QbLinha 
		cHtml += '  			font-family:calibri; '+QbLinha 
		cHtml += '  			font-size: 27px; '+QbLinha 
		cHtml += '  			text-align: center; '+QbLinha 
		cHtml += '  			font-color: #1C1C1C; '+QbLinha 
		cHtml += '  			font-weight: bold; '+QbLinha 
		cHtml += '  		} '+QbLinha 
		cHtml += '  		.Topo { '+QbLinha 
		cHtml += '  			width:80%; '+QbLinha 
		cHtml += '  			font-family:calibri; '+QbLinha 
		cHtml += '  			font-size: 16px; '+QbLinha 
		cHtml += '  			text-align: left; '+QbLinha 
		cHtml += '  			font-color: #1C1C1C; '+QbLinha 
		cHtml += '  			font-weight: bold; '+QbLinha 
		cHtml += '  		} '+QbLinha 
        cHtml += '  	</style> '+QbLinha 
        cHtml += '   '+QbLinha 
        cHtml += '  </head> '+QbLinha 
        cHtml += '  	<body> '+QbLinha 
        cHtml += '  		<p class="Topo">'+Alltrim(FWEmpName(Upper(cEmpAnt)))+' - '+Alltrim(Upper(FWFilName(cEmpAnt,cFilAnt)))+'</p> '+QbLinha 
        cHtml += '  			<table id="tabelaInicial"  class="tableBlue" border="1" cellpadding="0" cellspacing="0" width="80%"> '+QbLinha 
        cHtml += '  				<tr> '+QbLinha 
        cHtml += '  					<td"> '+QbLinha 
        cHtml += '  						<p class="Cabec">Motivo de Exclusao da Solicitacao de Compras</p> '+QbLinha 
        cHtml += '  					</td> '+QbLinha 
        cHtml += '  					<td width="9%"><font color="#eecbad" face="calibri" size="2"><b><img border="0"><img src="https://sites.google.com/a/equilibrioti.com.br/equilibrioti/logoavb/logo-avanco-oz.png" height="100" width="214"></b></font></td> '+QbLinha 
        cHtml += '  				</tr> '+QbLinha 
        cHtml += '  			</table> '+QbLinha 
        cHtml += '  		<p class="Caixa"> '+QbLinha 
        cHtml += '  			Este email está sendo enviado por que a Solicitação de Compras N° '+Alltrim(cNumSC)+' da filial '+Alltrim(cFilAnt)+' - '+Alltrim(Upper(FWFilName(cEmpAnt,cFilAnt)))+'. foi excluída do sistema pelo usuário '+Alltrim(Upper(UsrFullName((cAliasSC)->(C1_USER))))+', confira abaixo o motivo digitado para a exclusão. '+QbLinha 
        cHtml += '  		</p> '+QbLinha 
        cHtml += '  		<br> '+QbLinha 
        cHtml += '  		<p class="Cabec">Dados da Solicitacao de Compras Excluida</p> '+QbLinha 
        cHtml += '  		<table style="width: 80%;" class="tableBlue"> '+QbLinha 
        cHtml += '  			<tbody> '+QbLinha 
        cHtml += '  			  <tr class="trGray2"> '+QbLinha 
        cHtml += '  				<th rowspan="1">Item</th> '+QbLinha 
        cHtml += '  				<th rowspan="1">Produto</th> '+QbLinha 
        cHtml += '  				<th rowspan="1">Quantidade</th> '+QbLinha 
        cHtml += '  				<th rowspan="1">Unid</th> '+QbLinha 
        cHtml += '  				<th rowspan="1">C. Custo</th> '+QbLinha 
        cHtml += '  				<th rowspan="1">Item Contábil </th> '+QbLinha 
        cHtml += '  				<th rowspan="1">Observação</th> '+QbLinha 
        cHtml += '  			  </tr> '+QbLinha 

        While .not. (cAliasSC)->(Eof())
            SC1->(DbGoto((cAliasSC)->R_E_C_N_O_))
            cHtml += '  			  <tr> '+QbLinha 
            cHtml += '  				<td>'+Alltrim((cAliasSC)->(C1_ITEM))+'</td> '+QbLinha 
            cHtml += '  				<td align="left">'+Alltrim((cAliasSC)->(C1_PRODUTO))+' - '+Alltrim((cAliasSC)->(C1_DESCRI))+'</td> '+QbLinha 
            cHtml += '  				<td>'+Transform((cAliasSC)->(C1_QUANT),X3Picture("C1_QUANT"))+'</td> '+QbLinha 
            cHtml += '  				<td>'+Alltrim((cAliasSC)->(C1_UM))+'</td> '+QbLinha 
            cHtml += '  				<td>'+Alltrim((cAliasSC)->(C1_CC))+'</td> '+QbLinha 
            cHtml += '  				<td>'+Alltrim((cAliasSC)->(C1_ITEMCTA))+'</td> '+QbLinha 
            cHtml += '  				<td>'+Alltrim(SC1->C1_OBS)+'</td> '+QbLinha 
            cHtml += '  			  </tr> '+QbLinha 
            (cAliasSC)->(DbSkip())
        End 

        cHtml += '  			</tbody> '+QbLinha 
        cHtml += '  		</table> '+QbLinha 
        cHtml += '  		<br> '+QbLinha 
        cHtml += '  		<p class="Cabec">Motivo Digitado Pelo Usuario</p> '+QbLinha 
        cHtml += '  		<br><br> '+QbLinha 
        cHtml += '  		<p class="Caixa">'+Alltrim(cObsSC)+'</p>'+QbLinha 
        cHtml += '  	</body> '+QbLinha 
        cHtml += '  </html> '+QbLinha 
    EndIf
    (cAliasSC)->(DbCloseArea())
Return cHtml

/*/{Protheus.doc} ValMotivo
Função que valida o campo Memo digitado pelo usuario.
@type function
@author Ricardo Tavares Ferreira
@since 25/06/2021
@version 12.1.27
@return logical, Retorna verdadeiro se validou o campo.
@history 25/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//=============================================================================================================================
    Static Function ValMotivo()
//=============================================================================================================================

    If Empty(cObsSC)
        MsgStop("Não é possivel confirmar a tela sem digitar o motivo de exclusão da Solicitação de Compra.","Atenção")
        Return .F.
    EndIf
Return .T.
