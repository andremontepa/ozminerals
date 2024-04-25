#include "rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT097GRV  ºAutor  Adriano Reis         º Data ³  06/09/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descricao ³ 1 - PONTO DE ENTRADA NA LIBERACAO DE PEDIDOS DE COMPRA     ³±±
±±³          ³ UTILIZADO PARA CONTROLE DO VALOR LIMITE DOS TITULOS E DATAS³±±
±±³          ³ DE VENCIMENTO DOS TITULOS A PAGAR                          ³±±
±±³          ³ 2 - Correção Açadas do Workflow Compras					  ³±±
±±³          ³ 															  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Avanco                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT097GRV()
Local ExpA1 := PARAMIXB[1]
Local ExpD1 := PARAMIXB[2]
Local ExpN1 := PARAMIXB[3] //Contém a operação a ser executada.1-Inclusão do Documento;2-Transferência para Superior;3-Exclusão;4-Aprovação;5-Estorno;6-Bloqueio de aprovação
Local ExpC1 := PARAMIXB[4]
Local ExpL1 := PARAMIXB[5]
Local ExpL2 := .T.
Local aTmpAprov     := {}
local _cNumPed      := ""
Local _cTipoPed     := ""
Local _cFilial      := ""
Local cAtivaWF    	:= SuperGetMv("MV_XWORKPC",,.T.) //Logico // Ativa Processo Workflow Sim ou Nao.
Local aArea  		:= GetArea()
Local aAreaSCR		:= SCR->(GetArea())
Local aAreaSAL		:= SAL->(GetArea())
Local aAreaSC7		:= SC7->(GetArea())
Local cNameEmp      := ""
Private cGerentCom  := SuperGetMV("MV_XUSGCOM",,'000002') //ID do Usuario Gerente Modulo Compras.

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

if cAtivaWF
	
	IF ExpN1 = 4   //Caso seja Aprovação Passa para o Proximo Nivel Via E-mail.
		
		If !IsBlind()  //Caso seja Workflow ou ExecAuto.
			
			AADD(aTmpAprov, {SCR->CR_NIVEL,SCR->CR_USER , UsrRetName(SCR->CR_USER),'APROVADO',SCR->CR_APROV,DTOC(SCR->CR_DATALIB),Alltrim(SCR->CR_OBS)})
			
			_cNumPed  := Alltrim(PARAMIXB[1][1])
			_cTipoPed := Alltrim(PARAMIXB[1][2])
			_cFilial  := Alltrim(xFilial("SC7"))
			
			if ( SC7->C7_FILIAL+SC7->C7_NUM = _cFilial+_cNumPed  )
				
				IF cAtivaWF
					
					cMSGAprov  	:= 	"APROVADO"
					cAviso		:=	"NOTIFICAÇÃO - Pedido de Compra "+cMSGAprov+" - Pedido No "+_cNumPed+" - Empresa "+cNameEmp+" - Filial "+_cFilial
					
					//Mensagem
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
					xHTM +='  				<img id="_x0000_i1025" src="http://avancoresources.com/wp-content/uploads/AvancoLogo.png" border="0" width="263" height="123"></span></b></td>'
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
					xHTM +='			<TH ALIGN="center" BGCOLOR="#FFFFFF">'
					xHTM +='				<FONT  SIZE="5" COLOR="#005151" FACE="verdana, arial, helvetica, times" >'
					xHTM +='			</TH>'
					xHTM +='		</TR>'
					xHTM +='		<TR>'
					xHTM +='        	<TD align="left" BGCOLOR="#FFFFFF"> '
					xHTM +='            	<FONT  SIZE="3" COLOR="#005151" FACE="verdana, arial, helvetica, times" > '
					xHTM +='                <br/> '
					xHTM +='				'+Alltrim(cAviso)+' '+dtoc(date())+'  '+time()+' '
					xHTM +='                <br/> '
					xHTM +='				O pedido em referencia foi '+cMSGAprov+' '
					xHTM +='                <br/>'
					//xHTM +='                '+iif(!Empty(cJusti),'Motivo: '+cJusti,'')+' '
					xHTM +='                <br/>'
					xHTM +='				Data '+DTOC(date())+' Hora:'+time()+' '
					xHTM +='                <br/>'
					xHTM +='                Responsável '+UsrRetName(__CUSERID)+' '
					xHTM +='                <br/>'
					xHTM +='                </FONT>'
					xHTM +='			</TD> '
					xHTM +='		</TR> '
					xHTM +='	</TABLE>'
					xHTM +='	<br />'
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
					
					cDestino := UsrRetMail(cGerentCom)
					
					u_EnviEmail('','Aviso'+cAviso+'','Aviso : '+cAviso+'',xHTM,.t.,cDestino,'')	//Envia email de Aviso
					
					cNivelWf := U_UltiAprov(SC7->C7_FILIAL,SC7->C7_NUM,'PC')
					if !Empty(cNivelWf[1][1])
						cNivelApr := (cNivelWf[1][1])
						cNivelApr := padl(Val(cNivelApr)+1,2,'0')
						U_ACOMP003(,,cNivelApr,,,,,aTmpAprov)
					EndIf
				EndIf
				
			Else
				If _cTipoPed == "PC"
					DbSelectArea("SC7")
					SC7->(DbSetOrder(1))
					if SC7->(DbSeek(cFilial+cNumPed))
						IF cAtivaWF
							cNivelWf := U_UltiAprov(SC7->C7_FILIAL,SC7->C7_NUM,'PC')							
							if !Empty(cNivelWf[1][1])
								cNivelApr := (cNivelWf[1][1])
								cNivelApr := padl(Val(cNivelApr)+1,2,'0')
								U_ACOMP003(,,cNivelApr,,,,,aTmpAprov)
							EndIf						
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aArea)
RestArea(aAreaSCR)
RestArea(aAreaSAL)
RestArea(aAreaSC7)
Return(ExpL2)

