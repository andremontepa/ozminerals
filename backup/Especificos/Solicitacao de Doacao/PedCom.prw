#INCLUDE "rwmake.ch"

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | PedCom.prw       | AUTOR | ISMAEL JUNIOR |DATA | 14/02/2019   |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - PedCom()                                               |//
//|           |                                                                 |//
//|           | Visualização dos documento no banco de conhecimento na rotina   |//
//|           | de Liberação de Documentos                                      |//
//+-----------------------------------------------------------------------------+//
//| MANUTENCAO DESDE SUA CRIACAO                                                |//
//+-----------------------------------------------------------------------------+//
//| DATA     | AUTOR                | DESCRICAO                                 |//
//+-----------------------------------------------------------------------------+//
//|          |                      |                                           |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

User Function PedCom(cPedido,cTipo)
Local cExprFilTop  := ""
Local cTabela := "" 
Private cCadastro := "Conhecimento"
Private aRotina := { {"Conhecimento","MsDocument",0,4} }

Private cDelFunc := ".T." 
Private bFiltraBrw   := { || .F. } 
	If cTipo $ "IP#PC"  // Filtro para pedido de compra
		cTabela := "SC7"
	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	SC7->(DbSeek(XFILIAL("SC7")+Alltrim(cPedido)))
		If Empty(SC7->C7_MEDICAO) .AND. Empty(SC7->C7_CONTRA)
			
	        cExprFilTop    := "C7_NUM "
	        cExprFilTop    += "IN "
	        cExprFilTop    += "("
	        cExprFilTop    += "SELECT "
	        cExprFilTop    +=         "SC7.C7_NUM "
	        cExprFilTop    += "FROM "
	        cExprFilTop    +=         RetSqlName( "SC7" ) + " SC7 "
	        cExprFilTop    += "WHERE "
	        cExprFilTop    +=         "SC7.D_E_L_E_T_<>'*' "
	        cExprFilTop    +=    " AND "
	        cExprFilTop    +=         "SC7.C7_FILIAL='" + xFilial( "SC7" ) + "'"
	        cExprFilTop    +=    " AND "
	        cExprFilTop    +=         "SC7.C7_NUM='"+ Alltrim(cPedido) + "' "
	        cExprFilTop    += ")"
		Else
			cTabela := "CND"
	        cExprFilTop    := "CND_PEDIDO "
	        cExprFilTop    += "IN "
	        cExprFilTop    += "("
	        cExprFilTop    += "SELECT "
	        cExprFilTop    +=         "CND.CND_PEDIDO "
	        cExprFilTop    += "FROM "
	        cExprFilTop    +=         RetSqlName( "CND" ) + " CND "
	        cExprFilTop    += "WHERE "
	        cExprFilTop    +=         "CND.D_E_L_E_T_<>'*' "
	        cExprFilTop    +=    " AND "
	        cExprFilTop    +=         "CND.CND_FILIAL='" + xFilial( "CND" ) + "'"
	        cExprFilTop    +=    " AND "
	        cExprFilTop    +=         "CND.CND_PEDIDO='"+ Alltrim(cPedido) + "' "
	        cExprFilTop    += ")"		   
		
		Endif	        
	Elseif cTipo = "SC" //Filtro para solictação de compras
		cTabela := "SC1"
        cExprFilTop    := "C1_NUM "
        cExprFilTop    += "IN "
        cExprFilTop    += "("
        cExprFilTop    += "SELECT "
        cExprFilTop    +=         "SC1.C1_NUM "
        cExprFilTop    += "FROM "
        cExprFilTop    +=         RetSqlName( "SC1" ) + " SC1 "
        cExprFilTop    += "WHERE "
        cExprFilTop    +=         "SC1.D_E_L_E_T_<>'*' "
        cExprFilTop    +=    " AND "
        cExprFilTop    +=         "SC1.C1_FILIAL='" + xFilial( "SC1" ) + "'"
        cExprFilTop    +=    " AND "
        cExprFilTop    +=         "SC1.C1_NUM='"+ Alltrim(cPedido) + "' "
        cExprFilTop    += ")"	
	Elseif cTipo $ 'IC#IR#CT#RV' //Filtro para planilha de contratos
		cTabela := "CN9"
        cExprFilTop    := "CN9_NUMERO "
        cExprFilTop    += "IN "
        cExprFilTop    += "("
        cExprFilTop    += "SELECT "
        cExprFilTop    +=         "CN9.CN9_NUMERO "
        cExprFilTop    += "FROM "
        cExprFilTop    +=         RetSqlName( "CN9" ) + " CN9 "
        cExprFilTop    += "WHERE "
        cExprFilTop    +=         "CN9.D_E_L_E_T_<>'*' "
        cExprFilTop    +=    " AND "
        cExprFilTop    +=         "CN9.CN9_FILIAL='" + xFilial( "CN9" ) + "'"
        cExprFilTop    +=    " AND "
        cExprFilTop    +=         "CN9.CN9_NUMERO='"+ Alltrim(substr(cPedido,0,15)) + "' "
        cExprFilTop    += ")" 
        /*----------------- 
        Lucas Costa - STARSOFT INFORMÁTICA LTDA - 27/04/2021 
        Tratariva para agregar os anexos das Notas Fiscais para a rotina de liberação de documentos
        Chamado 4386
        *///-----------------
        Elseif cTipo = 'NF' //Filtro para Nota Fiscal
		cTabela := "SF1"
        cExprFilTop    := "F1_DOC "
        cExprFilTop    += "IN "
        cExprFilTop    += "("
        cExprFilTop    += "SELECT "
        cExprFilTop    +=         "SF1.F1_DOC "
        cExprFilTop    += "FROM "
        cExprFilTop    +=         RetSqlName( "SF1" ) + " SF1 "
        cExprFilTop    += "WHERE "
        cExprFilTop    +=         "SF1.D_E_L_E_T_<>'*' "
        cExprFilTop    +=    " AND "
        cExprFilTop    +=         "SF1.F1_FILIAL='" + xFilial( "SF1" ) + "'"
        cExprFilTop    +=    " AND "
        cExprFilTop    +=         "SF1.F1_DOC='"+ Alltrim(substr(cPedido,0,9)) + "' "
        cExprFilTop    += ")" 
	Elseif cTipo $ 'IM#MD' //Filtro para planilha de contratos
		cTabela := "CND"
        cExprFilTop    := "CND_PEDIDO "
        cExprFilTop    += "IN "
        cExprFilTop    += "("
        cExprFilTop    += "SELECT "
        cExprFilTop    +=         "CND.CND_PEDIDO "
        cExprFilTop    += "FROM "
        cExprFilTop    +=         RetSqlName( "CND" ) + " CND "
        cExprFilTop    += "WHERE "
        cExprFilTop    +=         "CND.D_E_L_E_T_<>'*' "
        cExprFilTop    +=    " AND "
        cExprFilTop    +=         "CND.CND_FILIAL='" + xFilial( "CND" ) + "'"
        cExprFilTop    +=    " AND "
        cExprFilTop    +=         "CND.CND_PEDIDO='"+ Alltrim(cPedido) + "' "
        cExprFilTop    += ")"
    Elseif Alltrim(cTipo) == "SD" //Filtro para planilha de contratos
		cTabela := "SZE"
        cExprFilTop    := "ZE_CODIGO "
        cExprFilTop    += "IN "
        cExprFilTop    += "("
        cExprFilTop    += "SELECT "
        cExprFilTop    +=         "SZE.ZE_CODIGO "
        cExprFilTop    += "FROM "
        cExprFilTop    +=         RetSqlName( "SZE" ) + " SZE "
        cExprFilTop    += "WHERE "
        cExprFilTop    +=         "SZE.D_E_L_E_T_ = ' ' "
        cExprFilTop    +=    " AND "
        cExprFilTop    +=         "SZE.ZE_FILIAL = '" + xFilial( "SZE" ) + "'"
        cExprFilTop    +=    " AND "
        cExprFilTop    +=         "SZE.ZE_CODIGO = '"+ Alltrim(cPedido) + "' "
        cExprFilTop    += ")"
	Else
		cTabela := "SC7"
        cExprFilTop    := "C7_NUM "
        cExprFilTop    += "IN "
        cExprFilTop    += "("
        cExprFilTop    += "SELECT "
        cExprFilTop    +=         "SC7.C7_NUM "
        cExprFilTop    += "FROM "
        cExprFilTop    +=         RetSqlName( "SC7" ) + " SC7 "
        cExprFilTop    += "WHERE "
        cExprFilTop    +=         "SC7.D_E_L_E_T_<>'*' "
        cExprFilTop    +=    " AND "
        cExprFilTop    +=         "SC7.C7_FILIAL='" + xFilial( "SC7" ) + "'"
        cExprFilTop    +=    " AND "
        cExprFilTop    +=         "SC7.C7_NUM='"+ Alltrim(cPedido) + "' "
        cExprFilTop    += ")"	                	
	Endif		
MBrowse(6,1,22,75,cTabela,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,cExprFilTop)

Return   

