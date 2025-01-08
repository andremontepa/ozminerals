#include "rwmake.ch"
#include "fileio.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA050INC  ºAutor  ³Ismael Junior       º Data ³  08/11/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada executado na inclusão do contas a pagar   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function  FA050INC()
//Local lValida  := .T.
//Local nX       := 0
//Local cVldItm
//Local nValPed  := 0
Local cAno     := Alltrim(Str(Year(Date())))
Local cTexto   := ""
Local cMes     := Month2Str(Date())
Local cCodUser := RetCodUsr() //Retorna o Codigo do Usuario
Local cNamUser := UsrRetName( cCodUser )//Retorna o nome do usuario
//Local nVlSaldo := 0
//Local nZw3Val  := 0
Local aCab     := {}
Local aInfor   := {}
//Local lRetWZ3  := .T.
Local _lRet    := .T.

//- Incluído por Lucas Costa em 13/05/2020
/*
If IsInCallStack("FINA050") 
   If ALLTRIM(M->E2_TIPO)<>"PA" .AND. ALLTRIM(M->E2_TIPO)<>"TX" .AND. ALLTRIM(M->E2_PREFIXO)<>"PRO" .AND. ALLTRIM(M->E2_PREFIXO)<>"GPE" .AND. ALLTRIM(M->E2_PREFIXO)<>"GPR".AND. ALLTRIM(M->E2_PREFIXO)<>"GRF" .AND. ALLTRIM(M->E2_PREFIXO)<>"GRP" 
      Help(,,"Atenção!",, "Inclusão permitda apenas para títulos de Pagamento Antecipado."+CHR(13)+"A Inclusão do Título será interrompido.", 1, 0 )
      _lRet:= .F.
      
      //- Alterando lMsErroAuto para .T. (verdadeiro), devido aos casos de integrações ou ExecAuto
      //- lMsErroAuto := .T.
   EndIf
Endif
*/
If _lRet
   // E2_CCUSTO,E2_ITEMCTA,E2_CLVL
   cQuery := " SELECT SUM(ZW2_PREANO)-SUM(ZW2_VLANO) VLSALDO, ZW2_BLOQ FROM "+RetSqlName("ZW2")+" ZW2 "
   cQuery += " WHERE ZW2_CCUSTO = '"+M->E2_CCUSTO+"' "
   cQuery += " AND ZW2_ITEMCO = '"+M->E2_ITEMCTA+"' "
   cQuery += " AND ZW2_CLVL = '"+M->E2_CLVL+"' "
   cQuery += " AND ZW2_CONTA = '"+M->E2_CONTAD+"' "
   cQuery += " AND ZW2_ANO = '"+cAno+"' " 
   cQuery += " AND ZW2_VLANO >= 0 "
   cQuery += " AND ZW2.D_E_L_E_T_ != '*' " 
   cQuery += " GROUP BY ZW2_BLOQ "  		
		
   If SELECT("TRA") > 0
      ("TRA")->(DbCloseArea())
   Endif                                  

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRA",.T.,.T.) 
   //Inicio ***************** 06/04/2020 verifica se bloqueia sim ou não ****************
   cQrybloq := " SELECT ZW2_BLOQ FROM "+RetSqlName("ZW2")+" ZW2 "
   cQrybloq += " WHERE ZW2_CCUSTO = '"+M->E2_CCUSTO+"' "
   cQrybloq += " AND ZW2_ITEMCO = '"+M->E2_ITEMCTA+"' "
   cQrybloq += " AND ZW2_CLVL = '"+M->E2_CLVL+"' "
   cQrybloq += " AND ZW2_CONTA = '"+M->E2_CONTAD+"' "
   cQrybloq += " AND ZW2_ANO = '"+cAno+"' "
   cQrybloq += " AND ZW2.D_E_L_E_T_ != '*' " 						
						
   If SELECT("TRD") > 0
      TRD->(DbCloseArea())
   Endif
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrybloq),"TRD",.T.,.T.)
   //Fim ***************************************************************************		
   If TRD->ZW2_BLOQ <> "S"
      Return(_lRet)
   Endif
   If TRA->VLSALDO < M->E2_VALOR
      _lRet    := .F.	   	
      cTexto +="Saldo da conta insuficiente!"+chr(13)+chr(10)
      cTexto +="Centro de Custo: "+Alltrim(M->E2_CCUSTO)+", Item: "+Alltrim(M->E2_ITEMCTA)+" e Conta: "+Alltrim(M->E2_CLVL)+chr(13)+chr(10)+;
      "Valor Solicitado: "+Transform(M->E2_VALOR,"@E 999,999,999.99")+chr(13)+chr(10)+;
      "Saldo conta     : "+Transform(TRA->VLSALDO,"@E 999,999,999.99")+chr(13)+chr(10)+chr(13)+chr(10)
			
      AADD(aInfor,Alltrim(M->E2_CCUSTO))
      AADD(aInfor,Alltrim(M->E2_CCUSTO)+" / "+Alltrim(M->E2_ITEMCTA)+" / "+Alltrim(M->E2_CLVL)+" / "+Alltrim(M->E2_CONTAD))
      AADD(aInfor,M->E2_VALOR)
      AADD(aInfor,M->E2_NUM)
      AADD(aInfor,TRA->VLSALDO)
      AADD(aInfor,M->E2_ITEMCTA)
      AADD(aCab,aInfor)

      cTexto +="O contas a pagar não pode ser gerado pois não tenha saldo sufiente!"+chr(13)+chr(10)+"Obs: Deseja Enviar um E-mail para o Gestor do centro de custos?"
      If MsgYesNo(cTexto,"Atenção")
         u_Wf120ok(aCab) // email para gesto avisando sobre pedido sem saldo.
         //_lRet := .F.
      Endif
   Else
      cQuery := " SELECT ZW3_CPNUM FROM "+RetSqlName("ZW3")+" ZW3 "
      cQuery += " WHERE ZW3_CPNUM = '"+M->E2_NUM+"' "
      cQuery += " AND ZW3.D_E_L_E_T_ != '*' "  		
		
      If SELECT("TRAZW3") > 0
         ("TRAZW3")->(DbCloseArea())
      Endif
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRAZW3",.T.,.T.)
      If Empty(TRAZW3->ZW3_CPNUM)	
         cUpdate:= " UPDATE " + RetSqlName("ZW2")+" SET ZW2_VAL"+cMes+"=ZW2_VAL"+cMes+"+"+Alltrim(Str(M->E2_VALOR))+" ,ZW2_VLANO = ZW2_VLANO+"+Alltrim(Str(M->E2_VALOR))
         cUpdate+= " WHERE ZW2_CCUSTO = '"+Alltrim(M->E2_CCUSTO)+"' "
         cUpdate+= " AND ZW2_ITEMCO = '"+Alltrim(M->E2_ITEMCTA)+"' "
         cUpdate+= " AND ZW2_CLVL = '"+Alltrim(M->E2_CLVL)+"' "
         cUpdate+= " AND ZW2_CONTA = '"+Alltrim(M->E2_CONTAD)+"' "
         cUpdate+= " AND ZW2_ANO = '"+cAno+"' "
         cUpdate+= " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
         cUpdate+= " AND D_E_L_E_T_ != '*' "
         nFlag := TcSqlExec(cUpdate)

         DbSelectArea("ZW3")
         ZW3->(DbSetOrder(2))
         RecLock("ZW3",.T.)
         ZW3->ZW3_FILIAL := XFILIAL("ZW3")
         ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
         ZW3->ZW3_TIPO   := "D"
         ZW3->ZW3_CCUSTO := M->E2_CCUSTO
         ZW3->ZW3_ITEMCO := M->E2_ITEMCTA
         ZW3->ZW3_ANO    := cAno
         ZW3->ZW3_CLVL  := M->E2_CLVL
         ZW3->ZW3_CONTA  := M->E2_CONTAD
         ZW3->ZW3_DATA   := Date()
         ZW3->ZW3_VALOR  := M->E2_VALOR
         ZW3->ZW3_ORIGEM := "Contas a Pagar"
         ZW3->ZW3_USUARI := cNamUser
         ZW3->ZW3_CPNUM  := M->E2_NUM
         ZW3->ZW3_HISTOR := "Valor ref. Conta a Pagar: "+M->E2_NUM
         ZW3->(MsUnLock())
         ConfirmSX8()
      Endif
   Endif 
Endif
Return(_lRet)
