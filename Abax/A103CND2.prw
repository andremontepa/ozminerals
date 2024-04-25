//-------00------------------------------------------------------------ 
/*/{Protheus.doc} A103CND2

	Programa utilizado para alterar as informações dos títulos a pagar, poderão ser modificadas as parcelas e os valores.
	Fonte trabalha em conjunto com com o fonte MTUFOPRO - Integração entre o Protheus e o Abax

	@author 	Leonardo Vasco Viana de Oliveira
	@since		27.10.2016
	@version	P11
/*/
User Function A103CND2() 

Local aNewVenc := {}       
Local aOldVenc := Paramixb 
Local nString  := 1

If Type('cMAVenc') <> 'U' 

	If !Empty(Alltrim(cMAVenc))	  

		aNewVal := Strtokarr(Alltrim(cMAVenc),'|') // Primeira posição Valor separada por '|'
		
		For nString:=1 to Len(aNewVal) 
				
			aValNew := strtokarr(aNewval[nString],';')
			
			nValABX := val(aValNew[1])
			dDtABX  := Ctod(aValNew[2])	  		
		  		
		   aadd(aNewVenc,{dDtABX,nValABX}) // := Condicao(nValor,cCondAbax,,dDtAbax) 
	   	   
		Next
		
	Else
		aNewVenc := Condicao(nVBrtAbax,cCondAbax,,dDtVAbax) 
	Endif	
Endif             

If Len(aNewVenc) > 0
	RETURN(aNewVenc) //aNewVenc)           14513.66
Else
	Return(aOldVenc)
Endif		
