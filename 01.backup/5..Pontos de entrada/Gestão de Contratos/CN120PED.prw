#INCLUDE "Rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCN120PED  บAutor  ณ Ismael Junior      บ Data ณ  18/03/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada apos a gravacao do Pedido de compras pela บฑฑ
ฑฑบ          ณ Rotina Automatica em CN120GrvPeD. Sera utilizado Gravar    บฑฑ  
ฑฑบ          ณ informacoes Adicionais ao Pedido de Compras                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ TOTVS STARSOFT                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function CN120PED()                           
	Local aCab     := PARAMIXB[1]
	Local aItm     := PARAMIXB[2]
	Local aArea    := GetArea()
	Local cCC      := ""
	Local cItemcta := ""
	Local cClvl    := ""
	Local cGrupo   := ""
	Local Nx       := 0
	Local cGrupo2  := ""
//	Local dDtEmis  := aCab[aScan(aCab,{|x|x[1]=="C7_EMISSAO"})][2]
//	Local dLimite  := GetNewPar("MV_DTNEWGR",CTOD("13/04/2021"))    // Novos grupos a partir desta data 
//	Local cTipo    := If(dDtEmis<dLimite,"A","B")
	Local cTpDBL   := Alltrim( SuperGetMV("OZ_TPDBL",,"C") )
	Local cGRPPad  := Alltrim( SuperGetMV("OZ_GRPAD",,"AVB990") )
	
	//-
	//- Toni Aguiar - TOTVS STARSOFT em 10/04/2021
	//- Nova condi็ใo: A partir de 13/04/2021, as seguintes regras foram 
	//- aplicadas a regras para sele็ใo de grupos de aprova็ใo automแtica:
	//- . Antes de 13/04/2021 usaremos os grupos do TIPO A
	//- . A partir de 13/04/2021, usaremos os grupos do tipo B
	//- . Informa็ใo contida na variแvel cTipo
    //-
	 
	For Nx:=1 to Len(aItm) 
		If (nLin :=aScan(aItm[Nx],{|x|x[1]=="C7_CC"})) //>0
			cCC  := aItm[Nx][nLin][2]
		Endif 
		If (nLin :=aScan(aItm[Nx],{|x|x[1]=="C7_ITEMCTA"})) //>0
			cItemcta := aItm[Nx][nLin][2]
		Endif
		If (nLin :=aScan(aItm[Nx],{|x|x[1]=="C7_CLVL"})) //>0
			cClvl    := aItm[Nx][nLin][2]
		Endif
		If Empty(cCC)
			If CN9->CN9_XGLOBA == "N"
				cQuery := " SELECT CNZ_CC,CNZ_ITEMCT,CNZ_CLVL FROM CNZ"+ CND->CND_XEMPRE + "0 CNZ "
			Else
				cQuery := " SELECT CNZ_CC,CNZ_ITEMCT,CNZ_CLVL FROM " + RetSqlName("CNZ")+ " CNZ "
			EndIf
			cQuery += " WHERE CNZ_CONTRA = '"+CN9->CN9_NUMERO+"' AND CNZ_ITEM = '01' AND CNZ_NUMMED = '"+ CND->CND_NUMMED +"' AND CNZ.D_E_L_E_T_ != '*' "

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
		If !Empty(TRADBL->AL_COD)
			cGrupo := TRADBL->AL_COD
			If (nLin :=aScan(aItm[Nx],{|x|x[1]=="C7_APROV"})) //>0
				aItm[Nx][nLin][2] := cGrupo
			Else
				aAdd(aItm[Nx],{"C7_APROV",cGrupo,nil})
			EndIf
		Else 
			cGrupo2 := cGRPPad
			If (nLin :=aScan(aItm[Nx],{|x|x[1]=="C7_APROV"})) //>0
				aItm[Nx][nLin][2] := cGrupo2
			Else
				aAdd(aItm[Nx],{"C7_APROV",cGrupo2,nil})
			EndIf	
		Endif
		TRADBL->(DbCloseArea())
	Next
	RestArea(aArea)
Return{aCab,aItm}
