#-----IMPLEMENTACAO DE UMA ARVORE BINÁRIA-----

	.data
	.align 0

#reserva espaco para uma string de 0s e 1s
buffer: .space 17

#labels responsaveis pela interface

inicio: 	.asciiz "\n\nEscolha uma opcao (1 a 5)\n"
opcoes:		.asciiz "1. Insercao \n 2. Remover \n 3. Busca \n 4. Visualizacao \n 5. Fim"
newline:	.asciiz "\n"
#-------------------------------------------------------------------------------------------
insertion: 	.asciiz ">> Digite o binário para insercao: "
search:		.asciiz ">> Digite o binário para busca: "
succesin:	.asciiz ">> Chave inserida com sucesso!\n"
errorin: 	.asciiz ">> Chave inválida. Insira somente numeros binarios (ou -1 retorna ao menu)\n"
repeatin:	.asciiz ">> Chave repetida. Insercao não permitida.\n"
returnMenu:	.asciiz "Retornando para o menu"
#-----------------------------------------------------------------------------------
remotion: 	.asciiz ">> Digite o binário para remoção: "
succesSearch:	.asciiz ">> Chave encontrada na árvore: "
way:		.asciiz ">> Caminho percorrido: "
succesRemove:	.asciiz "Chave removida com sucesso\n"
errorin2: 	.asciiz ">> Chave inválida. Insira somente numeros binários (ou -1 retorna ao menu)"
failSearch:	.asciiz ">> Chave não encontrada na arvore: -1"
raiz: .asciiz " raíz"
raiz2: .asciiz "raíz"
um: .asciiz "1"
zero: .asciiz "0"
dir: .asciiz ", dir"
esq: .asciiz ", esq"
T: .asciiz ", T"
NT: .asciiz ", NT"
N: .asciiz "\n>> N"
virgula: .asciiz ", "
null: .asciiz ", null"
abreParenteses: .asciiz " ("
fechaParenteses: .asciiz ")"

	.text

main:
	#Inicio a arvore com o nó raiz
	addi $sp, $sp, -12
	addi $t9, $sp, -12 		#guarda a próxima posição livre da pilha
	li $t1, 0 			#Quantidade de elementos na arvore
	sw $t1, 0($sp) 			#Nó esquerdo não tem filho
	sw $t1, 4($sp) 			#Nó direito não tem filho
	sw $t1, 8($sp) 			#Aqui defino que raiz não é o final de uma string (não seria necessário, pois a raiz nunca será um nó raiz mas padroniza o código, facilitando a programação)
	
	#entra no menu com loop
	addi $a1, $zero, 0		#utiliza variavel para entrar, salva $ra de main se for a primeira vez do menu
	
	j menu

fim:
	li $v0, 10			#codigo para terminar o programa
	
	syscall

	
####### menu ########################################
menu: 
	addi $a0, $zero, 0 		#coloca 0 para nao haver lixo
	li $a0, 4			#chamada para printar a msg de inicio
	la $a0, inicio
	li $v0, 4	
	
	syscall
	
	la $a0, opcoes
	li $v0, 4			#printa opcoes
	
	syscall
	
	la $a0, newline
	li $v0, 4			#printa nova linha
	
	syscall
	
	li $v0, 5			#recebe a opcao do usuario em $v0
	
	syscall
	
	addi $a0, $v0, 0 		#guarda a opcao em $a0
	addi $t4, $a0, 0		#guarda a opcao em t4 para acessar mais tarde
	
					#momento em que sera chamada a "funcao" de acordo com a entrada do usuario
	
	beq $a0, 1, insercao
	beq $a0, 2, remocao
	beq $a0, 3, busca
	beq $a0, 4, visualizacao
	beq $a0, 5, fim
	
############################################ funcoes relacionadas à inserção ################################
criaNoEsq:
	sw $t9, 0($t7)			 #o filho esquerdo de t7 aponta para a próxima posição vazia da pilha
					 #t9 é inicializado com os valores padrões
	sw $zero, 0($t9) 
	sw $zero, 4($t9)
	sw $zero, 8($t9)
	
	addi $t7, $t9, 0 		#a posição atual passa a ser a do novo nó criado
	addi $t9, $t9, -12 		#t9 volta a apontar para a proxima posição vazia
	
	j loopInsere 			#Volta a executar o loop de inserção

