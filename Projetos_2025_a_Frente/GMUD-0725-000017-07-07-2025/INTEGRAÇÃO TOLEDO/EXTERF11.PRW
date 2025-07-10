#Include "Protheus.ch"
#Include "RwMake.ch"

/*/{Protheus.doc} EXTERF11
Função para destravar o SX5 e o parametro MV_NUMITEM. 
Essa função foi criada porque a rotina MaPvlNfs não está destravando.

@author Julio Martins
@Junho  /2025
/*/

User Function EXTERF11(c_SerDoc,a_Recnos)

Local _aArea := GetArea()
Local _aAreaSX5 := SX5->(GetArea())
Local _cFilSx5 := xFilial("SX5")
Local _nCount1 := 0
Local _nCount2 := 0
//Local lVldF11  := SuperGetMV("MV_XVLDF11",,".T.")

Default c_SerDoc := ""
Default 	 := {}

MsUnlockAll()
DBCommitAll()

SX5->( dbCloseArea() )
dbSelectArea("SX5")

SX6->( dbCloseArea() )
dbSelectArea("SX6")


If ExistBlock("CHGX5FIL")
	_cFilSx5 := ExecBlock("CHGX5FIL",.f.,.f.)
EndIf

// Destrava SX5
DbSelectArea("SX5")
SX5->(dbSetOrder(1))
If SX5->(DbSeek(_cFilSx5+PadR("01",TamSx3("X5_TABELA")[1])+c_SerDoc))
	SX5->(MsUnLock())
EndIf

// Destrava o parametro
If GetMv("MV_NUMITEN",.T.)
	SX6->(MsUnLock())
EndIf

// Destrava registros utilizados na geração de nota
For _nCount1 := 1 To Len(a_Recnos)
	For _nCount2 := 1 To Len(a_Recnos[_nCount1])
		if ! empty( a_Recnos[_nCount1][_nCount2][1] ) .and. select( a_Recnos[_nCount1][_nCount2][1] ) > 0 .and. a_Recnos[_nCount1][_nCount2][2] > 0
			(a_Recnos[_nCount1][_nCount2][1])->(DbGoTo(a_Recnos[_nCount1][_nCount2][2]))
			If (a_Recnos[_nCount1][_nCount2][1])->(!Eof())
				(a_Recnos[_nCount1][_nCount2][1])->(MsUnLock())
			EndIf
		EndIf
	Next
Next

RestArea(_aAreaSX5)
RestArea(_aArea)

Return 
