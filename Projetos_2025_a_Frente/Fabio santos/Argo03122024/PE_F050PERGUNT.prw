#include "totvs.ch"
#include "Protheus.Ch"
#include "TbiConn.Ch"
#include "totvs.ch"
#include "ozminerals.ch"

/*/{Protheus.doc} F50PERGUNT - Manipula pergunta Execauto 

    Ponto de Entrada no Contas a Pagar, executado depois de carregar as perguntas do grupo FIN050 padrão.

@type function
@author Fabio Santos 
@since 22/09/2024
@version P12
@database SQL SERVER 

@Obs 
    Parametros:
    OZ_ADTPGT1 = 2 //Gerar Chq.p/Adiant. 1-Sim, 2-Não
    OZ_ADTPGT2 = 2 //Mov.Banc.sem Cheque 1-Sim, 2-Não

@nested-tags:Frameworks/OZminerals
/*/ 
User Function F50PERGUNT()
	Local aArea            := {}  as array     
	Local nGeraChequeAdt   := 0   as integer
	Local nMovtoBancario   := 0   as integer
	Local lPermiteExecutar := .F. as Logical

	nGeraChequeAdt         := GetNewPar("OZ_ADTPGT1",2) 
	nMovtoBancario         := GetNewPar("OZ_ADTPGT2",2) 
    aArea                  := GetArea()
	lPermiteExecutar       := GetNewPar("OZ_F050PGT",.T.)

	If ( lPermiteExecutar )
        If ( FWIsInCallStack("U_TGeraPA") .Or. FWIsInCallStack("U_VGERATIT")  )
            MV_PAR05 := nGeraChequeAdt
            MV_PAR09 := nMovtoBancario
        EndIf
    EndIf

    RestArea( aArea )

Return  