andaEsquerdaI:
	lw $t8, 0($t7) 			#$t8 recebe a posição do nó à esquerda
	beq $t8, 0, criaNoEsq 		#se a posição for 0, o nó será criado, caso contrario, ele existe
	addi $t7, $t8, 0 		#se ele existe, t7 passa à armazenar a posição do nó
	
	j loopInsere 			#Volta a executar o loop de inserção

criaNoDir:
	sw $t9, 4($t7) 			#o filho direito de t7 aponta para a próxima posição vazia da pilha
					#t9 é inicializado com os valores padrões
	sw $zero, 0($t9)
	sw $zero, 4($t9)
	sw $zero, 8($t9)
	
	addi $t7, $t9, 0 		#a posição atual passa a ser a do novo nó criado
	addi $t9, $t9, -12 		#t9 volta a apontar para a proxima posição vazia
	
	j loopInsere			#Volta a executar o loop de inserção

andaDireitaI:
	lw $t8, 4($t7) 			#$t8 recebe a posição do nó à direita
	beq $t8, 0, criaNoDir 		#se a posição for 0, o nó será criado, caso contrario, ele existe
	addi $t7, $t8, 0 		#se ele existe, t7 passa à armazenar a posição do nó
	
	j loopInsere 			#Volta a executar o loop de inserção

insercao:
	
	la $a0, insertion
	li $v0, 4
	
	syscall
	
	jal valida
	
	addi $t7, $sp, 0 		#t7 recebe posição inicial da pilha
					#nesse momento, t2 guarda o tamanho da string
	li $t5, -1 			#t5 passa ser meu contador

loopInsere:

	addi $t5, $t5, 1		 #anda 1 com o contador
	lb $t3, buffer($t5) 		 #le byte da string
	beq $t3, 48, andaEsquerdaI 	 #se for 0, anda para esquerda
	beq $t3, 49, andaDireitaI  	#se for 1, anda para direita #aqui acaba o loop
	
	#caso encontre o \n
	
	lw $a0, 8($t7) 			#salva a informação que represente se o ultimo nó é ou não o final de uma string 
	beq $a0, 1, printaRepeatin 	#caso seja 1, significa que a string já foi inserida anteriormente
	addi $a0, $zero, 1 		#caso contrario, indico nesse nó que uma string termina aqui
	sw $a0, 8($t7)
	
	#printa a msg de inserção bem sucedida
	la $a0, succesin
	li $v0, 4
	
	syscall
	
	j insercao

printaRepeatin:
	la $a0, repeatin
	li $v0, 4
	
	syscall
	
	j insercao
################################################ acaba funções relacionadas à inserção ##########################

################################################funções relacionadas à busca ####################################
busca:
	beq $t4, 2 printaFraseRemocao
	la $a0, search
	
retomadaBusca:
	li $v0, 4
	
	syscall
	
	jal valida
	addi $t7, $sp, 0 		#t7 recebe posição inicial da pilha
	
	#nesse momento, t2 guarda o tamanho da string
	
	li $t5, -1 			#t5 passa ser meu contador
	addi $s0, $zero, 0 		#guardei o zero no em s0
	sw $s0, 0($t9) 			#guardo 0 na primeira posição vazia da pilha para indicar que passei pela raiz
	addi $s2, $t9, 0 		#s2 inicializado apontando para ultima casa preenchida
	
loopBusca:
	addi $t5, $t5, 1 		#anda 1 com o contador
	lb $t3, buffer($t5) 		#le byte da string
	addi $s2, $s2, -4	 	#s2 passa a apontar para a proxima posição vazia da pilha
	beq $t3, 48, andaEsquerdaB 	#se for 0, anda para esquerda
	beq $t3, 49, andaDireitaB 	#se for 1, anda para direita #aqui acaba o loop
	
	#caso encontre o \n
	addi $s2, $s2, 4 		#faço s2 apontar para a ultima posição preenchida
	lw $a0, 8($t7) 			#salvo a informação que represente se o ultimo nó é ou não o final de uma string 
	beq $a0, 0, printaFailSearch 	#caso seja 0, significa que a string não foi inserida anteriormente
	
	#printa a msg de busca bem sucedida
	j printaSuccesSearch

