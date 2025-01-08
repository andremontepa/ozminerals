#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "protheus.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACOMP003  ºAutor  ³Sangelles           º Data ³  27/01/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada para envio de Workflow na apos confirmacao º±±
±±º          ³da Geracao do Pedido de Compra                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Acelerador Totvs Goias                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º	Dados Adicionais de Alteracao/Ajustes do Fonte                        º±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºData      ³ Descricao:                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User function ACOMP003(nOpcao, oProcess, cNivelWF, cObsWF, cCopiaPa, lAltera, cAnexo , aTmpAprov)

Private cNameEmp    := ""
Private cAviso		:= ""
Private cDestino    := ""
Private bXMSAPRO 	:= .T. ///SuperGetMV("MV_XMSAPRO")
Private cxFilial 	:= ""
Private cCodLiber	:= "000000"
Private cNivelApr	:= ""
Private lLiberou    := .F.
Private _xUsuario   := " "
Private cNivelUser  := cNivelWF
Private cAnexoWF    := ''
Private cObse       := ""
Private cCcusto     := ""
Private cGrpAprova  := ""
Private lEnvAnexo   := .F.
Private nHist		:= 0
Private cCopia      := ' '
Private cUserpad    := SuperGetMV("MV_XUSRPAD",,'')
Private cEnvHtm     := .F.
Private _cAltera    := ""
Private cCdUserMail := ""
Private texto1	    := ""
Private texto2	    := ""
Private texto3	    := ""
Private texto4	    := ""         
Private cGerentCom  := SuperGetMV("MV_XUSGCOM",,'000033') //ID do Usuario Gerente Modulo Compras.
Private aTempAprov  := aTmpAprov

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

If ValType(nOpcao) = "A"
	nOpcao := nOpcao[1]
Endif

If nOpcao == NIL
	nOpcao := 0
EndIf

If cNivelWF == NIL
	cNivelWF  := ''
Endif

If cNivelUser == NIL
	cNivelUser  := ''
Endif
                    
If aTmpAprov == NIL
	aTempAprov := {}
Else
	aTempAprov := aTmpAprov
EndIf

If cObsWF == NIL
	cObse  := ""
Else
	cObse  := 'REMETENTE : '+Alltrim(capital(cUserName))
	if !Empty(cObsWF)
		cObse  += Chr(13)+Chr(10)+'OBSERVAÇÃO DE REENVIO DE LIBERAÇÃO  : '+Alltrim(cObsWF)
	EndIf
EndIf

If cCopiaPa == NIL
	cCopiaPa:= ""
Else
	cCopia += cCopiaPa
EndIf

If lAltera == NIL
	_cAltera := ''
Else
	if lAltera
		_cAltera := "Pedido Alterado pelo usuario "+Alltrim(__cUserId)+ " - " +Alltrim(capital(cUserName))//U_zUsrFulnam(SC7->C7_USER)
	EndIf
EndIf

if cAnexo == NIL
	cAnexoWF := ''
Else
	cAnexoWF := cAnexo
	
	if !Empty(cAnexoWF)
		lEnvAnexo := .T.
	EndIf
	
EndIf

ConOut("Opcao:"+cValtochar(nOpcao))

If oProcess == NIL
	oProcess := TWFProcess():New( "PEDCOM", "Pedido de Compras" )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CPAR,NBARRA,N_ITEM,C_MAT,C_DEST,CGRAP")
SetPrvt("C_NUM,C_MOTIVO,N_TOTPC,CGRAPANT,N_TERMINA,N_DOHTML")
SetPrvt("CRAIZ,NRET,NHLDHTM,NHLDSCP,CIND,C_PCANT")
SetPrvt("N_QTDPC,N_FRTPC,A_ITENS,LCABEC,_AREGISTROS,NLIMITE")
SetPrvt("CAB_NUM,CAB_EMIS,CAB_FORN,CAB_COND,CAB_NOME,_NI")
SetPrvt("ARRAYCAB,ARRAYITENS,C_ITPED,NPRESUP,CAPROV,AINFO")
SetPrvt("CMAILAP,CNOMEAP,CORIGEM,CABEC,NHDLVLR,NCOUNT")
SetPrvt("NRESULT,CHTML,NHDLCONNECT")

Conout(" ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Vai entrar no Tipo De Opção: "+ alltrim(str(nOpcao)) )

