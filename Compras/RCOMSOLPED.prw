#INCLUDE "rwmake.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TbiCode.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRCOMSOLPED     บAutor  ณAdriano Reis   บ Data ณ  04/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela de Solicitar Libera็ใo do Pedido de Compras.           บฑฑ
ฑฑบ          ณe verificar andamento.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Avanca								                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RCOMSOLPED()
Local oButton1
Local oGroup1
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Private xcNivelwf := ''
Private cEmailWF  := ''
Private cCaminho  := ''
Private cNivelWf   := ''
Private aArrayUsr  := ''
Private cUsrGestor := ''
Private cStatusPed := '' 
Private cGrpAprova    := IIF(EMPTY(SC7->C7_APROV),SY1->Y1_GRAPROV,SC7->C7_APROV)   //SY1->SY1->Y1_GRAPROV  GRUPOS DE APROVACAO PADRรO

Static oDlg                       

DEFINE MSDIALOG oDlg TITLE "Posi็ใo do Pedido de Compras" FROM 000, 000  TO 500,1000 COLORS 0, 16777215 PIXEL

@ 048, 001 GROUP oGroup1 TO 210, 493 PROMPT "Andamento da Aprova็ใo do Pedido de Compras:" OF oDlg COLOR 0, 16777215 PIXEL
@ 007, 220 SAY oSay1 PROMPT "Status do Pedido: "+iif(Alltrim(SC7->C7_CONAPRO) = 'L','LIBERADO','BLOQUEADO') SIZE 099, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 007, 085 SAY oSay2 PROMPT "Num Pedido: "+SC7->C7_NUM SIZE 090, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 008, 005 SAY oSay3 PROMPT "Filial de Origem : "+SC7->C7_FILENT SIZE 090, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 022, 005 SAY oSay4 PROMPT "Grupo de Aprovacao: "+SC7->C7_APROV+'-'+Posicione("SAL",1,xFilial("SAL")+Alltrim(SC7->C7_APROV),"AL_DESC") SIZE 144, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 022, 220 SAY oSay7 PROMPT "Emissor: "+SC7->C7_USER+' - '+ UsrRetName(SC7->C7_USER) SIZE 144, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 035, 005 SAY oSay5 PROMPT "Centro de Custo: "+Alltrim(SC7->C7_CC)+' - '+Posicione("CTT",1,xFilial("CTT")+Alltrim(SC7->C7_CC),"CTT_DESC01")  SIZE 180, 007 OF oDlg COLORS 0, 16777215 PIXEL

fMSNewGe1()

@ 180, 003 SAY oSay6 PROMPT "Posi็ใo Libera็ใo Pedido: "+cStatusPed SIZE 409, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 194, 003 SAY oSay6 PROMPT "Ultimo E-mail Enviado para o Usuario - "+cUsrGestor+" ." SIZE 409, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 212, 187 BUTTON oButton1 PROMPT "Solicitar Nova Aprova็ใo" SIZE 102, 012 OF oDlg PIXEL Action (oTelenvMail(xcNivelwf,cEmailWF))

ACTIVATE MSDIALOG oDlg CENTERED

Return()

//------------------------------------------------
Static Function fMSNewGe1()       //MT121BRW
//------------------------------------------------
Local nX
Local aHeaderEx 	:= {}
Local aColsEx 	    := {}
Local aFieldFill 	:= {}
Local aFields 		:= {"CR_FILIAL","C7_NUM","CR_EMISSAO","CR_TIPO","CR_APROV","CR_USERLIB","AL_NOME","CR_NIVEL","CR_STATUS","CR_DATALIB","CR_OBS"}
Local aAlterFields  := {}
Local cTipo			:= "PC"
Static oMSNewGe1

// Define field properties
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
For nX := 1 to Len(aFields)
	If SX3->(DbSeek(aFields[nX]))
		Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
	Endif
Next nX

// Define field values
For nX := 1 to Len(aFields)
	If DbSeek(aFields[nX])
		Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
	Endif
Next nX

if Select("QRYSC7")>0
	QRYSC7->(dbCloseArea())
EndIf

xcNivelwf   := ' '
_xUsuario   := ' '
cxFilial 	:= SC7->C7_FILIAL
cNum     	:= SC7->C7_NUM

