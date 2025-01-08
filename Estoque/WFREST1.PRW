#include "totvs.ch"
#include "protheus.ch"
#include 'parmtype.ch'
#include "TbiConn.ch"
#Include "TopConn.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WFREST1   ºAutor  ³ Ismael Junior - STARSOFT em 25/11/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para consumo de webservice rest UNIDATA             º±±
±±º          ³ Objetivo buscar os lançamentos do combustível e inserir na º±±
±±º          ³ movimento interna do protheus e retornar ao Unidata os re- º±±
±±º          ³ gistros já inseridos                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAEST>SCHEDULLE                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß    
*/
User function WFREST1()
Local cPerg:= PadR("WFREST2", Len(SX1->X1_GRUPO))
If !Pergunte(cPerg, .T.)
 Return()
Endif
	Processa({|| u_WFREST2()}, "Executando...")
Return
User function WFREST2()
Local cURL := ""
Local aHeadOut := {}
Local cHeadRet := ""
Local cGetRet := ""
Local oJsontotal
Local ret
Local nT := 0
Local nAtual := 0
Local nTotal := 0

Private cURLget := "https://rest.scaplus.com.br/scaplus/rest/movimentacao/abastecimentos/get" //Alltrim(GetMv("MV_URLGET")) // "https://ws.unidatanet.com.br/scaplus-qas/rest/movimentacao/abastecimentos/get"
Private cURLput := "https://rest.scaplus.com.br" // Alltrim(GetMv("MV_URLPUT")) // "https://ws.unidatanet.com.br"
Private cURLrec := "/scaplus/rest/movimentacao/abastecimentos/setEnviados" //Alltrim(GetMv("MV_URLREC")) // "/scaplus-qas/rest/movimentacao/abastecimentos/setEnviados"
Private cToken := "8ae312b6-3056-11eb-adc1-0242ac120002" //Alltrim(GetMv("MV_TOKEN"))   // 6d7042a4-3055-11eb-adc1-0242ac120002

aadd(aHeadOut,"Content-Type: application/json")
AAdd(aHeadOut, 'token:' + cToken)

