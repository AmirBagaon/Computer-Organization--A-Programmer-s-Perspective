#Amir Bagaon

    .section    .rodata
pstr_length:    .string "first pstring length: %d, second pstring length: %d\n"
char_replace:   .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
scan_replace:   .string "\n%c %c"
int_scan:       .string "%d\n%d"
str_of_52_53:   .string "length: %d, string: %s\n"
not_option:     .string "invalid option!\n"

#Building the jump table:
    .align  8           #Align address to multiple of 8.  
.Options_Switch:
    .quad .Case50     
    .quad .Case51     
    .quad .Case52     
    .quad .Case53     
    .quad .Default    #When it's default



    .text
    .global run_func
    .type   run_func, @function
run_func:                       #Input: %rdi - option, %rsi - strp1, %rdx - strp2

#Save in stack the callee registers in order to restore them after function end
    pushq   %r12                    
    pushq   %r13                    
    pushq   %r14                    
    pushq   %r15       
    
#Save strp1 in r12 and save strp2 in r13
    movq    %rsi,%r12               #Save strp1 in r12
    movq    %rdx,%r13               #Save strp2 in r13             

#Calculating the switch
        leaq -50(%rdi),%rdi         #Decrease the value of option by 50
        cmpq $3,%rdi                
        jg .Default                 #If option > 3 Its illegal
        cmpq $0,%rdi                
        jl .Default                 #If option < 0 Its illegal

#jump to the switch-case
    jmp *.Options_Switch(,%rdi,8) 
####



.Case50:                            #pstrln params: Pstring*
    movq    $0,%rax                 
    movq    (%rsi),%rdi             #Move strp1 to 1st param.
    call    pstrlen                 #Call pstrlen to check length, which get only pstring*
    movq    %rax,%rsi               #Save strp1 length in the 2nd param
    
    #Second pstr
    movq    $0,%rax                 
    movq    (%rdx),%rdi             #Move strp2 to 1st param.
    call    pstrlen                 #Call pstrlen to check length, which get only pstring*
    movq    %rax,%rdx               #Save strp2 length in the 3rd param
    
    #Print (params: 2nd - pstr1 length, 3rd- pstr2 length1st - adress, )
    movq    $0,%rax                 
    movq    $pstr_length,%rdi    #Move the "%d" to 1st param
    call    printf 
    
    #Return 
    jmp .done



.Case51:                          #replaceChar params: Pstring*, Char old, Char new
        
#Scan old char to replace
    movq    $0,%rax
    subq    $2,%rsp                #Expand stack by 2 char's size for old and new chars.
    movq    %rsp,%rdx               #Move %rsp ('new' char address) to the 3rd param
    leaq    1(%rsp),%rsi            #Move %rsp ('old' char address) to the 2nd param
    movq    $scan_replace,%rdi      #Move the "%c %c" to the 1st param                 
    call    scanf                   #Scan old and new char
    
#Save old and new chars
    movb    1(%rsp),%r14b           #Save old char in r14
    movb    (%rsp),%r15b            #Save new char in r15
    
#Replace strp1's [in %r12] old and new char    
    movq    %r12,%rdi               #Move pstr1 to 1st param
    movq    %r14,%rsi               #Move old char to 2nd param
    movq    %r15,%rdx               #Move new char to 3rd param
    call    replaceChar             
    movq    %rax,%r12               #Save strp1 after the change in r12             
    
#Replace strp2's [in %r13] old and new char  
    movq    %r13,%rdi               #Move pstr1 to 1st param
    movq    %r14,%rsi               #Move old char to 2nd param
    movq    %r15,%rdx               #Move new char to 3rd param
    call    replaceChar             
    movq    %rax,%r13               #Save strp1 after the change in r12             
    
 #Print - 5 args: string, old char, new char, pstr1, pstr2   
    movq    $0,%rax                
    movq    $char_replace,%rdi      #Move the string to the 1st param
    movq    %r14,%rsi               #Move old char to the 2nd param
    movq    %r15,%rdx               #Move new char to the 3rd param
    movq    %r12,%rcx               #Move new p1 to the 4th param
    movq    %r13,%r8                #Move new p2 to the 5th param
    call    printf                  
    