Do Case
	Case nOpcao == 0
		Conout(" ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Entrando no SPCIniciar" )
		SPCIniciar( oProcess ,cNivelUser )
		Conout(" ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Saiu no SPCIniciar" )
	Case nOpcao == 1
		Conout(" ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Entrando no SPCRetorno")
		SPCRetorno( oProcess )             
		Conout(" ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Saiu no SPCRetorno")
	Case nOpcao == 2
		Conout(" ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Entrando no SPCTimeOut")
		SPCTimeOut( oProcess )
		Conout(" ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Saiu no SPCTimeOut")
		
	End
	Conout(" ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Saiu do Tipo Opção: "+ alltrim(str(nOpcao)) )
	Conout(" ( WF APROVAÇÃO) Data: ************************************************** PROCESSO ENCERRADO COM SUCESSO **************************************************")		
	oProcess:Free()

Return()
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SPCRetornoºAutor  ³Microsiga           º Data ³  07/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz Liberacao Automatica do Pedido                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 															  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SPCRetorno( oProcess )
Local cTipo		:= "PC"
Local cNum		:= oProcess:oHtml:RetByName('pedido')
Local cxFilial	:= oProcess:oHtml:RetByName('FILIAL')
Local cResp		:= oProcess:oHtml:RetByName('RBAPROVA')
Local cJusti	:= oProcess:oHtml:RetByName('lbmotivo')
Local codAprov	:= oProcess:oHtml:RetByName("lb_aprovado")
Local cCopia    := ""
Local cDestino  := ""
Local xLReprova := .F.

Conout("INICIO DE RETORNO WF APROVAÇÃO ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Iniciando 1002 ")
//Conout('Filial'+oProcess:oHtml:RetByName('Filial')+'Pedido No:'+oProcess:oHtml:RetByName('Pedido'))
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
Endif
                                                                                                       
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
	
Else

	ConOut("( WF APROVAÇÃO) Filial: "+ cxFilial+ "Rastreia o Pedido: "+cNum+"Processo: "+oProcess:fProcessID+'.'+oProcess:fTaskID )
	//RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,oProcess:fProcCode,'10005',,"BI")
	oProcess:Finish()	
	
	Dbselectarea("SC7") 
	
	if nOpc=2 //Inicia o processo do proximo nivel
			
		cNivelUser := padl(Val(cNivelApr)+1,2,'0')                                	//Busca Proximo Nivel de Usuario
		ConOut("( WF APROVAÇÃO)  Filial: "+ cxFilial+ " Inicia Chama SPCIniciar" )			
		Conout("SPCIniciar( oProcess,cNivelUser )  ENVIADO "+cxFilial+' '+cNum+' NIVEL '+cNivelUser)
		
		DbSelectArea("SC7")
		SC7->(dbSetOrder(1))
		SC7->(dbgotop())
		if SC7->(dbSeek(cxFilial+cNum))	
    
		Conout("*************Numero do Pedido Variavel     SPCIniciar( oProcess,cNivelUser ) "+cxFilial+' '+cNum)
		Conout("****************************************************Enviando Pedido para o Proximo Nivel****************************************************")
        
		if !Empty(cCodLiber)  //Enviar E-mail para o Proximo nivel somente se um Gestor Tiver Aprovado
			SPCIniciar(oProcess,cNivelUser) //Envia E-mail de Liberação do Proximo Nivel	
		EndIf
			
		Conout("****************************************************Envio de Pedido para o Proximo nivel finalizado com Sucesso****************************************************")
		Conout("SPCIniciar( oProcess,cNivelUser )  ENVIADO "+cxFilial)			
		ConOut("( WF APROVAÇÃO)  Filial: "+ cxFilial+ " Fim Chama SPCIniciar" )			
		
		EndIf  		
	Endif	
EndIf

cTipo  :='PC'
cDocto := cNum+Space(Len(SCR->CR_NUM)-Len(cNum))

DbSelectArea("SCR")
SCR->(DbSetOrder(2))
if !SCR->(dbSeek(cxFilial+cTipo+cDocto) )
	Conout("INICIO DE RETORNO WF APROVAÇÃO (WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Não achou SCR (1): "+ xFilial("SCR")+'PC'+cDocto )
Endif

cMSGAprov := iif(nOpc=2,'APROVADO','REPROVADO')
  
cAviso:="NOTIFICAÇÃO - Pedido de Compra "+cMSGAprov+" - Pedido No "+cNum+" - Empresa "+cNameEmp+" - Filial "+cxFilial
  
Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" INICIANDO HTML ")

 
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
xHTM +='                '+iif(!Empty(cJusti),'Motivo: '+cJusti,'')+' '
xHTM +='                <br/>'
xHTM +='				Data '+DTOC(date())+' Hora:'+time()+' '
xHTM +='                <br/>'
xHTM +='                Responsável '+UsrRetName(cCodLiber)+' '
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

Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" FIM xHTM ")

