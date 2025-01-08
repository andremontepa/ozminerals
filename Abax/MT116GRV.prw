
/*/{Protheus.doc} MT116GRV
(Ponto de entrada para alterar variavel l116Auto para permitir criar interface do MATA116  )

@author Ábax Sistemas
@since 07/04/2019
@version 1.0

@return Sem retorno esperado

@example
(examples)

0@see (http://tdn.totvs.com/display/public/mp/MT116GRV)
/*/
/* Ponto de Entrada para preencher a Chave e o tipo do CTE antes da gravação do mesmo*/
User Function MT116GRV()
	
	Local	aAreaOld	:= GetArea()
	
	If Type('cCHVCTE') <> 'U'

		If Type('aNFeDanfe') <> 'U' 
			aNFeDanfe[13] := cCHVCTE
			aNFeDanfe[18] := cTipCTE
		Else
		 	M->F1_TPCTE	 := cTipCTE
		 	M->F1_CHVNFE := cCHVCTE
		Endif
	
	Endif
		
	RestArea(aAreaOld)                                                    	
	
		
Return
