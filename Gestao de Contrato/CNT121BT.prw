#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CNT121BT
CNT121BT - Adicionar bot�es ao menu principal 
@type function
@author Ricardo Tavares Ferreira
@since 07/03/2022
@obs Ponto de entrada tem por objetivo permitir adicionar bot�es do usu�rio ao menu principal da rotina de medi��es. 
A vari�vel aRotina � private neste momento, possibilitando adicionar mais bot�es a rotina
Este ponto de entrada ir� substituir o PE CTA120MNU da rotina de medi��es nas vers�es anteriores ao Protheus 12.1.16
@link https://tdn.totvs.com/pages/releaseview.action?pageId=271385893
@version 12.1.33
@history 07/03/2022, Ricardo Tavares Ferreira, Constru��o Inicial
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
