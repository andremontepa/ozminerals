#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------

/*/{STARSOFT INFORMÁTICA LTDA} FUN_TRIBUT
	Este fonte tem como finalidade alimentar o segmento N (Pagamento de Tributos) em cada situação informada. 
	Os impostos organizados neste fonte estão: DARF, GPS, IPVA, FGTS e GARE.

 
@author Lucas Costa
@since 21/01/2020
/*/

//--------------------------------------------------------------

USER FUNCTION FUN_TRIBUT(cPar1)


LOCAL cString1	:=""
LOCAL cString2	:=""
LOCAL cString3	:=""
LOCAL cString4	:=""
LOCAL cString5	:=""
/*
LOCAL cTributo1 := AllTrim( SE2->E2_XGPS01  )
LOCAL cTributo2 := AllTrim( SE2->E2_XDARF01 )
LOCAL cTributo3 := AllTrim( SE2->E2_XGARE01 ) 
LOCAL cTributo4 := AllTrim( SE2->E2_XIPVA01 )
LOCAL cTributo5 := AllTrim( SE2->E2_XFGTS01 )
*/
//LOCAL cTributo5 := ALLTRIM(SE2->E2_CODBAR)


Do Case
   Case cPar1 == '01'
		cString1 :=  U_DADOSGPS()
		return(cString1)
   Case cPar1 == '02'	
		cString2 := U_DADOSDARF()
		return(cString2)	
   Case cPar1 == '03'
		cString3 := U_DADOSGARE()
		return(cString3) 
   Case cPar1 == '07'	        
		cString4 := U_DADOSIPVA()
		return(cString4)
   Case cPar1 == '11'	
		cString5 := U_DADOSFGTS()
		return(cString5)		
EndCase


Return()

//--------------------------------------------------------------

/*/{STARSOFT INFORMÁTICA LTDA} DADOSGPS
	Rotina criada para gerar string dos dados para pagamento da GPS
	sem codigo de barras.

 
@author Lucas Costa
@since 21/01/2020
/*/

//--------------------------------------------------------------

USER FUNCTION DADOSGPS()

Local cRetGPS  := ""


