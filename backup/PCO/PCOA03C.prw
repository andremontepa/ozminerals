#include 'totvs.ch'
#INCLUDE "protheus.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.ch"


//====================================================================
//    Preenchimento do campo C1_CONTA de acordo com campo
//    C1_CLVL
//    @type  Function
//    @author Flavio Dias
//    @since 22/10/2022
//    GATILHO
//    DOMINIO:C1_CC  CONTRA:C1_CONTA
//    REGRA: U_PCOA03C(M->C1_PRODUTO,M->C1_CLVL)     
//
//    RECARGA U_PCOA03ZZ( SC1->C1_PRODUTO , SC1->C1_CLVL )
//====================================================================
/*
Eduardo
1) A Classe valor OPXMAN001 aplicar:
Resp: se a Classe for OPX é utilizado a conta orçamentaria definido no campo B1_CTACUST no cadastro de produto.
2) A classe valor ESTOQUE 
 Não se aplica para Opex e nem Capex, esta classe é para aquisições de insumos, materiais, e etc para o Almoxarifado. @Nilson Coelho há alguma coisa sobre isso?
 Ratificado pelo Nilson
3) As demais Classes Valores aplicar:
    Resp: se a classe for CPX, é utilizado um parâmetro interno MV_XCONTA.
Att
Aquiles Alcantara
*/

User Function PCOA03C(  cProduto ,  cCusto , cCLVL )
	Local aArea1   := GetArea()
	Local aArea2   := CTT->(GetArea())
	Local aArea3   := SB1->(GetArea())
	Local cConta:= ''
	Default cClasse:=''
	Default cProduto:=''

	// v2
	IF ALLTRIM(cCusto) == ""
	    RETURN("")
	ENDIF

	IF ALLTRIM(cCLVL) == ""
	    RETURN("")
	ENDIF

	IF !"OPX" $ ALLTRIM(cCLVL) // NAO EH OPEX
	    RETURN("9999     ")
	ENDIF

	

	dbselectarea("CTT")
	dbsetorder(1)
	IF !dbseek(XFILIAL("CTT")+ALLTRIM(cCusto))
		RestArea(aArea3)
		RestArea(aArea2)
		RestArea(aArea1)
		RETURN('')
	ENDIF

	dbselectarea("SB1")
	dbsetorder(1)
	IF !dbseek(XFILIAL("SB1")+ALLTRIM(cProduto))
		RestArea(aArea3)
		RestArea(aArea2)
		RestArea(aArea1)
		RETURN('')
	ELSE
		DO CASE
		CASE ALLTRIM(CTT->CTT_CLASCC)  == "1"
			cConta  := ALLTRIM(SB1->B1_CTAATIV)
		CASE ALLTRIM(CTT->CTT_CLASCC)  == "2"
			cConta  := ALLTRIM(SB1->B1_CTACUST)
		CASE ALLTRIM(CTT->CTT_CLASCC)  == "3"
			cConta  := ALLTRIM(SB1->B1_CTADESP)
		CASE ALLTRIM(CTT->CTT_CLASCC)  == "4"
			cConta  := ALLTRIM(SB1->B1_XCTAEXP)
		OTHERWISE
			cConta  := ''
		END CASE
	ENDIF

  /* v1
	DO CASE
	CASE  ALLTRIM(cClasse) $ 'OPX/OPXMAN001'
		cConta:= Posicione('SB1',1,FWxFilial('SB1')+cProduto,'B1_CTACUST')

	CASE ALLTRIM(cClasse) == 'CPX' .OR. SUBSTR(ALLTRIM(cClasse),1,3) == 'CPX'
		cConta:= 	SUPERGETMV("MV_XCONTA", .F., "")

	CASE ALLTRIM(cClasse) == 'ESTOQUE'
		cConta := ''

	OTHERWISE
		cConta:= 	SUPERGETMV("MV_XCONTA", .F., "")
	ENDCASE
   */
	RestArea(aArea3)
	RestArea(aArea2)
	RestArea(aArea1)
Return( cConta )







USER FUNCTION PCOA03ZZ( )
	Local nI

	For nI := 1 to 7
		RPCSETENV(STRZERO(nI,2),"01")
		MsgRun("Processando SC1...", "Aguarde", {|| TRATATRB() })
		RpcClearEnv()
	Next

RETURN

STATIC FUNCTION TRATATRB()

	Local cConta := ""
//Local nVez := 0

	IF SELECT("TRB1") <> 0
		DBSELECTAREA("TRB1")
		TRB1->(DBCLOSEAREA())
	ENDIF

//BEGINSQL ALIAS "TRB1"


	dbselectarea("SC1")
	dbgotop()
	WHILE SC1->(!EOF())
		IF ALLTRIM(SC1->C1_PRODUTO) <> "" .AND. ALLTRIM(SC1->C1_CLVL) <> ""
			cConta :=  U_PCOA03C( SC1->C1_PRODUTO , SC1->C1_CLVL )

			IF ALLTRIM(cConta) <> ""

				RECLOCK("SC1",.F.)
				SC1->C1_CONTA := cConta
				MSUNLOCK()
				//COMMIT

			ENDIF
		ENDIF
		SC1->(DBSKIP())
	ENDDO

RETURN



USER FUNCTION TESTEX()

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"

/*
CQ := " SELECT CT1_CONTA AK6_CODIGO, CT1_DESC01 AK6_DESCRI, D_E_L_E_T_, R_E_C_N_O_ "
CQ += " INTO TESTEX "
CQ += " FROM CT1010 "
CQ += " WHERE D_E_L_E_T_  = ''   AND LEN(CT1_CONTA) = 6   AND CT1_CONTA NOT IN ( SELECT AK6_CODIGO FROM AK6010 ) "

TCSQLEXEC(CQ)
*/


	C1 := " UPDATE AKD010 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE AKD_TPSALD <> 'OR'  "
	C2 := " DELETE FROM AKD010 WHERE D_E_L_E_T_ = '*' "

	TCSQLEXEC(C1)
	TCSQLEXEC(C2)

	tcrefresh("AKD010")


RETURN
