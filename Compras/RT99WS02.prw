#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'


 
/*/{Protheus.doc} JsonUtil
Classe responsável por criar a funções genericas de validação e construção do Json Customizado.
@author Ricardo Tavares Ferreira
@since 11/08/2019
@version 12.1.17
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Class JsonUtil
//====================================================================================================

    Data cIdUSer    as String
    Data cResult    as String
    Data cIdService as String
    Data cErrorMes  as String

    Method New(cIdUSer) Constructor
    Method FilterParse(cFilter)
    Method GetFieldValue(aOFields,cField)
    Method FillProperty(cJson,cFields,xAlias,cFilGrid,xAliasGrid)
    Method PolyString(cString)
    Method CampoPorTitulo(cTabela,cTitulo,lVirtual)
End Class

/*/{Protheus.doc} New
Classe responsável iniciar a Classe.
@author Ricardo Tavares Ferreira
@since 11/08/2019
@version 12.1.17
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Method New(cIdUSer) Class JsonUtil
//====================================================================================================

    Default cIdUSer := ""
    ::cIdUSer       := cIdUSer
    ::cResult       := ""
    ::cIdService    := ""
    ::cErrorMes     := ""
Return

/*/{Protheus.doc} GetFieldValue
Classe responsável buscar o valor conforme o campo passado por parametro.
@author Ricardo Tavares Ferreira
@since 11/08/2019
@version 12.1.17
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Method GetFieldValue(aOFields,cField) class JsonUtil
//====================================================================================================

    Local xRet  := nil
    Local nX    := 0

    For nX:= 1 to Len(aOFields)
        If aOFields[nx]:Id == cField
            If AttIsMemberOf(aOFields[nx] , "Value")
                xRet := aOFields[nx]:Value
                Exit
            EndIf
        EndIf
    Next
    
Return xRet

/*/{Protheus.doc} FilterParse
Classe responsável o campo da SX3 com o array de campos passado como parametro.
@author Ricardo Tavares Ferreira
@since 11/08/2019
@version 12.1.17
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
    Method FilterParse(cFilter,aRelation) Class JsonUtil
//====================================================================================================

    Local cFilRet   := cFilter
    Local nX        := 0

    For nX:= 1 to Len(aRelation)
        cFilRet := StrTran(Upper(cFilRet),Upper(aRelation[nX][1]),aRelation[nX][2])
    Next

    If at('$',cFilRet) > 0    
        cFilRet := SubStr(cFilRet,1,at('$',cFilRet)-1)+" LIKE '%"+SubStr(cFilRet,at("'",cFilRet)+1,Len(cFilRet)-at("'",cFilRet)-1)+"%'"
    EndIf
Return cFilRet

/*/{Protheus.doc} FilterParse
Classe responsável o campo da SX3 com o array de campos passado como parametro.
@author Ricardo Tavares Ferreira
@since 11/08/2019
@version 12.1.17
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//===============================================================================================================
    Method FillProperty(cJson,cFields,xAlias,cFilGrid,xAliasGrid,cNewNode,cNewValue,lSemSpace) class JsonUtil
//===============================================================================================================

    Local lRet          := .F.
    Local aCampos       := {}
    Local oCustomJson   := JsonObject():new()
    Local oGridItem     := Nil
    Local aGrid         := {}
    Local nX            := 0
    Local nY            := 0
    Local oObj          := Nil
    Local cFieldName    := ""
    Local aCamposGrid   := {}

    Default cJson       := ""
    Default cFields     := ""
    Default xAlias      := ""
    Default cFilGrid    := ""
    Default xAliasGrid  := ""
    Default cNewNode    := ""
    Default cNewValue   := ""
    Default lSemSpace   := .T.

    If FWJsonDeserialize(cJson,@oObj)
        aCampos := Strtokarr( cFields, '|')

        For nX:= 1 to Len(aCampos)
            cFieldName := lower(::PolyString(FWX3Titulo(aCampos[nX]),lSemSpace,""))
            If Empty(cFieldName)
                cFieldName := aCampos[nX]
            EndIf
            xValue := ::GetFieldValue(oObj:Models[1]:Fields,aCampos[nX])                    
            oCustomJson[cFieldName] := iif(ValType(xValue) == 'N',xValue, ::PolyString(xValue,!lSemSpace,Iif(Len(TamSX3(aCampos[nX])) > 0,TamSX3(aCampos[nX])[3],"")) )
        Next nX          
        oCustomJson['pk'] := oObj:pk

        If .not. Empty(cFilGrid)
            aCamposGrid := Strtokarr(cFilGrid,'|')
            If AttIsMemberOf(oObj:Models[1] ,"Models") 
                If AttIsMemberOf(oObj:Models[1]:Models[1] ,"Items") 
                    For nY := 1 To Len(oObj:Models[1]:Models[1]:ITEMS)
                        oGridItem := JsonObject():new()
                        For nX:= 1 to Len(aCamposGrid)
                            cFieldName := lower(::PolyString(FWX3Titulo(aCamposGrid[nX]),lSemSpace,""))
                            xValue := ::GetFieldValue(oObj:Models[1]:Models[1]:ITEMS[nY]:FIELDS,aCamposGrid[nX])
                            oGridItem[cFieldName] := iif(ValType(xValue) == 'N' ,xValue, ::PolyString(xValue,!lSemSpace,Iif(Len(TamSX3(aCamposGrid[nX])) > 0,TamSX3(aCamposGrid[nX])[3],"")) )
                        Next nX  
                        aadd(aGrid,oGridItem)
                        oGridItem := Nil
                    Next nY
                    oCustomJson["itens"] := aGrid
                EndIf
            EndIf
        EndIf

        If !Empty(cNewNode) .and. !Empty(cNewValue)
            oCustomJson[cNewNode] := cNewValue
        EndIf 
        ::cResult := oCustomJson:toJson()       
        lRet := .T.
    EndIf
    oCustomJson := Nil        
return lRet

/*/{Protheus.doc} PolyString
Classe responsável por retirar do conteudo passado como parametro os caracteres especiais.
@author Ricardo Tavares Ferreira
@since 11/08/2019
@version 12.1.17
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//===============================================================================================================
    Method PolyString(cString,lSemSpace,cTipoCpo) Class JsonUtil
