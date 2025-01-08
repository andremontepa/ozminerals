#INCLUDE "TOPCONN.CH"
#Include "PRTOPDEF.CH"
#Include "RWMAKE.CH"

//-------------------------------------------------------------------------------
/* {Protheus.doc} MT110LOK
Programa - Valida as Linhas da Solicitação de Compras para várias condições solicitadas pelo cliente. 
Copyright - STARSOFT INFORMATICA LTDA
@author - Toni Aguiar 
@since 27/04/2017
@version Lobo Guara v.12.1.23
*/
//-------------------------------------------------------------------------------
User Function MT110LOK
Local cCodUsr
Local cDepto
Local lRet     :=.T.                                                 
Local _aRatCC  :={}
Local _nI      := 0
Local _aRatCV  :={}
Local _aRatGR  :={}
Local nPosCc   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CC'})
Local nPosItem := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_ITEMCTA'})
Local nPosCl   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CLVL'})
Local nPosRate := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_RATEIO'}) 
Local nPosProp := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XPROPRI'})  
Local cApropri := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XPRIORI'})
Local nVunit   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_VUNIT'})
Local cFornec  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_FORNECE'})
Local nProduto := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_PRODUTO'}) // ismael 02/12/2021
Local _cArea   :=GetArea()
Local _Chave
Local cMens    :=""

PswOrder(2)           
PswSeek(cUserName) 
aRet    := PswRet(1)
cCodUsr := aRet[1][1]
cDepto  := aRet[1][12]
aAllusers := FWSFALLUSERS({"000001"})

/*
SY1->(DbSetOrder(3))	//filial+codusuario
If SY1->(DbSeek(xFilial("SY1")+cCodUsr)) .Or. Alltrim(Upper(cDepto))=="ALMOXARIFADO"
   lRet:= .T.
Else
   If SB1->B1_APROPRI="I"	
      Alert("Usuário autorizado a solicitar ao compras, somente produtos de aplicação direta. Para os produtos"+;
            " de aplicação indireta, faça uma solicitação ao Armazém.")
      lRet:= .F.
   Endif
Endif                                                            
*/
//- Lucas Costa - TOTVS STARSOFT em 27/04/2021
//- Validação na Linha do Item para obrigatoriedade do preenchimento dos campos 
//- de quantidade e fornecedor caso estejam em branco e sempre que o campo C1_XPRIORI = 9. 
// **** Validação de Campos para Regularização de SC ****

If aCols[n][cApropri] = "9"
	If Empty(aCols[n][cFornec]) .Or. Empty(aCols[n][nVunit])
		ApMsgStop("SC de tipo Regularizacao, portanto os campos 'Vlr Unitario' e 'Fornecedor' precisam ser Preenchidos. Verifique!")
		lRet := .F.  
	EndIf