DbSelectArea("SCR")
SCR->(dbSetOrder(2))
SCR->(dbgotop())
if SCR->(dbSeek(cxFilial+cTipo+cNum))
	While !SCR->(EOF()) .AND. alltrim(cxFilial) == alltrim(SCR->CR_FILIAL) .AND. alltrim(cNum) == alltrim(SCR->CR_NUM)
		
		//		{ 'CR_STATUS== "01"', 'BR_AZUL' },;   //Bloqueado (aguardando outros niveis)
		//		{ 'CR_STATUS== "02"', 'DISABLE' },;   //Aguardando Liberacao do usuario
		//   	{ 'CR_STATUS== "03"', 'ENABLE'  },;   //Documento Liberado pelo usuario
		//  	{ 'CR_STATUS== "04"', 'BR_PRETO'},;   //Documento Bloqueado pelo usuario
		//  	{ 'CR_STATUS== "05"', 'BR_CINZA'} }   //Documento Liberado por outro usuario
		
		_CrStatus := ''
		
		
		if SCR->CR_STATUS== "01"
			_CrStatus := 'Bloqueado (aguardando outros niveis)'
		elseif SCR->CR_STATUS== "02"
			_CrStatus := 'Aguardando Liberacao do usuario'
		elseif SCR->CR_STATUS== "03"
			_CrStatus := 'Pedido Liberado pelo usuario'
		elseif SCR->CR_STATUS== "04"
			_CrStatus := 'Pedido Bloqueado pelo usuario'
		elseif SCR->CR_STATUS== "05"
			_CrStatus := 'Pedido Liberado por outro usuario'
		EndIf
		
		cUsrGestor := ' '
				
		if SCR->CR_STATUS = '02'
			cStatusPed  := 'Aguardando Liberacao do usuario '+SCR->CR_USER+' - '+ UsrRetName(SCR->CR_USER)+' - '+UsrRetMail(SCR->CR_USER)
			xcNivelwf   := SCR->CR_NIVEL
			cEmailWF    := UsrRetMail(SCR->CR_USER)
		Elseif SCR->CR_STATUS = "04"
			cStatusPed  := 'Pedido Bloqueado pelo usuario '+SCR->CR_USER+'- '+ UsrRetName(SCR->CR_USER)+' - '+UsrRetMail(SCR->CR_USER)
			xcNivelwf 	:= SCR->CR_NIVEL
			cEmailWF 	:= UsrRetMail(SCR->CR_USER)
		EndIf
		
		aFieldFill := {}
		Aadd(aFieldFill,SCR->CR_FILIAL)
		Aadd(aFieldFill,Alltrim(SCR->CR_NUM))
		Aadd(aFieldFill,DTOC(SCR->CR_EMISSAO))
		Aadd(aFieldFill,SCR->CR_TIPO)
		Aadd(aFieldFill,SCR->CR_APROV)
		Aadd(aFieldFill,SCR->CR_USERLIB)
		Aadd(aFieldFill,UsrRetName(SCR->CR_USER))
		Aadd(aFieldFill,SCR->CR_NIVEL)
		Aadd(aFieldFill,SCR->CR_STATUS+' - '+_CrStatus)
		Aadd(aFieldFill,DTOC(SCR->CR_DATALIB))
		Aadd(aFieldFill,SCR->CR_OBS)
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx,aFieldFill)
		
		SCR->(dbskip())
	Enddo
Else
Endif


If Empty(aColsEx)
	Aadd(aFieldFill,.F.)
	Aadd(aColsEx,aFieldFill)
Endif

aArrayUsr  := STRTOKARR(SC7->C7_XWFMAIL,";")
cUsrGestor := ' '

For nX:=1 to Len(aArrayUsr)
	If !Empty(aArrayUsr[nX])
		DbSelectArea("SAK")
		SAK->(DbgoTop())
		SAK->(DbSetOrder(2))
		if SAK->(dbSeek(xFilial("SAK")+Alltrim(aArrayUsr[nX])))          //CASO O USUARIO AINDA SEJA O APROVADOR.
			IF !Empty(cUsrGestor)
				cUsrGestor += ' / '
			EndIf
			cUsrGestor += UsrFullName(Alltrim(aArrayUsr[nX]))
		EndIf
	EndIf
Next Nx

if Empty(cUsrGestor)
	cUsrGestor := "E-MAIL NรO ENVIADO "
EndIf

if Empty(cStatusPed) .AND.SC7->C7_CONAPRO = 'L'
	cStatusPed := 'PEDIDO LIBERADO'
EndIf

cNivelWf := U_UltiAprov(SC7->C7_FILIAL,SC7->C7_NUM,'PC')     //ERRO

if select("XQRYSCR") > 0
	XQRYSCR->(DbCloseArea())
Endif