//===============================================================================================================

    Default lSemSpace   := .T.
    Default cTipoCpo    := "C"

    // cString := StrTran(cString,"Ç", "C")
	// cString := StrTran(cString,"ç", "ç")		
    cString := FwNoAccent(AllTrim(cString))
    If lSemSpace
        cString := StrTran(cString  ,' ','')
    EndIF
    If cTipoCpo <> "N"
        cString := StrTran(cString  ,'.','')
    EndIf
    cString := StrTran(cString      ,'/','')
    cString := StrTran(cString      ,'-','')
    cString := StrTran(cString      ,"ï","")
	cString := StrTran(cString      ,"»","")
	cString := StrTran(cString      ,"¿","")
	cString := StrTran(cString      ,"'","")
	cString := StrTran(cString      ,"#","")
	cString := StrTran(cString      ,"%","")
	cString := StrTran(cString      ,"*","")
	cString := StrTran(cString      ,"&","E")
	cString := StrTran(cString      ,">","")
	cString := StrTran(cString      ,"<","")
	cString := StrTran(cString      ,"!","")
	cString := StrTran(cString      ,"@","")
	cString := StrTran(cString      ,"$","")
	cString := StrTran(cString      ,"(","")
	cString := StrTran(cString      ,")","")
	cString := StrTran(cString      ,"=","")
	cString := StrTran(cString      ,"+","")
	cString := StrTran(cString      ,"{","")
	cString := StrTran(cString      ,"}","")
	cString := StrTran(cString      ,"[","")
	cString := StrTran(cString      ,"]","")
	cString := StrTran(cString      ,"?","")
  //cString := StrTran(cString      ,"\","")
	cString := StrTran(cString      ,"|","")
	cString := StrTran(cString      ,'"',"")
	cString := StrTran(cString      ,"°","")
	cString := StrTran(cString      ,"ª","")
	cString := StrTran(cString      ,"Ã","")
	cString := StrTran(cString      ,"£","")
        
Return cString

/*/{Protheus.doc} CampoPorTitulo
Classe responsável por buscar o nome do campo passado como parametro.
@author Ricardo Tavares Ferreira
@since 11/08/2019
@version 12.1.17
@return Nil
@obs Ricardo Tavares - Construcao Inicial
/*/
//===============================================================================================================
    Method CampoPorTitulo(cTabela,cTitulo,lVirtual) Class JsonUtil
//===============================================================================================================

    Local cX3Campo  := ""
    Local aCampos   := {}
    Local nX        := 0
    
    Default cTabela := ""
    Default cTitulo := ""
    Default lVirtual:= .F.
    
    aCampos   := FWSX3Util():GetAllFields(cTabela,lVirtual)

    If Len(aCampos) > 0
        For nX := 1 to Len(aCampos)
            If lower(::PolyString(FWX3Titulo(aCampos[nX]))) == cTitulo
                cX3Campo := aCampos[nX]
                Exit
            EndIf
        Next        
    EndIf
Return cX3Campo
