#INCLUDE "protheus.ch"

/*/      

Descritivo: Ponto de Entrada para realizar o bloqueio no encerramento de medicoes para contratos com data final atingida.  
PE: CN120VENC
Modulo: SIGAGCT
Cliente: AVB MINERACAO    
Autor:  Lucas Costa - STARSOFT INFORMATICA LTDA
Data:   02/03/2020

/*/

User Function CN120VENC
   Local _lRet     := .T.
   Local _dData    := cTod("//")
   Local _cAreaAnt := GetArea()
   Local aDados    := {}
   Local xCusto    := ""
   Local xItemC    := ""
   Local xClass    := ""
   Local cTab      := "CN9"

   aDados := GetEntContab(Alltrim(CND->CND_FILIAL),Alltrim(CND->CND_CONTRA),Alltrim(CND->CND_REVISA),AllTrim(CND->CND_NUMMED))

   If Len(aDados) > 0 
      xCusto := aDados[1]
      xItemC := aDados[2]
      xClass := aDados[3]
   EndIf 

   If .not. AVBUtil():ValidaGrupoAprovacao(cTab,xCusto,xItemC,xClass)[1]
      MsgStop("Não é possivel incluir uma PC sem Entidades contabeis amarradas para aprovação.","CN120VENC")
      Return .F. 
   EndIf 

   dBSelectArea("CN9")
   dBSetOrder(1) 
//--
//-- Alterado por Toni Aguiar - TOTVS STARSOFT em 01/04/2021
//-- dBSeek(CND->CND_FILIAL+CND->CND_CONTRA+CND->CND_REVISA) 
//--
If dBSeek(CND->CND_FILCTR+CND->CND_CONTRA+CND->CND_REVISA)

   _dData := DaySum(CN9->CN9_DTFIM,30)    // 29/04/2020 - Alterado para considerar mais 30 dias após o vencimento do contrato. 
		    
   If dDatabase > _dData
      MsgInfo("A medição não pode ser encerrada, pois o contrato enconta-se vencido.","Atenção!")
	  _lRet := .F.	   																			
   EndIf                 
Else
   //MsgInfo("Não foi possível encontrar o contrato nesta filial."+CHR(13)+CHR(10)+;
   //        " Verifique se está na filial de origem do contrato.","Atenção!")
   //_lRet := .F.
   _lRet := .T.	   																			
Endif
CN9->(dBCloseArea())
RestArea(_cAreaAnt)
Return(_lRet)

/*/{Protheus.doc} GetEntContab
Busca dos dados da entidade contabil.
@type function 
@author Ricardo Tavares Ferreira
@version 12.1.27
@return array, Array com os dados da entidade contabil.
@since 15/03/2022
@history 15/03/2022, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//=============================================================================================================================
    Static Function GetEntContab(xFil,xNumCtr,xRevCtr,xNumMed)
//=============================================================================================================================

   Local xCusto      := ""
   Local xItemC      := ""
   Local xClass      := ""
	Local QbLinha		:= chr(13)+chr(10)
	Local cAliasCNE	:= GetNextAlias()
	Local cQuery		:= ""
	Local nQtdReg  	:= 0
   Local aDadosCNZ   := {}

   cQuery := " SELECT "+QbLinha 

   If Alltrim(CN9->CN9_XGLOBA) == "N" .and. Alltrim(CND->CND_XEMPRE)+Alltrim(CND->CND_XFILIA) <> Alltrim(cEmpAnt)+Alltrim(CND->CND_FILIAL)
      cQuery += " CNE_XCC CNE_CC "+QbLinha  
      cQuery += " ,CNE_XITCTA CNE_ITEMCT "+QbLinha  
      cQuery += " ,CNE_XCLVL CNE_CLVL "+QbLinha 
   Else
      cQuery += " CNE_CC "+QbLinha  
      cQuery += " ,CNE_ITEMCT "+QbLinha  
      cQuery += " ,CNE_CLVL "+QbLinha  
   EndIf

	cQuery += " FROM "
	cQuery +=   RetSqlName("CNE") + " CNE "+QbLinha 
   cQuery += " WHERE "+QbLinha  
   cQuery += " CNE.D_E_L_E_T_ = ' ' "+QbLinha  
   cQuery += " AND CNE_FILIAL = '"+xFil+"' "+QbLinha  
   cQuery += " AND CNE_CONTRA = '"+xNumCtr+"' "+QbLinha 
   cQuery += " AND CNE_REVISA = '"+xRevCtr+"' "+QbLinha 
   cQuery += " AND CNE_NUMMED = '"+xNumMed+"' "+QbLinha 

   If Alltrim(CN9->CN9_XGLOBA) == "N" .and. Alltrim(CND->CND_XEMPRE)+Alltrim(CND->CND_XFILIA) <> Alltrim(cEmpAnt)+Alltrim(CND->CND_FILIAL)
      cQuery += " AND CNE_XCC <> ' ' "+QbLinha  
      cQuery += " AND CNE_XITCTA <> ' ' "+QbLinha  
      cQuery += " AND CNE_XCLVL <> ' ' "+QbLinha 
   Else
      cQuery += " AND CNE_CC <> ' ' "+QbLinha  
      cQuery += " AND CNE_ITEMCT <> ' ' "+QbLinha  
      cQuery += " AND CNE_CLVL <> ' ' "+QbLinha  
   EndIf 

   cQuery += " AND CNE_QUANT > 0 "+QbLinha 
	
	MemoWrite("C:/ricardo/ValidaGrupoAprovacao_CNE.sql",cQuery)			     
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasCNE,.F.,.T.)
            
   DbSelectArea(cAliasCNE)
   (cAliasCNE)->(DbGoTop())
   Count To nQtdReg
   (cAliasCNE)->(DbGoTop())
            
   If nQtdReg > 0
		xCusto := Alltrim((cAliasCNE)->CNE_CC)
      xItemC := Alltrim((cAliasCNE)->CNE_ITEMCT)
      xClass := Alltrim((cAliasCNE)->CNE_CLVL)
   Else 
      aDadosCNZ := GetDadosCNZ(xFil,xNumCtr,xRevCtr,xNumMed)
      If Len(aDadosCNZ) > 0
         xCusto := aDadosCNZ[1]
         xItemC := aDadosCNZ[2]
         xClass := aDadosCNZ[3]
      EndIf
	EndIf  
   (cAliasCNE)->(DbCloseArea())
Return {xCusto,xItemC,xClass}

/*/{Protheus.doc} GetDadosCNZ
Busca dos dados para quando existir rateio.
@type function 
@author Ricardo Tavares Ferreira
@version 12.1.27
@return array, Array com os dados da entidade contabil.
@since 13/04/2022
@history 13/04/2022, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//=============================================================================================================================
    Static Function GetDadosCNZ(xFil,xNumCtr,xRevCtr,xNumMed)
