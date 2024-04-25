#include 'protheus.ch'
#include 'dbtree.ch'
#INCLUDE 'totvs.ch'
#INCLUDE 'FWMVCDEF.ch'
#Include 'FWEditPanel.ch'

/*/{Protheus.doc} MT120BRW
MT120BRW - Adiciona botões à rotina.
@type function
@author Ricardo Tavares Ferreira
@since 27/09/2021
@version 12.1.25
@obs LOCALIZAÇÃO : Function MATA120 - Função do Pedido de Compras e Autorização de Entrega.
EM QUE PONTO : Após a montagem do Filtro da tabela SC7 e antes da execução da Mbrowse do PC, 
utilizado para adicionar mais opções no aRotina.
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6085467
@history 27/09/2021, Ricardo Tavares Ferreira, Construção Inicial.
@return array, Retorna o array com os botoes.
/*/
//====================================================================================================
    User Function MT120BRW()
//====================================================================================================

    Local aArea := GetArea()
    Local nPosDoc := 0

    nPosDoc := aScan(aRotina,{|x| AllTrim(x[2]) == "MsDocument"})

    aDel(aRotina , nPosDoc)
    aSize(aRotina, len(aRotina) - 1)
    aadd(aRotina , {"Conhecimento","U_RT02A003('PC')",0,6})

    RestArea(aArea)
Return aRotina
