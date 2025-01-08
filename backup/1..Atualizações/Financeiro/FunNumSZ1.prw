#Include 'Totvs.ch'
#Include 'Protheus.ch'         
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FunNumSZ1  ºAutor  ³Leonardo Medeiros   º Data ³  02/07/21  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Rotina de Provisão                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


user function FUNNUMSZ1() 

	Local cQuery	:= ""
	Local QbLinha	:= chr(13)+chr(10)
	Local cAliasY1	:= GetNextAlias()
    local Cnum  := ""

	cQuery := " SELECT MAX(Z1_CODIGO) Z1_CODIGO "+QbLinha
	cQuery += " FROM "
	cQuery +=   RetSqlName("SZ1") + " SZ1 "+QbLinha
	cQuery += " WHERE "+QbLinha 
	cQuery += " SZ1.D_E_L_E_T_ = ' ' "+QbLinha 
	cQuery += " AND SZ1.Z1_FILIAL = '"+FWxFilial("SZ1")+"' "+QbLinha
	
   MemoWrite("C:/ricardo/funNumSZ1.sql",cQuery)	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasY1,.F.,.T.)
		
	DbSelectArea(cAliasY1)
	(cAliasY1)->(DbGoTop())
	Count To nQtdReg
	(cAliasY1)->(DbGoTop())
		
	If nQtdReg <= 0
		(cAliasY1)->(DbCloseArea())
	Else
		While .not. (cAliasY1)->(Eof())
			cnum := strzERo(val((cAliasY1)->Z1_CODIGO) + 1,9)
			(cAliasY1)->(DbSkip())
		End
		(cAliasY1)->(DbCloseArea())
	EndIf
retuRn cnum
