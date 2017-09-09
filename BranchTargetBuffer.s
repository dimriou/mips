.data
						# 100 random numbers in 4 continuous blocks of memory
	A: 	  .word 1,3845,7797,5941,4166,6836,8825,5514,5448,2991,361,5595,9893,2310,5061,1495,4847,2136,2925,7904,5621,5127,3952,7477,6903,1282,5488
	B:	  .word 214,1348,601,2844,3459,6302,427,707,2523,4420,3418,9079,2096,5702,9573,3271,2177,147,6236,7971,8077,7757,8718,5834,4486,5875,1709
	C:        .word 4206,4059,7157,7864,8398,6796,1602,4527,3098,41,6556,7009,961,6449,7330,0,1989,6022,8612,6155,3525,8759,3057,2818,8225,4659,8011
	D:        .word 5300,6088,1068,6129,8291,7116,641,66,4446,8652,3378,1856,1109,3352,6623,9466,3591,1215,3031
	CONTROL:  .word32 0x10000
	DATA:     .word32 0x10008

	FAULT:	  .asciiz "Wrong input"     # string printed in case of error
						                # after the final stage of computing mod3
						                # the possible results are         0 1 2 3 4 5 6 7 8 9 10
						                # the sequence of mod3 is          0 1 2 0 1 2 0 1 2 0  1
                						# the truth table of mod3==0 is    1 0 0 1 0 0 1 0 0 1  0   with each number in 1 byte
	THREE:	  .word 0x0001000001000001,0x000100
                						# after the final stage of computing mod7
                						# the possible numbers are         0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
                						# the sequence of mod7 is          0 1 2 3 4 5 6 0 1 2  3  4  5  6  0  1  2  3  4  5 6
                						# the truth table of mod7==0 is    1 0 0 0 0 0 0 1 0 0  0  0  0  0  1  0  0  0  0  0 0   with each number in 1 byte
	SEVEN:	  .word 0x0100000000000001,0x0001000000000000,0x0


.text

	daddi r7,r0,A			        	# r7-has the address of array A
#	dadd r19, r0, r0			        # r19-counter : multiples of 3 , initialized to zero , can be avoided in simulator
#	dadd r21, r0, r0			        # r21-counter : multiples of 5 , initialized to zero , can be avoided in simulator
	daddi r8, r0, 100			        # r8-plithos stoixeiwn pinaka (100)
#	daddi r4, r0, 0				        # r4-counter epanalispeis (like i) , initialized to zero , can be avoided in simulator
#	daddi r16, r0, 0			        # r16-counter: multiples of 3 and 5 and 7 , initialized to zero , can be avoided in simulator
#	dadd r23, r0, r0		        	# r23-counter : multiples of 7 , initialized to zero , can be avoided in simulator
	daddi r15,r0,5				        # r15-constant value of 5
	daddi r13,r0,9999			        # r13-constant value of 9999

#################################################################################################
#################################################################################################

	LOOP3:
		ld r9, 0(r7)			        # load array's next value
		beq r4, r8, exit		        # if loops == size of array: exit

		###############################
		## PART OF CHECKING FOR MOD5 ##
		###############################
		ddiv r10,r9,r15			        # r10- div of current value with 5
		###############################
		############ END  #############
		###############################
		slt r14,r13,r9			        # r14 - value of (a > 9999)
		slt r5,r9,r0			        # r5 - value of (a < 0)
		or r5,r5,r14		        	# r5 - value of ( (a > 9999) || (a<0) )
		#------------------------------
		dsrl r11, r9, 8			        # step 1 of mod3 (to avoid RAW)
		#------------------------------
		bne r0,r5,error			        # if ( (a > 9999) || (a<0) ) true, goto error


		andi r12, r9, 0xFF		        # step 1 of mod3
		dadd r5, r11, r12		        # step 1 of mod3

		dsrl r11, r5, 4			        # step 2 of mod3
		andi r12, r5, 0xF		        # step 2 of mod3
		dadd r5, r11, r12		        # step 2 of mod3

		dsrl r11, r5, 2			        # step 3 of mod3
		andi r12, r5, 0x3		        # step 3 of mod3
		dadd r5, r11, r12		        # step 3 of mod3

		lb r5,THREE(r5)			        # r5 = THREE[r5] , 0=(rem!=0) / 1=(rem==0)

		#------------------------------
		dsrl r11, r9, 12		        # step 1 of mod7 ( to avoid RAW)
		#------------------------------

		dadd r19, r19, r5		        # counter : multiples of 3 + r5 ( which is 0(when not multiple) or 1(when it is multiple) )


#################################################################################################
#################################################################################################

	LOOP7:
		andi r12, r9, 0xFFF		        # step 1 of mod7
		dadd r6, r11, r12		        # step 1 of mod7

		dsrl r11, r6, 6			        # step 2 of mod7
		andi r12, r6, 0x3F		        # step 2 of mod7
		dadd r6, r11, r12		        # step 2 of mod7

		dsrl r11, r6, 3			        # step 3 of mod7
		andi r12, r6, 0x7		        # step 3 of mod7

		###############################
		## PART OF CHECKING FOR MOD5 ##
		###############################
		dmul  r10,r10,r15		        # r10 - multiplication of quotient(r10) by 5
		###############################
		############ END  #############
		###############################

		dadd r6, r11, r12		        # step 3 of mod7

		lb r6,SEVEN(r6)			        # r6 = SEVEN[r6] , 0=(rem!=0) / 1=(rem==0)
		#------------------------------
		daddi r7, r7, 8 		        # next position of array
		daddi r4, r4, 1			        # iterations ++
		#------------------------------
		beq r6,r0,LOOP5			        # if (r6==0) <-> (rem!=0) skip

		and r6, r5, r6			        # r6 = r5 & r6 (set to 1 only if the number is both multiple of 3 and 7)
		daddi r23, r23, 1		        # counter : multiples of 7 ++
#################################################################################################
#################################################################################################

	LOOP5:
		bne   r9,r10,LOOP3		        # if (mod 5 != 0) <-> (diairetaios != (phliko*diareth))

		dadd r16,r16,r6			        # r16 - counter of all + r6 , which is 1 when the number is multiple of both 3 and 7 and since reaching this
						                # point is means it is also multiple of 5 so the counter of all has to increase
		daddi r21, r21, 1		        # counter : multiples of 5 ++

#################################################################################################
#################################################################################################
		j LOOP3



	error:
		lwu r2,DATA(r0)    		        # r2 - address of data resister
      	        lwu r1,CONTROL(r0)		# r1 - address of control register
		daddi r11,r0,4			        # r11 - value 4 that stands for "print string"
		daddi r12,r0,FAULT		        # r12 - address of string to be printed
		sd r12,(r2)			            # write back to data register
		sd r11,(r1)			            # write back to control register
	exit:	halt				        # stop program