cURL := cURLget
cGetRet := HTTPSGET(cUrl,"","","","search=AD%3D"+DtoS(dDataBase-1)+"%20OR%20ZD%3D"+DtoS(dDataBase-1)+"&size=250",120,aHeadOut,@cHeadRet)
oJsontotal := JsonObject():new()
ret := oJsontotal:fromJson(cGetRet)
nTotal := len(oJsontotal)
If nTotal > 0
ProcRegua(nTotal)
	for nT := 1 TO nTotal
		nAtual++
		IncProc("Carregando " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
		WFREST3()
	next nT
Else
	MsgInfo("Não existem lançamentos a processar!","Informativo")
Endif
//Inclusão da movimentação interna		
u_WFMMT02()
Return

Static Function WFREST3()
Local cURL := ""
Local aHeadOut := {}
Local cHeadRet := ""
Local cGetRet := ""
Local oJson
Local ret
Local nL := 0
Private nCodMv := 0
Private nQuant := 0  
Private cItemC := ""
Private cCentC := "" 
Private cEmpatu := ""
Private cFilatu := ""
aadd(aHeadOut,"Content-Type: application/json")
AAdd(aHeadOut, 'token:' + cToken)

cURL := cURLget
cGetRet := HTTPSGET(cUrl,"","","","search=AD%3D"+DtoS(dDataBase-1)+"%20OR%20ZD%3D"+DtoS(dDataBase-1)+"&size=250",120,aHeadOut,@cHeadRet)
cGetRet := STRTRAN(cGetRet, '[', '')
cGetRet := STRTRAN(cGetRet, ']', '')
oJson := JsonObject():new()
  ret := oJson:fromJson(cGetRet)
  array:= oJson:GetNames()
  //Varinfo("Conteudo oJsonA:GetNames", array)
  For nL := 1 to len( array )
  	//Conout ( array[nL] )
  	//Conout ( cvaltochar( oJson[ array[ nL] ] ) )
  	If array[nL] == 'movi_codigo' 
  		nCodMv := Val(cvaltochar( oJson[array[ nL]] ) )
  	ElseIf array[nL] == 'movi_volume' 
  		nQuant := Val(cvaltochar( oJson[ array[ nL] ] ))
	ElseIf array[nL] == 'cecu_codigo' 
		cItemC := cvaltochar( oJson[ array[ nL] ] )  
	ElseIf array[nL] == 'cecu_descricao' 
		cCentC := cvaltochar( oJson[ array[ nL] ] ) 
	ElseIf array[nL] == 'empr_codigo' 
		cFilatu := cvaltochar( oJson[ array[ nL] ] )  		   				
	ElseIf array[nL] == 'movi_datahora_inicio' 
		cDtHora := cvaltochar( oJson[ array[ nL] ] ) 
  	Endif	
  Next nL  
  if ValType(ret) == "U"
    Conout("JsonObject populado com sucesso")
  else
    Conout("Falha ao popular JsonObject. Erro: " + ret)
    return
  endif
  If Empty(cFilatu) .OR. Empty(cItemC) .OR. Empty(cCentC)
  	u_WFRET1(nCodMv)
  	Conout ( "mov_codigo " + str(nCodMv) )
  	Conout ( "Centro de custo, item de conta ou filial em branco!" )  
  ElseIf nCodMv > 0 .AND. nQuant > 0
  	Conout ( "mov_codigo " + str(nCodMv) )
  	WFMMT01()
  ElseIf nQuant <= 0	
  	u_WFRET1(nCodMv)
  	Conout ( "mov_codigo " + str(nCodMv) )
  	Conout ( "Movimento quantidade zerada!" )
  EndIf	
return

Static Function WFMMT01()
  DbSelectArea("ZWA")
  DbSetOrder(1)
   	RecLock("ZWA",.T.)
	ZWA->ZWA_COD    := Alltrim(Str(nCodMv))
	ZWA->ZWA_VOLUME := nQuant
	ZWA->ZWA_ITEMC  := cItemC
	ZWA->ZWA_CCUSTO := cCentC
	ZWA->ZWA_CODEMP := cFilatu
	ZWA->ZWA_DTHORA := cDtHora
	ZWA->(MsUnLock()) 
	u_WFRET1(nCodMv) 
Return()

User Function WFMMT02()
Local ExpA1 := {}
Local ExpN2 := 3
Local cTPMovimento := "502"
Local nQtd 	   := 0
Local cProd	   := "000458"
Local cUnidade     := "L"
Local cArmazem     := "01"
Local dEmissao     := DDATABASE
Local nDtHora := 0
Local nDtPar1 := 0
Local nDtPar2 := 0
PRIVATE lMsErroAuto := .F.          

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+cProd)
cProd := B1_COD
cUnidade := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_UM")
cArmazem := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_LOCPAD")
dEmissao := dDataBase
ConOut(Repl("-",80))
ConOut(PadC("Auto Movimentacoes Internas",80))
ConOut("Inicio: "+Time())
	dbSelectArea("SM0")
	_aAreaSM0 := SM0->(GetArea())
	_cEmpBkp := SM0->M0_CODIGO //Guardo a empresa atual
	_cFilBkp := SM0->M0_CODFIL //Guardo a filial atual
	
	  nDtPar1 := Int(Val(FWTimeStamp(4,MV_PAR01,"10:00:00")) /86400+25569+(-3/24) )
	  nDtPar2 := Int(Val(FWTimeStamp(4,MV_PAR02,"10:00:00")) /86400+25569+(-3/24) )
	  
cQuery := "SELECT ZWA_COD,ZWA_VOLUME,ZWA_ITEMC,ZWA_CCUSTO,ZWA_CODEMP,ZWA_DTHORA FROM ZWA010 WHERE D_E_L_E_T_ != '*' "

//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
IF Select("TBZWA") <> 0
	TBZWA->(DbCloseArea())
ENDIF
//crio o novo alias
TCQUERY cQuery NEW ALIAS "TBZWA"

