#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} F050MDVC
    Ponto de entrada para alterar regra de data de vencimento do PCC
    @type  User Function
    @author Stephen Noel - Equilibrio T.I.
    @since 04/01/2024 / Melhorias e Ajustes lógicos - 22/JUN/2024 
    @Analista: Julio Martins - CRMServices
    @version 2.0
/*/

USER FUNCTION F050MDVC()

Local dNextDay := ParamIxb[1] //data calculada pelo sistema
Local cIMposto := ParamIxb[2]
Local dEmissao := ParamIxb[3]
//Local dEmis1   := ParamIxb[4]
Local dVencRea := ParamIxb[5]
Local nNextMes := Month(dEmissao)+1 // Month(dVencRea)+1 // Month(dVencRea)+1
Local _dData   := dVencRea
Local _nRet    := Dow(_dData)

    If !Alltrim(Str(_nRet)) $ "3#5" // 3 terça e 5 quinta
        If Alltrim(Str(_nRet)) == "2" //Caso caia na segunda subtraimos 4 dias
            _dData := DaySub(_dData, 4)
        Else
            _dData := DaySub(_dData, 1) //DaySum(_dData, 1)
        EndIf
       // dVencRea:= _dData
        dNextDay:= _dData 
    Endif
 
If cImposto $ "PIS,CSLL,COFINS,INSS,IRRF"//Calcula data 20 do próximo mes 
    dNextDay := CTOD("20/"+Iif(nNextMes==13,"01",StrZero(nNextMes,2))+"/"+; 
    Substr(Str(Iif(nNextMes==13,Year(dEmissao)+1,Year(dEmissao))),2))//Acho o ultimo dia util do periodo desejado 
    dNextday := DataValida(dNextday,.F.)
    
EndIf
If cImposto $ "ISS"//Calcula data 10 do próximo mes 
    dNextDay := CTOD("10/"+Iif(nNextMes==13,"01",StrZero(nNextMes,2))+"/"+; 
    Substr(Str(Iif(nNextMes==13,Year(dEmissao)+1,Year(dEmissao))),2))//Acho o ultimo dia util do periodo desejado 
    dNextday := DataValida(dNextday,.F.)
EndIf 

Return dNextDay