#Free the allocated memory
    leaq    2(%rsp),%rsp            #Decrease size by the size we had increased
    jmp .done


                         #Remind: 1st:   %rdi  2nd    %rsi  3rd %rdx 4th %rcx  
.Case52:                 #Params: Pstring dst, Pstring src, char i, char j

#Prepare to scan the indexes with scanf
    movq    $0,%rax
    movq    $int_scan,%rdi          #Move the string for the scanf to 1st param                 
    leaq    -8(%rsp),%rsp           #Expand stack by 2 ints
    movq    %rsp,%rdx               #Move rsp to 3rd param
    leaq    4(%rsp),%rsi            #Move rsp to 2nd param
    call    scanf                   #Send the 3 params to scanf
    movl    (%rsp),%r15d            #Move j index to r15
    movl    4(%rsp),%r14d           #Move i index to r14

#Prepare and call pstrijcpy
    movq    %r12,%rdi               #Move strp1 to 1st param
    movq    %r13,%rsi               #Move strp2 to 2nd param
    movq    %r14,%rdx               #Move 'i' to 3rd param
    movq    %r15,%rcx               #Move 'j' to 4th param
    call    pstrijcpy               
    
#Prepare to print strp1. 3 args: printf's string, %d length, %s pstr1  
    
#Get pstr1 length with pstrlen
    movq    $0,%rax                
    movq    (%r12),%rdi             #Move strp1 to 1st param
    call    pstrlen                 
    movq    %rax,%rsi               #For the print, we'll save the length in 2nd param    
#Now print    
    movq    $0,%rax                    
    movq    $str_of_52_53,%rdi     #Move printf's string to 1st param
    leaq    1(%r12),%rdx            #Move strp1 without its lenth (which is in 1 byte) to 3rd param
    call    printf                  

#Prepare to print strp2. 3 args: printf's string, %d length, %s pstr1  
    
#Get pstr2 length with pstrlen
    movq    $0,%rax                
    movq    (%r13),%rdi             #Move strp1 to 1st param
    call    pstrlen                 
    movq    %rax,%rsi               #For the print, we'll save the length in 2nd param    
#Now print    
    movq    $0,%rax                    
    movq    $str_of_52_53,%rdi     #Move printf's string to 1st param
    leaq    1(%r13),%rdx            #Move strp2 without its lenth (which is in 1 byte) to 3rd param
    call    printf                  

#Free the allocated memory
    leaq    8(%rsp),%rsp
    jmp .done



.Case53:                     #Params: Pstring* pstr
#Call the swapCase func for pstr1 
    movq    %r12,%rdi               #Move strp1 to 1st param
    call    swapCase
    movq    %rax,%r12               #Save strp1

#Prepare to print pstr1. 3 args: printf's string, %d length, %s pstr1      
#Get pstr1 length with pstrlen
    movq    $0,%rax                
    movq    (%r12),%rdi             #Move strp1 to 1st param
    call    pstrlen                 
    movq    %rax,%rsi               #For the print, we'll save the length in 2nd param    
#Now print    
    movq    $0,%rax                    
    movq    $str_of_52_53,%rdi     #Move printf's string to 1st param
    leaq    1(%r12),%rdx            #Move strp1 without its lenth (which is in 1 byte) to 3rd param
    call    printf                  

#Call the swapCase func for pstr2  
    movq    %r13,%rdi               #Move strp1 to 1st param
    call    swapCase
    movq    %rax,%r13               #Save strp1

#Prepare to print pstr2. 3 args: printf's string, %d length, %s pstr2      
#Get pstr2 length with pstrlen
    movq    $0,%rax                
    movq    (%r13),%rdi             #Move strp1 to 1st param
    call    pstrlen                 
    movq    %rax,%rsi               #For the print, we'll save the length in 2nd param    
#Now print    
    movq    $0,%rax                    
    movq    $str_of_52_53,%rdi     #Move printf's string to 1st param
    leaq    1(%r13),%rdx            #Move strp1 without its lenth (which is in 1 byte) to 3rd param
    call    printf                  


    jmp .done




#Default-Case
.Default:
    #Print that it is invalid option
    movq    $0,%rax
    movq    $not_option,%rdi                    
    call    printf
#And now fall through to the end label


#The end label
.done:
    pop     %r15                    
    pop     %r14                      
    pop     %r13                    
    pop     %r12                    
    ret
    