Endif        
//- Toni Aguiar - TOTVS STARSOFT em 30/03/2019
//- Valida se o item contábil está relacionado ao centro de custo
//- E se a classe de valor, está relacionada ao item contábil   
If aCols[n][nPosRate]<>"1"
   //- cc+it.contabil                                      
   _Chave:=PADR(aCols[n][nPosCc],TamSx3("Z7_CCUSTO")[1])+;
           PADR(aCols[n][nPosItem],TamSx3("Z7_CODITEM")[1])
   dbSelectArea("SZ7")   
   SZ7->(dbSetOrder(4))
   If lRet .And. !SZ7->(dbSeek(xFilial("SZ7")+_chave))     //- Valida relacionamento do CC x It. Contábil
      ApMsgStop("É necessario informar o It.Contabil pertencente ao centro de custo!")
      lRet := .F.
   Endif

   //- cc+it.contabil+cl.valor
   _Chave:=PADR(aCols[n][nPosCc],TamSx3("Z7_CCUSTO")[1])+;
           PADR(aCols[n][nPosItem],TamSx3("Z7_CODITEM")[1])+;
           PADR(aCols[n][nPosCl],TamSx3("Z7_CODCVL")[1]) 	  
        
   If lRet .And. !SZ7->(dbSeek(xFilial("SZ7")+_chave))     //- Valida relacionamento do CC x It. Contábil
      ApMsgStop("E necessario informar a Classe de Valor pertencente ao Item Contabil!")
      lRet := .F.
   Endif           
   SZ7->(dbCloseArea())
   RestArea(_cArea)
                        
   //- Toni Aguiar - TOTVS STARSOFT em 17/09/2019
   //- Checa se o centro de custo e item contábil, tem relacionamento com os grupos de aprovação.
   cQuery:="SELECT COUNT(*) NQTDREC FROM "+RetSqlName("DBL")+" DBL " 
   cQuery+="   INNER JOIN "+RetSqlName("SAL")+" SAL "
   cQuery+="           ON DBL.DBL_FILIAL =SAL.AL_FILIAL AND DBL.DBL_GRUPO = SAL.AL_COD AND SAL.AL_DOCSC='T' AND SAL.D_E_L_E_T_<>'*' "
   cQuery+="        WHERE DBL.DBL_FILIAL='"+xFilial("DBL")+"' AND DBL.DBL_CC = '"+aCols[n][nPosCc]+"' AND DBL.DBL_ITEMCT = '"+aCols[n][nPosItem]+"' AND DBL.D_E_L_E_T_<>'*' "
   cQuery:=ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery),"TMP1",.F.,.T.)
   TMP1->(dbGoTop())

   If lRet .And. TMP1->NQTDREC<=0 
      //APMSGSTOP("RETORNO: "+Str(TMP1->NQTDREC))
      //ApMsgStop("O Centro de Custo: "+aCols[n][nPosCc]+"/"+TMP1->DBL_CC+" ou Item Contábil: "+aCols[n][nPosItem]+"/"+TMP1->DBL_ITEMCT+", não estão relacionados com o grupo de aprovação: "+TMP1->AL_COD+"!") 
      ApMsgStop("O Centro de Custo: "+aCols[n][nPosCc]+" ou Item Contabil: "+aCols[n][nPosItem]+", nao estao relacionados com o grupo de aprovacao!")
      lRet := .F.
   Endif
   TMP1->(dbCloseArea())
   
