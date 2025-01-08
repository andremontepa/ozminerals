
user function M461LSF2()
local cProdNF := "12200"
Local cItemNF := "01"
Local cUFEmb  := "MA"
Local cLocEmb := "COMPLEXO PORTUARIO DE ITAQUI - AVENIDA DOS PORTUGUESES - MA"
local cFilSD2 := xFilial("SD2")
local cDoc := SF2->F2_DOC 
local cSerie := SF2->F2_SERIE
Local cESPEC := "SPED"
Local cCLIENT := SF2->F2_CLIENTE
Local cLOJA   := SF2->F2_LOJA
Local cINDDOC := "0"
Local cNUMDE  := SF2->F2_DOC
Local dDTDE   := dDataBase 
Local cNATEXP :=  "0"
Local cFILIAL := SF2->F2_FILIAL
Local cPais   := "161"


If SF2->F2_TIPOCLI == "X"

    DBSELECTAREA("SD2")
    SD2->(DbSetOrder(3)) 
    
    If SD2->( dbSeek(cFilSD2 + cDoc + cSerie ))
        cProdNF := SD2->D2_COD
        cItemNF := SD2->D2_ITEM
    EndIF

    RecLock('CDL', .T.)
        CDL_FILIAL := cFILIAL 
        CDL_DOC    := cDoc
        CDL_SERIE  := cSerie
        CDL_ESPEC  := cESPEC
        CDL_CLIENT := cCLIENT
        CDL_LOJA   := cLOJA
        CDL_INDDOC := cINDDOC
        CDL_NUMDE  := cNUMDE
        CDL_DTDE   := dDTDE
        CDL_NATEXP := cNATEXP
        CDL_PRODNF := cProdNF
        CDL_ITEMNF := cItemNF
        CDL_UFEMB  := cUFEmb
        CDL_LOCEMB := cLocEmb
        CDL_PAIS   := cPais
    CDL->(MsUnlock())

EndIf
return