cRetGPS := SUBSTR(Alltrim(SE2->E2_XIDTRIB),1,2 )		// IDENTIFICACAO DO TRIBUTO (2)
cRetGPS += SUBSTR(Alltrim(SE2->E2_XGPS02),1,4 )		// CODIGO DE PAGTO (4)
cRetGPS += SUBSTR(Alltrim(SE2->E2_XGPS03),1,6 )		// COMPETENCIA (6)
cRetGPS += SUBSTR(Alltrim(SE2->E2_XIDENTI),1,14 )	   //IDENTIFICADOR - CNPJ OU CPF (14)
cRetGPS += STRZERO((SE2->E2_VALOR)*100,14)			//VALOR PRINCIPAL (14)
cRetGPS += STRZERO(u_ITAUPAG("2")*100,14)		//VALOR ENTIDADES (14)
cRetGPS += STRZERO(u_ITAUPAG("1")*100,14)		//VALOR DA MULTA + JUROS + ATM(14)
cRetGPS += STRZERO(((SE2->E2_VALOR + SE2->E2_XMULTA + SE2->E2_XJUROS + SE2->E2_SDACRES + SE2->E2_XGPS04 )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,14)  //VALOR TOTAL (14)
cRetGPS += GRAVADATA(SE2->E2_VENCREA,.F.,5)			//DATA PAGAMENTO (8)
cRetGPS += SPACE(58)								//BRANCOS (50)
cRetGPS += SUBSTR(POSICIONE("SA2",3,XFILIAL("SA2")+SE2->E2_XIDENTI,"A2_NOME"),1,30)		//NOME DO CONTRIBUINTE (30)
//cRetGPS += SUBSTR(SM0->M0_NOME,1,30)				//NOME DO CONTRIBUINTE (30) - conteúdo antigo 20/03/2020

Return(cRetGPS)


//--------------------------------------------------------------

/*/{STARSOFT INFORMÁTICA LTDA} DADOSDARF
	Rotina criada para gerar string dos dados para pagamento de DARF
	sem codigo de barras.

 
@author Lucas Costa
@since 21/01/2020
/*/

//--------------------------------------------------------------

USER FUNCTION DADOSDARF()

Local cRetDARF  := ""


cRetDARF := SUBSTR(Alltrim(SE2->E2_XIDTRIB),1,2)						// IDENTIFICACAO DO TRIBUTO (02)
cRetDARF += SUBSTR(Alltrim(SE2->E2_XDARF02),1,4)		// CODIGO DA RECEITA (04)
cRetDARF += "2"											//TIPO DE INSCRICAO DO CONTRIBUINTE 1=CPF, 2=CNPJ  (1)
cRetDARF += SUBSTR(SM0->M0_CGC,1,14)					//INSCRICAO NUMERO - CNPJ OU CPF (14)
cRetDARF += GRAVADATA(SE2->E2_XDARF03,.F.,5)			//PERIODO DE APURACAO (8)       
cRetDARF += IIF(Empty(SE2->E2_XDARF04),SPACE(17),(SUBST(Alltrim(SE2->E2_XDARF04),1,17)))//NUMERO DE REFERENCIA (17)
cRetDARF += STRZERO((SE2->E2_VALOR)*100,14)				//VALOR PRINCIPAL (14)
cRetDARF += STRZERO(u_ITAUPAG("4")*100,14)				//VALOR DA MULTA (14)
cRetDARF += STRZERO(u_ITAUPAG("3")*100,14)//VALOR DOS JUROS/ENCARGOS (14)  // ((SE2->E2_XJUROS + SE2->E2_SDACRES)*100,14)
cRetDARF += STRZERO(((SE2->E2_VALOR + SE2->E2_XMULTA + SE2->E2_XJUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,14)//VALOR TOTAL (14)
cRetDARF += GRAVADATA(SE2->E2_VENCTO,.F.,5)				//DATA VENCIMENTO (8)
cRetDARF += GRAVADATA(SE2->E2_VENCREA,.F.,5)		    //DATA PAGAMENTO (8)
cRetDARF += SPACE(30)									//BRANCOS (30)
cRetDARF += SUBSTR(SM0->M0_NOME,1,30)					//NOME DO CONTRIBUINTE (30)

Return(cRetDARF)

//--------------------------------------------------------------

/*/{STARSOFT INFORMÁTICA LTDA} DADOSGARE
	Rotina criada para gerar string dos dados para pagamento de GARE
	sem codigo de barras.

 
@author Lucas Costa
@since 21/01/2020
/*/

//--------------------------------------------------------------

USER FUNCTION DADOSGARE()
	
Local cRetGARE  := ""

cRetGARE := SUBSTR(Alltrim(SE2->E2_XIDTRIB),1,2)	//IDENTIFICACAO DO TRIBUTO (02)
cRetGARE += SUBSTR(Alltrim(SE2->E2_XGARE02),1,4)	//CODIGO DA RECEITA (04)
cRetGARE += "2"					   					//TIPO DE INSCRICAO DO CONTRIBUINTE 1=CPF, 2=CNPJ  (01)
cRetGARE += SUBSTR(SM0->M0_CGC,1,14)				//INSCRICAO NUMERO - CNPJ OU CPF (14)
cRetGARE += SUBSTR(SM0->M0_INSC,1,12)				//INSCRICAO ESTADUAL - CNPJ OU CPF (12)
cRetGARE += SPACE(13)								//BRANCOS (13)
cRetGARE += SUBSTR(Alltrim(SE2->E2_XGARE03),1,6)	//REFERENCIA (06)
cRetGARE += SPACE(13)								//BRANCOS (13)
cRetGARE += STRZERO((SE2->E2_VALOR)*100,14)			//VALOR RECEITA (14)
cRetGARE += STRZERO(u_ITAUPAG("3")*100,14)//VALOR DOS JUROS/ENCARGOS (14)
cRetGARE += STRZERO(u_ITAUPAG("4")*100,14)			//VALOR DA MULTA (14)
cRetGARE += STRZERO(((SE2->E2_VALOR + SE2->E2_XMULTA + SE2->E2_XJUROS + SE2->E2_SDACRES )-(SE2->E2_DESCONT + SE2->E2_SDDECRE))*100,14)//VALOR DO PAGAMENTO (14)
cRetGARE += GRAVADATA(SE2->E2_VENCTO,.F.,5)			//DATA VENCIMENTO (8)
cRetGARE += GRAVADATA(SE2->E2_VENCREA,.F.,5)		//DATA PAGAMENTO (8)
cRetGARE += SPACE(11)								//BRANCOS (11)
cRetGARE += SUBSTR(SM0->M0_NOME,1,30)				//NOME DO CONTRIBUINTE (30)

Return(cRetGARE)      



//--------------------------------------------------------------

/*/{STARSOFT INFORMÁTICA LTDA} DADOSIPVA
	Rotina criada para gerar string dos dados para pagamento de IPVA
	sem codigo de barras.

 
@author Lucas Costa
@since 21/01/2020
/*/

//--------------------------------------------------------------


USER FUNCTION DADOSIPVA()

Local cRetIPVA  := ""

	//POSICIONA NO FORNECEDOR
	//=======================
	SA2->(DBSETORDER(01))
	SA2->(DBSEEK(xFILIAL("SA2")+SE2->(E2_FORNECE+E2_LOJA)))
		
	cRetIPVA := SUBSTR(Alltrim(SE2->E2_XIDTRIB),1,2)											//IDENTIFICACAO DO TRIBUTO (02)
	cRetIPVA += SPACE(04)																		// BRANCOS
	cRetIPVA += IIF(SA2->A2_TIPO == "J", "2", "1")         										// TIPO DE INSCRIÇÃO DO CONTRIBUINTE (1-CPF / 2-CNPJ) 
	cRetIPVA += STRZERO(VAL(SA2->A2_CGC),14)                									// CPF OU CNPJ DO CONTRIBUINTE
	cRetIPVA += SUBSTR(DTOS(dDATABASE),1,4)	            										// ANO BASE
	cRetIPVA += PADR(SE2->E2_XIPVA02,09)//E2_XRENAVA                    						// CODIGO RENEVAN
	cRetIPVA += SE2->E2_XIPVA03 //E2_XUFRENA													// UF RENEVAN
	cRetIPVA += IIF(EMPTY(SE2->E2_XIPVA04),PADR(SA2->A2_COD_MUN,05),PADR(SE2->E2_XIPVA04,05))	// COD.MUNICIPIO RENEVAN  -SE2->E2_XMUNREN
	cRetIPVA += PADR(SE2->E2_XIPVA05,07)//SE2->E2_XPLACA				     					// PLACA DO VEICULO
	cRetIPVA += SE2->E2_XIPVA06	//E2_XOPCPAG										// OPCAO DE PAGAMENTO
	cRetIPVA += STRZERO(INT((SE2->E2_SALDO+SE2->E2_ACRESC)*100),14)     						// VALOR DO IPVA + MULTA + JUROS
	cRetIPVA += STRZERO(INT(SE2->E2_DECRESC*100),14)											// VALOR DO DESCONTO
	cRetIPVA += STRZERO(INT(((SE2->E2_SALDO+SE2->E2_ACRESC)-SE2->E2_DECRESC)*100),14)			// VALOR DO PAGAMENTO
	cRetIPVA += GRAVADATA(SE2->E2_VENCREA,.F.,5) 												// DATA DE VENCIMENTO
	cRetIPVA += GRAVADATA(SE2->E2_VENCREA,.F.,5) 												// DATA DE PAGAMENTO 
	cRetIPVA += SPACE(41) 								                       					// COMPLEMENTO DE REGISTRO                           
	cRetIPVA += SUBSTR(SA2->A2_NOME,1,30)								            			// NOME DO CONTRIBUINTE 	

 Return(cRetIPVA)                    	


//--------------------------------------------------------------

/*/{STARSOFT INFORMÁTICA LTDA} DADOSFGTS
	Rotina criada para gerar string dos dados para pagamento de FGTS
	sem codigo de barras.

 
@author Lucas Costa
@since 21/01/2020
/*/

//--------------------------------------------------------------

USER FUNCTION DADOSFGTS()
             
Local  cRetFGST :=""                 	

			    				 							// ===> FGTS - GFIP
	cRetFGST := SUBSTR(Alltrim(SE2->E2_XIDTRIB),1,2)		// IDENTIFICACAO DO TRIBUTO (02)"11"            	                            
	cRetFGST += SubStr(SE2->E2_XFGTS02,1,4)					// Código da Receita
	cRetFGST += "1"											// TIPO DE INSCRIÇÃO DO CONTRIBUINTE (1-CNPJ / 2-CEI) 
	cRetFGST += SUBSTR(Alltrim(SE2->E2_XFGTS07),1,14 )    	// CPF OU CNPJ DO CONTRIBUINTE 
	cRetFGST += AllTrim(SE2->E2_XFGTS03)                   	// CODIGO DE BARRAS (LINHA DIGITAVEL)	(*criar campo*) 
	cRetFGST += StrZero(Val(SE2->E2_XFGTS04),16) 			// Identificador FGTS 
	cRetFGST += StrZero(Val(SE2->E2_XFGTS05),9)   			// Lacre de Conectividade Social 
	cRetFGST += StrZero(Val(SE2->E2_XFGTS06),2)  			// Digito do Lacre  
	cRetFGST += SubStr(SM0->M0_NOMECOM,1,30)                // NOME DO CONTRIBUINTE
	cRetFGST += GravaData(SE2->E2_VENCREA,.F.,5)           	// DATA DO PAGAMENTO 
	cRetFGST += StrZero(SE2->E2_SALDO*100,14)             	// VALOR DO PAGAMENTO 
	cRetFGST += Space(30)                                  	// COMPLEMENTO DE REGISTRO 
Return(cRetFGST)

//--------------------------------------------------------------

/*/{STARSOFT INFORMÁTICA LTDA} ITAUPAG
	Função criada para gerar o acumulador nas variáveis de Juros/Mutas e Outras Entidades. 
	Esta função tem como finalidade gerar o trailer do lote no arquivo de remessa. 
 
@author Lucas Costa
@since 21/01/2020
/*/

//--------------------------------------------------------------

User Function ITAUPAG(cPar)   
Do case           
   case cPar = "1"  // Soma juros e multas
      nWsomaJurMul += SE2->(E2_XJUROS+E2_XMULTA)
      Return SE2->(E2_XJUROS+E2_XMULTA) 
   case cPar = "2"  // Soma outros descontos/abatimentos 
	  nWsomaOutras += SE2->(E2_XGPS04)
	  Return SE2->(E2_XGPS04)
   case cPar = "3"  // soma apenas os juros para abatimento
      nWsomaJurMul += SE2->(E2_XJUROS)
      Return SE2->(E2_XJUROS)     
   case cPar = "4"  // soma apenas a multa para abatimento
      nWsomaJurMul += SE2->(E2_XMULTA)
      Return SE2->(E2_XMULTA)     
Endcase

Return Nil 	

//--------------------------------------------------------------

/*/{STARSOFT INFORMÁTICA LTDA} ITAUSOMA
	Função criada para retornar a soma total das váriaveis nWsomaJurMul e nWsomaOutras.
	carrega esta informação no traller de lote 
	
 
@author Lucas Costa
@since 21/01/2020
/*/

//--------------------------------------------------------------
User Function ITAUSOMA(cPar)

If cPar == "1"
	Return(nWsomaJurMul)
ElseIF cPar == "2"
	Return(nWsomaOutras)
EndIf		

Return Nil
