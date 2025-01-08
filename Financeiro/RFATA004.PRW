#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "PRTOPDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATA004  ºAutor  ³Leonardo/Sangelles  º Data ³  20/10/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

user function RFATA004(cTipo, nIndice)

    
	cValor := "" 
	if SZ1->Z1_CONTABI == "2"	
		return cValor := SZ1->Z1_DEBITO	
	endif
	if nIndice == 1
		if cTipo == "Debito"  
				return cValor := SZ1->Z1_DEBITO
		elseif cTipo == "Custo" 
				return	cValor := SZ1->Z1_CC
		elseif cTipo == "Item"
				return	cValor := SZ1->Z1_ITEMC		
		elseif cTipo == "Valor" 
				return	cValor := SZ1->Z1_VALOR
		elseif cTipo == "Classe" 
				return	cValor := SZ1->Z1_CLVL
		endif					
	endif
	SZ2->(dbsetorder(1))
	SZ2->(dbgotop())
	if !SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO))
		if cTipo == "Debito"  
			if nIndice == 1
				return cValor := SZ1->Z1_DEBITO
			endif
		elseif cTipo == "Custo" 
			if nIndice == 1
				return	cValor := SZ1->Z1_CC
			endif 
		elseif cTipo == "Item" 
			if nIndice == 1
				return	cValor := SZ1->Z1_ITEMC
			endif			
		elseif cTipo == "Valor" 
			if nIndice == 1
				return	cValor := SZ1->Z1_VALOR
			endif					
		endif
	endif
	 
		SZ2->(dbsetorder(1))
		SZ2->(dbgotop())			
		if nIndice == 1
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"001"))			
		elseif nIndice == 2		
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"002"))			
		elseif nIndice == 3		
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"003"))			
		elseif nIndice == 4		
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"004"))			
		elseif nIndice == 5		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"005"))			
		elseif nIndice == 6		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"006"))						
		elseif nIndice == 7		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"007"))
		elseif nIndice == 8		                          
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"008"))
		elseif nIndice == 9		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"009"))
			elseif nIndice == 10		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"010"))			
		elseif nIndice == 11		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"011"))			
		elseif nIndice == 12		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"012"))			
		elseif nIndice == 13		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"013"))			
		elseif nIndice == 14		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"014"))			
		elseif nIndice == 15		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"015"))			
		elseif nIndice == 16		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"016"))			
		elseif nIndice == 17		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"017"))			
		elseif nIndice == 18		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"018"))			
		elseif nIndice == 19		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"019"))			
		elseif nIndice == 20		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"020"))			
		elseif nIndice == 21		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"021"))			
		elseif nIndice == 22		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"022"))			
		elseif nIndice == 23		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"023"))			
		elseif nIndice == 24		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"024"))			
		elseif nIndice == 25		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"025"))			
		elseif nIndice == 26		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"026"))			
		elseif nIndice == 27		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"027"))			
		elseif nIndice == 28		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"028"))			
		elseif nIndice == 29		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"029"))			
		elseif nIndice == 30		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"030"))			
		elseif nIndice == 31		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"031"))			
		elseif nIndice == 32		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"032"))			
		elseif nIndice == 33		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"033"))			
		elseif nIndice == 34		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"034"))			
		elseif nIndice == 35		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"035"))			
		elseif nIndice == 36		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"036"))			
		elseif nIndice == 37		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"037"))			
		elseif nIndice == 38		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"038"))			
		elseif nIndice == 39		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"039"))			
		elseif nIndice == 40		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"040"))			
		elseif nIndice == 41		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"041"))			
		elseif nIndice == 42		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"042"))			
		elseif nIndice == 43		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"043"))			
		elseif nIndice == 44		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"044"))			
		elseif nIndice == 45		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"045"))			
		elseif nIndice == 46		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"046"))			
		elseif nIndice == 47		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"047"))			
		elseif nIndice == 48		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"048"))			
		elseif nIndice == 49		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"049"))			
		elseif nIndice == 50		                  
			SZ2->(dbseek(xFilial("SZ2")+SZ1->Z1_CODIGO+"050"))						
		endif	           
		if cTipo == "Debito" 
			return SZ2->Z2_DEBITO			
		elseif cTipo == "Custo" 
			return SZ2->Z2_CC			
		elseif cTipo == "Item"
			return SZ2->Z2_ITEMC					
		elseif cTipo == "Valor"
			return SZ2->Z2_VALOR					
		endif
return 