andaDireitaB:
	lw $t8, 4($t7) 			#$t8 recebe a posição do nó à direita
	addi $s0, $zero, 2 		#2 representa que andei pra direita
	sw $s0, 0($s2) 			#salvo o caminho andado na pilha
	beq $t8, 0, printaFailSearch 	#se a posição for 0, o nó não existe e a busca para
	addi $t7, $t8, 0 		#se ele existe, t7 passa à armazenar a posição do nó
	
	j loopBusca 			#Volta a executar o loop de busca


andaEsquerdaB:
	lw $t8, 0($t7)	 		#$t8 recebe a posição do nó à esquerda
	addi $s0, $zero, 1 		#1 representa que andei pra esquerda
	sw $s0, 0($s2) 			#salvo o caminho andado na pilha
	beq $t8, 0, printaFailSearch 	#se a posição for 0, o nó não existe e a busca para
	addi $t7, $t8, 0 		#se ele existe, t7 passa à armazenar a posição do nó
	
	j loopBusca 			#Volta a executar o loop de busca


printaFailSearch:
	li $t0, 0
	la $a0, failSearch
	li $v0, 4
	
	syscall
	
	la $a0, newline
	li $v0, 4
	
	syscall
	
	j printaCaminho

printaSuccesSearch:
	li $t0, 1
	la $a0, succesSearch
	li $v0, 4
	
	syscall
	
	la $a0, buffer
	li $v0, 4
	
	syscall
	
	j printaCaminho

printaCaminho:
	addi $s0, $t9, 0 		#inicializa variavel s0, com o valor referente a onde está o primeiro nó percorrido (no caso raiz)
	
	#printo a frase caminho percorrido e já printo raiz também
	la $a0, way
	li $v0, 4
	
	syscall
	la $a0, raiz 			#já imprimo a raiz, pois sempre passo por ela
	li $v0, 4
	
	syscall
	
loopPrintaCaminho:
	addi $s0, $s0, -4 		#passa a guardar a posição do proximo nó percorrido
	lw $s1, 0($s0)
	addi $s4, $s0, 0		 #coloca s0 em s4
	
					# enquanto s0 for maior ou igual s2 ele entra na condição bgez
	sub $s4, $s4, $s2
	bgez $s4, verificaDir
	la $a0, newline
	li $v0, 4
	
	syscall
	
	beq $t4, 2, retomaRemocao
	
	j busca

verificaDir:
	beq $s1, 1, printaEsq
	beq $s1, 2, printaDir

printaDir:
	la $a0, dir
	li $v0, 4
	
	syscall
	
	j loopPrintaCaminho

printaEsq:
	la $a0, esq
	li $v0, 4
	
	syscall
	
	j loopPrintaCaminho



################################################ acaba funções relacionadas à busca ##########################



################################################funções relacionadas à remoção ####################################
remocao:
	j busca
	
retomaRemocao:
	beq $t0, 1, removeString 		#caso a string tenha sido encontrada, a mesma será removida
	
	j remocao
	
removeString:
	sw $zero, 8($t7)
	lw $t8, 0($t7)
	
	bne $t8, 0, remocao
	lw $t8, 4($t7)
	
	bne $t8, 0, remocao
	la $a0, succesRemove
	li $v0, 4
	
	syscall
	
	addi $t7, $sp, 0 			#t7 recebe posição inicial da pilha
	
	#nesse momento, t2 guarda o tamanho da string
	li $t5, -1 				#t5 passa ser meu contador
	addi $s0, $sp, 0 			#guardei o a raiz em s0
	sw $s0, 0($t9) 				#guardo raiz na primeira posição vazia da pilha para indicar que passei pela raiz
	addi $s2, $t9, 0 			#s2 inicializado apontando para ultima casa preenchida
	
loopRemove:

	addi $t5, $t5, 1 			#anda 1 com o contador
	lb $t3, buffer($t5) 			#le byte da string
	addi $s2, $s2, -4 			#s2 passa a apontar para a proxima posição vazia da pilha
	
	beq $t3, 48, andaEsquerdaR 		#se for 0, anda para esquerda
	beq $t3, 49, andaDireitaR 		#se for 1, anda para direita #aqui acaba o loop
	
	#printa a msg de busca bem sucedida
	
	j removeNosRestantes
	
removeNosRestantes:

	addi $s0, $s2, 0 			#inicializa variavel s0, com o valor referente a onde está o último nó percorrido
	