//=============================================================================================================================

   Local xCusto      := ""
   Local xItemC      := ""
   Local xClass      := ""
	Local QbLinha		:= chr(13)+chr(10)
	Local cAliasCNZ	:= GetNextAlias()
	Local cQuery		:= ""
	Local nQtdReg  	:= 0

   cQuery := " SELECT TOP 1 "+QbLinha  
   cQuery += " CNZ_FILIAL "+QbLinha 
   cQuery += " , CNZ_CONTRA "+QbLinha 
   cQuery += " , CNZ_NUMMED "+QbLinha 
   cQuery += " , CNZ_REVISA "+QbLinha 

   If Alltrim(CN9->CN9_XGLOBA) == "N" .and. Alltrim(CND->CND_XEMPRE)+Alltrim(CND->CND_XFILIA) <> Alltrim(cEmpAnt)+Alltrim(CND->CND_FILIAL)
      cQuery += " ,CNZ_XCC CNZ_CC "+QbLinha  
      cQuery += " ,CNZ_XITEM CNZ_ITEMCT "+QbLinha  
      cQuery += " ,CNZ_XCLVL CNZ_CLVL "+QbLinha 
   Else
      cQuery += " ,CNZ_CC "+QbLinha  
      cQuery += " ,CNZ_ITEMCT "+QbLinha  
      cQuery += " ,CNZ_CLVL "+QbLinha  
   EndIf
   
   cQuery += " FROM "+QbLinha 
   cQuery +=   RetSqlName("CNZ") + " CNZ "+QbLinha
   cQuery += " WHERE "+QbLinha  
   cQuery += " CNZ.D_E_L_E_T_ = ' ' "+QbLinha  
   cQuery += " AND CNZ_CONTRA = '"+xNumCtr+"' "+QbLinha 
   cQuery += " AND CNZ_NUMMED = '"+xNumMed+"' "+QbLinha 
   cQuery += " AND CNZ_REVISA = '"+xRevCtr+"' "+QbLinha 
   cQuery += " AND CNZ_FILIAL = '"+xFil+"' "+QbLinha 

   If Alltrim(CN9->CN9_XGLOBA) == "N" .and. Alltrim(CND->CND_XEMPRE)+Alltrim(CND->CND_XFILIA) <> Alltrim(cEmpAnt)+Alltrim(CND->CND_FILIAL)
      cQuery += " AND CNZ_XCC <> ' ' "+QbLinha  
      cQuery += " AND CNZ_XITEM <> ' ' "+QbLinha  
      cQuery += " AND CNZ_XCLVL <> ' ' "+QbLinha 
   Else
      cQuery += " AND CNZ_CC <> ' ' "+QbLinha  
      cQuery += " AND CNZ_ITEMCT <> ' ' "+QbLinha  
      cQuery += " AND CNZ_CLVL <> ' ' "+QbLinha  
   EndIf
	
	MemoWrite("C:/ricardo/ValidaGrupoAprovacao_CNZ.sql",cQuery)			     
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasCNZ,.F.,.T.)
            
   DbSelectArea(cAliasCNZ)
   (cAliasCNZ)->(DbGoTop())
   Count To nQtdReg
   (cAliasCNZ)->(DbGoTop())
            
   If nQtdReg > 0
		xCusto := Alltrim((cAliasCNZ)->CNZ_CC)
      xItemC := Alltrim((cAliasCNZ)->CNZ_ITEMCT)
      xClass := Alltrim((cAliasCNZ)->CNZ_CLVL)
	EndIf  
   (cAliasCNZ)->(DbCloseArea())
Return {xCusto,xItemC,xClass}
