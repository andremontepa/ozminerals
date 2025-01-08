#Define cNFISCAL

USER FUNCTION CLASCC  
PRIVATE _cClass := ""  
IF SD1->D1_RATEIO <>"1"
 _cClass := POSICIONE("CTT",1,XFILIAL("CTT")+SD1->D1_CC,"CTT_CLASCC")
ELSE
 _cClass := POSICIONE("CTT",1,XFILIAL("CTT")+SDE->DE_CC,"CTT_CLASCC")  
ENDIF 
RETURN (_cClass)

//----------------------------------------------------------------------------------------------------------//
USER FUNCTION SD3CC  
PRIVATE _cClasD3 := ""  
PRIVATE _nNumReq :=""

_nNumReq:= Posicione("SCP",1,XFILIAL("SCP")+SD3->D3_NUMSA,"CP_RATEIO")
IF _nNumReq <>"1"
 _cClasD3 := POSICIONE("CTT",1,XFILIAL("CTT")+SD3->D3_CC,"CTT_CLASCC")
ELSE
 _cClasD3 := POSICIONE("CTT",1,XFILIAL("CTT")+SGS->GS_CC,"CTT_CLASCC")  
ENDIF 
RETURN (_cClasd3) 

//-- Toni Aguiar em 03/08/16
//-- Coloca zero da esquerda para direita do campo F1_DOC
//-- Função chamada na validação do Campo F1_DOC
//--
User Function fZeroDoc()
Local _nTam := TamSx3("F1_DOC")[1] 

If !Empty(M->F1_DOC) .Or. !Empty(cNFISCAL)
   M->F1_DOC := StrZero(Val(M->F1_DOC), _nTam)
//   cNFISCAL  := M->F1_DOC
Endif   
Return .t.           

//----------------------------------------------------------------------------------------------------------//
USER FUNCTION VALRAT
PRIVATE _ValRat := IIF(SD1->D1_RATEIO=="1",(((SD1->(D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC-D1_VALCOF-D1_VALPIS-D1_VALISS-D1_VALCSL-D1_VALIRR-D1_VALINS))*SDE->DE_PERC)/100),0)      
PRIVATE _ValNot := IIF(SD1->D1_RATEIO=="1",(SD1->(D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC-D1_VALCOF-D1_VALPIS-D1_VALISS-D1_VALCSL-D1_VALIRR-D1_VALINS)),0)                                            
private _ValRat2 := _ValNot/2
Private _ValRat3
_ValRat3 := _ValRat - _ValRat2

Alert( "VALRAT"+_valrat +"VALNOT"+ _valnot + "VALNOT2"+_valrat2 + "VALRAT3"+_valrat3)

/*                                                            
PRIVATE cCUSTO := IIF(SD1->D1_RATEIO=="1", SDE->DE_CUSTO1,0)//2   
PRIVATE cFret := IIF(SD1->D1_RATEIO=="1",((SD1->D1_VALFRE)*SDE->DE_PERC)/100,0)
PRIVATE cSeg := IIF(SD1->D1_RATEIO=="1",((SD1->D1_SEGURO)*SDE->DE_PERC)/100,0)  
PRIVATE cDesp := IIF(SD1->D1_RATEIO=="1",((SD1->D1_DESPESA)*SDE->DE_PERC)/100,0)     
PRIVATE cDesc := IIF(SD1->D1_RATEIO=="1",((SD1->D1_VALDESC)*SDE->DE_PERC)/100,0)  
PRIVATE cPis := IIF(SD1->D1_RATEIO=="1",((SD1->D1_VALPIS)*SDE->DE_PERC)/100,0)                                                                                                                                                           
PRIVATE cCofins := IIF(SD1->D1_RATEIO=="1",((SD1->D1_VALCOF)*SDE->DE_PERC)/100,0)                                                                                                                                          
PRIVATE cIRF := IIF(SD1->D1_RATEIO=="1",((SD1->D1_VALIRR)*SDE->DE_PERC)/100,0)                                                                                                                                          
PRIVATE cISS := IIF(SD1->D1_RATEIO=="1",((SD1->D1_VALISS)*SDE->DE_PERC)/100,0)                                                                                                                                          
PRIVATE cCSLL := IIF(SD1->D1_RATEIO=="1",((SD1->D1_VALCSL)*SDE->DE_PERC)/100,0)                                                                                                                                         
PRIVATE cINS := IIF(SD1->D1_RATEIO=="1",((SD1->D1_VALINS)*SDE->DE_PERC)/100,0)                                                                                                                                          
PRIVATE cIPI := IIF(SD1->D1_RATEIO=="1", ((SD1->D1_VALIPI)*SDE->DE_PERC)/100,0)                                                                                                                                         
PRIVATE cPisAp := IIF(SD1->D1_RATEIO=="1",((SD1->D1_VALIMP6)*SDE->DE_PERC)/100,0)                                                                                                                                      
PRIVATE cCofAp := IIF(SD1->D1_RATEIO=="1",((SD1->D1_VALIMP5)*SDE->DE_PERC)/100,0)     

PRIVATE nRAT := cCusto + cPisAp + cCofAp + cIPI+ cFret + cSeg+ cDesp - cDesc - cPis - cCofins - cIRF - cISS - cCSLL - cINS //+ cPisAp + cCofAp
*/
Return(_valrat3)    

//-- Toni Aguiar em 03/08/16
//-- Valida o centro de custo da SE2 para contabilização.
//--
User Function SE2CC  
Local _cClasE2 := ""  
_cClasE2 := Posicione("CTT",1,xFilial("CTT")+SE2->E2_CCUSTO,"CTT_CLASCC")
RETURN (_cClasE2)
                 