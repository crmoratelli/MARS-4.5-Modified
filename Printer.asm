# Trabalho 1 - Microprocessadores
# Feito por Luiz Susin e Lissandra Fischer
#
# Como utilizar:
# 1 - Compile o código
# 2 - Abra o Mars Bot
# 3 - Abra o Mars Scanner
# 4 - Selecione um arquivo no Mars Scanner
# 5 - Selecione as opções de acordo com o necessário
# 6 - Clique em "Calcular e Enviar"
# 7 - Execute o código
#
# Haja vista a inviabilidade de utilizar registradores para salvar
# todos os endereços a serem utilizados, faz-se uso da lista abaixo
# para que os endereços (MMIO) fiquem catalogados para uso interno:
#
# Mars Bot Addresses
# Endereço para direção do robô - 0xffff8010
# Endereço para pintar - 0xffff8020
# Endereço para coordenada X - 0xffff8030
# Endereço para coordenada Y - 0xffff8040
# Endereço para mover ou parar o robô - 0xffff8050
#
# Mars Scanner Addresses
# Endereço para pular para o próximo ponto (X,Y) - 0xffff9000
# Endereço de início X - 0xffff9020
# Endereço de início Y - 0xffff9040
# Endereço para o próximo ponto traced X - 0xffff9060
# Endereço para o próximo ponto traced Y - 0xffff9080
#
# No Mars Scanner, o ponto (-1,-1) indica fim das marcações e término da imagem. Nenhum outro ponto pode ser negativo.
.data
.text
    j PROC_main #Pula para a main
    
    # Procedimento para movimentar em X
    # Utiliza Pooling para movimentação
    # Entradas:
    #     $a0 = Posição X
    #     $a1 = Paint on Point (se 1, pintar, se 0, manter)
    PROC_moveX:
        move $t0,$a0 # Move de a0 para t0
        move $t1,$a1 # Move de a1 para t1
        
        li $s0,0xFFFF8030 # Armazena o endereço em s0
        lw $t2,0($s0) # Carrega para t2 o valor de dentro do endereço de s0
        
        sub $t3,$t0,$t2 # Subtrai o valor de t0 com o valor de t2 para verificar se deve se mover para a direita ou para a esquerda
       	
       	li $s0,0xFFFF8010 #Carrega o endereço para dentro de $s0
       	
       	bgtz $t3,rightSector # Verifica-se se deve-se mover para direita ou para esquerda (90 ou 270)
       	
       	#se para esquerda...
       	li $t3,270 #Carrega $t3 com o valor 270 (direção)
       	sw $t3,0($s0) #Escreve $t3 dentro do endereço $s0
       	li $s0,0xFFFF8050 #Carrega o endereço em $s0
        li $t3,1 #Define o valor 1 dentro do registrador $t3 para que o robô se mova
        sw $t3,0($s0) 
        
        li $s0,0xFFFF8030
            
        loopSectorLeft:
            lw $t2,0($s0)
        blt $t0,$t2,loopSectorLeft #Faz o pooling até chegar na posição referida
        
        j paintSectorX
       	
       	#se para direita... fazer a mesma movimentação de para a esquerda, mas com outra direção
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
        
            beqz $t1,endSectorX #Se for pintar, prossegue, se não, pula para o final
        
            li $s0, 0xFFFF8020 #Move o endereço para dentro de $s0
            li $t3,1
            sw $t3, 0($s0) # Ativa a pintura
        
            sw $zero, 0($s0) # Desativa a pintura (realizou a pintura de um ponto)
        
        endSectorX:
    jr $ra
    
    # Procedimento para movimentar em Y
    # Utiliza Pooling para movimentação
    # Entradas:
    #     $a0 = Posição Y
    #     $a1 = Paint on Point (se 1, pintar, se 0, manter)
    PROC_moveY:
        move $t0,$a0 # Move de a0 para t0
        move $t1,$a1 # Move de a1 para t1
        
        li $s0,0xFFFF8040 # Armazena o endereço em s0
        lw $t2,0($s0) # Carrega para t2 o valor de dentro do endereço de s0
        
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
            
            li $s0,0xFFFF9000 #Pulsará 0 e 1 para pular para o próximo ponto (pop do ponto na fila)
            li $t0,1
            sw $t0,0($s0)
            sw $zero,0($s0)
            
            li $s0,0xFFFF9080 #Carrega o ponto de pintura Y
            lw $t1,0($s0)
            
            li $s1,0xFFFF8040 #Carrega a posição atual Y
            lw $t2,0($s1)
            
            sub $t0,$t1,$t2
            beqz $t0,finalMovement  #Verifica se há diferença entre os pontos e, se houver...
            
            #...movimentará para o referido ponto, removendo a discrepância em Y
            li $s0,0xFFFF9080
            lw $a0,0($s0)
            li $a1,0 #Sem pintar
            jal PROC_moveY #Movimentará para o ponto
            
            #... se não
            finalMovement:
            li $s0,0xFFFF9060 #Verifica se o ponto é negativo, indicando fim do movimento
            lw $t0,0($s0)
        bgtz $t0,loopMovement #Se for, prossegue para baixo, se não, continuará a pintura
        
        li $a0,0
        li $a1,0
        jal PROC_moveX #Move X para posição 0
        jal PROC_moveY #Move Y para a posição 0
        
