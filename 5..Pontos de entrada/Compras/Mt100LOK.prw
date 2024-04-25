#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include 'parmtype.ch'

/*/{Protheus.doc} MT100LOK
MT100LOK - Alterações de Itens da NF de Despesas de Importação
@type function
@author Ricardo Tavares Ferreira
@since 08/05/2022
@obs Localização : Function A113LinOk e A113TudOK - Função de Validação ( linha OK da Getdados) para Inclusão/Alteração 
do item da NF de Despesas de Importação e A103LinOk - Função de Validação da LinhaOk.Em que Ponto: No final das validações 
após a confirmação da inclusão ou alteração da linha, antes da gravação da NF de Despesas de Importação.
Finalidade: Permite alterar itens da NF de Despesas de Importação.
@version 12.1.33
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6085397
@return logical, Retorna verdadeiro se pode prosseguir com a inclusao dos itens do doc de entrada.
@history 07/05/2022, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    User Function MT100LOK()
//====================================================================================================

   Local aArea    := GetArea()
//   Local dDtDig   := aCols[n,GDFieldPos("D1_DTDIGIT")]
   Local nPosDel  := len(aHeader) + 1
/*
   If .not. AVBUtil():GetSM2(Dtos(dDtDig))
      ApMsgStop("Não é possivel prosseguir com a inclusão do Documento por que não existe taxa de moeda cadastrada para a data -> "+Dtoc(dDtDig)+", para prosseguir cadastre a cotação de moeda da data informada.","Atenção")
      Return .F. 
   EndIf 
*/
   If !aCols[n,nPosDel]    
      If aCols[n,GDFieldPos("D1_RATEIO")] <> "1" // Se não for rateio, obriga a informar os campos em validação.   
   
      // Valida o item contábil
         If Empty(aCols[n,GDFieldPos("D1_ITEMCTA")]) 
            ApMsgStop("É necessário informar o ITEM CONTÁBIL no item da nota!")
            Return .F.
         Endif 
      
      // Valida a classificação de valor
         If Posicione("CTD",1,xFilial("CTD")+aCols[n,GDFieldPos("D1_ITEMCTA")],"CTD_ACCLVL") == "1"
            If Empty(aCols[n,GDFieldPos("D1_CLVL")])
               ApMsgStop("É necessário informar um CÓD. DE CLASSIFICAÇÃO DE VALOR referente ao item contábil informado.")
               Return .F.
            Endif
         Endif
      
         // Valida o centro de custo. 
         If Empty(aCols[n,GDFieldPos("D1_CC")]) 
            ApMsgStop("É necessário informar o CENTRO DE CUSTO no item da nota!")
            Return .F. 
         Endif
      Endif
   Endif
   RestArea(aArea)
Return .T.

/*
#include "rwmake.ch"
#include "colors.ch"

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Mt100lok º Autor ³Toni Aguiar         º Data ³ 20/09/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida o centro de custo e item contábil                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Documento de entrada                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß


User Function Mt100lok()       
Local _cArea:=GetArea()
Local dDtDig := aCols[n,GDFieldPos("D1_DTDIGIT")]
_lRet    := .t.
nPosDel := len(aHeader) + 1

    If .not. AVBUtil():GetSM2(Dtos(SE2->E2_EMIS1))
        ApMsgStop("Não é possivel prosseguir com a baixa por que não existe taxa de moeda cadastrada para a data -> "+Dtoc(SE2->E2_EMIS1)+", para prosseguir cadastre a cotação de moeda da data informada.","Atenção")
        Return .F. 
    EndIf 


/*If !aCols[n,nPosDel]    
   If aCols[n,GDFieldPos("D1_RATEIO")]<>"1" // Se não for rateio, obriga a informar os campos em validação.   
   
      // Valida o item contábil
      If Empty(aCols[n,GDFieldPos("D1_ITEMCTA")]) 
         ApMsgStop("É necessário informar o ITEM CONTÁBIL no item da nota!")
         _lRet := .F.
      Endif 
      
      // Valida a classificação de valor
      If _lRet .And. Posicione("CTD",1,xFilial("CTD")+aCols[n,GDFieldPos("D1_ITEMCTA")],"CTD_ACCLVL")=="1"
         If Empty(aCols[n,GDFieldPos("D1_CLVL")])
            ApMsgStop("É necessário informar um CÓD. DE CLASSIFICAÇÃO DE VALOR referente ao item contábil informado.")
            _lRet := .F.
         Endif
      Endif
      
      // Valida o centro de custo. 
      If _lRet .And.  Empty(aCols[n,GDFieldPos("D1_CC")]) 
         ApMsgStop("É necessário informar o CENTRO DE CUSTO no item da nota!")
         _lRet := .F.
      ElseIf _lRet    
      Endif
   Endif
Endif
RestArea(_cArea)
Return(_lRet)*/
