# Trabalho 1 - Microprocessadores
# Feito por Luiz Susin e Lissandra Fischer
#
# Como utilizar:
# 1 - Compile o c�digo
# 2 - Abra o Mars Bot
# 3 - Abra o Mars Scanner
# 4 - Selecione um arquivo no Mars Scanner
# 5 - Selecione as op��es de acordo com o necess�rio
# 6 - Clique em "Calcular e Enviar"
# 7 - Execute o c�digo
#
# Haja vista a inviabilidade de utilizar registradores para salvar
# todos os endere�os a serem utilizados, faz-se uso da lista abaixo
# para que os endere�os (MMIO) fiquem catalogados para uso interno:
#
# Mars Bot Addresses
# Endere�o para dire��o do rob� - 0xffff8010
# Endere�o para pintar - 0xffff8020
# Endere�o para coordenada X - 0xffff8030
# Endere�o para coordenada Y - 0xffff8040
# Endere�o para mover ou parar o rob� - 0xffff8050
#
# Mars Scanner Addresses
# Endere�o para pular para o pr�ximo ponto (X,Y) - 0xffff9000
# Endere�o de in�cio X - 0xffff9020
# Endere�o de in�cio Y - 0xffff9040
# Endere�o para o pr�ximo ponto traced X - 0xffff9060
# Endere�o para o pr�ximo ponto traced Y - 0xffff9080
#
# No Mars Scanner, o ponto (-1,-1) indica fim das marca��es e t�rmino da imagem. Nenhum outro ponto pode ser negativo.
.data
.text
    j PROC_main #Pula para a main
    
    # Procedimento para movimentar em X
    # Utiliza Pooling para movimenta��o
    # Entradas:
    #     $a0 = Posi��o X
    #     $a1 = Paint on Point (se 1, pintar, se 0, manter)
    PROC_moveX:
        move $t0,$a0 # Move de a0 para t0
        move $t1,$a1 # Move de a1 para t1
        
        li $s0,0xFFFF8030 # Armazena o endere�o em s0
        lw $t2,0($s0) # Carrega para t2 o valor de dentro do endere�o de s0
        
        sub $t3,$t0,$t2 # Subtrai o valor de t0 com o valor de t2 para verificar se deve se mover para a direita ou para a esquerda
       	
       	li $s0,0xFFFF8010 #Carrega o endere�o para dentro de $s0
       	
       	bgtz $t3,rightSector # Verifica-se se deve-se mover para direita ou para esquerda (90 ou 270)
       	
       	#se para esquerda...
       	li $t3,270 #Carrega $t3 com o valor 270 (dire��o)
       	sw $t3,0($s0) #Escreve $t3 dentro do endere�o $s0
       	li $s0,0xFFFF8050 #Carrega o endere�o em $s0
        li $t3,1 #Define o valor 1 dentro do registrador $t3 para que o rob� se mova
        sw $t3,0($s0) 
        
        li $s0,0xFFFF8030
            
        loopSectorLeft:
            lw $t2,0($s0)
        blt $t0,$t2,loopSectorLeft #Faz o pooling at� chegar na posi��o referida
        
        j paintSectorX
       	
       	#se para direita... fazer a mesma movimenta��o de para a esquerda, mas com outra dire��o
       	rightSector:
       	    li $t3,90
       	    sw $t3,0($s0)
       	    
       	    li $s0,0xFFFF8050
            li $t3,1
            sw $t3,0($s0) 
        
            li $s0,0xFFFF8030
            
            loopSectorRight:
                lw $t2,0($s0)
            blt $t2,$t0,loopSectorRight
        
        paintSectorX:
            li $s0,0xFFFF8050
            sw $zero,0($s0) #Cessa o movimento
        
            beqz $t1,endSectorX #Se for pintar, prossegue, se n�o, pula para o final
        
            li $s0, 0xFFFF8020 #Move o endere�o para dentro de $s0
            li $t3,1
            sw $t3, 0($s0) # Ativa a pintura
        
            sw $zero, 0($s0) # Desativa a pintura (realizou a pintura de um ponto)
        
        endSectorX:
    jr $ra
    
    # Procedimento para movimentar em Y
    # Utiliza Pooling para movimenta��o
    # Entradas:
    #     $a0 = Posi��o Y
    #     $a1 = Paint on Point (se 1, pintar, se 0, manter)
    PROC_moveY:
        move $t0,$a0 # Move de a0 para t0
        move $t1,$a1 # Move de a1 para t1
        
        li $s0,0xFFFF8040 # Armazena o endere�o em s0
        lw $t2,0($s0) # Carrega para t2 o valor de dentro do endere�o de s0
        
        sub $t3,$t0,$t2 # Subtrai o valor de t0 com o valor de t2
       	
       	li $s0,0xFFFF8010
       	
       	bltz $t3,upSector # Verifica-se se deve-se mover para cima ou para baixo (0 ou 180)
       	
       	li $t3,180
       	sw $t3,0($s0)
       	li $s0,0xFFFF8050
        li $t3,1
        sw $t3,0($s0) 
        
        li $s0,0xFFFF8040
            
        loopSectorDown:
            lw $t2,0($s0)
        blt $t2,$t0,loopSectorDown
        
        j paintSectorY
       	
       	upSector:
       	    sw $zero,0($s0)
       	    
       	    li $s0,0xFFFF8050
            li $t3,1
            sw $t3,0($s0) 
        
            li $s0,0xFFFF8040
            
            loopUpSector:
                lw $t2,0($s0)
            blt $t0,$t2,loopUpSector
        
        paintSectorY:
            li $s0,0xFFFF8050
            sw $zero,0($s0)
        
            beqz $t1,endSectorY
        
            li $s0, 0xFFFF8020
            li $t3,1
            sw $t3, 0($s0)
        
            sw $zero, 0($s0)
        
        endSectorY:
    jr $ra

    PROC_main:
        li $s0,0xFFFF9020 #Carrega o ponto inicial X
        lw $a0,0($s0)
        li $a1,0 #Sem pintar ao chegar
        jal PROC_moveX #Move para o ponto referido
        
        li $s0,0xFFFF9040 #Carregar o ponto inicial Y
        lw $a0,0($s0)
        li $a1,0 #Sem pintar ao chegar
        jal PROC_moveY #Move para o ponto referido
        
        loopMovement:
            li $s0,0xFFFF9060 #Carrega o ponto de pintura X
            lw $a0,0($s0)
            li $a1,1 #Pintar ao chegar no ponto
            jal PROC_moveX #Move para o ponto referido
            
            li $s0,0xFFFF9000 #Pulsar� 0 e 1 para pular para o pr�ximo ponto (pop do ponto na fila)
            li $t0,1
            sw $t0,0($s0)
            sw $zero,0($s0)
            
            li $s0,0xFFFF9080 #Carrega o ponto de pintura Y
            lw $t1,0($s0)
            
            li $s1,0xFFFF8040 #Carrega a posi��o atual Y
            lw $t2,0($s1)
            
            sub $t0,$t1,$t2
            beqz $t0,finalMovement  #Verifica se h� diferen�a entre os pontos e, se houver...
            
            #...movimentar� para o referido ponto, removendo a discrep�ncia em Y
            li $s0,0xFFFF9080
            lw $a0,0($s0)
            li $a1,0 #Sem pintar
            jal PROC_moveY #Movimentar� para o ponto
            
            #... se n�o
            finalMovement:
            li $s0,0xFFFF9060 #Verifica se o ponto � negativo, indicando fim do movimento
            lw $t0,0($s0)
        bgtz $t0,loopMovement #Se for, prossegue para baixo, se n�o, continuar� a pintura
        
        li $a0,0
        li $a1,0
        jal PROC_moveX #Move X para posi��o 0
        jal PROC_moveY #Move Y para a posi��o 0
        
