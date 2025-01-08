#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CN121PED
CN121PED - Tratamento especifico antes da geração do Pedido de Compra ou de Venda.
@type function
@author Ricardo Tavares Ferreira
@since 25/04/2022
@obs Possibilita ao desenvolvedor realizar operações após o encerramento da medição.
Executado uma vez ao fim do encerramento ainda dentro da transação e mais uma vez após o fim da transação.
@version 12.1.33
@history 25/04/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    User Function CN121PED()
//=============================================================================================================================

    Local aCab     := PARAMIXB[1] 
    Local aItens   := PARAMIXB[2]
    Local oModel   := Nil
    Local lVenda   := .F.
    Local lCompra  := .F.
    Local nX       := 0
	Local aArea    := GetArea()
	Local cCC      := ""
	Local cItemcta := ""
	Local cClvl    := ""
	Local cGrupo   := ""
	Local cGrupo2  := ""
	Local cTpDBL   := Alltrim( SuperGetMV("OZ_TPDBL",,"C"))
	Local cGRPPad  := Alltrim( SuperGetMV("OZ_GRPAD",,"AVB990"))
    Local nPosObs  := 0
    Local cCodProd := ""

    If .not. (Empty(aCab) .Or. Empty(aItens))
        oModel  := FwModelActive()      
        lVenda  := Cn121RetSt("VENDA" ,0,/*cPlan*/,/*cContra*/,.T.,oModel) 
        lCompra := Cn121RetSt("COMPRA",0,/*cPlan*/,/*cContra*/,.T.,oModel)    

        If lCompra
            For nX := 1 to Len(aItens) 
                If nLin := aScan(aItens[nX],{|x|x[1]=="C7_CC"}) //> 0
                    cCC := aItens[nX][nLin][2]
                Endif 

                If nLin := aScan(aItens[nX],{|x|x[1]=="C7_ITEMCTA"}) //> 0
                    cItemcta := aItens[nX][nLin][2]
                Endif

                If nLin := aScan(aItens[nX],{|x|x[1]=="C7_CLVL"}) //> 0
                    cClvl := aItens[nX][nLin][2]
                Endif

                If Empty(cCC)
                    If CN9->CN9_XGLOBA == "N"
                        cQuery := " SELECT CNZ_CC,CNZ_ITEMCT,CNZ_CLVL FROM CNZ"+ CND->CND_XEMPRE + "0 CNZ "
                    Else
                        cQuery := " SELECT CNZ_CC,CNZ_ITEMCT,CNZ_CLVL FROM " + RetSqlName("CNZ")+ " CNZ "
                    EndIf
                    cQuery += " WHERE CNZ_CONTRA = '"+CN9->CN9_NUMERO+"' AND CNZ_ITEM = '01' AND CNZ_NUMMED = '"+ CND->CND_NUMMED +"' AND CNZ.D_E_L_E_T_ = ' ' "

                    If SELECT("TRACNZ") > 0
                        TRACNZ->(DbCloseArea())
                    Endif

                    dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery),"TRACNZ",.T.,.T.)
                    DbSelectArea("TRACNZ")
                    TRACNZ->(dbGoTop())
                    
                    cCC      := TRACNZ->CNZ_CC
                    cItemcta := TRACNZ->CNZ_ITEMCT
                    cClvl    := TRACNZ->CNZ_CLVL
                Endif
                
                cQuery := " SELECT TOP 1 A.AL_COD "
                cQuery += " FROM " 
                cQuery +=   RetSqlName("SAL")+ " A, " + RetSqlName("DBL")+ " B "
                cQuery += " WHERE B.D_E_L_E_T_ = '' "
                cQuery += " AND   B.DBL_FILIAL = A.AL_FILIAL "
                cQuery += " AND   B.DBL_GRUPO  = A.AL_COD "
                cQuery += " AND   B.DBL_CC = '"+cCC+"' "
                cQuery += " AND   B.DBL_ITEMCT = '"+cItemcta+"' "
                cQuery += " AND   B.DBL_CLVL = '"+cClvl+"' "
                cQuery += " AND   B.DBL_XTIPO = '"+cTpDBL+"'"
                cQuery += " AND   A.D_E_L_E_T_ = '' "
                cQuery += " AND   A.AL_DOCMD   = 'T' "

                If SELECT("TRADBL") > 0
                    TRADBL->(DbCloseArea())
                Endif

                dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery),"TRADBL",.T.,.T.)
                DbSelectArea("TRADBL")
                TRADBL->(dbGoTop())
                If .not. Empty(TRADBL->AL_COD)
                    cGrupo := Alltrim(TRADBL->AL_COD)
                    If nLin :=aScan(aItens[nX],{|x|x[1]=="C7_APROV"}) //> 0
                        aItens[nX][nLin][2] := cGrupo
                    Else
                        aAdd(aItens[nX],{"C7_APROV",cGrupo,nil})
                    EndIf
                Else 
                    cGrupo2 := cGRPPad
                    If nLin := aScan(aItens[nX],{|x|x[1]=="C7_APROV"}) //> 0
                        aItens[nX][nLin][2] := cGrupo2
                    Else
                        aAdd(aItens[nX],{"C7_APROV",cGrupo2,nil})
                    EndIf	
                Endif
                TRADBL->(DbCloseArea())
            Next

            DbSelectArea("SB1")
	        SB1->(DbSetOrder(1))

            For nX := 1 to Len(aItens)
                nPosObs := aScan(aItens[nX], {|aVal| Alltrim(aVal[1]) == "C7_XOBS"})
                If nPosObs <= 0
                    aadd(aItens[nX],{"C7_XOBS",CND->CND_OBS,Nil}) 
                EndIf

                If nLin := aScan(aItens[nX],{|x| x[1] == "C7_PRODUTO"}) //> 0
                    cCodProd  := aItens[nX][nLin][2]
                Endif  

                If SB1->(DbSeek(FWXFilial("SB1")+SubStr(cCodProd,1,TamSX3("B1_COD")[1])))   
                    aadd(aItens[nX],{"C7_XTPAPL",SB1->B1_XAPROPR,Nil})
                Endif
            Next nX 
        ElseIf lVenda
            // Tratar aqui quando o contrato de de venda.
        EndIf 
    EndIf
    RestArea(aArea)
Return {aCab,aItens}
