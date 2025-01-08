#Include 'Protheus.ch'

User Function MTA161BUT()

Local aRotina:= PARAMIXB[1]

Local aAcoes:= { }   

AAdd( aRotina, {"#Visualizar Cotação", "A161MAPCOT()", 0, 2, 0, nil} )

//Validações do usuário

Return (aRotina)