# ProjectCPU

<b>16-bit Instruction Word (IW) of ProjectCPU</b>

```
                                IW
               |----------------------------------
  bit position |15    13| 12                    0|
               |----------------------------------
    field name | opcode |           A            |
               |----------------------------------
     bit width |   3b   |          13b           |
               |----------------------------------
			   

i: Every instruction can operate in indirect addressing mode, if A==0, replace *A above with **2.


```

### Instruction Set of ProjectCPU</b>


*<b>ADD   -></b>* unsigned Add
<ul style="margin-left:40px">
         opcode = 0 <br>
         W = W + (*A) <br>
         write(readFromAddress(A) +W) to W <br>
         *A = value, address A = mem[A] <br>

</ul>


-----

*<b>NAND  -></b>* bitwise NAND
<ul style="margin-left:40px">
          opcode = 1 <br>
         W = ~(W & (*A)) <br>
</ul>

-----

*<b>SRRL  -></b>* Shift Rotate Right or Left
<ul style="margin-left:40px">
         opcode = 2 <br>
         if((*A) is less than 16) W = W >> (*A) <br>
		     else if((*A) is between 16 and 31) W = W << lower4bits(*A) <br>
		     else if((*A) is between 32 and 47) W = RotateRight W by lower4bits(*A) <br>
		      else W = RotateLeft W by lower4bits(*A) <br>
</ul>

-----

*<b>GE  -></b>* Unsigned Greater Equal
<ul style="margin-left:40px">
          opcode = 3 <br>
          W = W >= (*A) <br>
</ul>

-----

*<b>SZ  -></b>* Skip on Zero
<ul style="margin-left:40px">
        opcode = 4 <br>
        PC = ((*A) == 0) ? (PC+2) : (PC+1) <br>
</ul>

-----

*<b>CP2W  -></b>* Copy to W
<ul style="margin-left:40px">
        opcode = 5 <br>
         W = *A <br>
</ul>

-----

*<b>CPfW  -></b>* Copy from W
<ul style="margin-left:40px">
        opcode = 6 <br>
         *A = W <br>
</ul>

-----

*<b>JMP  -></b>* Jump
<ul style="margin-left:40px">
        opcode = 7 <br>
         PC = lower13bits(*A)
</ul>
