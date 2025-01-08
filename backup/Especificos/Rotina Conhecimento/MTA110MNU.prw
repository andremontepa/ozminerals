#include 'protheus.ch'
#include 'dbtree.ch'
#INCLUDE 'totvs.ch'
#INCLUDE 'FWMVCDEF.ch'
#Include 'FWEditPanel.ch'

/*/{Protheus.doc} MTA110MNU
MTA110MNU - Acréscimo de botões ao menu principal.
@type function
@author Ricardo Tavares Ferreira
@since 21/09/2021
@version 12.1.25
@obs LOCALIZAÇÃO : Executado pela rotina MATA110 ( Rotina de atualizacao manual das solicitacoes de compra).FINALIDADE : 
O ponto de entrada 'MTA110MNU' é utilizado para adicionar botões ao Menu Principal através do array aRotina.
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6085755
@history 18/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return array, Retorna o array com os botoes.
/*/
//====================================================================================================
    User Function MTA110MNU()
//====================================================================================================

    Local aArea := GetArea()
    Local nPosDoc := 0

    nPosDoc := aScan(aRotina,{|x| AllTrim(x[2]) == "MsDocument"})

    aDel(aRotina , nPosDoc)
    aSize(aRotina, len(aRotina) - 1)
    aAdd(aRotina , {"Conhecimento","U_RT02A003('SC')",0,6}) // Novo Botão de Inclusao de Documentos

    RestArea(aArea)
Return aRotina