//- Valida os campos com origem na tabela SCX - Rateio da SC
//- Toni Aguiar - TOTVS STARSOFT em 30/06/2020 
Else
   _nI :=0
   For _nI := 1 To Len(aCpiSCX[1][2])
      _Chave := xFilial("SZ7") + PADR(aCpiSCX[1,2,_nI,3],TamSx3("Z7_CCUSTO")[1]) + PADR(aCpiSCX[1,2,_nI,5],TamSx3("Z7_CODITEM")[1])  // filial+cc+it.contabil
      dbSelectArea("SZ7")   
      SZ7->(dbSetOrder(4))
      If !SZ7->(dbSeek(_chave))     //- Valida relacionamento do CC x It. Contábil
         AADD(_aRatCC,{"SC: "+CA110NUM+", Linha: "+aCpiSCX[1,2,_nI,1]+", CC: "+aCpiSCX[1,2,_nI,3]+", It.Contab: "+aCpiSCX[1,2,_nI,5]})
         lRet := .F.
      Endif

      //- cc+it.contabil+cl.valor
      _Chave:=xFilial("SZ7")+PADR(aCpiSCX[1,2,_nI,3],TamSx3("Z7_CCUSTO")[1]) + PADR(aCpiSCX[1,2,_nI,5],TamSx3("Z7_CODITEM")[1]) + PADR(aCpiSCX[1,2,_nI,6],TamSx3("Z7_CODCVL")[1])   // filial+cc+it.contabil+cl.valor
      If !SZ7->(dbSeek(_chave))     //- Valida relacionamento do CC x It. Contábil x Cl.Valor
         AADD(_aRatCV,{"SC: "+CA110NUM+", Linha: "+aCpiSCX[1,2,_nI,1]+", CC: "+aCpiSCX[1,2,_nI,3]+", It.Contab: "+aCpiSCX[1,2,_nI,5]+", Cl.Valor: "+aCpiSCX[1,2,_nI,6]})
         lRet := .F.
      Endif         
 
      //- Checa se o centro de custo e item contábil, tem relacionamento com os grupos de aprovação.
      cQuery:="SELECT COUNT(*) NQTDREC FROM "+RetSqlName("DBL")+" DBL " 
      cQuery+="   INNER JOIN "+RetSqlName("SAL")+" SAL "
      cQuery+="           ON DBL.DBL_FILIAL =SAL.AL_FILIAL AND DBL.DBL_GRUPO = SAL.AL_COD AND SAL.AL_DOCSC='T' AND SAL.D_E_L_E_T_<>'*' "
      cQuery+="        WHERE DBL.DBL_FILIAL='"+xFilial("DBL")+"' AND DBL.DBL_CC = '"+aCpiSCX[1,2,_nI,3]+"' AND DBL_XTIPO = 'C' AND DBL.DBL_ITEMCT = '"+aCpiSCX[1,2,_nI,5]+"' AND DBL.D_E_L_E_T_<>'*' "
      cQuery:=ChangeQuery(cQuery)
      dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery),"TMP2",.F.,.T.)
      TMP2->(dbGoTop())
      If TMP2->NQTDREC<=0
         AADD(_aRatGR,{"SC: "+CA110NUM+", Linha: "+aCpiSCX[1,2,_nI,1]+", CC: "+aCpiSCX[1,2,_nI,3]+", It.Contab: "+aCpiSCX[1,2,_nI,5]})
         lRet := .F.
      Endif           
      TMP2->(dbCloseArea())
   Next
   
   If Len(_aRatCC)>0; _nI:=0
      For _nI:= 1 To Len(_aRatCC)
         cMens := cMens + _aRatCC[_nI][1] + CHR(13)+CHR(10)
      Next
      MsgInfo(cMens,"Os Itens Contabeis relacionados nao pertencem ao Centro de Custo!")
   Endif
   If Len(_aRatCC)<=0 .And. Len(_aRatCV)>0
      cMens:=""; _nI:=0
      For _nI:= 1 To Len(_aRatCV)
         cMens := cMens + _aRatCV[_nI][1] + CHR(13)+CHR(10)
      Next
      MsgInfo(cMens,"As Classes de Valores relacionadas nao pertencem ao Item Contabil!")
   Endif
   If (Len(_aRatCC)+Len(_aRatCV))<=0 .And. Len(_aRatGR)>0
      cMens:=""; _nI:=0
      For _nI:= 1 To Len(_aRatGR)
         cMens := cMens + _aRatGR[_nI][1] + CHR(13)+CHR(10)
      Next
      MsgInfo(cMens,"Os Centro de Custos ou Itens Contabeis, nao estao relacionados com o Grupo de Aprovacao!")
   Endif
   SZ7->(dbCloseArea())
Endif
//valida se o usuario tem permissão para solicitar produto indireto
//**************** ismael junior 02/12/2021************************
   If Alltrim(aCols[n][nPosProp]) = "I"
      DbSelectArea("SZ0")
      SZ0->(DbSetOrder(1))
         if SZ0->(DbSeek(xFilial("SZ0") + cCodUsr ))
            If SZ0->Z0_INDIRET == 'N'       	
               Alert("Usuario sem permissao para solicitar produtos Indiretos (Estoque). Favor alterar o campo Apropriacao para Direto.")
               lRet:= .F.
            Endif 
         else
            Alert("Usuario nao cadastrado para solicitar produtos indiretos (Estoque). Favor alterar o campo Apropriacao para Direto.")
            lRet:= .F.               
         Endif     
   Endif 
//Fim *************************************************************                                            
Return lRet
