#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RAVB0002  º Autor ³ Sangelles          º Data ³  21/01/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ ROTINA INTEGRACAO DA PRODUCAO COM KARDEX                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ APONTAMENTO DA PRODUCAO - KARDEX                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RAVB0002 

//cFile := cGetFile('Arquivo *|*.*|Arquivo JPG|*.Jpg','Todos os Drives',0,'C:\Dir\',.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE,.T.)
        
	if ZZ0->ZZ0_STATUS = "2"
		Aviso("Atenção","Produto já integrado!",{"OK"})
		return
	endif
	if MsgYesNo("Tem certeza que deseja fazer a integração do produto "+alltrim(ZZ0->ZZ0_PRODUT)+" ?")
		                           
			DbSelectArea("SB1")
			DbSetOrder(1)
			if !(DbSeek(xFilial("SB1")+ZZ0->ZZ0_PRODUT)) 
			    Aviso("Atenção","Erro ao localizar o produto!",{"OK"})
			    return
			endif
                                   
			nXOP                := GetNumSc2()

			ConfirmSX8()
			
			if ZZ0->ZZ0_TIPO == "1" .OR. ZZ0->ZZ0_TIPO == "2"
				RecLock("SC2",.T.)		
				SC2->C2_FILIAL 		:= xFilial("SC2")
				SC2->C2_NUM 		:= nXOP                                                                                                                     			
				SC2->C2_ITEM 		:= "01"        
				SC2->C2_SEQUEN 		:= "001"
				SC2->C2_PRODUTO  	:= ZZ0->ZZ0_PRODUT
				SC2->C2_LOCAL	  	:= ZZ0->ZZ0_LOCAL
				SC2->C2_CC		  	:= ZZ0->ZZ0_CENTRO			
				SC2->C2_QUANT	  	:= ZZ0->ZZ0_QTDE
				SC2->C2_UM		  	:= SB1->B1_UM
				SC2->C2_DATPRI	  	:= ZZ0->ZZ0_DATA
				SC2->C2_DATPRF	  	:= ZZ0->ZZ0_DATA   
				SC2->C2_EMISSAO	  	:= ZZ0->ZZ0_DATA
				SC2->C2_PRIOR	  	:= "500"          
				if ZZ0->ZZ0_TIPO == "1" .OR. ZZ0->ZZ0_TIPO == "2"			
					SC2->C2_QUJE	  	:= ZZ0->ZZ0_QTDE
				else                                    
					SC2->C2_QUJE	  	:= 0			
				endif
				if ZZ0->ZZ0_TIPO == "1" .OR. ZZ0->ZZ0_TIPO == "2"			
					SC2->C2_DATRF	  	:= ZZ0->ZZ0_DATA
				endif
				SC2->C2_STATUS	  	:= "N"      
				if !(ZZ0->ZZ0_TIPO == "1" .OR. ZZ0->ZZ0_TIPO == "2")
					SC2->C2_DESTINA	  := "E"
				endif			
				SC2->C2_TPOP	  	:= "F"
				SC2->C2_BATCH	  	:= "S"
				SC2->C2_BATUSR	  	:= "000000"
				SC2->C2_BATORCA	  	:= "N"
				SC2->C2_BATROT	  	:= "RAVB0002"
				SC2->C2_DIASOCI	  	:= 99
				SC2->C2_TPPR		:= "I"
				SC2->(MsUnlock())
			endif

			RecLock("SD3",.T.)		
			SD3->D3_FILIAL 		:= xFilial("SD3")
			SD3->D3_COD		  	:= ZZ0->ZZ0_PRODUT
			SD3->D3_QUANT	 	:= ZZ0->ZZ0_QTDE
			
			if ZZ0->ZZ0_TIPO == "1" .OR. ZZ0->ZZ0_TIPO == "2"
				SD3->D3_TM	 		:= "001"
				SD3->D3_CF	 		:= "PR0"				
			else 
				SD3->D3_TM	 		:= "999"
				SD3->D3_CF	 		:= "RE1"				
			endif	
			SD3->D3_UM		  	:= SB1->B1_UM
			SD3->D3_ITEMCTA		:= ZZ0->ZZ0_ITEMCC
			                                               
			if ZZ0->ZZ0_TIPO == "1" .OR. ZZ0->ZZ0_TIPO == "2"
				SD3->D3_OP			:= nXOP+"01001"
			elseif  ZZ0->ZZ0_TIPO == "3"                         			
				_cQuery := " SELECT D3_OP FROM " +RetSqlName("ZZ0")+" ZZ0  "
				_cQuery += " , " +RetSqlName("SD3")+" SD3  "
				_cQuery += " WHERE  " 
				_cQuery += "  ZZ0_TIPO = '1'  "
				_cQuery += "   AND SD3.D_E_L_E_T_ <> '*'  "
				_cQuery += "   AND ZZ0.D_E_L_E_T_ <> '*'  "
				_cQuery += "   AND ZZ0_DATA = '"+dtos(ZZ0->ZZ0_DATA)+"'  "
				_cQuery += "   AND D3_FILIAL = ZZ0_FILIAL  "
				_cQuery += "   AND D3_EMISSAO = ZZ0_DATA  "
				_cQuery += "   AND D3_COD = ZZ0_PRODUT  "
			
				If Select("TMP") > 0
					TMP->(DbCloseArea())
				Endif

				dbUseArea(.T.,"TOPCONN",TCGenQry(,,ALLTRIM(Upper(_cQuery))),'TMP',.F.,.T.) 
				SD3->D3_OP := TMP->D3_OP 
			endif
			SD3->D3_LOCAL		:= ZZ0->ZZ0_LOCAL
			if  ZZ0->ZZ0_TIPO == "4"
				SD3->D3_DOC			:= "VEN"+nXOP
			else 	 
				SD3->D3_DOC			:= "PRO"+nXOP   
			endif
			SD3->D3_EMISSAO		:= ZZ0->ZZ0_DATA
			SD3->D3_GRUPO		:= SB1->B1_GRUPO
			SD3->D3_CUSTO1		:= ZZ0->ZZ0_CUSTO
			SD3->D3_CC			:= ZZ0->ZZ0_CENTRO
			SD3->D3_DTLANC		:= ZZ0->ZZ0_DATA
			if ZZ0->ZZ0_TIPO == "1" .OR. ZZ0->ZZ0_TIPO == "2"			
				SD3->D3_PARCTOT		:= "T"			
			endif
			SD3->D3_NUMSEQ 		:= "000003"                                                                                                                     			
			SD3->D3_TIPO 		:= SB1->B1_TIPO
			SD3->D3_USUARIO     := cUserName
			if ZZ0->ZZ0_TIPO == "1" .OR. ZZ0->ZZ0_TIPO == "2"			
				SD3->D3_CHAVE		:= "R0"
				SD3->D3_STSERV		:= "1"   
				SD3->D3_GARANTI		:= "N"                                				
			else
				SD3->D3_CHAVE		:= "E0"							
			endif                          
			SD3->D3_IDENT 		:= "000004"
					
			SD3->(MsUnlock())                     
		
			//Produto em Processamento MV_XPRDP  
			//Produto em Acabado MV_XPRDA  	
			
			//Alterar Produto Acabado ou Em Processamento
			if ZZ0->ZZ0_TIPO == "1" .OR. ZZ0->ZZ0_TIPO == "2"  
				if ZZ0->ZZ0_TIPO == "1"
					cXPRD := SuperGetMv("MV_XPRDA")
				else
					cXPRD := SuperGetMv("MV_XPRDP")
				endif
				if empty(cXPRD) 
					cXPRD := "''"
				endif	
				
				cQry := "UPDATE " +RetSqlName("SD3")+" SET D3_OP = '"+nXOP+"01001"+"' "
				cQry += " WHERE D3_TM >= '500'  "
				cQry += " AND D_E_L_E_T_ <> '*'  " 
				cQry += " AND D3_COD IN ( "+cXPRD+") " 
				cQry += " AND YEAR(CAST(D3_EMISSAO AS DATETIME)) =  YEAR(cast('"+dtos(ZZ0->ZZ0_DATA)+"' as datetime))  "
				cQry += " AND MONTH(CAST(D3_EMISSAO AS DATETIME)) =  MONTH(cast('"+dtos(ZZ0->ZZ0_DATA)+"' as datetime))  "
				
				If (TCSQLExec(cQry) < 0)
		    		Return MsgStop("Erro ao integrar produto!" + TCSQLError())
				EndIf 
	
	        endif
			
			cUlMes := SuperGetMV("MV_ULMES")
			
			if cUlMes >= ZZ0->ZZ0_DATA //se o parâmetro MV_ULMES é maior ou igual a data da produção informada
				
				DbSelectArea("SB9")
				SB9->(DbSetOrder(1))      //B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)
				if !(SB9->(DbSeek(xFilial("SB9")+ZZ0->ZZ0_PRODUT+ZZ0->ZZ0_LOCAL+DTOS(ZZ0->ZZ0_DATA))))			
					RecLock("SB9",.T.)		                 
				else	                                     
					RecLock("SB9",.F.)		                 				
	  		    endif
				
				SB9->B9_FILIAL 		:= xFilial("SB9") 
				SB9->B9_DATA		:= cUlMes
				SB9->B9_COD		  	:= ZZ0->ZZ0_PRODUT
				SB9->B9_LOCAL	  	:= ZZ0->ZZ0_LOCAL
				DbSelectArea("SB2")
				DbSetOrder(1)
				if !(DbSeek(xFilial("SB2")+ZZ0->ZZ0_PRODUT+ZZ0->ZZ0_LOCAL)) 
				    Aviso("Atenção","Erro ao localizar o produto!",{"OK"})
				    return
				endif                      
				                                               
				if ZZ0->ZZ0_TIPO == "3" .OR. ZZ0->ZZ0_TIPO == "4"  
					SB9->B9_QINI		:= SB9->B9_QINI   - ZZ0->ZZ0_QTDE
					SB9->B9_VINI1		:= SB9->B9_VINI1  - ZZ0->ZZ0_CUSTO
					SB9->B9_CM1			:= (SB9->B9_VINI1  - ZZ0->ZZ0_CUSTO) / (SB9->B9_QINI   - ZZ0->ZZ0_QTDE)				
				else
					SB9->B9_QINI		:= ZZ0->ZZ0_QTDE  + SB9->B9_QINI
					SB9->B9_VINI1		:= ZZ0->ZZ0_CUSTO + SB9->B9_VINI1
					SB9->B9_CM1			:= (SB9->B9_VINI1 + ZZ0->ZZ0_CUSTO) / (SB9->B9_QINI   + ZZ0->ZZ0_QTDE)					 				            
				endif
				SB9->B9_MCUSTD		:= "1"        
				SB9->(MsUnlock())         
			endif    
			/*
			if MsgYesNo("IMPORTANTE: Será executado a rotina de Saldo Atual que tem como objetivo fazer os ajustes dos Sados dos Produtos! Deseja executa-la?")
				PARAMIXB := .T.      //-- Caso a rotina seja rodada em batch(.T.), senão (.F.)     
				MSExecAuto({|x| mata300(x)},PARAMIXB) //Atualizando Saldo                                                                                          
			endif
			*/
			RecLock("ZZ0",.F.)		
			ZZ0->ZZ0_STATUS := "2"
			ZZ0->(MsUnlock())                     
			Aviso("Aviso","Integração feita com sucesso!",{"OK"})
	endif

return