dbSelectArea("SCR")
SCR->(dbSetOrder(2))
SCR->(dbgotop())
SCR->(dbSeek(cxFilial+cTipo+cNum))
While !SCR->(EOF()) .AND.  cxFilial = SCR->CR_FILIAL .and. SCR->CR_NUM = cNum

	Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" while cxFilial=SCR->CR_FILIAL .and. SCR->CR_NUM = cNum" )
	Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Valores de cCodLiber: "+alltrim(cCodLiber)+" cNivelApr: "+alltrim(cNivelApr))
	Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Preparando para Entrarno Codigo Nivel = o Nivel para enviar todos do mesmo Nivel"+SCR->CR_USER+'<>'+cCodLiber +'.and.'+ cNivelApr +'='+ SCR->CR_NIVEL)
     
 	cDestino := UsrRetMail(SCR->CR_USER)
    cDestino := UsrRetMail(cGerentCom) //Avisa somente o Gerente do Modulo Compras Incluido no Paräemtro
	//cDestino := "adrianogtitec@gmail.com;leonardo@equilibrioti.com.br"			
		    
	if SCR->CR_USER <> cCodLiber .And. cNivelApr = SCR->CR_NIVEL //Avisa o mesmo nível
       
		Conout("Entrou no Envio de E-mail para o Mesmo Nivel 	if SCR->CR_USER<>cCodLiber .and. cNivelApr = SCR->CR_NIVEL //Avisa o mesmo nível")
   
			Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Entrou no if SCR->CR_USER<>cCodLiber .and. cNivelApr=SCR->CR_NIVEL //Avisa o mesmo nível")
			Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Enviando o E-mail sem ser Nivel 01")
			Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Enviando E-MAIL PARA  "+UsrRetMail(SCR->CR_USER))           //Envia E-mail para Comprador.		
		
		u_EnviEmail('','Aviso'+cAviso+'','Aviso : '+cAviso+'',xHTM,.t.,cDestino,cCopia)	//Envia email de Aviso 
					
	EndIf
    
	if SCR->CR_USER = cCodLiber //Avisa o mesmo nível
		
		Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Enviando Email para o Mesmo Usuario que Aprovou o Pedido de Compras")
		Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Entrou no if SCR->CR_USER<>cCodLiber .and. cNivelApr=SCR->CR_NIVEL //Avisa o Mesmo Usuario )")
		Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Enviando E-MAIL PARA  "+Alltrim(cDestino))
				
		u_EnviEmail('','Aviso'+cAviso+'','Aviso : '+cAviso+'',xHTM,.t.,cDestino,cCopia)	//Envia email de Aviso 
	
	EndIf
                                                      	
	//Avisa Todos que Aprovou o Pedido de Compra.
	
	if nOpc = 3 .AND. SCR->CR_USERLIB <> ' '  .AND.  SCR->CR_LIBAPRO <>  ' ' .AND. SCR->CR_APROV = SCR->CR_LIBAPRO //Avisa todos os Aprovadores caso o Pedido seja Bloqueado
		
		Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Enviando Email para todos os Aprovadores Caso o pedido seja Rejeitado")
		                                                                       				
		u_EnviEmail('','Aviso'+cAviso+'','Aviso : '+cAviso+'',xHTM,.t.,cDestino,cCopia)	//Envia email de Aviso
		
		Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Enviando Email para todos os Aprovadores Caso o pedido seja Rejeitado")
	
	EndIf   
	
	if xLReprova
	
		Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Enviando Email para todos os Aprovadores Caso o pedido seja Rejeitado")
		                                                                       				
		u_EnviEmail('','Aviso'+cAviso+'','Aviso : '+cAviso+'',xHTM,.t.,cDestino,cCopia)	//Envia email de Aviso
		
		Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Enviando Email para todos os Aprovadores Caso o pedido seja Rejeitado")
	
	EndIf   

	
	SCR->(dbskip())
Enddo   

//Avisa o comprador

if lLiberou .or. nOpc = 3   

	Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Avisando o Comprador")
	
	cDestino := UsrRetMail(cPCUser)+";"+UsrRetMail(cGerentCom)
		    
	//cDestino := "adrianogtitec@gmail.com;leonardo@equilibrioti.com.br"			
	
	u_EnviEmail('','Aviso'+cAviso+'','Aviso : '+cAviso+'',xHTM,.t.,cDestino,cCopia)	//Envia email de Aviso

EndIf

