#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CNT121BT
CNT121BT - Adicionar botões ao menu principal 
@type function
@author Ricardo Tavares Ferreira
@since 07/03/2022
@obs Ponto de entrada tem por objetivo permitir adicionar botões do usuário ao menu principal da rotina de medições. 
A variável aRotina é private neste momento, possibilitando adicionar mais botões a rotina
Este ponto de entrada irá substituir o PE CTA120MNU da rotina de medições nas versões anteriores ao Protheus 12.1.16
@link https://tdn.totvs.com/pages/releaseview.action?pageId=271385893
@version 12.1.33
@history 07/03/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    User Function CNT121BT()
//=============================================================================================================================

    Local aArea := GetArea()

    Add Option aRotina Title "Gerar Ped. Compra Nacional"       Action "U_IACOMP01()" Operation MODEL_OPERATION_UPDATE Access 0
    Add Option aRotina Title "Estorno Ped. Compra Nacional"     Action "U_IACOMP02()" Operation MODEL_OPERATION_UPDATE Access 0
    Add Option aRotina Title "Relatorio de Contratos Nacional"  Action "U_IACOMR01()" Operation MODEL_OPERATION_UPDATE Access 0

    RestArea(aArea)
Return Nil 

/*
CN120ENCMD 	- CN121ENC
CN120ENVL 	- MVC - MODELVLDACTIVE
CN120IT7 	- CN121PED
CN120PED 	- CN121PED
CN120VENC	- MVC - MODELVLDACTIVE
CN120VEST 	- MVC - MODELVLDACTIVE
CTA120MNU	- CNT121BT
*/
