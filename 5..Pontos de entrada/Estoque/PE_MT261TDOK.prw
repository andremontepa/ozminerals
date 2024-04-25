#include "Protheus.Ch"
#include "TbiConn.Ch"
#include "totvs.ch"
#include "ozminerals.ch"

/*/{Protheus.doc} MT261TDOK

	Ponto de entrada para gravr as contas contabeis na origem - OZminerals 
   
	Localização : Está localizado na função a261Grava.Quando: O ponto é chamado no final da função após 
                  a gravação.Finalidade: Efetuar Customizações após a gravação da Transferencia Mod. II

    Tdn https://tdn.totvs.com/pages/releaseview.action?pageId=6087931

@type function
@author Fabio Santos - CRM Services 
@since  05/11/2023
@version P12
@database SQL SERVER 

@Obs

	Parametros:

	Se o parametro OZ_MT261TD estiver Habilitado, Será gravado as contas contabeis para as Transferencia de Armazen. 
	Portanto, recomendamos usa-lo em empresas que tenha processo de custeio neste modelo. 

@see MATA261
@see OZGENSQL
@see u_GravaCtaContabilTranferenciaArmazen()

@nested-tags:Frameworks/OZminerals
/*/ 
User Function MT261TDOK()
	Local aArea                := {}  as array     
	Local cNumeroSequencia     := ""  as character
    Local cCodigoProduto       := ""  as character
	Local lPermiteExecutar     := .F. as Logical

    aArea                      := GetArea()
	lPermiteExecutar           := GetNewPar("OZ_MT261TD",.F.)
	cNumeroSequencia           := SD3->D3_NUMSEQ
    cCodigoProduto             := SD3->D3_COD

	If ( !IsBlind() )
		If ( lPermiteExecutar )
			If ( FindFunction("estoque.Producao.Custeio.u_GravaCtaContabilTranferenciaArmazen") )
				estoque.Producao.Custeio.u_GravaCtaContabilTranferenciaArmazen(cNumeroSequencia, cCodigoProduto)
			EndIf
		EndIf
	EndIf

	RestArea( aArea )
Return 
