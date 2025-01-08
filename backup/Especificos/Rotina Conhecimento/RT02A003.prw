#include "prtopdef.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include 'parmtype.ch'
#include 'FWMVCDef.ch'

/*/{Protheus.doc} RT02A003
RT02A003 - Rotina que gera o botão de inclusao dos documentos
@type function
@author Ricardo Tavares Ferreira
@since 21/09/2021
@version 12.1.25
@history 21/09/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    User Function RT02A003(cTipo)
//====================================================================================================

	Local cQuery		:= ""
	Local QbLinha		:= chr(13)+chr(10)
    Local cAliasAC9 	:= GetNextAlias()
    Local nQtdReg   	:= 0

    If cTipo == "SC"
        MsDocument("SC1",SC1->(RecNo()),4)
    Else 
        MsDocument("SC7",SC7->(RecNo()),4)
    EndIf

    cQuery := " SELECT AC9.* "+QbLinha 
    
	cQuery += " FROM "
	cQuery +=   RetSqlName("AC9") + " AC9 "+QbLinha

	cQuery += " INNER JOIN "
	cQuery +=   RetSqlName("ACB") + " ACB "+QbLinha
    cQuery += " ON AC9_FILIAL = ACB_FILIAL "+QbLinha
    cQuery += " AND AC9_CODOBJ = ACB_CODOBJ "+QbLinha
    cQuery += " AND ACB.D_E_L_E_T_ = ' ' "+QbLinha

    cQuery += " WHERE "+QbLinha 
    cQuery += " AC9.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND AC9_FILIAL = '"+FWXfilial("AC9")+"' "+QbLinha

    If cTipo == "SC"
        cQuery += " AND AC9_ENTIDA = 'SC1' "+QbLinha
        cQuery += " AND SUBSTRING(AC9_CODENT,1,2) = '"+cFilAnt+"' "+QbLinha
        cQuery += " AND SUBSTRING(AC9_CODENT,3,6) = '"+Alltrim(SC1->C1_NUM)+"' "+QbLinha
    Else 
        cQuery += " AND AC9_ENTIDA = 'SC7' "+QbLinha
        cQuery += " AND SUBSTRING(AC9_CODENT,1,2) = '"+cFilAnt+"' "+QbLinha
        cQuery += " AND SUBSTRING(AC9_CODENT,3,6) = '"+Alltrim(SC7->C7_NUM)+"' "+QbLinha
    EndIf

    MemoWrite("C:/ricardo/RT02A003.sql",cQuery)			     
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasAC9,.F.,.T.)
            
    DbSelectArea(cAliasAC9)
    (cAliasAC9)->(DbGoTop())
    Count To nQtdReg
    (cAliasAC9)->(DbGoTop())
    /*        
    If nQtdReg <= 0
		(cAliasAC9)->(DbCloseArea())
	Else
        If cTipo == "SC"
            While .not. (cAliasAC9)->(Eof())
                If Alltrim((cAliasAC9)->AC9_XDTALT) <> Dtos(Date()) .or. Alltrim((cAliasAC9)->AC9_XHRALT) <> Time()
                    If Empty(Alltrim((cAliasAC9)->AC9_XDTALT)) .or. Empty(Alltrim((cAliasAC9)->AC9_XHRALT))
                        If Dtos(SC1->C1_EMISSAO) <> Alltrim((cAliasAC9)->AC9_XDTINC)
                            If CriaAprov(AllTrim(SC1->C1_FILIAL),AllTrim(SC1->C1_NUM),"SC")
                                AtualizaDoc("SC")
                            EndIf
                            Exit
                        EndIf
                    Else 
                        If CriaAprov(AllTrim(SC1->C1_FILIAL),AllTrim(SC1->C1_NUM),"SC")
                            AtualizaDoc("SC")
                        EndIf 
                        Exit
                    EndIf 
                EndIf 
                (cAliasAC9)->(DbSkip())
            End
        Else 
            While .not. (cAliasAC9)->(Eof())
                If Alltrim((cAliasAC9)->AC9_XDTALT) <> Dtos(Date()) .or. Alltrim((cAliasAC9)->AC9_XHRALT) <> Time()
                    If Empty(Alltrim((cAliasAC9)->AC9_XDTALT)) .or. Empty(Alltrim((cAliasAC9)->AC9_XHRALT))
                        If Dtos(SC7->C7_EMISSAO) <> Alltrim((cAliasAC9)->AC9_XDTINC)
                            If CriaAprov(AllTrim(SC7->C7_FILIAL),AllTrim(SC7->C7_NUM),"PC")
                                AtualizaDoc("PC")
                            EndIf
                            Exit
                        EndIf
                    Else 
                        If CriaAprov(AllTrim(SC7->C7_FILIAL),AllTrim(SC7->C7_NUM),"PC")
                            AtualizaDoc("PC")
                        EndIf 
                        Exit
                    EndIf 
                EndIf 
                (cAliasAC9)->(DbSkip())
            End
        EndIf 
        (cAliasAC9)->(DbCloseArea())
    EndIf*/
Return Nil 
