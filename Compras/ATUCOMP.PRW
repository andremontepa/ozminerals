#Include "PROTHEUS.CH" 
#include "rwmake.ch"
#include "fileio.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "Topconn.ch"

//--------------------------------------------------------------
/*/{STARSOFT INFORMATICA LTDA} ATUCOMP.PRW

	Este fonte tem como objetivo permitir a inclusão do codigo do comprador após a inclusão da Solicitação de Compras
	sem necessidade da SC passar novamente por uma aprovação. 	


@author Lucas Costa
@since 17/12/2019
/*/
//--------------------------------------------------------------
User Function ATUCOMP()    
Local oComprador
Local oGroup1
Local oSay1
Local oSay2
Local oButton1      // Confirma
Local oButton2      // Cancela
//Local cGesto  		:= SuperGetMV("MV_XCOMPRA")
Local cUser 		:= RetCodUsr()
Private cCompra 	:= SPACE(6)
Static oDlg

		// Condições para acessar a rotina
 If cUser$ SuperGetMV("MV_XCOMPRA")
 	//If SC1->C1_QUJE == 0 .AND. SC1->C1_COTACAO == SPACE(LEN(SC1->C1_COTACAO)) .AND. SC1->C1_APROV $ " ,L" .AND. EMPTY(SC1->C1_RESIDUO)
	
       /*/
	     Montagem da tela para Seleção de Compradores
       /*/
       DEFINE MSDIALOG oDlg TITLE "Seleção de Comprador" FROM 000, 000  TO 220, 360 COLORS 0, 16777215 PIXEL

         @ 003, 003 GROUP oGroup1 TO 105, 173 PROMPT "Selec Comprador" OF oDlg COLOR 0, 16777215 PIXEL
         @ 023, 093 MSGET oComprador VAR cCompra SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "SY1" PIXEL
         @ 025, 015 SAY oSay1 PROMPT "Comprador" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
         @ 059, 016 SAY oSay2 PROMPT "Esta rotina tem como função definir o comprador para solicitações de compras." SIZE 137, 021 OF oDlg COLORS 0, 16777215 PIXEL
         @ 091, 95 BUTTON oButton1 PROMPT "Cancelar" SIZE 037, 012 OF oDlg ACTION IIF(MsgYesNo("Deseja realmente fechar a rotina?","Atenção"),oDlg:END(),) PIXEL
         @ 091, 135 BUTTON oButton2 PROMPT "OK" SIZE 037, 012 OF oDlg ACTION u_ATUCOM() PIXEL

       ACTIVATE MSDIALOG oDlg CENTERED
	/*
  	else

  	 MsgInfo("Impossível realizar esta alteração, pois esta SC não está com o Status=Pendente.","Atenção")

  	Endif
	*/ 
 else
 
  	MsgInfo("Usuário não Autorizado.","Atenção")
  
 Endif

Return

/*/
	Função para efetuar update no registro
/*/

User Function ATUCOM()
Local cComp := Alltrim(cCompra)  // SC1->C1_CODCOMP
 
	cUpdate:= " UPDATE " + RetSqlName("SC1") + " SET C1_CODCOMP = '"+ cComp +"', "
	cUpdate+= " C1_XNOMECP = '"+Posicione("SY1",1,xFilial("SY1")+cComp, "Y1_NOME")+"' "
	cUpdate+= " WHERE C1_NUM = '"+SC1->C1_NUM+"' "
	cUpdate+= " AND C1_FILIAL = '"+SC1->C1_FILIAL+"' "
	cUpdate+= " AND D_E_L_E_T_ != '*' "
	nFlag := TcSqlExec(cUpdate)

MsgInfo("Atualização executada com sucesso.","TOTVS")
oDlg:END()

Return