if xLReprova

	Conout("( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" Avisando o Comprador")
	
	cDestino := UsrRetMail(cPCUser)+";"+UsrRetMail(cGerentCom)
		    
	//cDestino := "adrianogtitec@gmail.com;leonardo@equilibrioti.com.br"			
	
	u_EnviEmail('','Aviso'+cAviso+'','Aviso : '+cAviso+'',xHTM,.t.,cDestino,cCopia)	//Envia email de Aviso

EndIf

Return()       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SPCIniciarºAutor  ³Microsiga           º Data ³  07/03/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao do Workflow de Iniciar.                              º±±
±±º          ³1 - Classe Workflow                                         º±±
±±º          ³2 - Funcao de Usuario                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³		                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SPCIniciar( oProcess ,cNivelUser )
Local aCond:={},nTotal := _nXF := 0
Local cAssunto
Local cHTML 	  	:= AllTrim( "/workflow/")
Local cIMAGE	  	:= AllTrim( WFGetMV("MV_WFIMG","/web/ruasag_teste_wf/images/") )
Local cHttpServer 	:= "http://" + AllTrim("10.106.10.20" ) + "/"
Local cAviso 		:= ""
Local cDestino 		:= ""
Local cLink 		:= ""
Local xHTM 			:= ""
Local cMailID 		:= ""
Local i         	:= 0
Local cTipo			:= "PC"
Local Nz 			:= 0

//Abre o HTML criado. Repare que o mesmo se encontra abaixo do RootPath
cAssunto:= "Solicitação de Aprovacao de Pedido de Compra - Pedido No "+SC7->C7_NUM

oProcess:NewTask( "Solicitação", cHTML+"wfw120pv.htm" )
oProcess:cSubject := cAssunto
oProcess:bReturn  := "U_WFW120P( 1 )"

//  Timeout                                  dia          /        Hora       /  Minuto
//oProcess:bTimeOut := {{"U_WFW120P(2)", SuperGetMv("MV_WFDIAS",.F.,3) , SuperGetMv("MV_WFHORAS",.T.,12)  , 1 }}

oHTML := oProcess:oHTML
	
//	oHtml:ValByName( "wf2p11", "WFHTTPRET.APL")
	
/*** Preenche os dados do cabecalho ***/
oHtml:ValByName( "EMISSAO", SC7->C7_EMISSAO )
oHtml:ValByName( "FORNECEDOR", SC7->C7_FORNECE )    

dbSelectArea('SA2')
SA2->( dbSetOrder(1) )
SA2->( dbSeek(xFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA) )

oHtml:ValByName( "lb_nome", Posicione('SA2',1,xFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA,'A2_NOME') )    
oHtml:ValByName( "lb_cond", Posicione('SE4',1,xFilial('SE4')+SC7->C7_COND,'E4_DESCRI') )    	
oHtml:ValByName( "lb_comprador", UsrRetName(SC7->C7_USER) )    
oHtml:ValByName( "lb_observacao", SC7->C7_XOBS )    

dbSelectArea('SC7')
cxFilial := SC7->C7_FILIAL
cNum 	 := SC7->C7_NUM
                                      
oHtml:ValByName( "EMPRESA_FILIAL", cNameEmp+' - Filial - '+ SM0->M0_CODFIL )
oHtml:ValByName( "NOME_EMPFIL", cNameEmp )
oHtml:ValByName( "FILIAL", SC7->C7_FILIAL )
oHtml:ValByName( "PEDIDO", SC7->C7_NUM )

oProcess:fDesc := "Pedido de Compras No "+ cNum

DbSelectArea('SC7')
SC7->(dbGoTop())
SC7->(dbSetOrder(1))
IF SC7->(dbSeek(cxFilial+cNum))	
Else    
	Alert('Atenção !!! Comprador , Verifique o Centro de Custo do Pedido de Compras !!!')
	Return(.F.)
EndIf

//
// Inicia-se o processo de identificação da cotação
//
//Qry:= "	SELECT  * FROM   "+RetSqlName("SCR")+" SCR "
//Qry+= "	WHERE SCR.D_E_L_E_T_ <> '*' AND SCR.CR_USERLIB <> '  '  AND  SCR.CR_LIBAPRO <>  '  ' AND CR_APROV = CR_LIBAPRO "
//Qry+= "	AND SCR.CR_FILIAL = '"+cxFilial+"' AND SCR.CR_NUM = '"+cNum+"'"
//Qry+= "	ORDER BY CR_NIVEL "
//tcquery Qry new alias "QryScr"                                                      
//		Regra de Controle de Liberação		                                               
//		{ 'CR_STATUS== "01"', 'BR_AZUL' },;   //Bloqueado (aguardando outros niveis)
//		{ 'CR_STATUS== "02"', 'DISABLE' },;   //Aguardando Liberacao do usuario
//   	{ 'CR_STATUS== "03"', 'ENABLE'  },;   //Documento Liberado pelo usuario
//  	{ 'CR_STATUS== "04"', 'BR_PRETO'},;   //Documento Bloqueado pelo usuario
//  	{ 'CR_STATUS== "05"', 'BR_CINZA'} }   //Documento Liberado por outro usuario
     
nHist:= 0
     
Conout(" ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+" WHILE NO HISTORICO")	

//oHtml:ValByName( "nHistorico"," NUMERO DO PEDIDO - "+cNum )  

DbSelectArea("SCR")
SCR->(dbSetOrder(1))
SCR->(dbgotop())
if SCR->(dbSeek(cxFilial+cTipo+cNum))
	While !SCR->(EOF()) .AND. Alltrim(cxFilial) == Alltrim(SCR->CR_FILIAL) .AND. Alltrim(cNum) == Alltrim(SCR->CR_NUM)
		
		IF  ( SCR->CR_USERLIB <> '  '  .and.  SCR->CR_LIBAPRO <>  '  ' .and. SCR->CR_APROV = SCR->CR_LIBAPRO )
			
			cNomeUsu := UsrRetName(SCR->CR_USERLIB)
			
			AAdd( (oHtml:ValByName( "histori.item" ))		, SCR->CR_NIVEL  )
			AAdd( (oHtml:ValByName( "histori.usuario" ))	, SCR->CR_USER  )
			AAdd( (oHtml:ValByName( "histori.nomeuse" ))	, cNomeUsu)
			AAdd( (oHtml:ValByName( "histori.status" ))		, IIF(SCR->CR_STATUS== "03",'APROVADO','REPROVADO')  )
			AAdd( (oHtml:ValByName( "histori.aprov" ))		, SCR->CR_APROV )
			AAdd( (oHtml:ValByName( "histori.datalib" ))	, DTOC(SCR->CR_DATALIB) )
			AAdd( (oHtml:ValByName( "histori.observ" ))		, Alltrim(SCR->CR_OBS) )
			  
			nHist++
		EndIf
		
		SCR->(Dbskip())
	Enddo
EndIf

IF Len(aTempAprov) > 0
	
	For Nz:=1 to Len(aTempAprov)
				
		AAdd( (oHtml:ValByName( "histori.item" )), 		aTempAprov[Nz][1]  )
		AAdd( (oHtml:ValByName( "histori.usuario" )), 	aTempAprov[Nz][2]  )
		AAdd( (oHtml:ValByName( "histori.nomeuse" )),	aTempAprov[Nz][3]  )
		AAdd( (oHtml:ValByName( "histori.status" )),  	aTempAprov[Nz][4]  )
		AAdd( (oHtml:ValByName( "histori.aprov")),		aTempAprov[Nz][5]  )
		AAdd( (oHtml:ValByName( "histori.datalib" )), 	aTempAprov[Nz][6]  )
		AAdd( (oHtml:ValByName( "histori.observ" )), 	aTempAprov[Nz][7]  )
		           
		nHist++
					
	Next Nz
		
EndIf

IF nHist = 0
	
	AAdd( (oHtml:ValByName( "histori.item" )), '   '  )
	AAdd( (oHtml:ValByName( "histori.usuario" )), '	'  )
	AAdd( (oHtml:ValByName( "histori.nomeuse" )),'	' )
	AAdd( (oHtml:ValByName( "histori.status" )),  ' '  )
	AAdd( (oHtml:ValByName( "histori.aprov")),'	' )
	AAdd( (oHtml:ValByName( "histori.datalib" )), '	' )
	AAdd( (oHtml:ValByName( "histori.observ" )), '	' )

EndIf   

/*
IF !Empty(SC7->C7_XOBSREN)//Caso Esteja Diferente de Branco o campo Observação Reenvio
 
		cNomeUsu := UsrRetMail(SC7->C7_USER)
  						
		AAdd( (oHtml:ValByName( "histori.item"  )), ' '  )
		AAdd( (oHtml:ValByName( "histori.usuario" )), ''  )
		AAdd( (oHtml:ValByName( "histori.nomeuse" )),UsrFulname(substr(SC7->C7_XOBSREN,1,6)))
		AAdd( (oHtml:ValByName( "histori.status" )),  'Mensagem Reenvio'  )
		AAdd( (oHtml:ValByName( "histori.aprov" )),'' )//Codigo Aprovador
		AAdd( (oHtml:ValByName( "histori.datalib" )), SUBSTR(SC7->C7_XOBSREN,8,10) )
		AAdd( (oHtml:ValByName( "histori.observ" )), Alltrim(SUBSTR(SC7->C7_XOBSREN,19,200)) )
		
EndIf
*/
/*
DbSelectArea("SC8")
SC8->( DbSetOrder(3) )
if 	SC8->(DbSeek(cxFilial+SC7->C7_NUMCOT))
	oHtml:ValByName( "nCotacao"," - Nr.:"+SC7->C7_NUMCOT+" EM "+dtoc(SC8->C8_EMISSAO) )
Endif
While !SC8->( Eof() ) .And. (SC7->C7_FILIAL+SC7->C7_NUMCOT) = (SC8->C8_FILIAL+SC8->C8_NUM)
	
	if SC8->C8_FORNECE == SC7->C7_FORNECE .and. SC8->C8_LOJA == SC7->C7_LOJA
		
		AAdd( (oHtml:ValByName( "cotacao.item" )),SC8->C8_ITEM )
		AAdd( (oHtml:ValByName( "cotacao.codigo" )),SC8->C8_PRODUTO )
		AAdd( (oHtml:ValByName( "cotacao.descricao" )),Posicione('SB1',1,xFilial('SB1')+SC8->C8_PRODUTO,'B1_DESC') )
		AAdd( (oHtml:ValByName( "cotacao.fornecedor" )),Posicione('SA2',1,xFilial('SA2')+C8_FORNECE,'A2_NREDUZ') )
		AAdd( (oHtml:ValByName( "cotacao.total" )),TRANSFORM( SC8->C8_TOTAL,'@E 99,999.99' ) )
		AAdd( (oHtml:ValByName( "cotacao.entrega" )),dtoc(SC8->C8_DATPRF) )
		AAdd( (oHtml:ValByName( "cotacao.condPag" )),Posicione('SE4',1,xFilial('SE4')+SC8->C8_COND,'E4_DESCRI') )
		++_nXF
		
	Endif
	
	SC8->(DbSkip() )
enddo 
*/
aUltPrc	:= {0,0,0}
     
If Select("QryScr") > 0
	QryScr->(dbCloseArea())
EndIf

dbSelectArea('SC7')
SC7->( dbSetOrder(1) )
SC7->( dbSeek(cxFilial+cNum) )
    While !SC7->( Eof() ) .and. SC7->C7_FILIAL+SC7->C7_NUM = cxFilial+cNum
       
	   //aUltPrc	  := U_UltPrc(SC7->C7_PRODUTO)
 	   nTotal 	  := nTotal + C7_TOTAL
 	   	
 	   cGrpAprova := SC7->C7_APROV 
       cAnexoWF   := Alltrim(SC7->C7_XOBSFLU)  //Anexo Manual do Pedido de Compra
                                                                     
       dbSelectArea('SB1')
       SB1->( dbSetOrder(1) )
       SB1->( dbSeek(xFilial('SB1')+SC7->C7_PRODUTO) )    
       
       AAdd( (oHtml:ValByName( "produto.item" )),SC7->C7_ITEM )
       AAdd( (oHtml:ValByName( "produto.codigo" )),SC7->C7_PRODUTO )
       AAdd( (oHtml:ValByName( "produto.ccusto" )),SC7->C7_CC )
       AAdd( (oHtml:ValByName( "produto.itemcta" )),SC7->C7_ITEMCTA )    
       AAdd( (oHtml:ValByName( "produto.descricao" )),Posicione('SB1',1,xFilial('SB1')+SC7->C7_PRODUTO,'B1_DESC') )
       AAdd( (oHtml:ValByName( "produto.quant" )),TRANSFORM( SC7->C7_QUANT,'@E 99,999,999.99' ) )		              
       AAdd( (oHtml:ValByName( "produto.preco" )),TRANSFORM( SC7->C7_PRECO,'@E 99,999,999.99' ) )		                     
       AAdd( (oHtml:ValByName( "produto.total" )),TRANSFORM( SC7->C7_TOTAL,'@E 99,999,999.99' ) )		                     
       AAdd( (oHtml:ValByName( "produto.unid" )) ,SB1->B1_UM )		              
       //AAdd( (oHtml:ValByName( "produto.entrega" )),dtoc(SC7->C7_DATPRF) )	
       //AAdd( (oHtml:ValByName( "produto.entrega2" )), "")     	                       
       //AAdd( (oHtml:ValByName( "produto.condPag" )),Posicione('SE4',1,xFilial('SE4')+SC7->C7_COND,'E4_DESCRI') )		                    
	   //AAdd( (oHtml:ValByName( "produto.ultimo" )), aUltPrc[1] )    
	   //AAdd( (oHtml:ValByName( "produto.penult" )), aUltPrc[2] )    
	   //AAdd( (oHtml:ValByName( "produto.antepe" )), aUltPrc[3] )
       //WFSalvaID('SC7','C7_WFID',oProcess:fProcessID) 
      
       SC7->(dbSkip())
    Enddo

    oHtml:ValByName( "lbValor" ,TRANSFORM( nTotal,'@E 99,999,999.99' ) )		              	
    //oHtml:ValByName( "lbFrete" ,TRANSFORM( 0,'@E 99,999.99' ) )		              	    
    oHtml:ValByName( "lbTotal" ,TRANSFORM( nTotal,'@E 99,999,999.99' ) )		              	    

//	oProcess:ClientName( UsrRetName(WFCodUser("BI")) )
//	oProcess:UserSiga := WFCodUser("BI")         
        
if !lEnvAnexo
	cAnexoWF := " "
Else
EndIf

aMail:={}
	
dbSelectArea("SCR")
SCR->(dbgotop())
SCR->(dbSetOrder(2))
if SCR->(dbSeek(xFilial("SCR")+'PC'+ALLTRIM(cNum)))
	While !SCR->(EOF()) .AND. Alltrim(cxFilial) == Alltrim(SCR->CR_FILIAL) .AND. Alltrim(cNum) == Alltrim(SCR->CR_NUM)
		
		if Empty(SCR->CR_DATALIB) .OR. ( !Empty(SCR->CR_DATALIB) .AND. SCR->CR_STATUS = '04'  )				  					//Correção Reenvio para o aprovador mesmo que ele já tenha aprovado em um dia anterior.
			
			Conout("Compara"+ SUBSTR(alltrim(cxFilial),1,2)+" com "+SUBSTR(alltrim(SCR->CR_FILIAL),1,2))
			
			If  Alltrim(cxFilial) == Alltrim(SCR->CR_FILIAL) .AND. alltrim(cNum) == Alltrim(SCR->CR_NUM)
				
				if SCR->CR_NIVEL = cNivelUser //Customizado Envio apenas para o Usuario do Nivel 1 Acima do usuario que esta liberando.
					
					if !Empty(UsrRetMail(SCR->CR_USER))
						aadd(aMail,{UsrRetName(SCR->CR_USER),UsrRetMail(SCR->CR_USER),SCR->CR_USER})
						oHtml:ValByName("lb_aprovado",SCR->CR_USER )
						oHtml:ValByName("usr",SCR->CR_USER )
					Else
						Aviso("Aviso","Email não cadastrado para o usuário >> "+UsrRetName(SCR->CR_USER),{"Ok"},1)
					Endif
					
				Endif
			EndIf
		EndIf
		SCR->(dbskip())
	Enddo
Else
	Conout(" ( WF APROVAÇÃO) Data: "+dtoc(ddatabase)+ "Hora: "+time()+"Este pedido não existe SCR (Aprovadores)")
Endif


oProcess:cTo :=  "pedcom"

if len(aMail)>0
	
	cMailID := oProcess:Start()
  	//RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,oProcess:fProcCode,'10001','Processo do Pedido '+cNum+' iniciado!' )
	
	for i:=1 to len(aMail)
		
		cAviso	  := "Solicitação de Aprovacao de Pedido de Compra - Pedido No "+oProcess:oHtml:RetByName('Pedido')+' - Empresa '+cNameEmp+' - Filial '+cxFilial
		cDestino  := aMail[i,2]
		cLink	  := 'http://10.106.10.20:9090' + "/messenger/"+"emp" + SM0->M0_CODIGO + "/pedcom/" + cMailID + ".htm"
		
		//Envia email de Aviso
	
		texto1    := 'Você está recebendo um Link de aprovacao de Pedido de Compra - Pedido No '+oProcess:oHtml:RetByName('Pedido')+' - Empresa '+cNameEmp+' - Filial '+cxFilial+' em '+dtoc(date())+'&nbsp;&nbsp;&nbsp;'+time()+'.'
		
		If !Empty(_cAltera)
			texto2    := 'Motivo Alteração : '+_cAltera+'.'
		EndIf
		
		if !Empty(cObse)
			texto3    := ''+cObse+''
		EndIf
		
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
		xHTM +='		</TR>'
		xHTM +='		<TR>'
		xHTM +='        	<TD align="left" BGCOLOR="#FFFFFF"> '
		xHTM +='            	<FONT  SIZE="3" COLOR="#005151" FACE="verdana, arial, helvetica, times" > '
		xHTM +='                <br/> '
		xHTM +='                Prezado(a):'+capital(aMail[i,1])+' '
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
		xHTM +='			  <p><font color="#005151" size="-1" face="verdana, arial, helvetica, times">Clique <a href="'+cLink+"?user="+aMail[i,3]+'">aqui</a> para aprovar o pedido de compra. </font></p>'
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
				
		//cDestino := "adrianogtitec@gmail.com;leonardo@equilibrioti.com.br"			
		
		cOkWF := u_EnviEmail(cAnexoWF,'Aviso'+cAviso+'','Aviso : '+cAviso+'',xHTM,.t.,cDestino,cCopia) 		//Envia email de Aviso
		
		cCdUserMail+= aMail[i,3]+';'		//Grava Codigos dos Usuarios
		
	Next i
Endif

if len(aMail)>0 

	//Atenção !!! Processo Criado para Gravar Apenas Ultimo Processo e Usuario de E-mail Enviado por Pedido.

	cQuery := "  UPDATE  "+RetSqlName("SC7")+" "
	cQuery += "  SET  C7_XWFID  = '" +cMailID+ "' , C7_XWFMAIL  = '" +cCdUserMail+ "'  "
	cQuery += "  WHERE D_E_L_E_T_ = ' ' "
	cQuery += "  AND C7_FILIAL  =  '" +cxFilial+ "' "
	cQuery += "  AND C7_NUM  =  '" +cNum+ "' "
	
	Begin Transaction
	TcSqlExec(cQuery)
	End Transaction		
	
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SPCTimeOu ºAutor  ³Microsiga           º Data ³  06/05/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envia E-mail se Exceder o Tempo Limite Contido nos	      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SPCTimeOut( oProcess )
//Conout("Funcao de TIMEOUT executada Pedido "+oProcess:oHtml:RetByName('Pedido') )
cAviso:="NOTIFICAÇÃO - Aprovação de Pedido de Compra PENDENTE - Pedido No "+oProcess:oHtml:RetByName('Pedido')
cDestino:=UsrRetMail(WFCodUser("BI"))
//Envia email de Aviso
xHTM := '<HTML><BODY>'
xHTM += '<hr>'
xHTM += '<p  style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
xHTM += '<b><font face="Verdana" SIZE=3>'+cAviso+' &nbsp; '+dtoc(date())+'&nbsp;&nbsp;&nbsp;'+time()+'</b></p>'
xHTM += '<hr>'
xHTM += '<br>'
xHTM += '<br>'
xHTM += 'O pedido em referencia ainda não foi respondido <BR> <br>'
xHTM += '</BODY></HTML>'
ExxNVIAREMAIL('','Aviso - '+cAviso+'','Aviso - '+cAviso+'',xHTM,.t.,cDestino)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACOMP003  ºAutor  ³Microsiga           º Data ³  06/05/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function UltPrc(cCod)
Local aArea		:= GetArea()
Local aRet		:= {0,0,0}
Local cAlias	:= GetNextAlias()

BeginSql Alias cAlias
	SELECT DISTINCT D1_FILIAL, D1_COD, D1_DOC, D1_SERIE, D1_DTDIGIT, D1_VUNIT, D1_QUANT, D1_UM
	FROM %TABLE:SD1% SD1
	WHERE  SD1.D_E_L_E_T_ = ' '
	AND SD1.D1_COD = %Exp:cCod%
	AND SD1.D1_TIPO = 'N'
	ORDER BY D1_DTDIGIT DESC
EndSql

_aQuery := GetLastQuery()
MemoWrite("C:\temp\wfw120p_ult_prc.txt",_aQuery[2])
If (cAlias)->(!EOF())
	_N := 1
	While (cAlias)->(!EOF()) .AND. _N < 4
		aRet[_N] := "R$ "+alltrim(str((cAlias)->D1_VUNIT))+" - "+alltrim(str((cAlias)->D1_QUANT))+alltrim((cAlias)->D1_UM)
		_N++
		(cAlias)->(dbSkip())
	EndDo
EndIf

RestArea(aArea)
Return aRet


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
/*
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
Local lDeletou := .F.
Local dDataLib := IIF(dDataRef==Nil,dDataBase,dDataRef)
DEFAULT dDataRef := dDataBase
DEFAULT cDocSF1 := cDocto
DEFAULT lResiduo := .F.
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
		dbSelectArea("SAL")
		dbSetOrder(2)
		If !Empty(cGrupo) .And. dbSeek(xFilial("SAL")+cGrupo)
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
				SCR->CR_EMISSAO:= aDocto[10]
				SCR->CR_MOEDA	:=	nMoeDcto
				SCR->CR_TXMOEDA:= nTxMoeda
				MsUnlock()
				dbSelectArea("SAL")
				dbSkip()
			EndDo
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
		dbSetOrder(2)
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
*/
