#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include 'parmtype.ch'

/*/{Protheus.doc} MT100LOK
MT100LOK - Altera��es de Itens da NF de Despesas de Importa��o
@type function
@author Ricardo Tavares Ferreira
@since 08/05/2022
@obs Localiza��o : Function A113LinOk e A113TudOK - Fun��o de Valida��o ( linha OK da Getdados) para Inclus�o/Altera��o 
do item da NF de Despesas de Importa��o e A103LinOk - Fun��o de Valida��o da LinhaOk.Em que Ponto: No final das valida��es 
ap�s a confirma��o da inclus�o ou altera��o da linha, antes da grava��o da NF de Despesas de Importa��o.
Finalidade: Permite alterar itens da NF de Despesas de Importa��o.
@version 12.1.33
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6085397
@return logical, Retorna verdadeiro se pode prosseguir com a inclusao dos itens do doc de entrada.
@history 07/05/2022, Ricardo Tavares Ferreira, Constru��o Inicial.
/*/
//====================================================================================================
    User Function MT100LOK()
//====================================================================================================

   Local aArea    := GetArea()
//   Local dDtDig   := aCols[n,GDFieldPos("D1_DTDIGIT")]
   Local nPosDel  := len(aHeader) + 1
/*
   If .not. AVBUtil():GetSM2(Dtos(dDtDig))
      ApMsgStop("N�o � possivel prosseguir com a inclus�o do Documento por que n�o existe taxa de moeda cadastrada para a data -> "+Dtoc(dDtDig)+", para prosseguir cadastre a cota��o de moeda da data informada.","Aten��o")
      Return .F. 
   EndIf 
*/
   If !aCols[n,nPosDel]    
      If aCols[n,GDFieldPos("D1_RATEIO")] <> "1" // Se n�o for rateio, obriga a informar os campos em valida��o.   
   
      // Valida o item cont�bil
         If Empty(aCols[n,GDFieldPos("D1_ITEMCTA")]) 
            ApMsgStop("� necess�rio informar o ITEM CONT�BIL no item da nota!")
            Return .F.
         Endif 
      
      // Valida a classifica��o de valor
         If Posicione("CTD",1,xFilial("CTD")+aCols[n,GDFieldPos("D1_ITEMCTA")],"CTD_ACCLVL") == "1"
            If Empty(aCols[n,GDFieldPos("D1_CLVL")])
               ApMsgStop("� necess�rio informar um C�D. DE CLASSIFICA��O DE VALOR referente ao item cont�bil informado.")
               Return .F.
            Endif
         Endif
      
         // Valida o centro de custo. 
         If Empty(aCols[n,GDFieldPos("D1_CC")]) 
            ApMsgStop("� necess�rio informar o CENTRO DE CUSTO no item da nota!")
            Return .F. 
         Endif
      Endif
   Endif
   RestArea(aArea)
Return .T.

/*
#include "rwmake.ch"
#include "colors.ch"

�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Mt100lok � Autor �Toni Aguiar         � Data � 20/09/2016  ���
�������������������������������������������������������������������������͹��
���Descricao � Valida o centro de custo e item cont�bil                   ���
�������������������������������������������������������������������������͹��
���Uso       � Documento de entrada                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������


User Function Mt100lok()       
Local _cArea:=GetArea()
Local dDtDig := aCols[n,GDFieldPos("D1_DTDIGIT")]
_lRet    := .t.
nPosDel := len(aHeader) + 1

    If .not. AVBUtil():GetSM2(Dtos(SE2->E2_EMIS1))
        ApMsgStop("N�o � possivel prosseguir com a baixa por que n�o existe taxa de moeda cadastrada para a data -> "+Dtoc(SE2->E2_EMIS1)+", para prosseguir cadastre a cota��o de moeda da data informada.","Aten��o")
        Return .F. 
    EndIf 


/*If !aCols[n,nPosDel]    
   If aCols[n,GDFieldPos("D1_RATEIO")]<>"1" // Se n�o for rateio, obriga a informar os campos em valida��o.   
   
      // Valida o item cont�bil
      If Empty(aCols[n,GDFieldPos("D1_ITEMCTA")]) 
         ApMsgStop("� necess�rio informar o ITEM CONT�BIL no item da nota!")
         _lRet := .F.
      Endif 
      
      // Valida a classifica��o de valor
      If _lRet .And. Posicione("CTD",1,xFilial("CTD")+aCols[n,GDFieldPos("D1_ITEMCTA")],"CTD_ACCLVL")=="1"
         If Empty(aCols[n,GDFieldPos("D1_CLVL")])
            ApMsgStop("� necess�rio informar um C�D. DE CLASSIFICA��O DE VALOR referente ao item cont�bil informado.")
            _lRet := .F.
         Endif
      Endif
      
      // Valida o centro de custo. 
      If _lRet .And.  Empty(aCols[n,GDFieldPos("D1_CC")]) 
         ApMsgStop("� necess�rio informar o CENTRO DE CUSTO no item da nota!")
         _lRet := .F.
      ElseIf _lRet    
      Endif
   Endif
Endif
RestArea(_cArea)
Return(_lRet)*/
