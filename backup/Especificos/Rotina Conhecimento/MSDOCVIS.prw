#include "prtopdef.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include 'parmtype.ch'
#include 'FWMVCDef.ch'

/*/{Protheus.doc} MSDOCVIS
MSDOCVIS - Bloqueia manipulação de dados
@type function
@author Ricardo Tavares Ferreira
@since 18/08/2021
@version 12.1.25
@obs LOCALIZAÇÃO   :  Function MsDocument - Função principal da amarração entidades x documentos  do banco de conhecimento.
EM QUE PONTO :  No início da função, antes da montagem dos botões. É utilizado para permitir apenas a ' visualização' dos dados, 
ou seja, não permite que o usuário efetue  manipulação dos dados.
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6087680
@history 18/08/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    User Function MSDOCVIS()
//====================================================================================================

    Local aArea := GetArea()
    Local lRet  := .F.

    If FWIsInCallStack("MATA110") // Solicitação de Compras
        If .not. Empty(SC1->C1_PEDIDO) 
            lRet  := .T.
            MsgInfo("Acesso liberado apenas para visualização de arquivos pois a SC está amarrada ao Pedido de Compras N° <b>"+Alltrim(SC1->C1_PEDIDO)+"</b>","Atenção")
        EndIf 
    EndIf 

    If FWIsInCallStack("MATA120") // Pedido de Compras
        If SC7->C7_QUJE > 0 .or. SC7->C7_ENCER = "E"
            lRet  := .T.
            MsgInfo("Acesso liberado apenas para visualização de arquivos pois este pedido ja se encontra amarrado à um Documento ou Pré Documento de Entrada.","Atenção")
        EndIf 
    EndIf 
    RestArea(aArea)
Return lRet 
