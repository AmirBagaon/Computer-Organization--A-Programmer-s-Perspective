# Amir Bagaon
    
            .section	.rodata

length_scan:	.string "%d"
string_scan:    .string "%s\0"
.text
.global main
main:
    movq %rsp, %rbp #for correct debugging
    # Starting
    pushq   %rbp	            	
    movq    %rsp,%rbp           	
    pushq   %r15                 
  #  pushq   %r14
    movq    $0, %rax	        #move 0 to %rax     	
 
    #Getting n1 length
    leaq    -4(%rsp), %rsp		#Change base-pointer (for next: bP) so it can get int
    movq    $length_scan, %rdi		#Move "%d" to 1st parameter to function
    movq    %rsp, %rsi 		        #Move the rsp to the 2nd parameter to function
    call    scanf
    movl    (%rsp),%r15d                    #Get the return value(n1 length) to %r15
    leaq    4(%rsp),%rsp               #Resize the stack														

    #Get the 1st string
    movq    $0, %rax		     	
    leaq    -1(%rsp),%rsp  			#Add one for '\0'
    subq    %r15, %rsp  			#move bP down for %r15 size
    movq    $string_scan,%rdi            #move "%s" with '\0' to the first param to func
    movq    %rsp, %rsi  			#Move rsp (the address) to the second param
    call    scanf                         #now (%rsp) contains the scanned value (pstr1)
    
    #Save the length with the string to create pstring
    subq    $1, %rsp                #decrease rsp by 1 for the length
    movb    %r15b, (%rsp)           #move 1 byte because its char that represent length
    
    
    #Getting n2 length
    movq    $0, %rax	        #move 0 to %rax
    leaq    -4(%rsp), %rsp		#Change base-pointer (for next: bP) so it can get int
    movq    $length_scan, %rdi		#Move "%d" to 1st parameter to function
    movq    %rsp, %rsi 		        #Move the rsp to the 2nd parameter to function
    call    scanf
    movl    (%rsp),%r14d                   #Get the return value to %r14
    leaq    4(%rsp),%rsp               #Resize the stack														

    #Get the 2nd string
    movq    $0, %rax		     	
    leaq    -1(%rsp),%rsp  			       #Add one for '\0'
    subq    %r14, %rsp  			#move bP down for %r14 size
    movq    $string_scan,%rdi            #move string to the first param to func
    movq    %rsp, %rsi  			#Move rsp to the second param
    call    scanf                       #now (%rsp) contains the scanned value (pstr2)
	

        #Save the length with the string to create pstring
    subq    $1, %rsp                    #decrease rsp by 1 for the length
    movb    %r14b, (%rsp)           #move 1 byte because its char that represent length
    
    #Get option to menu
    movq    $0, %rax		     	
    leaq    -4(%rsp), %rsp	#needed?#	#Change base-pointer (for next: bP) so it can get int
    movq    $length_scan, %rdi		#Move "%d" to 1st parameter to function
    movq    %rsp, %rsi 		        #Move the rsp to the 2nd parameter to function
    call    scanf

    #Now set params and call the run_func function	
    movl    (%rsp), %edi    #move the menu-option to the first param to func
    movq    $0, %rax		     	
    leaq    4(%rsp),%rdx			#Move pstr2 to the 3rd param
    movq    %rdx, %r15                  #Move pstr2 LENGTH to r15
    leaq    2(%r15,%r14), %r15          #Take r14(start of pstr2), add 2 and pstr2-length(r15) to get pstr1
    movq 	%r15, %rsi	
    call 	run_func
    
    #End	
    movq    $0, %rax	     		       
    movq    %rbp,%rsp 		 	#Mov the originial adress of rsp to it
    popq    %rbp		     		#Free from stack
    ret				       			
	