dbSelectArea("TBZWA")
TBZWA->(dbGoTop())
While TBZWA->(!Eof())
  nDtHora := Int(Val(SubStr(Alltrim(TBZWA->ZWA_DTHORA),1,10))/86400+25569+(-3/24)) 

  	If nDtHora >= nDtPar1 .AND. nDtHora <= nDtPar2	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Inclusao do Movimento                                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		If !Empty(TBZWA->ZWA_CCUSTO)
			cCentC := Alltrim(TBZWA->ZWA_CCUSTO)
		Endif  
		If !Empty(TBZWA->ZWA_ITEMC)
			cItemC := Alltrim(TBZWA->ZWA_ITEMC)
		Endif
		If !empty(TBZWA->ZWA_CODEMP)
		cEmpatu := substr(Alltrim(TBZWA->ZWA_CODEMP),1,2)
		cFilatu := substr(Alltrim(TBZWA->ZWA_CODEMP),4,2)
		Endif 
		nQtd := TBZWA->ZWA_VOLUME
			dbSelectArea("SM0") //Abro a SM0
				SM0->(dbSetOrder(1))
				SM0->(dbSeek(cEmpatu + cFilatu,.T.)) //Posiciona Empresa
				cEmpAnt := SM0->M0_CODIGO //Seto as variaveis de ambiente
				cFilAnt := SM0->M0_CODFIL
				OpenFile(cEmpAnt + cFilAnt) //Abro a empresa que eu desejo trabalhar
		Begin Transaction   	
		ExpA1 := {} 		
		aadd(ExpA1,{"D3_TM",cTPMovimento,})		
		aadd(ExpA1,{"D3_COD",cProd,})	
		aadd(ExpA1,{"D3_UM",cUnidade,})			
		aadd(ExpA1,{"D3_LOCAL",cArmazem,})	
		aadd(ExpA1,{"D3_QUANT",nQtd,})	
		aadd(ExpA1,{"D3_EMISSAO",dEmissao,})  
		aadd(ExpA1,{"D3_CONTA","110401012",})       
		aadd(ExpA1,{"D3_GRUPO","0024",})   
		aadd(ExpA1,{"D3_CC",cCentC,}) 
		aadd(ExpA1,{"D3_ITEMCTA",cItemC,}) 
		aadd(ExpA1,{"D3_CLVL","OPX",}) 
		aadd(ExpA1,{"D3_DTLANC",dEmissao,})	
		aadd(ExpA1,{"D3_OBSERVA","movi_codigo " + Alltrim(TBZWA->ZWA_COD),})	        
		MSExecAuto({|x,y| mata240(x,y)},ExpA1,ExpN2)		
		If !lMsErroAuto		
			ConOut("Incluido com sucesso! "+cTPMovimento)
			//u_WFRET1(nCodMv)	
			cUpdate:= " UPDATE " + RetSqlName("ZWA") + " SET D_E_L_E_T_ = '*' WHERE ZWA_COD = '" + Alltrim(TBZWA->ZWA_COD) + "' "
			nFlag := TcSqlExec(cUpdate)	
		Else		
			ConOut("Erro na inclusao!")	
			MostraErro()
		EndIf	
			ConOut("Fim  : "+Time())	         
		End Transaction
	Endif
	TBZWA->(dbSkip())	
Enddo
TBZWA->(DbCloseArea())
	
	dbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	SM0->(RestArea(_aAreaSM0)) //Restaura Tabela
	cFilAnt := SM0->M0_CODFIL //Restaura variaveis de ambiente
	cEmpAnt := SM0->M0_CODIGO
	OpenFile(cEmpAnt + cFilAnt) //Abertura das tabelas
Return Nil

User Function WFRET1(nCodret)                                       
    Local cURI      := cURLput //"https://ws.unidatanet.com.br" 								//SERVIDOR
    Local cResource := cURLrec //"/scaplus-qas/rest/movimentacao/abastecimentos/setEnviados"  //PATCH / RECURSO
    Local oRest     := FwRest():New(cURI)                            				// CLIENTE PARA CONSUMO REST
    Local aHeader   := {}                                            				// CABEÇALHO DA REQUISIÇÃO

    // PREENCHE CABEÇALHO DA REQUISIÇÃO
    aadd(aHeader,"Content-Type: application/json")
    AAdd(aHeader, 'token:'+ cToken)
    // INFORMA O RECURSO
    oRest:SetPath(cResource)
    // REALIZA O MÉTODO PUT, ENVIA O JSON NO CORPO (BODY) E VALIDA O RETORNO
    If (oRest:Put(aHeader, GetJson(nCodret)))
        ConOut("PUT: " + oRest:GetResult())
    Else
        ConOut("PUT: " + oRest:GetLastError())
    EndIf
Return (NIL)

// CRIA O JSON QUE SERÁ ENVIADO NO CORPO (BODY) DA REQUISIÇÃO
Static Function GetJson(nCodret)
    Local bObject := {|| JsonObject():New()}
    Local oJson   := Eval(bObject)
    ret := oJson:fromJson("[" + Str(nCodret) + "]") 
Return (oJson:ToJson())