#include "prtopdef.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include 'parmtype.ch'
#include 'FWMVCDef.ch'

/*/{Protheus.doc} MSDOCVIS
MSDOCVIS - Bloqueia manipula��o de dados
@type function
@author Ricardo Tavares Ferreira
@since 18/08/2021
@version 12.1.25
@obs LOCALIZA��O   :  Function MsDocument - Fun��o principal da amarra��o entidades x documentos  do banco de conhecimento.
EM QUE PONTO :  No in�cio da fun��o, antes da montagem dos bot�es. � utilizado para permitir apenas a ' visualiza��o' dos dados, 
ou seja, n�o permite que o usu�rio efetue  manipula��o dos dados.
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6087680
@history 18/08/2021, Ricardo Tavares Ferreira, Constru��o Inicial.
/*/
//====================================================================================================
    User Function MSDOCVIS()
//====================================================================================================

    Local aArea := GetArea()
    Local lRet  := .F.

    If FWIsInCallStack("MATA110") // Solicita��o de Compras
        If .not. Empty(SC1->C1_PEDIDO) 
            lRet  := .T.
            MsgInfo("Acesso liberado apenas para visualiza��o de arquivos pois a SC est� amarrada ao Pedido de Compras N� <b>"+Alltrim(SC1->C1_PEDIDO)+"</b>","Aten��o")
        EndIf 
    EndIf 

    If FWIsInCallStack("MATA120") // Pedido de Compras
        If SC7->C7_QUJE > 0 .or. SC7->C7_ENCER = "E"
            lRet  := .T.
            MsgInfo("Acesso liberado apenas para visualiza��o de arquivos pois este pedido ja se encontra amarrado � um Documento ou Pr� Documento de Entrada.","Aten��o")
        EndIf 
    EndIf 
    RestArea(aArea)
Return lRet 
