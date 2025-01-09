.model small
.stack 100h
.data
    ; Menu strings
    welcome     db 13,10,'=== SELAMAT DATANG DI CAFE ===',13,10,'$'
    menu_txt    db 13,10,'MENU MINUMAN:',13,10
                db '1. Es Teh      : Rp 5.000',13,10
                db '2. Es Jeruk    : Rp 7.000',13,10
                db '3. Cappuccino  : Rp 15.000',13,10
                db '4. Latte       : Rp 18.000',13,10
                db '5. Matcha      : Rp 20.000',13,10
                db '6. Americano   : Rp 17.000',13,10
                db '7. Milk Tea    : Rp 16.000',13,10
                db '8. Chocolate   : Rp 19.000',13,10,'$'
    input_txt   db 13,10,'Masukkan pesanan (menu,jumlah): $'
    next_txt    db 13,10,'Pesanan berikutnya (menu,jumlah) atau 0 untuk selesai: $'
    order_sum   db 13,10,'=== RINGKASAN PESANAN ===',13,10,'$'
    item_txt    db 13,10,'Menu #$'
    qty_txt     db ' Jumlah: $'
    unit_price  db ' @Rp $'
    price_txt   db ' = Rp $'
    total_txt   db 13,10,13,10,'Total pembayaran: Rp $'
    error_txt   db 13,10,'Input tidak valid!$'
    thanks_txt  db 13,10,'Terima kasih telah memesan!$'
    
    ; Variables
    orders      db 8 dup(0)     ; Array to store quantity for each menu
    prices      dw 5000, 7000, 15000, 18000, 20000, 17000, 16000, 19000
    menu_names  db 'Es Teh    $'
                db 'Es Jeruk  $'
                db 'Cappuccino$'
                db 'Latte     $'
                db 'Matcha    $'
                db 'Americano $'
                db 'Milk Tea  $'
                db 'Chocolate $'
    choice      db ?
    quantity    db ?
    subtotal    dw 0
    grandtotal  dd 0    ; Changed to double word for larger totals

.code
main proc
    mov ax, @data
    mov ds, ax
    
    ; Clear screen
    mov ax, 0003h
    int 10h
    
    ; Display welcome and menu
    lea dx, welcome
    mov ah, 09h
    int 21h
    
    lea dx, menu_txt
    mov ah, 09h
    int 21h
    
input_loop:
    ; Display input prompt
    lea dx, input_txt
    mov ah, 09h
    int 21h
    
    ; Get menu choice
    mov ah, 01h
    int 21h
    sub al, '0'
    
    ; Check if done (0)
    cmp al, 0
    je calculate_total
    
    ; Validate menu choice
    cmp al, 1
    jl invalid
    cmp al, 8
    jg invalid
    
    mov choice, al
    
    ; Get comma
    mov ah, 01h
    int 21h
    
    ; Get quantity
    mov ah, 01h
    int 21h
    sub al, '0'
    
    ; Validate quantity (1-9)
    cmp al, 1
    jl invalid
    cmp al, 9
    jg invalid
    
    mov quantity, al
    
    ; Store order in array
    mov bl, choice
    dec bl          ; Adjust for 0-based array
    mov bh, 0
    mov al, quantity
    mov [orders + bx], al
    
    ; Display next order prompt
    lea dx, next_txt
    mov ah, 09h
    int 21h
    jmp input_loop
    
calculate_total:
    ; Display order summary
    lea dx, order_sum
    mov ah, 09h
    int 21h
    
    ; Reset grandtotal
    mov word ptr grandtotal, 0
    mov word ptr grandtotal+2, 0
    
    ; Loop through orders array
    mov cx, 8       ; 8 menu items
    mov si, 0       ; array index
    
print_orders:
    mov al, [orders + si]
    cmp al, 0
    je next_item    ; Skip if quantity is 0
    
    ; Display menu number
    lea dx, item_txt
    mov ah, 09h
    int 21h
    
    mov dl, si
    inc dl          ; Convert to menu number
    add dl, '0'
    mov ah, 02h
    int 21h
    
    ; Display quantity
    lea dx, qty_txt
    mov ah, 09h
    int 21h
    
    mov dl, [orders + si]
    add dl, '0'
    mov ah, 02h
    int 21h
    
    ; Display unit price
    lea dx, unit_price
    mov ah, 09h
    int 21h
    
    mov bx, si
    shl bx, 1      ; Multiply by 2 for word array index
    mov ax, [prices + bx]
    call display_num
    
    ; Calculate subtotal
    mov al, [orders + si]  ; Get quantity
    xor ah, ah            ; Clear AH
    mul word ptr [prices + bx]  ; Multiply by price
    mov subtotal, ax
    
    ; Display subtotal
    lea dx, price_txt
    mov ah, 09h
    int 21h
    
    mov ax, subtotal
    call display_num
    
    ; Add to grandtotal
    mov ax, subtotal
    add word ptr grandtotal, ax
    adc word ptr grandtotal+2, 0    ; Add carry if any
    
next_item:
    inc si
    loop print_orders
    
    ; Display grand total
    lea dx, total_txt
    mov ah, 09h
    int 21h
    
    mov ax, word ptr grandtotal
    call display_num
    
    ; Display thank you message
    lea dx, thanks_txt
    mov ah, 09h
    int 21h
    
    jmp exit
    
invalid:
    lea dx, error_txt
    mov ah, 09h
    int 21h
    jmp input_loop
    
exit:
    mov ah, 4ch
    int 21h
    
main endp

; Procedure to display number
display_num proc
    push ax
    push bx
    push cx
    push dx
    
    mov cx, 0
    mov bx, 10
    
divide:
    xor dx, dx      ; Clear DX before division
    div bx
    push dx
    inc cx
    test ax, ax     ; Check if quotient is 0
    jnz divide
    
display:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop display
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
display_num endp

end main