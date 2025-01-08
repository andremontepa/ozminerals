#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RWMAKE.CH'
#Include 'Ap5mail.ch'

/*/{Protheus.doc} M460FIM
Ponto de Entrada executado depois da gravação da NF de Saida fora da transação.
@author Ricardo Tavares Ferreira
@since 06/09/2018
@version 12.1.17
@return Nulo
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    User Function M460FIM()
//====================================================================================================

    Local aArea := GetArea()
    Local oSay  := Nil

    //FWMsgRun(,{|oSay| U_ENV_SEFAZ(oSay,SF2->F2_SERIE,SF2->F2_DOC)},"Transmissao da Nota Fiscal","Transmitindo Nota Fiscal de Saida...")
        
    RestArea(aArea)

Return 


