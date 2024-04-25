#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M110STTS  ºAutor  ³ Ismael Junior - STARSOFT em 26/03/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para tratamento de campos específicos     º±±
±±º          ³ na geração da solicitação de compras                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM>Atualizações>Solicitar/Cotar>Solicitações de Compras>MATA110º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß    
*/
User Function M110STTS()
//   Local cCodEmp := FWCodEmp()
   Local cSql := "" 
   Local cUsuario := __cUserId	
   Local aArea     := GetArea()
   Local cNumSol   := Paramixb[1]
   Local nOpt      := Paramixb[2]
   Local lCopia    := Paramixb[3]
   Local aDados    := {}  
   Local aRetAprov := {}  
   Local nX        := 0
   Local nPosQuant := aScan(aHeader,{|x| AllTrim(x[2])=="C1_QUANT"})
   Local nPosValor := aScan(aHeader,{|x| AllTrim(x[2])=="C1_VUNIT"})
   Local nTotal    := 0
   Local aDadosSCX := {}
   Local xCodCC    := ""
   Local xCodItem  := ""
   Local xCodCLvl  := ""
   Local nPosCc    := aScan(aHeader,{|x| AllTrim(x[2])=="C1_CC"})
   Local nPosItcta := aScan(aHeader,{|x| AllTrim(x[2])=="C1_ITEMCTA"})
   Local nPosClvl  := aScan(aHeader,{|x| AllTrim(x[2])=="C1_CLVL"})

Private nStart      := 0

   If nOpt == 3 .and. .not. lCopia
        aDados := GetDadosSC1(FWXFilial("SC1"),cNumSol)
        U_RT02M001(cNumSol) // Envia email na exclusao do Pedido para o Solicitante
        APIUtil():GravaDadosZR4("SC1",aDados)
   EndIf

   aDados := aCols
   For nX := 1 To Len(aDados)
      nTotal += (aDados[nX][nPosQuant] * aDados[nX][nPosValor])
   Next nX 

   If Empty(Alltrim(aDados[1][nPosCc])) .or. Empty(Alltrim(aDados[1][nPosItcta])) .or. Empty(Alltrim(aDados[1][nPosClvl]))
      aDadosSCX := GetRatSCX(Alltrim(cNumSol))
      xCodCC    := aDadosSCX[1]
      xCodItem  := aDadosSCX[2]
      xCodCLvl  := aDadosSCX[3]
   Else 
      xCodCC    := Alltrim(aDados[1][nPosCc])
      xCodItem  := Alltrim(aDados[1][nPosItcta])
      xCodCLvl  := Alltrim(aDados[1][nPosClvl])
   EndIf

   AVBUtil():DeletaGrupoAprovacao(FWXFilial("SC1"),Alltrim(cNumSol),"SC")
   aRetAprov := AVBUtil():ValidaGrupoAprovacao("SC1",xCodCC,xCodItem,xCodCLvl)
   AVBUtil():TrocaGrupoAprovacao("SC1",Alltrim(cNumSol),,DDataBase,nTotal,aRetAprov[2])

//*************************************************************************//
//Somente a primeira linha da SC será considerada na aprovação

