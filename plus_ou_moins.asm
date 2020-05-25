;Auteur --> aiglematth
BITS 64

global _start

section .data
	entre_int     db "Entrez un entier dans [0,9] : ", 0 
	len_entre_int equ $-entre_int          

	len_str_resultat dq 20

	max_alea		 dq 10

	re_essai         db "Vous vous êtes trompé...", 10, 10, 0
	len_re_essai     equ $-re_essai

	str_plus         db "Visez plus haut !", 10, 0
	len_plus         equ $-str_plus

	str_moins        db "Visez moins haut !", 10, 0
	len_moins        equ $-str_moins

	gagne_str        db 10, "Vous avez trouvé : ", 0
	len_gagne        equ $-gagne_str

section .bss
	int_alea     resq 1  

	str_aff      resd 1

	str_resultat resb 20 ;On considère qu'avec 20 bytes on peut lire l'int

section .text

	;MAIN
	_start:

		call get_aleatoire

		mov [int_alea],rax

		essai:

			call demander_int
			mov rax,str_resultat
			call strlen

			cmp rax,1
			jg  essai

			mov  rax,[str_resultat]
			call ctoi

			mov  rbx,[int_alea]
			cmp  rax,rbx
			je   fin
			jl   plus_haut
			jg   moins_haut

		plus_haut:
			call plus
			jmp erreur

		moins_haut:
			call moins
			jmp erreur

		erreur:
			call erreur_re_essai
			jmp essai

		fin:
			call gagne

		call exit

	;;;;;;;;;;;;;;;;;;;;;;;
	;    INPUT / OUTPUT   ;
	;;;;;;;;;;;;;;;;;;;;;;;

	plus:

		;SYSWRITE
		mov rdx,len_plus
		
		mov rax,str_plus
		mov rsi,rax
		
		mov rax,1
		mov rdi,rax

		mov rax,1
		syscall

		ret

	moins:

		;SYSWRITE
		mov rdx,len_moins
		
		mov rax,str_moins
		mov rsi,rax
		
		mov rax,1
		mov rdi,rax

		mov rax,1
		syscall

		ret

	gagne:

		;SYSWRITE
		mov rdx,len_gagne
		
		mov rax,gagne_str
		mov rsi,rax
		
		mov rax,1
		mov rdi,rax

		mov rax,1
		syscall

		mov  rax,[int_alea]
		call itoc
		mov  [str_aff],rax
		mov  qword [str_aff+1],10

		;SYSWRITE
		mov rdx,2
		
		mov rax,str_aff
		mov rsi,rax
		
		mov rax,1
		mov rdi,rax

		mov rax,1
		syscall

		ret

	erreur_re_essai:

		;SYSWRITE
		mov rdx,len_re_essai
		
		mov rax,re_essai
		mov rsi,rax
		
		mov rax,1
		mov rdi,rax

		mov rax,1
		syscall

		ret

	demander_int:
		
		;SYSWRITE
		mov rdx,len_entre_int
		
		mov rax,entre_int
		mov rsi,rax
		
		mov rax,1
		mov rdi,rax

		mov rax,1
		syscall

		;SYSREAD
		mov rdx,[len_str_resultat]

		mov rax,str_resultat
		mov rsi,rax

		mov rax,1
		mov rdi,rax

		mov rax,0
		syscall

		mov rax,str_resultat
		call strlen
		dec rax

		mov byte [rsi+rax],0

		ret

	afficher_str_resultat:

		;SYSWRITE
		mov rdx,len_str_resultat
		
		mov rax,str_resultat
		mov rsi,rax
		
		mov rax,1
		mov rdi,rax

		mov rax,1
		syscall

		ret

	get_aleatoire:

		;On retourne un entier aleatoire entre 0 et 9

		rdrand rax
		mov    rdx,0
		mov    rbx,[max_alea]
		div    rbx
		mov    rax,rdx

		ret

	;;;;;;;;;;;;;;;;;;;;;;;
	;        UTILE        ;
	;;;;;;;;;;;;;;;;;;;;;;;

	exit:

		;SYSEXIT
		mov rax,0
		mov rdi,rax

		mov rax,60
		syscall

	strlen:

		;On retourne la longueur de la chaine de chars ou -1
		;RAX --> pointeur vers la chaine de chars

		;while RBX != 0
		mov rcx,0
		
		loop_rbx_not_zero:
			mov rbx,[rax + rcx]
			inc rcx	
			cmp rbx,0
			jne loop_rbx_not_zero

		dec rcx
		mov rax,rcx

		ret

	;;;;;;;;;;;;;;;;;;;;;;;
	;    CONVERSIONS      ;
	;;;;;;;;;;;;;;;;;;;;;;;

	ctoi:

		;On retourne la valeur entière du chiffre ou -1
		;RAX --> valeur du char

		;RBX = RAX-48 --> On va ensuite voir si c'est supérieur à 10
		mov rbx,rax
		sub rbx,48

		;if RBX >= 10
		cmp rbx,10
		jge return_dix

		;Retourne la val du decimal
		mov rax,rbx
		ret

		return_dix:
			mov rax,-1
		
		ret

	itoc:

		;On retourne la valeur entière du ascii ou -1
		;RAX --> valeur du char

		;if RAX < 10
		cmp rax,10
		jl  good_return

		;Retourne la val du decimal
		mov rax,-1
		ret

		good_return:
			;RBX = RAX+48 --> On va ensuite voir si c'est supérieur à 10
			add rax,48
		
		ret