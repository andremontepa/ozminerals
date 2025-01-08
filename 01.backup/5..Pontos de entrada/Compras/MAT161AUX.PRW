#INCLUDE "PROTHEUS.ch"

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | MAT161AUX.prw      | AUTOR | ISMAEL JUNIOR |DATA | 14/02/2019   |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - MAT161AUX()                                            |//
//|           |                                                                 |//
//|           | Visualização dos documento no banco de conhecimento do pedido   |//
//|           | de compra                                                       |//
//+-----------------------------------------------------------------------------+//
//| MANUTENCAO DESDE SUA CRIACAO                                                |//
//+-----------------------------------------------------------------------------+//
//| DATA     | AUTOR                | DESCRICAO                                 |//
//+-----------------------------------------------------------------------------+//
//|          |                      |                                           |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

User Function MAT161AUX(cCotacao)
Local cExprFilTop  := ""
Local cTabela := "" 
Private cCadastro := "Cotação"
Private aRotina := { {"Cotação","A161MAPCOT()",0,2} }

Private cDelFunc := ".T." 
Private bFiltraBrw   := { || .F. } 
			 // Filtro para pedido de compra
			cTabela := "SC8" 
	        cExprFilTop    := "C8_NUM "
	        cExprFilTop    += "IN "
	        cExprFilTop    += "("
	        cExprFilTop    += "SELECT "
	        cExprFilTop    +=         "SC8.C8_NUM "
	        cExprFilTop    += "FROM "
	        cExprFilTop    +=         RetSqlName( "SC8" ) + " SC8 "
	        cExprFilTop    += "WHERE "
	        cExprFilTop    +=         "SC8.D_E_L_E_T_<>'*' "
	        cExprFilTop    +=    " AND "
	        cExprFilTop    +=         "SC8.C8_FILIAL='" + xFilial( "SC8" ) + "'"
	        cExprFilTop    +=    " AND "
	        cExprFilTop    +=         "SC8.C8_NUM='"+ Alltrim(cCotacao) + "' "
	        cExprFilTop    += ")"

MBrowse(6,1,22,75,cTabela,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,cExprFilTop)

Return   
