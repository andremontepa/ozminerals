#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
/*/{Protheus.doc}   OZGERAPED
@author Julio Martins - Crmservices
@Maio/2025
/*/
User Function OZGERAPED(cCliente, cLoja,cTransp, cTabela,cMoeda,nPbruto,nPliqui,cProduto,cDesc,nQuant,nPreco,aChave)
Local cA1Cod     := cCliente  // SUPERGETMV("OZ_CLIEXP")   // Código do Cliente
Local cA1Loja    := cLoja                                  // Loja do Cliente
Local cB1Cod     := cProduto                               // Código do Produto
Local cF4TES     := SUPERGETMV("OZ_TESEXP")                                                              // Código do TES
Local cE4Codigo  := SUPERGETMV("OZ_E4COND")
Local cMenChv    := ""
Local cMoeTit    := 1
local nQtdVen    := nQuant    // Peso Liquido
local cLocal     := "01"
Local cTrasnp    := cTransp  // SUPERGETMV("OZ_TRANSP")  // Transportadora Dela Volpe
lOCAL nTotVen    := 0
Local cMsgLog    := ""
Local cLogTxt    := ""
Local cFilSA1    := ""
Local cFilSB1    := ""
Local cFilSE4    := ""
Local cFilSF4    := ""
Local cArquivo   := "C:\TEMP\TOLEDO.TXT"
Local nOpcX      := 0
Local nX         := 0
Local nAux       := 0
Local aCabec     := {}
Local aItens     := {}
Local aLinha     := {}
Local aLogAuto   := {}
Local lOk        := .T.
Public lRet      := .F.
Public cPedido   := ""    


Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.
Private lMsHelpAuto :=.T.

//cA1Cod     := SUBSTRING(SUPERGETMV("OZ_CLIEXP"),1,6)    // Código do Cliente
//cA1Loja    := SUBSTRING(SUPERGETMV("OZ_CLIEXP"),7,2)  

 //****************************************************************
//* Abertura do ambiente
//****************************************************************
ConOut("Inicio: " + Time())
 
ConOut(Repl("-",80))
ConOut(PadC("Teste de inclusao / alteração / exclusão de 01 pedido de venda com 02 itens", 80))
 
SA1->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SE4->(dbSetOrder(1))
SF4->(dbSetOrder(1))
SC5->(dbSetOrder(1))
DA1->(dbSetOrder(1))

cFilAGG := xFilial("AGG")
cFilSA1 := xFilial("SA1")
cFilSB1 := xFilial("SB1")
cFilSE4 := xFilial("SE4")
cFilSF4 := xFilial("SF4")
cFilSC5 := xFilial("SC5")
cFilDA1 := xFilial("DA1") 
//****************************************************************
//* Verificacao do ambiente para teste
//****************************************************************


If SB1->(! MsSeek(cFilSB1 + cB1Cod))
   cMsgLog += "Cadastrar o Produto: " + cB1Cod + CRLF
   lOk     := .F.
EndIf
 
If SF4->(! MsSeek(cFilSF4 + cF4TES))
   cMsgLog += "Cadastrar o TES: " + cF4TES + CRLF
   lOk     := .F.
EndIf
 
If SE4->(! MsSeek(cFilSE4 + cE4Codigo))
   cMsgLog += "Cadastrar a Condição de Pagamento: " + cE4Codigo + CRLF
   lOk     := .F.
EndIf
 
If SA1->(! MsSeek(cFilSA1 + cA1Cod + cA1Loja))
   cMsgLog += "Cadastrar o Cliente: " + cA1Cod + " Loja: " + cA1Loja + CRLF
   lOk     := .F.
EndIf

//If DA1->(! MsSeek(cFilDA1 + cDA1TAB + cB1Cod))
//   cMsgLog += "Cadastrar o Produto: " + cB1Cod + CRLF
 //  lOk     := .F.
//Else
//   nPrcVen := DA1->DA1_PRCVEN
//EndIf



