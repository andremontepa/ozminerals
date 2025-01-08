#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOTVS.CH"

User Function atucampos(cCampo)

	Local nOper
	Local lRet := .T.
	Local nCND := 1
	DEFAULT cCampo = ' '
	Local cNewVal

	oModel 		:= FWModelActive()
	oModelcne	:= oModel:GetModel('CNEDETAIL')

	nOper		:= oModelcne:GetOperation()
	nLinha 		:= oModelcne:Getline()



	If nLinha = 1 .and. nOper == 3 .and. oModelcne:Length() > 1
		If cCampo = 'CNE_XCC'
			cNewVal:= CNE_XCC
		ElseIf cCampo = 'CNE_XITCTA'
			cNewVal:= CNE_XITCTA
		ElseIf cCampo = 'CNE_XCLVL'
			cNewVal:= CNE_XCLVL
		ElseIf cCampo = 'CNE_DTENT'
			cNewVal:= CNE_DTENT
		EndIf
		If MsgNoYes("Deseja atualizar todas a linhas?","Atenção!")

			for nCND := 1 to oModelcne:Length()
				oModelcne:GoLine( nCND )
				if !oModelcne:isDeleted(nCND) .and. oModelcne:Getline()
					If cCampo = 'CNE_QUANT'
						oModelcne:SetValue("CNE_QUANT",0) //U_ATUCAMPOS('CNE_DTENT')
					ElseIf cCampo = 'CNE_XCC'
						oModelcne:SetValue("CNE_XCC",cNewVal)
					ElseIf cCampo = 'CNE_XITCTA'
						oModelcne:SetValue("CNE_XITCTA",cNewVal)
					ElseIf cCampo = 'CNE_XCLVL'
						oModelcne:SetValue("CNE_XCLVL",cNewVal)
					ElseIf cCampo = 'CNE_DTENT
						oModelcne:SetValue("CNE_DTENT",cNewVal)
					EndIf
				endif
			next
		EndIf
		oView:=FwViewActive()
		oView:Refresh()
	EndIf

Return lRet
