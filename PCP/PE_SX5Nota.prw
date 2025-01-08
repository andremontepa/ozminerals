#include "Protheus.Ch"
#include "TbiConn.Ch"
#include "totvs.ch"
#include "ozminerals.ch"

#define  DOC_SERIE    "CST"

/*/{Protheus.doc} SX5NOTA

    Seleção Séries tabela 01 no faturamento para selecionar NF

    A finalidade do ponto de entrada SX5NOTA é permitir que o usuário faça uma validação 
    das séries das notas fiscais de saída que deseja considerar no momento da geração da NF.

    TDN : https://tdn.totvs.com/pages/releaseview.action?pageId=6784448   

@type function
@author Fabio Santos - CRM Service
@since 08/12/2023
@version P12
@database SQL SERVER 

@Obs

	Parametros:

	Se o parametro OZ_SX5NOTA estiver Habilitado, Ira inibir séries no faturamento
	Portanto, recomendamos usa-lo em empresas que tenha processo de custeio neste modelo. 

	No parametro OZ_LIBSER contem a serie que será desabilitada na nota fiscal
    Caso necessite colocar mais de uma SERIE incluir com barra "/".

@nested-tags:Frameworks/OZminerals
/*/ 
User Function SX5NOTA()
    Local lRetorno          := .T. as logical
	Local lPermiteExecutar  := .F. as logical 
    Local cSerieCpv         := ""  as character

    lRetorno                := .T.
    cSerieCpv               := GetNewPar("OZ_LIBSER",DOC_SERIE) 
	lPermiteExecutar        := GetNewPar("OZ_SX5NOTA",.T.)

    If ( lPermiteExecutar )
        If ( AllTrim( SX5->X5_CHAVE ) $ cSerieCpv )
            lRetorno := .F.
        EndIf
    EndIf

Return lRetorno
