#Amir Bagaon
    .section    .rodata
invalid_string:    .string "invalid input!\n"
.text

#Return pstr length
.global pstrlen
    .type   pstrlen,   @function
pstrlen:
    movq $0, %rax    #Put 0 in rax
    movb %dil, %al   #Get the first byte from %rdi. This byte is the length, as we set it in the main program
    ret


#Pstring* replaceChar(Pstring* pstr, char old, char new)
#Remind: %rsi contains old char, %sil - old char. %rdx contains new char, %dl - new char
.globl  replaceChar
        .type   replaceChar,   @function
replaceChar:
        #r9 - pstr backup. r10 - Loop counter
        leaq 1(%rdi), %r9               #save the pstring in r9 without its length
        movq $0, %r10                   #Put 0 in r10
        movb %dil, %r10b                #Get pstr length as described above, and put in the counter
        
        cmp 	$1, %r10		       #Compare length and 0
        jl .Finish                      #If length < 1 -- should end
        jmp .Loop                       #Else, we should continue

.Loop:
	movb 	(%r9),%cl	       #Move pstring's first char
	cmpb	%sil,%cl		       #Compare to old char
	je .Equal                       #If equal
	jmp .Next                       #Else

.Equal:                                  #When equal, Replace old and new char
	movb 	%dl,(%r9)               #Replace old char with new char.
	jmp .Next		       #Go to check the Next char

.Next:
	incq	%r9			#Look at Next char (by increasing addres by 1)
	decq	%r10			#Decrease counter by 1
    js .Finish 				#If counter == 0 ->Finish
    jmp .Loop

.Finish:
    #Return the pstr (without length)
    leaq 1(%rdi), %rax
    ret
    
    
#pstrijcpy
#Remind: 1st:   %rdi  2nd    %rsi  3rd %rdx 4th %rcx  
#Params: Pstring dst, Pstring src, char i, char j

.globl  pstrijcpy
        .type   pstrijcpy,   @function
pstrijcpy:

        #Check if its valid input or not
              
        cmpq	%rdx,%rcx	#If j (end index) < i (start index) then its invalid
        jl 	.NotValid

        movq  $0, %r8
        movb 	(%rdi),%r8b 			#Move pstr1 length to r8-register
        cmpq	%rcx,%r8			#If length < j then its invalid
        jl .NotValid 
        cmpq	$0,%rdx			#If i < 0 then its invalid
        jl .NotValid
        #now we know pstr1 Length >= j >= i >= 0

        movq  $0, %r8
        movb 	(%rsi),%r8b 			#Move pstr2 length to r8-register
        cmpq	%rcx,%r8			#If length < j then its invalid
        jl .NotValid 
        cmpq	$0,%rdx			#If i < 0 then its invalid
        jl .NotValid
      #now we know pstr2 Length >= j >= i >= 0
      #We know that all indexes are Fine        
       
      movq   $0,%r8
      movq   $0,%r9
      movb   %dl,%r8b		       #Move i to r8
      movb   %cl,%r9b			#Move j to r9

      #Counter- r10	
      movq $0, %r10                      #Put 0 in counter
      #Reminder: rdi - pstr1, rsi - pstr
	incq	%rdi				#Skip pstr1 length
	incq	%rsi 				#Skip pstr2 length
	jmp .ShouldStart

.ShouldStart:		
	cmpq	%r8,%r10			#If the counter >= i 
	jge    .CopyChar			#We start copying
	jmp    .Increase			#Else, we increase the counter and others

.CopyChar:
      #Moving the value of byte in pstr2 (src, in %rsi) to pstr1 (dst, in %rdi)
      #Using rax help to move value
	movb   (%rsi),%al 			
	movb 	%al,(%rdi)			
       #Keep increasing counter and others
       incq	%r10				#Counter
       incq	%rdi				#pstr1 next char
	incq	%rsi				#pstr2 next char
	jmp .ShouldStop

.Increase:						
      #Increase by 1 the counter, pstr1 current char and pstr2 current char
	incq	%r10				#Counter
	incq	%rdi				#pstr1 next char
	incq	%rsi				#pstr2 next char
	jmp .ShouldStart

.ShouldStop:		
	cmpq	%r9,%r10	#If counter==j, we should stop
	jg .Stop
	jmp .CopyChar

.Stop:
    	ret

.NotValid:
       #Print that it's invalid input
    	movq    $0,%rax                
       movq    $invalid_string,%rdi
    	call    printf
    	ret




.globl  swapCase        #Param: Pstring * pstr
        .type   swapCase,   @function
        #Note: Values In ASCII Table: A-Z:65-90, a-z 97-122
        #Diff between Big and Small letter: 32
swapCase:
        
        movq %rdi, %r8                  #Save pstr address in r8
        #Counter will be %r10
        movq $0, %r10                   #Put 0 in r10
        movb %dil, %r10b                #Get pstr length and put in counter
        incq %rdi                       #Skip pstr length
        
        jmp .LOOPSWAP

.LOOPSWAP:
        cmp 	$0, %r10			#If length <= 0 we should stop
        jle .ENDSWAP
        
       movb 	(%rdi),%cl			#Current char in pstr1
       #Check the range: between 65 to 122
       cmpb	$122,%cl			#Compare with 'z' value
	jg .NEXTCHAR				#If its over 'z', Go to Next char		
	cmpb	$65,%cl			#Compare with 'A' value
	jl .NEXTCHAR				#If its below 'A', Go to Next char	

       #Now we know that its between 65 to 122
       cmpb	$91,%cl		#if its between 65 to 90 its Capital
	jl .CapitalLetter
	
       cmpb	$96,%cl		#if its between 97 and 122 its a small letter
	jg .SmallLetter
	
       #Else, its just a sign
       jmp .NEXTCHAR

.NEXTCHAR:
	decq	%r10				#Decrease counter by 1
	incq	%rdi				#Look at next char
    	jmp .LOOPSWAP


.CapitalLetter:
	addq 	$32,(%rdi)			#Add the difference between low and high letter
	jmp .NEXTCHAR

.SmallLetter:
       subq 	$32,(%rdi)			#Change to big letter.
	jmp .NEXTCHAR

.ENDSWAP:
	movq 	%r8,%rax	        #Return the pstr (include its length)
	ret

