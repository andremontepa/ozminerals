#include "Protheus.Ch"
#include "TbiConn.Ch"
#include "totvs.ch"
#include "ozminerals.ch"

#define  PRODUCAO         "1"
#define  TRANSFERENCIA    "2"
#define  BAIXA_REQUISICAO "3"
#define  VENDA_CPV        "4"

/*/{Protheus.doc} MTA650AE

	Ponto de entrada para Retornar Status da Tabela PAX/PAY

    Funções A650Deleta() e A650DelOp() Em Que Ponto: O P.E. MTA650AE é executado 
    após a exclusão da Op e está localizado na função A650Deleta (Deleta Ops).

    TDN : https://tdn.totvs.com/pages/releaseview.action?pageId=6089301

@type function
@author Fabio Santos - CRM Services 
@since  08/12/2023
@version P12
@database SQL SERVER 

@Obs

	Parametros:

	Se o parametro OZ_MT650EX estiver Habilitado, Será Executado o retorno do Status Tabela PAY/PAX
	Portanto, recomendamos usa-lo em empresas que tenha processo de custeio neste modelo. 

@see MATA650
@see OZGENSQL
@see u_ExcluiOrdemProducao()

@nested-tags:Frameworks/OZminerals
/*/ 
User Function MTA650AE()
	Local aArea            := {}  as array     
    Local cNumero          := ""  as character     
    Local cItem            := ""  as character     
    Local cSequencia       := ""  as character
	Local cOrdemProd       := ""  as character 
	Local cNumOrdemProd    := ""  as character 
	Local cCodFilial       := ""  as character     
	Local lPermiteExecutar := .F. as logical 

	aArea          		   := GetArea()
    cNumero                := PARAMIXB[1]
    cItem                  := PARAMIXB[2]
    cSequencia             := PARAMIXB[3]
	lPermiteExecutar       := GetNewPar("OZ_MT650EX",.T.)
	cNumOrdemProd          := cNumero+cItem+cSequencia
	cOrdemProd             := Posicione("PAY",5,SC2->C2_FILIAL + PAD(cNumOrdemProd,TAMSX3("PAY_OP")[1]) + PRODUCAO ,"PAY_OP")
	cCodFilial             := SC2->C2_FILIAL

	If ( !IsBlind() )
		If ( lPermiteExecutar )
			If !Empty(Alltrim(cOrdemProd)) 
				If ( FindFunction("estoque.Producao.Custeio.u_ExcluiOrdemProducao") )
					estoque.Producao.Custeio.u_ExcluiOrdemProducao(cOrdemProd,cCodFilial)
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea) 	
Return