If lOk

    For nX := 1 To len(aChave)
        cMenChv += aChave[nx] 
   
    NEXT nX


   // Neste RDMAKE (Exemplo), o mesmo número do Pedido de Venda é utilizado para a Rotina Automática (Modelos INCLUSÃO / ALTERAÇÃO e EXCLUSÃO).
   cPedido := GetSxeNum("SC5", "C5_NUM")
   //****************************************************************
   //* Inclusao - INÍCIO
   //****************************************************************
   aCabec   := {}
   aItens   := {}
   aLinha   := {}
   aadd(aCabec, {"C5_NUM",     cPedido,   Nil})
   aadd(aCabec, {"C5_TIPO",    "N",       Nil})
   aadd(aCabec, {"C5_CLIENTE", cA1Cod,    Nil})
   AAdd(aCabec, {"C5_TIPOCLI", Posicione("SA1", 1, xFilial("SA1") + cA1Cod + cA1Loja, "A1_TIPO"), Nil})
   aadd(aCabec, {"C5_LOJACLI", cA1Loja,   Nil})
   aadd(aCabec, {"C5_CLIENT",  cA1Cod,    Nil})
   aadd(aCabec, {"C5_LOJAENT", cA1Loja,   Nil})
   aadd(aCabec, {"C5_CONDPAG", cE4Codigo, Nil})
   aadd(aCabec, {"C5_MOEDTIT", cMoeTit,   Nil})
   aadd(aCabec, {"C5_MOEDA",   cMoeTit,   Nil}) 
   //aadd(aCabec, {"C5_TABELA",  cDA1TAB,   Nil}) 
   aadd(aCabec, {"C5_TRANSP",  cTrasnp,   Nil}) 
   aadd(aCabec, {"C5_EMISSAO", dDataBase, Nil})


    nTotVen :=(nPreco * nQtdVen)
    nX := 1
    aLinha := {}
    aadd(aLinha,{"C6_ITEM",    StrZero(nX,2), Nil})
    aadd(aLinha,{"C6_PRODUTO", cB1Cod,        Nil})
    aadd(aLinha,{"C6_DESCRI", Posicione("SB1", 1, xFilial("SB1") + cB1Cod, "B1_DESC" ), Nil})
    aadd(aLinha,{"C6_UM", Posicione("SB1", 1, xFilial("SB1") + cB1Cod, "B1_UM" ), Nil})
    aadd(aLinha,{"C6_QTDVEN", nQtdVen,       Nil})
    aadd(aLinha,{"C6_PRCVEN", nPreco,       Nil})
    aadd(aLinha,{"C6_CLI",  cA1Cod,       Nil})
    aadd(aLinha,{"C6_LOJA",  cA1Loja,       Nil})
    aadd(aLinha,{"C6_PRUNIT",  nPreco,       Nil})
    aadd(aLinha,{"C6_ENTREG",  dDataBase,       Nil})
    aadd(aLinha,{"C6_SUGENTR",  dDataBase,       Nil})
    aadd(aLinha,{"C6_VALOR",   nTotVen,       Nil})
    aadd(aLinha,{"C6_TES",     cF4TES,        Nil})
    aadd(aLinha,{"C6_LOCAL",  cLocal,        Nil})

   
    aadd(aItens, aLinha)
    
   nOpcX := 3  // Inclusão
   MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)
 

   If !lMsErroAuto
      //ConOut("Incluido com sucesso! " + cDoc)
      ///MSGINFO( ("Incluido com sucesso! " + cDoc))
      LRet := .T.
      For nX := 1 To len(aChave)
      If SC5->( MsSeek(cFilSC5 + cDoc))
      iF Empty(SC5->C5_XMENNFE) 
      RecLock( "SC5", .F. )
      SC5->C5_XMENNFE := "NÃO INC. ICMS ART 612-B - INCISO II, ALINEA A. e LC 87/96 ART 3 PARAGR UNICO-INCISO II."
      SC5->C5_XMENNFE := SC5->C5_XMENNFE+" NÃO INC. IPI ART. 42, INCISO V ALIN. B, DEC. 4544/02. COMPLEXO PORTUARIO DE ITAQUI - "
      SC5->C5_XMENNFE := SC5->C5_XMENNFE+" AVENIDA DOS PORTUGUESE  - SÃO LUIS - MA. CODIGO DO RECINTO ALFANDEGADO: 3.93.27.05 "
      SC5->C5_XMENNFE := SC5->C5_XMENNFE+" CONFORME NF-E REFERENCIADAS DO LOTE. "+rPara12  //" Ref. Chaves :  " 

      SC5->( MsUnlock() )
      Endif
      EndIF 
   
      NEXT nX
		IF Lret 
//    		MSGINFO( ("Pedido de Vendas "+cDoc+" incluido com sucesso! " ))
    		ConfirmSx8()
    		msunlock('SC5')
		EndIF
      
   Else
         lRet := .F.
         //Pegando log do ExecAuto
         aLogAuto := GetAutoGRLog()
         //Percorrendo o Log e incrementando o texto (para usar o CRLF você deve usar a include "Protheus.ch")
         For nAux := 1 To Len(aLogAuto)
         cLogTxt += aLogAuto[nAux] + CRLF
         Next
         //Criando o arquivo txt
         If Empty(cLogTxt)
         cLogTxt:= "TOLEDO"
         Endif
         MemoWrite(cArquivo, cLogTxt)
         
   EndIf
else
    
ENDIF

RETURN(lRet)


