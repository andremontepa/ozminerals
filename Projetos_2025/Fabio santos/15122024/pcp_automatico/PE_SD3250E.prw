#include 'Protheus.Ch'
#include "Protheus.Ch"
#include "TbiConn.Ch"
#include "totvs.ch"
#include "ozminerals.ch"

#define  PRODUCAO         "1"
#define  TRANSFERENCIA    "2"
#define  BAIXA_REQUISICAO "3"
#define  VENDA_CPV        "4"

/*/{Protheus.doc} SD3250E

	Ponto de entrada para Retornar Status da Tabela PAX/PAY

    Executado na função A250DesAtu(), rotina responsável por estornar a atualização das 
    tabelas de apontamentos de produção simples.
    Executado após atualização dos arquivos no processamento do estorno das atualizações.

    TDN: https://tdn.totvs.com/pages/releaseview.action?pageId=6087849

@type function
@author Fabio Santos - CRM Service
@since  08/10/2023
@version P12
@database SQL SERVER 

@Obs
	Parametro:

	Se o parametro OZ_SD3250E estiver Habilitado, Será executado o ponto de entrada. 
	Portanto, recomendamos usa-lo em empresas que tenha processo neste modelo. 

@see MATA250
@see u_EstornaApontamentoProducao()

@nested-tags:Frameworks/OZminerals
/*/ 
User Function SD3250E()
	Local aArea            := {}  as array     
	Local cOrdemProd       := ""  as character
	Local cCodFilial       := ""  as character

	Local lPermiteExecutar := .F. as Logical

	aArea              	   := GetArea()

	lPermiteExecutar       := GetNewPar("OZ_SD3250E",.T.)
	cOrdemProd             := Posicione("PAY",5,SD3->D3_FILIAL + SD3->D3_OP + PRODUCAO ,"PAY_OP")
	cCodFilial             := SD3->D3_FILIAL

	If ( !IsBlind() )
		If ( lPermiteExecutar )
			If !Empty(Alltrim(cOrdemProd))	
				If ( FindFunction("estoque.Producao.Custeio.u_EstornaApontamentoProducao") )
					estoque.Producao.Custeio.u_EstornaApontamentoProducao(cOrdemProd,cCodFilial)
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea) 	

Return nil  