/*
cQry1 := " SELECT R_E_C_N_O_ AS C1RECNUM,C1_APROV,C1_CC,C1_ITEMCTA,C1_CLVL "
cQry1 += " FROM "+ RetSqlName("SC1")+ " SC1 "
cQry1 += " WHERE C1_NUM = '"+SC1->C1_NUM+"' "
cQry1 += " AND C1_FILIAL = '"+xFilial("SC1")+"' AND C1_ITEM = '0001' AND SC1.D_E_L_E_T_ = ' ' "
If SELECT("TRASC1") > 0
	TRASC1->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry1),"TRASC1",.T.,.T.)
DbSelectArea("TRASC1")
TRASC1->(dbGoTop())
Do While TRASC1->(!Eof())
*/
   cQry2 := " SELECT AL_APROV,AL_USER,DBL_CC,DBL_ITEMCT,DBL_CLVL,DBL_GRUPO " 
   cQry2 += " FROM "+ RetSqlName("SAK")+ " SAK "
   cQry2 += " INNER JOIN "+ RetSqlName("SAL")+ " SAL ON AL_USER = AK_USER AND AL_DOCSC = 'T' AND SAL.D_E_L_E_T_ = ' ' "
   cQry2 += " INNER JOIN "+ RetSqlName("DBL")+ " DBL ON AL_COD = DBL_GRUPO AND DBL_CC = '"+xCodCC+"' AND DBL_ITEMCT = '"+xCodItem+"' AND DBL_CLVL = '"+xCodCLvl+"' AND DBL.DBL_XTIPO = 'C' AND DBL.D_E_L_E_T_ = ' ' "
   cQry2 += " WHERE SAK.D_E_L_E_T_ = ' ' "

   If SELECT("TRASAK") > 0
      TRASAK->(DbCloseArea())
   Endif
   dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry2),"TRASAK",.T.,.T.)
   DbSelectArea("TRASAK")
   TRASAK->(dbGoTop())
   Do While TRASAK->(!Eof())

      //Ajusta tabela DBM para permanecer somente os aprovadores da primeira linha dos itens
	  cSql := " UPDATE "+ RetSqlName("DBM")+ " SET D_E_L_E_T_ = '*' WHERE DBM_NUM = '"+SC1->C1_NUM+"' AND DBM_FILIAL = '"+xFilial("DBM")+"' AND DBM_ITEM+DBM_GRUPO <> '"+'0001'+TRASAK->DBL_GRUPO+"' AND D_E_L_E_T_ = ' ' "
	  TcSQLExec(cSql) 
	  nStatus := TcSQLExec(cSql)  
	  if (nStatus < 0)
        	FwLogMsg("M110STTS", /*cTransactionId*/, "M110STTS", FunName(), "", "01","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
	  endif 
  
      cQry1 := " SELECT DBM_ITGRP FROM "+ RetSqlName("DBM")+ " DBM WHERE DBM_NUM = '"+SC1->C1_NUM+"' AND DBM_FILIAL = '"+xFilial("DBM")+"' AND D_E_L_E_T_ = ' ' "
	  If SELECT("TRADBM") > 0
	     TRADBM->(DbCloseArea())
	  Endif
      dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry1),"TRADBM",.T.,.T.)
      DbSelectArea("TRADBM")
	  TRADBM->(dbGoTop())    
      //Ajusta tabela SCR para permanecer somente os aprovadores da primeira linha dos itens
      //cSql := " UPDATE "+ RetSqlName("SCR")+ " SET D_E_L_E_T_ = '*' WHERE CR_NUM = '"+SC1->C1_NUM+"' AND CR_FILIAL = '"+xFilial("SCR")+"' AND CR_DATALIB = '' AND CR_GRUPO+CR_ITGRP <> '"+TRASAK->DBL_GRUPO+TRADBM->DBM_ITGRP+"' AND D_E_L_E_T_ = ' ' "
      //TcSQLExec(cSql) 
      //nStatus := TcSQLExec(cSql)  
      //if (nStatus < 0)
      //endif	  	
	  	        
	  dbSelectArea("TRASAK")
	  TRASAK->(dbSkip())
   EndDo 
	
   //dbSelectArea("TRASC1")
   //TRASC1->(dbSkip())
//EndDo


// Faz a tratativa para produtos indiretos
// Antonio Aguiar - STARSOFT 
f_INDI()

//Libera a sc caso o solicitante seja o unico aprovador
cQry1 := " SELECT R_E_C_N_O_ AS C1RECNUM,C1_APROV,C1_CC,C1_ITEMCTA,C1_CLVL "
cQry1 += " FROM "+ RetSqlName("SC1")+ " SC1 "
cQry1 += " WHERE C1_NUM = '"+SC1->C1_NUM+"' "
cQry1 += " AND C1_FILIAL = '"+xFilial("SC1")+"' AND SC1.D_E_L_E_T_ = ' ' "
If SELECT("TRASC1") > 0
	TRASC1->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry1),"TRASC1",.T.,.T.)
