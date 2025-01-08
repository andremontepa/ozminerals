
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FUNOPER     ºAutor  ³Sangelles/Leonardoº Data ³  12/07/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


user function FUNOPER
	lSair := .T.
	
	_nPedido   := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_PEDIDO"})
	_nItemPC   := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_ITEMPC"})
	_nOper	   := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_XOPER"})

	if !empty(aCols[n,_nPedido])	
		SC7->(dbsetorder(1))
		SC7->(dbgotop())
		if SC7->(dbseek(xFilial("SC7")+aCols[n,_nPedido]+aCols[n,_nItemPC]))
			if SC7->C7_XTPAPL == "D"
				if M->D1_XOPER != "O"
					Aviso("Atenção","Tipo de Operação não pode ser diferente de 'O'! ",{"OK"})
					lSair := .F.
				endif
			elseif 	SC7->C7_XTPAPL == "I"
		   		if M->D1_XOPER != "51"
		   			Aviso("Atenção","Tipo de Operação não pode ser diferente de '51'! ",{"OK"})
					lSair := .F.
				endif
			endif   
		endif
    endif
return lSair
