/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ATUDOLAR     ³ Toni Aguiar - TOTVS STARSOFT em 01/04/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programa  ³ Atualiza a cotação do Dólar no cadastro de moedas         ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include 'rwmake.ch'
#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'tbicode.ch'

User Function AtuDolar()

/* COLOCAR ESTAS LINHAS NO APPSERVER.INI
[ONSTART]
jobs=Dolar
;TEMPO EM SEGUNDOS 86400=24 HORAS
RefreshRate=86400

[Dolar]
main=u_AtuDolar
Environment=Environment
*/

Private	cFile,cTexto,nLinhas,nPass,j,lAuto := .F.,lAtuOk := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Testa se esta sendo rodado do menu³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	Select('SX2') == 0
	RPCSetType( 3 )                                      // Não consome licensa de uso
	//RpcSetEnv(aEmp,,,,"FIN")           // atencao para esta linha.
    //ConOut('Empresa: '+aEmp[01]+'/'+aEmp[02]+' - Ok!')
	//PREPARE ENVIRONMENT EMPRESA aEmp[01] FILIAL aEmp[02] MODULO "FIN"
    
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "FIN"

	sleep( 5000 )	                                     // aguarda 5 segundos para que as jobs IPC subam.
	ConOut('Dollar - Atualizacao de Moedas... '+Dtoc(DATE())+' - '+Time())
	lAuto := .T.
Endif

if	( ! lAuto )
	LjMsgRun(OemToAnsi('Atualizando Moedas on-line pelo Banco Central'),,{|| xExecMoeda()} )
else
	xExecMoeda()
endif

Return

Static Function xExecMoeda()   
Local cData  := ""
Local dDataRef := CTOD("//")
Local cURL   := ""
Local nPass
Local cPath  := "\Data\" //GetSrvProfString("Startpath","")
Local cLinha := ""
Local nDia   := 0
DbSelectArea('CTP')
CTP->(DbSetOrder(1))

DbSelectArea('SM2')
SM2->(DbSetOrder(1))

For nPass := 1 to 1 step -1

    dDataRef:=dDataBase     //-nPass
	If	Dow(dDataRef) == 1
		//Se for domingo
		nDia:=2
	Elseif Dow(dDataRef) == 7
		//Se for sabado
		nDia:=1
	Endif

	cData:=Subs(DTOS(dDataRef-nDia),5,2)+"-"+Right(DTOS(dDataRef-nDia),2)+"-"+Left(DTOS(dDataRef-nDia),4)  // MM-DD-AAAA
	cURL :="https://olinda.bcb.gov.br/olinda/servico/PTAX/versao/v1/odata/CotacaoDolarDia(dataCotacao=@dataCotacao)?@dataCotacao="+;
	       "'"+cData+"'&$format=json"

	cTexto := HTTPGET(cURL)
	
	If !Empty(cTexto)
		cLinha  := Subst(cTexto, AT("[{",cTexto))
		cCompra := Substr(cLinha, AT("CotacaoCompra",cLinha)+15,10)
		cCompra := Substr(cCompra,1, RAT(",",cCompra)-1)
		cVenda  := substr(cLinha, AT("cotacaoVenda",cLinha)+14,10)
		cVenda  := Substr(cVenda,1, RAT(",",cVenda)-1)

		DbSelectArea('SM2')
		If	SM2->(DbSeek(Dtos(dDataBase)))
			Reclock('SM2',.F.)
		Else
			Reclock('SM2',.T.)
			SM2->M2_DATA := dDataBase
		Endif
		SM2->M2_MOEDA2 := ROUND(VAL(cVenda),TAMSX3('M2_MOEDA2')[2])
		SM2->M2_INFORM := 'S'
		SM2->(MsUnlock()) 

		DbSelectArea('CTP')
		If	CTP->(DbSeek(xFilial("CTP")+Dtos(dDataBase)+"01"))
			Reclock('CTP',.F.)
		Else
			Reclock('CTP',.T.)
			CTP->CTP_DATA := dDataBase
		Endif
		CTP->CTP_MOEDA := '01'
		CTP->CTP_TAXA  := 1
		CTP->CTP_BLOQ  := '2'
		CTP->(MsUnlock()) 

		If	CTP->(DbSeek(xFilial("CTP")+Dtos(dDataBase)+"02"))
			Reclock('CTP',.F.)
		Else
			Reclock('CTP',.T.)
			CTP->CTP_DATA := dDataBase
		Endif
		CTP->CTP_MOEDA := '02'
		CTP->CTP_TAXA  := ROUND(VAL(cVenda),TAMSX3('M2_MOEDA2')[2])
		CTP->CTP_BLOQ  := '2'
		CTP->(MsUnlock()) 

		lAtuOk	:= .T.
	Endif
Next

if	( lAuto )
	If lAtuOk
		ConOut('Dollar - Moedas Atualizadas. '+Dtoc(date())+' - '+Time() )
		MemoWrit(cPath+"Dolar"+DTOS(dDatabase)+".txt",cLinha)
	Else
		ConOut('Dollar - Moedas N�o Atualizadas. '+Dtoc(date())+' - '+Time() )	
	EndIf
	//RpcClearEnv() // Libera o Environment
    RESET ENVIRONMENT
Else
	If lAtuOk
		MsgAlert('Dollar - Moedas atualizadas com sucesso. '+Dtoc(dDataBase)+' - '+Time())
		MemoWrit(cPath+"Dolar_MNU"+DTOS(dDatabase)+".txt",cLinha)
	Else
		MsgAlert('Dollar - Moedas n�o foram atualizadas. '+Dtoc(dDataBase)+' - '+Time() )	
	EndIf
Endif
Return
