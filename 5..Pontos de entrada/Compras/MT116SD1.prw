#include "PROTHEUS.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include 'parmtype.ch'
#include 'TOTVS.ch'


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  MT116SD1 �Autor  �Stephen Noel          � Data �  21/09/2022 ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca D1_TES                                               ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
*/

User Function MT116SD1()


	Local lRet := .T.//Valida��es de usu�rio.
	Local nEwTes:= Posicione('SF4',1, xFilial('SF4')+D1_TES,'F4_CODIGO2')

	If !empty(nEwTes)
		aparametros[12]:= nEwTes
	EndIf

Return(lRet)