loopRemoveNosRestantes:
	lw $t6, 0($s0) 				#guardo o nó filho ao nó verificado
	addi $s0, $s0, 4 			#passa a guardar a posição do proximo nó percorrido
	lw $s1, 0($s0)
	addi $s4, $s0, 0 			#coloca s0 em s4
	
	# enquanto s0 for menor ou igual t9(nó raiz) ele entra na condição blez
	sub $s4, $s4, $t9
	blez $s4, corrigeNo
	
	j remocao
	
verificaSeExisteFilho1: 			#se existe outro filho, não é mais necessário corrigir os outros nós

	lw $t7, 4($s1)
	bne $t7, 0, remocao
	
	j corrigeNoCont
	
verificaSeExisteFilho0:

	lw $t7, 0($s1)
	bne $t7, 0, remocao
	
	j corrigeNoCont
	
removeFilho0:

	sw $zero, 0($s1)
	
	j verificaSeExisteFilho1
	
removeFilho1:
	sw $zero, 4($s1)
	
	j verificaSeExisteFilho0
	
corrigeNo:
	lw $t7, 0($s1)
	sub $t7, $t7, $t6
	beq $t7, 0, removeFilho0
	
	lw $t7, 4($s1)
	sub $t7, $t7, $t6
	beq $t7, 0, removeFilho1
	
corrigeNoCont:
	lw $t7, 8($s1)
	beq $t7, 1, remocao
	
	j loopRemoveNosRestantes

andaDireitaR:
	lw $t8, 4($t7) 			#$t8 recebe a posição do nó à direita
	addi $s0, $t8, 0 
	sw $s0, 0($s2) 			#salvo o caminho andado na pilha
	addi $t7, $t8, 0 		#t7 passa à armazenar a posição do nó
	
	j loopRemove 			#Volta a executar o loop de busca


andaEsquerdaR:
	lw $t8, 0($t7) 			#$t8 recebe a posição do nó à esquerda
	addi $s0, $t8, 0
	sw $s0, 0($s2) 			#salvo o caminho andado na pilha
	addi $t7, $t8, 0 		#t7 passa à armazenar a posição do nó
	
	j loopRemove 			#Volta a executar o loop de busca

printaFraseRemocao:
	la $a0, remotion
	
	j retomadaBusca

################################################ acaba funções relacionadas à remoção ##########################


################################################funções relacionadas à visualização ####################################
printaNivel:
	la $a0, N
	li $v0, 4
	
	syscall
	
	addi $a0, $t2, 0
	li $v0, 1
	
	syscall
	
	addi $t6, $t2, 0
	
	j continuaLoopImprime
	
printaNoZero:
	la $a0, zero
	li $v0, 4
	
	syscall
	
	j continuaLoopImprime2
	
printaNoUm:
	la $a0, um
	li $v0, 4
	
	syscall
	
	j continuaLoopImprime2
	
printaNoRaiz:
	la $a0, raiz2
	li $v0, 4
	
	syscall
	
	j continuaLoopImprime2
	
verificaSeEhTerminal:
	lw $s7, 8($s0)
	beq $s7, 1, printaTerminal
	beq $s7, 0, printaNaoTerminal

printaTerminal:
	la $a0, T
	li $v0, 4
	
	syscall	
	
	jr $ra
	
printaNaoTerminal:
	la $a0, NT
	li $v0, 4
	
	syscall	
	
	jr $ra

verificaFilhoEsq:
	lw $s7, 0($s0)
	beq $s7, 0, printaNull
	la $a0, virgula
	li $v0, 4
	
	syscall
	
	addi $a0, $s7, 0
	li $v0, 1
	
	syscall
	
	jr $ra

verificaFilhoDir:
	lw $s7, 4($s0)
	beq $s7, 0, printaNull
	la $a0, virgula
	li $v0, 4
	
	syscall
	
	addi $a0, $s7, 0
	li $v0, 1
	
	syscall
	
	jr $ra

printaNull:
	la $a0, null
	li $v0, 4
	
	syscall
	
	jr $ra
	
insereFilaEsq:
	sw $s7, 4($s4)
	sw $zero, 0($s4)
	
	j continuaLoopImprime3

insereFilaDir:
	sw $s7, 4($s4)
	addi $a0, $zero, 1
	sw $a0, 0($s4)
	
	j continuaLoopImprime4
	
