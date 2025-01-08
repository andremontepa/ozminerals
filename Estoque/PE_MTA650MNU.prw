#include "Protheus.Ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "parmtype.ch"
#include "totvs.ch"

/*/{Protheus.doc} MTA650MNU

	Rotina que é chamada pelo Ponto de entrada MA650MNU, 
	Tratamento do Custo em partes dentro do Sistema

	Localização  : Function MenuDef() - Responsável pelo menu Funcional.

	Em Que Ponto : Ponto de Entrada MA650MNU, utilizado para adicionar itens no 
				   menu  principal do fonte MATA650.
	
	Tdn : https://tdn.totvs.com/display/public/PROT/MA650BUT+-+Adiciona+itens+no+menu+principal+do+fonte+MATA650

@type function
@author Fabio Santos - CRM Service
@since 11/11/2023
@version P12
@database SQL SERVER 

@Obs

	Parametros:

	Se o parametro OZ_MA650MN estiver Habilitado, Será executado  criação ordem em Antas. 
	Portanto, recomendamos usa-lo em empresas que tenha processo de custeio neste modelo. 

@see MATA330
@see OZGENSQL
@see u_GeraOrdemProducaoAntas()

@nested-tags:Frameworks/OZminerals
/*/ 
User Function MTA650MNU()
	Local aArea             := {}  as array     
	Local lPermiteExecutar  := .F. as Logical

	lPermiteExecutar        := GetNewPar("OZ_MA650MN",.T.)

	Private cSintaxeRotina  := ""  as character

    aArea                   := GetArea()
	cSintaxeRotina          := ProcName(0)

	If ( !IsBlind() )
		If ( lPermiteExecutar )
			aAdd(aRotina, {"Gera OP Antas", "estoque.Producao.Custeio.u_GeraOrdemProducaoAntas( SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, SC2->C2_PRODUTO )" , 0, 2, Nil})
		EndIf
	EndIf

	RestArea( aArea )

Return 
