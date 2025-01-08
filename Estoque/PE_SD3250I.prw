#include 'Protheus.Ch'
#include "Protheus.Ch"
#include "TbiConn.Ch"
#include "totvs.ch"
#include "ozminerals.ch"

/*/{Protheus.doc} SD3250I

	Ponto de entrada para informções contabeis - OZminerals 
   
	Executado na função A250Atu(), rotina responsável pela atualização das tabelas 
	de apontamentos de produção simples.
	DESCRIÇÃO : Após atualização dos arquivos na rotina de produções. 
	Executa após atualizar SD3, SB2, SB3 e SC2.

	Tdn https://tdn.totvs.com/pages/releaseview.action?pageId=6087850

@type function
@author Fabio Santos - CRM Service
@since  08/10/2023
@version P12
@database SQL SERVER 

@Obs
	Parametro:

	Se o parametro OZ_PE250I estiver Habilitado, Será executado o ponto de entrada. 
	Portanto, recomendamos usa-lo em empresas que tenha processo neste modelo. 

@see MATA250
@see MATA680
@see u_GravaInformacaoContabil()

@nested-tags:Frameworks/OZminerals
/*/ 
User Function SD3250I()
	Local aArea                := {}  as array     
	Local cNumeroSequencia     := ""  as character
	Local lPermiteExecutar     := .F. as Logical

	aArea                      := GetArea()
	lPermiteExecutar           := GetNewPar("OZ_SD3250I",.T.)
	cNumeroSequencia           := SD3->D3_NUMSEQ
	
	If ( !IsBlind() )
		If ( lPermiteExecutar )
			If ( FindFunction("estoque.Producao.Custeio.u_GravaInformacaoContabil") )
				estoque.Producao.Custeio.u_GravaInformacaoContabil(cNumeroSequencia)
			EndIf
		EndIf
	EndIf

	RestArea( aArea )

Return nil  