oMSNewGe1 := MsNewGetDados():New( 060, 004, 167, 490, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRCOMSOLPEDบAutor  ณMicrosiga           บ Data ณ  05/11/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function oTelenvMail(cNivel,cEmailWF)
Local oButton1
Local oButton2
Local oButton3
Local oGet1
Local cGet1 := cNivel+' - '+cEmailWF
Local oGet2
Local cGet2 := Space(200)
Local oGet3
Local cGet3 := Space(200)
Local oGet4
Local cGet4 := Space(200)
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Static oDlgTela                                                                

Private cCaminho := ''

if SC7->C7_CONAPRO = 'L'
	MsgAlert("Pedido Liberado, Nใo e possivel realizar nova Solicita็ใo de Aprova็ใo.")	
	Return()
EndIf

DEFINE MSDIALOG oDlgTela TITLE "Reenvio de E-Mail :" FROM 000, 000  TO 400, 700 COLORS 0, 16777215 PIXEL

@ 011, 022 MSGET oGet1 VAR cGet1 SIZE 303, 010 OF oDlgTela WHEN .F. COLORS 0, 16777215 PIXEL
@ 034, 003 GET oGet2 VAR cGet2 MEMO SIZE 342, 083 OF oDlgTela COLORS 0, 16777215 PIXEL
@ 143, 032 MSGET oGet3 VAR cGet3 := cCaminho SIZE 293, 010 OF oDlgTela COLORS 0, 16777215 PIXEL
@ 143, 002 SAY oSay1 PROMPT "Anexo:" SIZE 025, 007 OF oDlgTela COLORS 0, 16777215 PIXEL
@ 142, 329 BUTTON oButton1 PROMPT "..." SIZE 017, 010 OF oDlgTela PIXEL Action(cCaminho := A750DlgArq(cCaminho))
@ 131, 002 SAY oSay2 PROMPT "Copia Para:" SIZE 028, 007 OF oDlgTela COLORS 0, 16777215 PIXEL 
@ 130, 032 MSGET oGet4 VAR cGet4 SIZE 293, 010 OF oDlgTela COLORS 0, 16777215 PIXEL WHEN .F.
@ 160, 105 BUTTON oButton2 PROMPT "Reenviar" SIZE 037, 012 OF oDlgTela PIXEL Action(Reenviar(cNivel,cGet2,cGet4))
@ 160, 165 BUTTON oButton3 PROMPT "Cancelar" SIZE 037, 012 OF oDlgTela PIXEL Action(oDlgTela:End())
@ 025, 003 SAY oSay3 PROMPT "Observacao de Reenvio:" SIZE 067, 007 OF oDlgTela COLORS 0, 16777215 PIXEL
@ 012, 002 SAY oSay4 PROMPT "Para:" SIZE 016, 007 OF oDlgTela COLORS 0, 16777215 PIXEL

ACTIVATE MSDIALOG oDlgTela CENTERED

Return()

Static Function Reenviar(cNivel,cObs,cCopia)

if !Empty(cCaminho) 
	cCaminho	:= U_cCopyServer(cCaminho)
Else
	cCaminho    := Alltrim(SC7->C7_XOBSFLU)
EndIf	
	
	cQuery:= "   UPDATE  "+RetSqlName("SC7")+" SET C7_XOBSFLU = '"+cCaminho+' '+"' , C7_XOBSREN = '"+iif(!Empty(Alltrim(cObs)),__CUSERID+'-'+DTOC(DDATABASE)+'-'+Alltrim(cObs),' ')+"' "   //C7_XOBSREN = '"+Alltrim(cGet2)+"'
	cQuery += "  WHERE D_E_L_E_T_ = ' ' "
	cQuery += "  AND C7_FILIAL  =  '" +SC7->C7_FILIAL+ "' "
	cQuery += "  AND C7_NUM  =  '" +SC7->C7_NUM+ "' "	 
	
	Begin Transaction
	TcSqlExec(cQuery)
	End Transaction	

cCopia += " "        

U_ACOMP003(,,cNivel,Alltrim(cObs),Alltrim(cCopia),,cCaminho)

MSGINFO( 'Pedido Enviado com Sucesso', 'WF Compras' )

oDlgTela:End()

Return()


Static Function A750DlgArq(cArquivo)
cType 	 := "Extensใo do arquivo" +" (*.*) |*.csv|"
cArquivo := cGetFile('*.*',"Selecione arquivo",0,'C:\Dir\',.T.,,.F.)//cGetFile(cType, "Ok")
//If !Empty(NewcArquivo)
//	if !Empty(cArquivo)
//		cArquivo +=';'
//	EndIf
//	cArquivo += NewcArquivo
//EndIf
Return cArquivo                 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNCOES   บAutor  ณMicrosiga           บ Data ณ  09/30/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para Copiar Arquivo local para o Servidor.       	 บฑฑ
ฑฑบ          ณEnviar em Anexo.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Tecnomont                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function cCopyServer(cCaminho)
Local aToSend   := {}  
Local cReturn   := ""
Local cArqEmail := ""    
Local _CENVIA 	:= ""
Local _CCAMINHO := ""            
Local _n  := 1
Local _n1 := 1

If File(cCaminho)
	
	aAdd(aToSend,{Directory(cCaminho)})
	
	For _n1 := 1 to len(aToSend)
		For _n := 1 to len(aToSend[_n1,1])     
		
			_CENVIA   := cCaminho
			_CCAMINHO := MsDocPath()+"\"+aToSend[_n1,1,_n,1]
			
			__CopyFile(_CENVIA,_CCAMINHO)					 //Copia para o Servidor
			
			cArqEmail += MsDocPath()+"\"+aToSend[_n1,1,_n,1]//+","
			
		Next _n
	Next _n1
	
	if !Empty(cArqEmail)
		cReturn := cArqEmail
	EndIf
	
Else        

	Alert('Caminho Nใo Encontrado')
	
EndIf

Return(cReturn)