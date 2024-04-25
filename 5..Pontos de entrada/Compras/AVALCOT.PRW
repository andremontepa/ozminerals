#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PRTOPDEF.CH"

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | AVALCOT.prw      | AUTOR | ISMAEL JUNIOR |DATA | 20/03/2019     |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - AVALCOT()                                              |//
//|           |                                                                 |//
//|           | O ponto se encontra no final do evento 4 da MaAvalCot           |//
//|           | (Analise da Cotação) após a gravação do item do PC gerado a     |//
//|           | partir da cotação vencedora. e pode ser utilizado para          |//
//|           | manipularo item do pedido de compras posicionado tabela SC7.    |//
//|           | Pedido de compra                                                |//
//+-----------------------------------------------------------------------------+//
//| MANUTENCAO DESDE SUA CRIACAO                                                |//
//+-----------------------------------------------------------------------------+//
//| DATA     | AUTOR                | DESCRICAO                                 |//
//+-----------------------------------------------------------------------------+//
//|          |                      |                                           |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
User Function AVALCOT
//-
//- Toni Aguiar - TOTVS STARSOFT em 10/04/2021
//- Nova condição: A partir de 13/04/2021, as seguintes regras foram 
//- aplicadas para seleção de grupos de arpovação automática:
//- . Antes de 13/04/2021 usaremos a Regra antiga, classificando o grupo relacionado com CC x It.Cont x Clas.Vl.
//- . A partir de 13/04/2021, se a Classe de Valor for OPX o grupo será um, e se for CPX será outro.
//- . Conforme variável cGrupo
//-
//- Local cGrupo  := "" 

//***************** Regra Nova
   Local cGrupo      := ""
   Local dDtEmis     := SC7->C7_EMISSAO
   //Local dLimite   := GetNewPar("MV_DTNEWGR",CTOD("13/04/2021"))    // Novos grupos a partir desta data 
   Local lExecAPI    := .F.
	Local cTpDBL      := Alltrim( SuperGetMV("OZ_TPDBL",,"C"))
	Local cGRPPad     := Alltrim( SuperGetMV("OZ_GRPAD",,"AVB990"))
   Public __cGrupo__ := cGRPPad

   If Type("__cCodCC__") == "U"
      lExecAPI := .F.
   Else
      lExecAPI := .not. Empty(__cCodCC__) .and. .not. Empty(__cCodIt__) .and. .not. Empty(__cCodCl__)
   EndIF
      
      
If lExecAPI
   dDtEmis  := DDataBase
EndIf 

If .not. lExecAPI
   //***************** Regra Antiga
   cQry1 := " SELECT C7_CC, C7_ITEMCTA, C7_CLVL, C7_FILIAL, C7_NUM, C7_ITEM, C1_EMISSAO "
   cQry1 += "   FROM " + RetSqlName("SC7")+ " SC7 "
   cQry1 += "  INNER JOIN "+RetSqlName("SC1")+" SC1 ON SC7.C7_FILIAL=SC1.C1_FILIAL AND SC7.C7_NUMSC=SC1.C1_NUM " 
   cQry1 += "    AND SC7.C7_ITEMSC=SC1.C1_ITEM AND SC1.D_E_L_E_T_<>'*' "
   cQry1 += " WHERE C7_NUM = '"+SC7->C7_NUM+"' "
   cQry1 += " AND C7_FILIAL = '"+xFilial("SC7")+"' "
   cQry1 += " AND SC7.D_E_L_E_T_ <> '*' "
   cQry1 += " ORDER BY C7_ITEM "
   If SELECT("TRASC7") > 0
      TRASC7->(DbCloseArea())
   Endif 
   dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry1),"TRASC7",.T.,.T.)
   DbSelectArea("TRASC7")
   TRASC7->(dbGoTop())

   // passamos a considerar, a data da SC para definir o antes e depois.
   dDtEmis := STOD(TRASC7->C1_EMISSAO)
EndIf 

// se o pedido foi emitido antes de 13/04/2021, entra na regra antiga para selecionar 
// o grupo de aprovação automaticamente.
/*If dDtEmis<dLimite 	
   cQuery := "	SELECT DBL_GRUPO FROM " + RetSqlName("DBL")+ " DBL "

   If lExecAPI
      cQuery += " WHERE DBL_CC = '"+__cCodCC__+"' "
      cQuery += " AND DBL_ITEMCT = '"+__cCodIt__+"' "
      cQuery += " AND DBL_CLVL = '"+__cCodCl__+"' "
   Else 
      cQuery += " WHERE DBL_CC = '"+TRASC7->C7_CC+"' "
      cQuery += " AND DBL_ITEMCT = '"+TRASC7->C7_ITEMCTA+"' "
      cQuery += " AND DBL_CLVL = '"+TRASC7->C7_CLVL+"' "
   EndIf 

   cQuery += " AND DBL_GRUPO NOT LIKE '%MD%' "
   cQuery += " AND DBL_XTIPO = '"+cTpDBL+"'"
   cQuery += " AND DBL.D_E_L_E_T_ = ' ' "

   If SELECT("TRADBL") > 0
      TRADBL->(DbCloseArea())
   Endif

   dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery),"TRADBL",.T.,.T.)
   DbSelectArea("TRADBL")
   TRADBL->(dbGoTop())

   Do While TRADBL->(!Eof())
      cQry := " SELECT AL_COD FROM " + RetSqlName("SAL")+ " SAL " 
      cQry += " WHERE AL_COD = '"+TRADBL->DBL_GRUPO+"' " 
      cQry += " AND AL_DOCPC = 'T' " 		
      cQry += " AND SAL.D_E_L_E_T_ <> '*' "                      
      If SELECT("TRBSAL") > 0
         TRBSAL->(DbCloseArea())
      Endif		
      dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry),"TRBSAL",.T.,.T.)
      If !Empty(TRBSAL->AL_COD)
         cGrupo := TRBSAL->AL_COD
         __cGrupo__ := TRBSAL->AL_COD
      Endif	
      dbSelectArea("TRADBL")
      TRADBL->(dbSkip())
   EndDo
   
// se o pedido foi emitido a partir de 13/04/2021, entra na nova regra para 
// selecionar o grupo de aprovação automaticamente.
//Els
//   If lExecAPI
//      __cGrupo__ := 'AVB990'  //If(Alltrim(__cCodCl__) == "OPX", GetNewPar("MV_GRUPOPX","AVB990"), GetNewPar("MV_GRUPCPX","AVB991"))
//   Else 
//      cGrupo := If(Alltrim(SC7->C7_CLVL)=="OPX", GetNewPar("MV_GRUPOPX","AVB990"), GetNewPar("MV_GRUPCPX","AVB991"))
//   EndIf
 
//Endif*/

If Empty(cGrupo)
   cGrupo := cGRPPad
EndIf 

If Empty(__cGrupo__)
   __cGrupo__ := cGRPPad
EndIf 

If .not. lExecAPI
   Do While TRASC7->(!Eof())
      If !Empty(cGrupo)
         SC7->(DbGoTop()) 
         SC7->(DbSetOrder(1))
         If SC7->(DbSeek(TRASC7->C7_FILIAL+TRASC7->C7_NUM+TRASC7->C7_ITEM))
            Reclock("SC7",.F.)      
            SC7->C7_APROV := cGrupo
            MsUnlock()			
         Endif
      Endif	 
      dbSelectArea("TRASC7")
      TRASC7->(dbSkip())
   EndDo		
EndIf 

Return NIL
