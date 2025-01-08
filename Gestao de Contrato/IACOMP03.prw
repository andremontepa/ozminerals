#include 'protheus.ch'
#include 'parmtype.ch'

user function IACOMP03(cOldEmp, cNewEmp, cChvSc7)
	Local aCabExe := {}
	Local aLinExe := {}
	Local aIteExe := {}
	Local nOpcExe := 4
	
	Private lMsErroAuto := .F.
	
	conout("Antes RPCSETENV")
	RpcSetType(3)
	RpcSetEnv(cNewEmp,Left(cChvSc7,02),,,"COM")
	conout("Empresa " + cEmpAnt)
	conout("Chave " + cChvSc7)
			
	dbSelectArea("SC7")
	SC7->(dbSetOrder(01))
	If SC7->(dbSeek(cChvSc7))
		conout("Achou Pedido")

		aadd(aCabExe,{"C7_NUM"    ,SC7->C7_NUM,Nil})
		aadd(aCabExe,{"C7_EMISSAO",SC7->C7_EMISSAO,Nil})
		aadd(aCabExe,{"C7_FORNECE",SC7->C7_FORNECE,Nil})
		aadd(aCabExe,{"C7_LOJA"   ,SC7->C7_LOJA,Nil})
		aadd(aCabExe,{"C7_CONTATO",SC7->C7_CONTATO,Nil})
		aadd(aCabExe,{"C7_COND"   ,SC7->C7_COND,Nil})
		aadd(aCabExe,{"C7_FILENT" ,SC7->C7_FILENT,Nil})
		aadd(aCabExe,{"C7_MOEDA"  ,SC7->C7_MOEDA,Nil})
		aadd(aCabExe,{"C7_TXMOEDA",SC7->C7_TXMOEDA,Nil})
		aadd(aCabExe,{"C7_FRETE"  ,SC7->C7_FRETE,Nil})
		aadd(aCabExe,{"C7_DESPESA",SC7->C7_DESPESA,Nil})
		aadd(aCabExe,{"C7_SEGURO" ,SC7->C7_SEGURO,Nil})
		aadd(aCabExe,{"C7_DESC1"  ,SC7->C7_DESC1,Nil})
		aadd(aCabExe,{"C7_DESC2"  ,SC7->C7_DESC2,Nil})
		aadd(aCabExe,{"C7_DESC3"  ,SC7->C7_DESC3,Nil})
		aadd(aCabExe,{"C7_MSG"    ,SC7->C7_MSG,Nil})
		aadd(aCabExe,{"C7_REAJUST",SC7->C7_REAJUST,Nil})
		

		Do While !SC7->(Eof()) .And. SC7->C7_FILIAL + SC7->C7_NUM == cChvSc7
			aLinExe := {}
			
			aadd(aLinExe,{"C7_ITEM",SC7->C7_ITEM ,Nil})
			aadd(aLinExe,{"C7_PRODUTO",SC7->C7_PRODUTO,Nil})
			aadd(aLinExe,{"C7_QUANT",SC7->C7_QUANT ,Nil})
			aadd(aLinExe,{"C7_QTDSOL",SC7->C7_QTDSOL,Nil})
			aadd(aLinExe,{"C7_UM",SC7->C7_UM,Nil})
			aadd(aLinExe,{"C7_QTSEGUM",SC7->C7_QTSEGUM,Nil})
			aadd(aLinExe,{"C7_PRECO",SC7->C7_PRECO,Nil})
			aadd(aLinExe,{"C7_TOTAL",SC7->C7_TOTAL,Nil})
			aadd(aLinExe,{"C7_NUMSC",SC7->C7_NUMSC,Nil})
			aadd(aLinExe,{"C7_ITEMSC",SC7->C7_ITEMSC,Nil})
			aadd(aLinExe,{"C7_IPI",SC7->C7_IPI,Nil})
			aadd(aLinExe,{"C7_REAJUST",SC7->C7_REAJUST,Nil})
			aadd(aLinExe,{"C7_FRETE",SC7->C7_FRETE,Nil})
			aadd(aLinExe,{"C7_DATPRF",SC7->C7_DATPRF,Nil})
			aadd(aLinExe,{"C7_LOCAL",SC7->C7_LOCAL,Nil})
			aadd(aLinExe,{"C7_MSG",SC7->C7_MSG,Nil})
			aadd(aLinExe,{"C7_TPFRETE",SC7->C7_TPFRETE,Nil})
			aadd(aLinExe,{"C7_OBS",SC7->C7_OBS,Nil})
			aadd(aLinExe,{"C7_CONTA",SC7->C7_CONTA,Nil})
			aadd(aLinExe,{"C7_CC",SC7->C7_CC,Nil})
			aadd(aLinExe,{"C7_DESCRI",SC7->C7_DESCRI,Nil})
			aadd(aLinExe,{"C7_SEQMRP",SC7->C7_SEQMRP,Nil})
			aadd(aLinExe,{"C7_TPOP",SC7->C7_TPOP,Nil})
			
			aadd(aLinExe,{"C7_ITEMCTA",SC7->C7_ITEMCTA,Nil})
			aadd(aLinExe,{"C7_CLVL",SC7->C7_CLVL,Nil})
			aadd(aLinExe,{"C7_APROV",SC7->C7_APROV,Nil})
			aadd(aLinExe,{"C7_XTPAPL",SC7->C7_XTPAPL,Nil})
			aadd(aLinExe,{"C7_VALICM",SC7->C7_VALICM,Nil})
			aadd(aLinExe,{"C7_PICM",SC7->C7_PICM,Nil})
			aadd(aLinExe,{"C7_BASEICM",SC7->C7_BASEICM,Nil})
			aadd(aLinExe,{"C7_BASEIPI",SC7->C7_BASEIPI,Nil})
			aadd(aLinExe,{"C7_XOBS",SC7->C7_XOBS,Nil})
			aadd(aLinExe,{"C7_SOLICIT",SC7->C7_SOLICIT,Nil})
			aadd(aLinExe,{"C7_XAPLIC",SC7->C7_XAPLIC,Nil})
			aadd(aLinExe,{"C7_XOBSF",SC7->C7_XOBSF,Nil})
			aadd(aLinExe,{"C7_RATEIO",SC7->C7_RATEIO,Nil})
			//aadd(aLinExe,{"C7_CONTRA",SC7->C7_CONTRA,Nil})
			
			aadd(aLinExe,{"C7_XFLAGMD","S",Nil})
			aadd(aIteExe,aLinExe)
		
			SC7->(dbSkip())
		EndDo

		//Processa rotinas especificas antes do encerramento da medicao
		cSql := " UPDATE " + RetSqlName("SAL")+ " SET AL_DOCPC = 'T',AL_DOCIP = 'T',AL_DOCCT = 'T',AL_DOCGA = 'T' WHERE AL_DOCPC <> 'T' AND AL_DOCMD = 'T' AND D_E_L_E_T_ != '*' " 
		TcSQLExec(cSql)
		nStatus := TcSQLExec(cSql)
		if (nStatus < 0)
			conout("TCSQLError() " + TCSQLError())
		endif
		
		MSExecAuto({|a,b,c,d,e| MATA120(a,b,c,d,e)},1,aCabExe,aIteExe,nOpcExe,.F.)
		
		//Processa rotinas especificas apos o encerramento da medicao
		cSql := " UPDATE " + RetSqlName("SAL")+ " SET AL_DOCPC = 'F',AL_DOCIP = 'F',AL_DOCCT = 'F',AL_DOCGA = 'F' WHERE AL_DOCGA = 'T' AND AL_DOCMD = 'T' AND D_E_L_E_T_ != '*' " 
		nStatus := TcSQLExec(cSql)
		// TcSQLExec("COMMIT")
   
		if (nStatus < 0)
			conout("TCSQLError() " + TCSQLError())
		endif
		
		
		If !lMsErroAuto
			conout("Alterado PC: " + cChvSc7)
		Else
			conout("Erro na alteracao!")
			cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
	        ConOut(PadC("Automatic routine ended with error", 80))
	        ConOut("Error: "+ cError)
	    EndIf
	EndIf
	RpcClearEnv()
	
return