somaNivel:
	addi $t2, $t2, 1
	addi $s3, $s4, 0 			#s3 passa a apontar para a posição do ultimo elemento da fila pertencente ao nivel
		
	jr $ra
	
verificaNivel:
	sub $a0, $s1, $s3
	blez $a0, somaNivel
	
	jr $ra

visualizacao:
	addi $t2, $zero, 2
	addi $s1, $t9, 0 			#s1 inicializado apontando para primeira casa vazia da pilha
	addi $s0, $sp, 0 			#s0 inicializado apontando para a raiz da arvore
	
	sw $s0, 4($s1) 				#coloco a raiz na fila 
	sw $t2, 0($s1) 				# guardo o valor 2 que representa que o nó é uma raiz
	
	addi $t2, $zero, 0 			#representa o nivel atual
	addi $t6, $t2, -1 			#t6 guarda o nivel anterior
	addi $s3, $s1, 0 			#fim do nivel
	addi $s4, $s1, 0 			#s4 aponta para ultima posição da fila
	
loopVisualizacao:
	sub $t5, $t6, $t2
	bltz $t5, printaNivel
	
continuaLoopImprime:
	#carrega item da fila
	lw $t1, 0($s1)
	lw $s0, 4($s1)
	
	#abre parenteses
	la $a0, abreParenteses
	li $v0, 4
	
	syscall
	
	#verifica se é raiz, 0 ou 1 e printa
	beq $t1, 0, printaNoZero
	beq $t1, 1, printaNoUm
	beq $t1, 2, printaNoRaiz
	
continuaLoopImprime2:
	jal verificaSeEhTerminal
	#verifica os filhos do nó atual
	
	jal verificaFilhoEsq
	
	jal verificaFilhoDir
	
	
	la $a0, fechaParenteses
	li $v0, 4
	syscall
	
	#realiza a inserção de um nó esquerdo na fila
	addi $s4, $s4, -8
	lw $s7, 0($s0)
	bne $s7, 0, insereFilaEsq
	addi $s4, $s4, 8 			#caso não seja inserido, volta a apontar para a ultima posição
	
continuaLoopImprime3:
	#realiza a inserção de um nó direito na fila
	addi $s4, $s4, -8
	lw $s7, 4($s0)
	bne $s7, 0, insereFilaDir
	addi $s4, $s4, 8 			#caso não seja inserido, volta a apontar para a ultima posição
	
continuaLoopImprime4:

	jal verificaNivel
	
	#verifica se acabou a fila
	sub $a0, $s1, $s4	
	blez $a0, menu
	addi $s1, $s1, -8
	
	j loopVisualizacao
	
################################################ acaba funções relacionadas à visualização ##########################


################################################ funções relacionadas à validação ###############################

testaSeEhUm: 					#só entra aquis e o primeiro byte for '-'
	addi $t2, $t2, 1 
	lb $t3, buffer($t2) 			#leio o segunda byte
	beq $t3, 49, menu			#se for 1, retorna ao menu
	
	#se não for um, volto para validação
	li $t2, 0
	
	j inicioLoopValida
	
testaSeNaoEhUm:

	bne $t3, 49, printaErroin 		#verifica se é diferente de 0 
	
	j somaContador
	
valida:
	li $v0, 8
	la $a0, buffer
	li $a1, 17
	
	syscall
	
	li $t2, 0 				#utilizo t2 como contador
	lb $t3, buffer($t2) 			#leio o primeiro byte
	beq $t3, 45, testaSeEhUm 		#se for -, verifico se o prox byte é 1
	
inicioLoopValida:
	lb $t3, buffer($t2)
	
	beq $t3, 10, terminaValidacao 		#verifica se é \n, se sim, terminou a validação
	bne $t3, 48, testaSeNaoEhUm 		#verifica se é diferente de 0, se for, verifica se é 1
	
somaContador:
	addi $t2, $t2, 1 			#soma 1 ao contador
	
	j  inicioLoopValida

	
	li $v0, 4
	syscall 				#imprime a string so de boas
	
terminaValidacao:

	jr $ra

printaErroin:
	li $v0, 4
	la $a0, errorin
	syscall
	beq $t4, 1, insercao
	beq $t4, 2, remocao
	beq $t4, 3, busca	

################################################ acaba funções relacionadas à validação ##########################