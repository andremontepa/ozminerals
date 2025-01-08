#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "fileio.ch"

/*/{Protheus.doc} MT120FIM
MT120FIM - Ponto de entrada executado no final da gravação do pedido de compras.
@type class 
@author Ricardo Tavares Ferreira
@since 13/10/2021
@version 12.1.27
@obs LOCALIZAÇÃO: O ponto se encontra no final da função A120PEDIDO
EM QUE PONTO: Após a restauração do filtro da FilBrowse depois de fechar a operação realizada no pedido de compras, 
é a ultima instrução da função A120Pedido.
@link https://tdn.totvs.com/display/public/PROT/MT120FIM
@history 11/10/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    User Function MT120FIM()
//=============================================================================================================================

    Local aArea := GetArea()
    Local nOpcao := PARAMIXB[1]   // Opção Escolhida pelo usuario 
    Local cNumPC := PARAMIXB[2]   // Numero do Pedido de Compras
    Local nOpcA  := PARAMIXB[3]   // Indica se a ação foi Cancelada = 0  ou Confirmada = 1
	Local nTotal := GetTotal(cNumPC)
	
	If .not. FWIsInCallStack("MATA094")
		If .not. FWIsInCallStack("CNTA120")
			If Type("__aExcSet__") == "A"
				APIUtil():GrvSC7(PARAMIXB[1],PARAMIXB[2],PARAMIXB[3])
			EndIf
		EndIf

		if SubStr(Alltrim(cNumPC), 1, 1) == "N" .and. FWIsInCallStack("U_IACOMP03") .and. (nOpcao == 3 .or. nOpcao == 4)
			AVBUtil():DeletaGrupoAprovacao(FWXFilial("SC7"),Alltrim(cNumPC),"PC")
			SC7->(MsSeek(FWXFilial("SC7")+cNumPC))
			AVBUtil():TrocaGrupoAprovacao("SC7",Alltrim(cNumPC),Alltrim(SC7->C7_CLVL),Date(),nTotal,AllTrim(SC7->C7_APROV))
		ElseIf nOpcA == 1 .and. (nOpcao == 3 .or. nOpcao == 4)
			AVBUtil():DeletaGrupoAprovacao(FWXFilial("SC7"),Alltrim(cNumPC),"PC")
			AVBUtil():TrocaGrupoAprovacao("SC7",Alltrim(cNumPC),Alltrim(SC7->C7_CLVL),Date(),nTotal,AllTrim(SC7->C7_APROV))
		EndIf 
	EndIf
    RestArea(aArea)
Return Nil 

/*/{Protheus.doc} GetTotal
Retorna o total do pedido de compra.
@type class 
@author Ricardo Tavares Ferreira
@since 13/10/2021
@version 12.1.27
@obs LOCALIZAÇÃO: O ponto se encontra no final da função A120PEDIDO
EM QUE PONTO: Após a restauração do filtro da FilBrowse depois de fechar a operação realizada no pedido de compras, 
é a ultima instrução da função A120Pedido.
@link https://tdn.totvs.com/display/public/PROT/MT120FIM
@history 11/10/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Static Function  GetTotal(cNumPC)
//=============================================================================================================================

	Local nTotal 	:= 1
    Local cQuery	:= ""
	Local QbLinha	:= chr(13)+chr(10)
	Local nQtdReg	:= 0
    Local cAliC5ITE := GetNextAlias()

	cQuery := " SELECT SUM(C7_TOTAL) TOTAL "+QbLinha
	cQuery += " FROM " 
	cQuery +=   RetSqlName("SC7")+ " SC7 "+QbLinha
	cQuery += " WHERE SC7.D_E_L_E_T_ = ' ' "+QbLinha
	cQuery += " AND C7_FILIAL = '"+FWXFilial("SC7")+"' "+QbLinha
	cQuery += " AND C7_NUM = '"+cNumPC+"' "+QbLinha

    MemoWrite("C:/ricardo/MT120FIM_GetTotal.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliC5ITE,.F.,.T.)
		
	DbSelectArea(cAliC5ITE)
	(cAliC5ITE)->(DbGoTop())
	Count TO nQtdReg
	(cAliC5ITE)->(DbGoTop())
		
	If nQtdReg <= 0
        (cAliC5ITE)->(DbCloseArea())
		Return nTotal
	Else 
		nTotal := (cAliC5ITE)->TOTAL
    EndIf 
    (cAliC5ITE)->(DbCloseArea())
Return nTotal
