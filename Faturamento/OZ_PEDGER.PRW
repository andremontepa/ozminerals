#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
 
User Function OZ_GERPED(cCliente, cLoja,cTransp, cTabela,cMoeda,nPbruto,nPliqui,cProduto,cDesc,nQuant,nPreco,aChave)
 

Local cA1Cod     := SUBSTRING(SUPERGETMV("OZ_CLIEXP"),1,6)    // Código do Cliente
Local cA1Loja    := SUBSTRING(SUPERGETMV("OZ_CLIEXP"),7,2)                                                // Loja do Cliente
Local cB1Cod     := cProduto                                   // Código do Produto
Local cF4TES     := SUPERGETMV("OZ_TESEXP")                                                              // Código do TES
Local cE4Codigo  := SUPERGETMV("OZ_E4COND")
Local cMenChv    := ""
Local cMoeTit    := 1
local nQtdVen    := nQuant
local cLocal     := "01"
Local cDA1TAB    := SUPERGETMV("OZ_DA0TAB")
Local cTrasnp    := SUPERGETMV("OZ_TRANSP")
//local cTIPCLI    := "X"
local nPrcVen    := 0
lOCAL nTotVen    := 0
Local cMsgLog    := ""
Local cLogErro   := ""
Local cFilSA1    := ""
Local cFilSB1    := ""
Local cFilSE4    := ""
Local cFilSF4    := ""
Local nOpcX      := 0
Local nX         := 0
Local nCount     := 0
Local aCabec     := {}
Local aItens     := {}
Local aLinha     := {}
Local aErroAuto  := {}
Local lOk        := .T.
Local lRet       := .F.
Public cDoc       := ""    
//Local cmesg      := " "

Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .F.
 
//****************************************************************
//* Abertura do ambiente
//****************************************************************
ConOut("Inicio: " + Time())
 
ConOut(Repl("-",80))
ConOut(PadC("Teste de inclusao / alteração / exclusão de 01 pedido de venda com 02 itens", 80))
 
//PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"
 
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

If DA1->(! MsSeek(cFilDA1 + cDA1TAB + cB1Cod))
   cMsgLog += "Cadastrar o Produto: " + cB1Cod + CRLF
   lOk     := .F.
Else
   nPrcVen := DA1->DA1_PRCVEN
EndIf



If lOk

    For nX := 1 To len(aChave)
        cMenChv += aChave[nx] 
   
    NEXT nX


   // Neste RDMAKE (Exemplo), o mesmo número do Pedido de Venda é utilizado para a Rotina Automática (Modelos INCLUSÃO / ALTERAÇÃO e EXCLUSÃO).
   cDoc := GetSxeNum("SC5", "C5_NUM")
   //****************************************************************
   //* Inclusao - INÍCIO
   //****************************************************************
   aCabec   := {}
   aItens   := {}
   aLinha   := {}
   aadd(aCabec, {"C5_NUM",     cDoc,      Nil})
   aadd(aCabec, {"C5_TIPO",    "N",       Nil})
   aadd(aCabec, {"C5_CLIENTE", cA1Cod,    Nil})
   AAdd(aCabec, {"C5_TIPOCLI", Posicione("SA1", 1, xFilial("SA1") + cA1Cod + cA1Loja, "A1_TIPO"), Nil})
   aadd(aCabec, {"C5_LOJACLI", cA1Loja,   Nil})
   aadd(aCabec, {"C5_CLIENT",  cA1Cod,    Nil})
   aadd(aCabec, {"C5_LOJAENT", cA1Loja,   Nil})
   aadd(aCabec, {"C5_CONDPAG", cE4Codigo, Nil})
   aadd(aCabec, {"C5_MOEDTIT", cMoeTit,   Nil})
   aadd(aCabec, {"C5_MOEDA",   cMoeTit,   Nil}) 
 //  aadd(aCabec, {"C5_TABELA",  cDA1TAB,   Nil}) 
   aadd(aCabec, {"C5_TRANSP",  cTrasnp,   Nil}) 
   aadd(aCabec, {"C5_EMISSAO", dDataBase, Nil})


    nTotVen := rPara1 * nQtdVen
    nX := 1
    aLinha := {}
    aadd(aLinha,{"C6_ITEM",    StrZero(nX,2), Nil})
    aadd(aLinha,{"C6_PRODUTO", cB1Cod,        Nil})
    aadd(aLinha,{"C6_DESCRI", Posicione("SB1", 1, xFilial("SB1") + cB1Cod, "B1_DESC" ), Nil})
    aadd(aLinha,{"C6_UM", Posicione("SB1", 1, xFilial("SB1") + cB1Cod, "B1_UM" ), Nil})
    aadd(aLinha,{"C6_QTDVEN",  nQtdVen,       Nil})
    aadd(aLinha,{"C6_PRCVEN", rPara1,       Nil})
    aadd(aLinha,{"C6_CLI",  cA1Cod,       Nil})
    aadd(aLinha,{"C6_LOJA",  cA1Loja,       Nil})
    aadd(aLinha,{"C6_PRUNIT",  rPara1,       Nil})
    aadd(aLinha,{"C6_ENTREG",  dDataBase,       Nil})
    aadd(aLinha,{"C6_SUGENTR",  dDataBase,       Nil})
    aadd(aLinha,{"C6_VALOR",   nTotVen,       Nil})
    aadd(aLinha,{"C6_TES",     cF4TES,        Nil})
    aadd(aLinha,{"C6_LOCAL",  cLocal,        Nil})

   
    aadd(aItens, aLinha)
    
   nOpcX := 3
   MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)
  //MSExecAuto({|x,y,z|Mata410(x,y,z)}, aCabec, aItens, 3) //adiciona pedido de vendas  

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
      SC5->C5_XMENNFE := SC5->C5_XMENNFE+" CONFORME NF-E REFERENCIADAS DO LOTE. "+rPara2+" Ref. Chaves :  " + aChave[nx] + " "
                SC5->( MsUnlock() )
            Else
                RecLock( "SC5", .F. )
                   // if len(aChave) < 72
                   //     cmesg := aChave[nx]
                  //  Endif
                    SC5->C5_XMENNFE := SC5->C5_XMENNFE+ " " + aChave[nx] + " "
               SC5->( MsUnlock() )
            Endif
        EndIF 
   
      NEXT nX
IF Lret == .T.
    MSGINFO( ("Pedido de Vendas "+cDoc+" incluido com sucesso! " ))
    ConfirmSx8()
    msunlock('SC5')
EndIF
      
   Else
      mostraerro()  
      //ConOut("Erro na inclusao!")


      aErroAuto := GetAutoGRLog()
      For nCount := 1 To Len(aErroAuto)
         cLogErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " "
         ConOut(cLogErro)
      Next nCount
   EndIf
else
    
ENDIF

RETURN(lRet)