DbSelectArea("TRASC1")
TRASC1->(dbGoTop())
Do While TRASC1->(!Eof())
   cQry2 := " SELECT AL_APROV,AL_NIVEL,AL_USER,DBL_CC,DBL_ITEMCT,DBL_CLVL " 
   cQry2 += " FROM "+ RetSqlName("SAK")+ " SAK "
   cQry2 += " INNER JOIN "+ RetSqlName("SAL")+ " SAL ON AL_USER = AK_USER AND AL_DOCSC = 'T' AND SAL.D_E_L_E_T_ = ' ' "
   cQry2 += " INNER JOIN "+ RetSqlName("DBL")+ " DBL ON AL_COD = DBL_GRUPO AND DBL_CC = '"+TRASC1->C1_CC+"' "
   cQry2 += "        AND DBL_ITEMCT = '"+TRASC1->C1_ITEMCTA+"' "
   cQry2 += "        AND DBL_CLVL = '"+TRASC1->C1_CLVL+"' "
   cQry2 += "        AND DBL_XTIPO = 'C' "
   cQry2 += "        AND DBL.D_E_L_E_T_ = ' ' "
   cQry2 += " WHERE AK_USER = '"+cUsuario+"' "
   cQry2 += " AND SAK.D_E_L_E_T_ = ' ' "

   If SELECT("TRASAK") > 0
      TRASAK->(DbCloseArea())
   Endif
   dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry2),"TRASAK",.T.,.T.)
   dbSelectArea("TRASAK")
   TRASAK->(dbGoTop())
   Do While TRASAK->(!Eof())

      cSql := " UPDATE "+ RetSqlName("SCR")+ " SET CR_USERLIB = '"+TRASAK->AL_USER+"',CR_LIBAPRO ='"+TRASAK->AL_APROV+"',CR_VALLIB = CR_TOTAL,CR_TIPOLIM = 'D',CR_STATUS = '03',CR_DATALIB = CONVERT(CHAR(8),GETDATE(),112) WHERE CR_NUM = '"+SC1->C1_NUM+"' AND CR_TIPO = 'SC' AND CR_FILIAL = '"+xFilial("SCR")+"' AND CR_NIVEL = '"+TRASAK->AL_NIVEL+"' AND D_E_L_E_T_ = ' ' "
      TcSQLExec(cSql) 
      nStatus := TcSQLExec(cSql)  
      if (nStatus < 0)
        	FwLogMsg("M110STTS", /*cTransactionId*/, "M110STTS", FunName(), "", "01","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
      endif	
	   
      cSql := " UPDATE "+ RetSqlName("SCR")+ " SET CR_STATUS = '02' WHERE CR_NUM = '"+SC1->C1_NUM+"' AND CR_FILIAL = '"+xFilial("SCR")+"' AND CR_TIPO = 'SC' AND CR_NIVEL <> '"+TRASAK->AL_NIVEL+"' AND D_E_L_E_T_ = ' ' "
      TcSQLExec(cSql) 
      nStatus := TcSQLExec(cSql)  
      if (nStatus < 0)
        	FwLogMsg("M110STTS", /*cTransactionId*/, "M110STTS", FunName(), "", "01","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
      endif	  
   
      cQry2 := " SELECT COUNT(CR_NUM) QUANT FROM "+ RetSqlName("SCR")+ " SCR "
	  cQry2 += " WHERE CR_NUM = '"+SC1->C1_NUM+"' " 
	  cQry2 += " AND CR_TIPO = 'SC'  
      cQry2 += " AND CR_DATALIB = ''
	  cQry2 += " AND SCR.D_E_L_E_T_ = ' '
	
	  If SELECT("TRASCR") > 0
	     TRASCR->(DbCloseArea())
	  Endif
	  dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry2),"TRASCR",.T.,.T.)
	  DbSelectArea("TRASCR")
	  TRASCR->(dbGoTop())
      If Empty(TRASCR->QUANT) 
	     cSql := " UPDATE "+ RetSqlName("SC1")+ " SET C1_APROV = 'L' WHERE C1_NUM = '"+SC1->C1_NUM+"' AND C1_FILIAL = '"+xFilial("SC1")+"' AND D_E_L_E_T_ = ' ' "
	     TcSQLExec(cSql)	 
	     nStatus := TcSQLExec(cSql)  
	     if (nStatus < 0)
        	FwLogMsg("M110STTS", /*cTransactionId*/, "M110STTS", FunName(), "", "01","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
	     endif
	  Endif  
	     
	  dbSelectArea("TRASAK")
	  TRASAK->(dbSkip())
   EndDo 
	
   dbSelectArea("TRASC1")
   TRASC1->(dbSkip())
EndDo


cSql := " UPDATE B SET B.DBM_ITGRP = A.CR_ITGRP "
cSql += " FROM "+RetSqlName("SCR")+" A,"+RetSqlName("DBM")+" B "
cSql += " WHERE B.D_E_L_E_T_ = ' ' "
cSql += " AND   B.DBM_FILIAL = A.CR_FILIAL "
cSql += " AND   B.DBM_TIPO   = A.CR_TIPO "
cSql += " AND   B.DBM_NUM    = A.CR_NUM "
cSql += " AND   B.DBM_GRUPO  = A.CR_GRUPO "
cSql += " AND   B.DBM_USER   = A.CR_USER "
cSql += " AND   B.DBM_USAPRO = A.CR_APROV "
cSql += " AND   A.D_E_L_E_T_ = ' ' "
cSql += " AND   A.CR_TIPO    = 'SC' "
cSql += " AND   A.CR_FILIAL  = '"+xFilial("SCR")+"' "
cSql += " AND   A.CR_NUM     = '"+SC1->C1_NUM+"' "

nStatus := TcSQLExec(cSql)  
if (nStatus < 0)
   FwLogMsg("M110STTS", /*cTransactionId*/, "M110STTS", FunName(), "", "01","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
endif	  


RestArea(aArea)  
Return


// Toni Aguiar - TOTVS STARSOFT em 16/11/2020
// Checa produtos indiretos e direciona ao grupo 
// de aprovação do almoxarifado.
//------------------------------------------------
Static Function f_INDI()                            
//------------------------------------------------                                        
Local aAprov :={}
Local cQuery        
Local nCnt   := 0      
Local nTotal := 0      
Local dEmissao, dPrazo, dAviso
Local nNivel := 0 
Local _cChave                  
Local aUsSCR := {}
Local aApSCR := {}
Local aGpSCR := {}    
Local cNivelAtual:=""
Local nReg   := SCR->(Recno())

dbSelectArea("SCR")
SCR->(dbSetOrder(1))
SCR->(dbSeek(xFilial("SCR")+"SC"+SC1->C1_NUM))
nTotal   := SCR->CR_TOTAL
dEmissao := SCR->CR_EMISSAO
dPrazo   := SCR->CR_PRAZO
dAviso   := SCR->CR_AVISO
_cChave  := SCR->CR_FILIAL+"SC"+SCR->CR_NUM
Do While _cChave == SCR->CR_FILIAL+"SC"+SCR->CR_NUM .And. !SCR->(Eof())
   nNivel := Val(SCR->CR_NIVEL)
   AADD(aUsSCR, SCR->CR_USER)
   AADD(aApSCR, SCR->CR_APROV)
   AADD(aGpSCR, SCR->CR_GRUPO) 
   SCR->(dbSkip())
Enddo 

// Checa se há produtos indiretos
cQuery:="    SELECT C1_NUM, C1_ITEM, C1_XPROPRI, C1_APROV,C1_CC,C1_ITEMCTA,C1_CLVL "
cQuery+="      FROM "+RetSqlName("SC1")+" SC1 "
//cQuery+="INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_COD=SC1.C1_PRODUTO AND SB1.B1_APROPRI='I' AND SB1.D_E_L_E_T_<>'*' "
cQuery+="     WHERE C1_NUM = '"+SC1->C1_NUM+"' AND C1_FILIAL = '"+xFilial("SC1")+"' AND SC1.D_E_L_E_T_ = ' ' AND C1_XPROPRI = 'I'"
ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SB1A",.T.,.T.)
SB1A->(dbGoTop())

// Se houver produtos indiretos, seleciona os aprovadores do grupo de almoxarifado
// e inclui para na aprovação da SC.
If !SB1A->(Eof()) 
   cQuery:="SELECT * FROM "+RetSqlName("SAL")+" WHERE D_E_L_E_T_ = ' ' AND  AL_XESTOQ = 'T' AND AL_FILIAL='"+xFilial("SAL")+"' ORDER BY AL_NIVEL"
   ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SALA",.T.,.T.)
                                                               
   //- Toni Aguiar em 28/04/2021
   //- A variavel cNivelAtual, controla se existir vários aprovadores do mesmo grupo que seja do mesmo nível
   //- coloca na mesma sequencia de nível para aprovação na SCR, ou seja, só precisa de uma aprovação apenas
   //- de qualquer um dos aprovadores que estejam no mesmo nível.
   cNivelAtual:=""	
   Do While !SALA->(Eof())
      If ASCAN(aApSCR, SALA->AL_APROV)=0 
         nNivel+=IIf(cNivelAtual<>SALA->AL_NIVEL, 1, 0)
         AADD(aAprov, {SALA->AL_USER, SALA->AL_APROV, SALA->AL_COD, SALA->AL_ITEM, Strzero(nNivel,2)}) 
      Endif
      cNivelAtual:=SALA->AL_NIVEL
      SALA->(dbSkip())
   Enddo                                    
   
   If Len(aAprov)>0
      For nCnt:=1 To Len(aAprov)
         RecLock("SCR",.T.)
         SCR->CR_FILIAL  := xFilial("SCR")
         SCR->CR_NUM     := SC1->C1_NUM
         SCR->CR_TIPO    := "SC"
         SCR->CR_USER    := aAprov[nCnt][1]  // Código do Usuário
         SCR->CR_APROV   := aAprov[nCnt][2]  // Código do Aprovador 
         SCR->CR_GRUPO   := aAprov[nCnt][3]  // Código do Grupo de aprovação 
         //SCR->CR_ITGRP   := aAprov[nCnt][4]  // Item de aprovação                               
         SCR->CR_NIVEL   := aAprov[nCnt][5]  // Nível de aprovação 
         SCR->CR_STATUS  := "02"             // 02-Aguardando liberação 
         SCR->CR_EMISSAO := dEmissao
         SCR->CR_TOTAL   := nTotal
         SCR->CR_PRAZO   := dPrazo
         SCR->CR_AVISO   := dAviso
         SCR->CR_ESCALON := .F.
         SCR->CR_ESCALSP := .F.
         SCR->CR_XFLAG   := "1"
         SCR->(MsUnLock())
         
         RecLock("DBM",.T.)
         DBM->DBM_FILIAL := xFilial("SCR")
         DBM->DBM_NUM    := SC1->C1_NUM
         DBM->DBM_TIPO   := "SC"
         DBM->DBM_ITEM   := "0001"   
         DBM->DBM_USER   := aAprov[nCnt][1]  // Código do Usuário
         DBM->DBM_APROV  := "2" 
         DBM->DBM_USAPRO := aAprov[nCnt][2]  // Código do Aprovador 
         DBM->DBM_GRUPO  := aAprov[nCnt][3]  // Código do Grupo de aprovação 
         //DBM->DBM_ITGRP  := aAprov[nCnt][4]  // Item de aprovação                               
         DBM->DBM_VALOR  := nTotal
         DBM->DBM_XFLAG  := "1"
         DBM->(MsUnLock())
      Next
   Endif                        
   SALA->(dbCloseArea())   
Endif   
SB1A->(dbCloseArea())     
SCR->(dbGoTo(nReg))
Return 

/*/{Protheus.doc} GetDadosSC1
Busca os Dados deletados da Solicitação de Compra.
@type function 
@author Ricardo Tavares Ferreira
@since 05/04/2021
@param xFil, character, Codigo da Filial em Execução.
@param xNumSC, character, Numero da SC Excluida.
@history 05/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 12/04/2021, Ricardo Tavares Ferreira, Mudança na busca dos dados, agora a busca está sendo feita pela Classe APIExQry query Codigo SC1.
@return array, Retorna um Array contendo os dados Deletados.
@version 12.1.27
/*/
//=============================================================================================================================
    Static Function GetDadosSC1(xFil,xNumSC)
//=============================================================================================================================

    Local oQuery    := Nil
    Local cCodQry 	:= "SC1"
    Local aRet      := {}
    Local cCodComp  := ""
    Local nX        := 0
    Local nY        := 0
    Local cFil      := ""
    Local cNum      := ""
    Local cItem     := ""
    Local cRecno    := ""
    Local aDados    := {}
    Local cDataGrv  := Date()
    Local cHoraGrv  := Time()

    Default xFil    := ""
    Default xNumSC  := ""

    oQuery := APIExQry():New(.T.)
    oQuery:SetFormula(cCodQry)
    oQuery:SetHasHead(.F.)
    oQuery:AddFilter("TAB1", RetSqlName("SC1"))
    oQuery:AddFilter("TAB2", RetSqlName("ZR4"))

    If .not. oQuery:BuildQuery()
        APIUtil():ConsoleLog("M110STTS|GetDadosSC1","Nao foi possivel carregar a query passada como parametro "+cCodQry,3)
        Return cCodComp
    Else 
        oQuery:oPrepS:SetString(01,xNumSC)
        oQuery:oPrepS:SetString(02,xFil)

        aRet := oQuery:ExecPreparedSt()
        If Len(aRet) > 0
            For nX := 1 To Len(aRet)
                For nY := 1 To Len(aRet[nX])
                    If Alltrim(aRet[nX][nY][1]) == "C1_FILIAL"
                        cFil := Alltrim(aRet[nX][nY][2])
                    EndIf
                    If Alltrim(aRet[nX][nY][1]) == "C1_NUM"
                        cNum := Alltrim(aRet[nX][nY][2])
                    EndIf
                    If Alltrim(aRet[nX][nY][1]) == "C1_ITEM"
                        cItem := Alltrim(aRet[nX][nY][2])
                    EndIf
                    If Alltrim(aRet[nX][nY][1]) == "IDSC1"
                        cRecno := cValToChar(aRet[nX][nY][2])
                    EndIf
                Next nY
                aadd(aDados,{cFil,"SC1",cNum,cItem,cDataGrv,cHoraGrv,cRecno})
            Next nX
        Else 
            APIUtil():ConsoleLog("M110STTS|GetDadosSC1","Registro nao encontrado pela query executada. "+cCodQry,3)
        EndIf
    EndIf
    FWFreeObj(oQuery)
Return aDados


/*/{Protheus.doc} GetRatSCX
Busca dos dados para quando existir rateio.
@type function 
@author Ricardo Tavares Ferreira
@version 12.1.27
@return array, Array com os dados da entidade contabil.
@since 13/04/2022
@history 13/04/2022, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//=============================================================================================================================
    Static Function GetRatSCX(xNumSc)
//=============================================================================================================================

    Local xCusto      := ""
    Local xItemC      := ""
    Local xClass      := ""
	Local QbLinha		:= chr(13)+chr(10)
	Local cAliasSCX	:= GetNextAlias()
	Local cQuery		:= ""
	Local nQtdReg  	:= 0

    cQuery := " SELECT TOP 1 "+QbLinha
    cQuery += " CX_CC "+QbLinha  
    cQuery += " ,CX_ITEMCTA "+QbLinha  
    cQuery += " ,CX_CLVL "+QbLinha  
    cQuery += " FROM "+QbLinha 
    cQuery +=   RetSqlName("SCX") + " SCX "+QbLinha
    cQuery += " WHERE "+QbLinha  
    cQuery += " SCX.D_E_L_E_T_ = ' ' "+QbLinha  
    cQuery += " AND CX_SOLICIT = '"+xNumSc+"' "+QbLinha 
    cQuery += " AND CX_FILIAL = '"+FWXFilial("SC1")+"' "+QbLinha 
	
	MemoWrite("C:/ricardo/ValidaGrupoAprovacao_SCX.sql",cQuery)			     
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSCX,.F.,.T.)
            
    DbSelectArea(cAliasSCX)
    (cAliasSCX)->(DbGoTop())
    Count To nQtdReg
    (cAliasSCX)->(DbGoTop())
            
    If nQtdReg > 0
	    xCusto := Alltrim((cAliasSCX)->CX_CC)
        xItemC := Alltrim((cAliasSCX)->CX_ITEMCTA)
        xClass := Alltrim((cAliasSCX)->CX_CLVL)
	EndIf  
    (cAliasSCX)->(DbCloseArea())
Return {xCusto,xItemC,xClass}
