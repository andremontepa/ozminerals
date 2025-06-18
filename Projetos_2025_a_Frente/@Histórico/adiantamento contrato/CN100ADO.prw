#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"


User Function CN100ADO()
Local ExpL1 := .T.
Local cContra := CN9->CN9_NUMERO
Local cGloba  := CN9->CN9_XGLOBA 
Local cVladt  := CN9->CN9_XVLADT
Local cParcel := CN9->CN9_XPAADT  // Numero Parcelas a descontar
Local cForn   := " "
Local cLoja   := " "

         DBSELECTAREA("CNC")
         CNC->(DbSetOrder(1))
         dbSeek(xFilial("CNC")+cContra )
         cForn := CNC->CNC_CODIGO
         cLoja := CNC->CNC_LOJA

If !CNX->( dbSeek(xFilial("CNX")+cContra )) .and. cGloba  <> "S"
 if cVladt >0 .and. cParcel >0  // tem adiantamento nas solicitações de compras
 OZGeraAdt(CN9->CN9_NUMERO, CN9->CN9_REVISA, cVladt)
 endif
endif
Return ExpL1


/*Exemplo da utilização dos adiantamentos sem interface gráfica*/
static Function OZGeraAdt(cContrato, cRev, nValor)

    Local oModel    := NIL
    Local cModelId  := ""
    Local cChave    := xFilial("CN9") + cContrato + cRev
    Local aErro     := {}
    Local oMdlCNX   := NIL
    Local cAgenc :=""
    Local cConta :=""
    Local cBanco := "341"
    Local cNumero:= "000001"
    Local cContra:= CN9->CN9_NUMERO
   
    Local cEmpr:= FWCodEmp()
    If CNX->( dbSeek(xFilial("CNX")+cContra )) 
    cNumero :=strzero(val(CNX->CNX_NUMERO)+1,6,0)
    endif

If cParcel := 0
cParcel := 1
endif

IF cEmpr="01" // AVB MINERAÇÃO
cAgenc:="7780"
endif
IF cEmpr="02" // VALE DOURADO MINERAÇÃO
cAgenc:="XXXX"
endif
IF cEmpr="03" // SANTA LUCIA MINERAÇÃO
cAgenc:="7780"
endif
IF cEmpr="04" // AVANCO RESOURCES MINERAÇÃO
cAgenc:="7780"
endif
IF cEmpr="05" // AGG MINERAÇÃO
cAgenc:="7499"
endif
IF cEmpr="06" // MCT MINERAÇÃO
cAgenc:="2979"
endif
IF cEmpr="07" // MINERAÇÃO AGUAS BOAS
cAgenc:="XXXX"
endif

IF cEmpr="01"   // AVB MINERAÇÃO
cConta:="370008"
endif
IF cEmpr="02"   // VALE DOURADO MINERAÇÃO
cConta:="XXXXXX"
endif
IF cEmpr="03"   // SANTA LUCIA MINERAÇÃO
cConta:="640830"
endif
IF cEmpr="04"   // AVANCO RESOURCES MINERAÇÃO
cConta:="918954"
endif
IF cEmpr="05"  // AGG MINERAÇÃO
cConta:="248891"
endif
IF cEmpr="06"   // MCT MINERAÇÃO
cConta:="139009"
endif
IF cEmpr="07"   // MINERAÇÃO AGUAS BOAS
cConta:="XXXXXX"
endif
DBSELECTAREA("SA6")
SA6->(DbSetOrder(1))
If SA6->(DbSeek(xFilial("SA6")+cBanco+cAgenc+Cconta))
cBanco := SA6->A6_COD
cAgenc := SA6->A6_AGENCIA
cConta := SA6->A6_NUMCON
Endif
 CN9->(DbSetOrder(1))
    If CN9->(DbSeek(cChave))
        A300lAdian(.T.) //Ativa operação adiantamento
 
      //  cModelId:= CN9->(IIF(CN9_ESPCTR == '1', 'CNTA300', 'CNTA301'))
          oModel  := FwLoadModel("CNTA300")
          oModel:SetOperation(MODEL_OPERATION_UPDATE)
        If oModel:Activate()
            oMdlCNX := oModel:GetModel("CNXDETAIL")
 
            cNumero := StrZero(oMdlCNX:Length(), GetSx3Cache('CNX_NUMERO','X3_TAMANHO'))
            oMdlCNX:SetValue('CNX_NUMERO', cNumero)
 
            If cModelId == 'CNTA301'//Venda               
                oMdlCNX:SetValue('CNX_CLIENT', oModel:GetValue('CNCDETAIL', 'CNC_CLIENT'))
                oMdlCNX:SetValue('CNX_LOJACL', oModel:GetValue('CNCDETAIL', 'CNC_LOJACL'))
            Else//Compra
                oMdlCNX:SetValue('CNX_FORNEC', oModel:GetValue('CNCDETAIL', 'CNC_CODIGO'))
                oMdlCNX:SetValue('CNX_LJFORN', oModel:GetValue('CNCDETAIL', 'CNC_LOJA'))
            EndIf
 
            oMdlCNX:SetValue('CNX_VLADT' , CN9->(CN9_XVLADT))
            oMdlCNX:SetValue('CNX_BANCO' , cBanco) 
            oMdlCNX:SetValue('CNX_AGENCI', cAgenc) 
            oMdlCNX:SetValue('CNX_CONTA' , cConta) 
             
            If oModel:VldData()
                oModel:CommitData()
            EndIf
        EndIf
 
 
        if oModel:HasErrorMessage()
            aErro := aClone(oModel:GetErrorMessage())
        endif
 
        If oModel:IsActive()
            oModel:DeActivate()
        EndIf
        FreeObj(oModel)
 
        A300lAdian(.F.) //Desativa operação adiantamento
         
        If !Empty(aErro)
            VarInfo('Erro apresentado:', aErro)           
        EndIf
    EndIf

 
Return
     
Return


User Function valoradia()
Local lRet := .T.
if  M->CN9_XVLADT>M->CN9_SALDO
lRet := .F.
Endif
Return (lRet)


User Function parceadia()
Local lRet := .T.
if  M->CN9_XVLADT>0 
if M->CN9_XPAADT=0
lRet := .F.
endif
Endif
Return (lRet)




