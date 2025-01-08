#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} MTALCPER
MTALCPER - Ponto para customizar a Al�adas em documentos que n�o controlam al�adas por padr�o.
@type function           
@author Ricardo Tavares Ferreira
@since 31/01/2022
@obs O ponto de entrada MTALCPER permite utilizar o controle de al�adas de forma customizada em documentos que n�o controlam al�ada por padr�o. 
Localiza��o: No momento da libera��o de documentos bloqueados por controle de al�ada.
Programa Fonte: MATA194; MATA197; MATXALC;
@link https://tdn.totvs.com/pages/releaseview.action?pageId=268571093
@version 12.1.27
@history 31/01/2022, Ricardo Tavares Ferreira, Constru��o Inicial
@return array, Retorna o ARRAY com os dados da Al�ada Customizada.
/*/
//=============================================================================================================================
    User Function MTALCPER()
//=============================================================================================================================

    Local aAlcada  := {}
    Local aArea    := GetArea()
    Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,"Salvar"},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
    Local aView    := {|| FWExecView("Solicita��o de Doa��es","OZ05A001",MODEL_OPERATION_VIEW,,{|| .T.},,100,aButtons)}

    If Alltrim(SCR->CR_TIPO) == "SD"
         aadd(aAlcada,{Alltrim(SCR->CR_TIPO),"SZE",2,"SZE->ZE_CODIGO",aView,{|| .T.},{"SZE->ZE_STATUS","3","4","2"}})
    EndIf 
    
    RestArea(aArea)
Return aAlcada 
