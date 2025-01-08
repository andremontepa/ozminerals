#Include "Protheus.ch"
#Include "Totvs.ch"
/*---------------------------------------------------------------------------------------------------------------------------*
 | P.E.:  FA080PCC                                                                                                            |
 | Autor: Stephen Noel - Equilibrio                                                                                          |
 | Data:  04/05/2023                                                                                                         |
 | Desc:  Ponto de entrada MVC na rotina manutenção contratos                                                                |
*---------------------------------------------------------------------------------------------------------------------------*/
User Function FA080PCC()

	Local aArea   := GetArea()
	Local nTotImp := 0
	//-------------------------------------------------
	// aParam [1] = Valor do PIS
	// aParam [2] = Valor do COFINS
	// aParam [3] = Valor do CSLL
	// aParam [4] = Valor do IRRF
	// aParam [5] = Valor do titulO
	//-------------------------------------------------
	If SE2->E2_TIPO <> 'PA'
		If NPIS+NCOFINS+NCSLL < 10 //Somente quando for menor que 10 reais, caso contrario ja traz automaticamente

			NPIS := SE2->E2_PIS
			NCOFINS := SE2->E2_COFINS
			NCSLL := SE2->E2_CSLL

			nTotImp := NTOTPIS+NTOTCOF+NTOTCSL
			NVALLIQ := NVALTOT - nTotImp

		EndIf
	EndIf

	RestArea(aArea)

Return
