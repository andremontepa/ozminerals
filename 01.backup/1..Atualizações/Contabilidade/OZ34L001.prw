/*/{Protheus.doc} OZ34L001
Rotina de 
@type function
@author Stephen
@since 30/08/2022
@version 12.1.33
@history 30/08/2022, Stephen, Construção Inicial
/*/
//=============================================================================================================================
    User Function OZ34L001()
//=============================================================================================================================

	Local nValLp:= 0
	If CT5->CT5_LANPAD == "650"

		If CT5->CT5_SEQUEN == "008"
			If SD1->D1_RATEIO<>"1" .AND.SD1->D1_TES<>"026"
				nValLp:= (SD1->(D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC-IF(SA2->A2_RECISS="N" .OR. SA2->A2_RECISS=" ",D1_VALISS,0)-IF(SD1->D1_VALIRR>0,D1_VALIRR,0)-D1_VALINS))
			Else
				nValLp:=0
			EndIf
	
		EndIf

	EndIf

Return nValLp
