/*
 * Assembly language function implementations
 */

#define MAX_WORDLEN 63

/*
 * Offsets for the fields of the struct WordEntry data type
 * (Note that there is 4 bytes of padding between the count and next
 * fields.)
 */
#define WORDENTRY_WORD_OFFSET   (0)
#define WORDENTRY_COUNT_OFFSET  (MAX_WORDLEN+1)
#define WORDENTRY_NEXT_OFFSET   (MAX_WORDLEN+1+4+4)

	.section .rodata
/* Define any string constants or read-only data here */

	.section .text

/*
 * Compute a hash code for the given NUL-terminated
 * character string.
 *
 * The hash algorithm should be implemented as follows:
 *
 * uint32_t hash_code = 5381
 * for each character c of w in order {
 *   hash_code = hash_code * 33 + c
 * }
 *
 * Note that the character values should be treated as
 * being unsigned (in the range 0..255)
 *
 * C function prototype:
 *    uint32_t wc_hash(const unsigned char *w);
 */
	.globl wc_hash
wc_hash:
	/* TODO: implement */
	movl $5381, %r10d /* Storing uint32_t hash_code = 5381 */

.Lhash_loop:
	cmpb $0, (%rdi) 				/* Checking if the dereferenced char is a null terminator */
	je .Ldone_hash 						/* If dereferenced char is a null terminator, then we go finish */
	movl $33, %esi 					/* store 33 in %esi */ 
	imull %esi, %r10d 				/* hash_code = hash_code * 33 */
	movzbl (%rdi), %esi 			/* zero extend w[i] to 32-bit */
	addl %esi, %r10d 				/* hash_code = hash_code + w[i] */
	incq %rdi 						/* Increment the pointer */
	jmp .Lhash_loop						/* Iterate through loop again */

.Ldone_hash:
	movl %r10d, %eax				/* Store the hash_code as a return value */
	ret

/*
 * Compare two strings lexicographically. Return
 *
 * - a negative value if lhs string is less than rhs string
 * - 0 if lhs string is identical to rhs string
 * - a positive value if lhs string is greater than rhs string
 *
 * Lexicographical comparison is a generalization of alphabetical
 * order, but using character codes. If one string is a prefix
 * of the other, it is considered as "less than". E.g.,
 * "hi" would compare as less than "high".
 *
 * C function prototype:
 *    int wc_str_compare(const unsigned char *lhs, const unsigned char *rhs);
 */
	.globl wc_str_compare
wc_str_compare:
	movl $0, %r10d 					/* Initialize for loop counter 'i' to 0 */
	jmp .LcharCompareLoop 			/* After initializing index i = 0, go into the loop */

.LcharCompareLoop:
	leal (%rdi, %r10, 1), %edx 		/* Calculate the address of ith index element of &lhs */
	movzbl (%rdx), %r11d 			/* Store the the dereferenced char at the ith index of lhs */
	cmpl $'\0', %r11d 				/* Check if the ith char of lhs is not '\0'. If it is '\0', jump off the for loop */
	je .LcheckPrefixOfOther 		/* If lhs[i] is '\0', we should jump to check if lhs or rhs has a prefix of each other to compare. */

	leal (%rsi, %r10, 1), %ecx 		/* Calculate the address of ith index element of &rhs */
	movzbl (%rcx), %edx 			/* Store the dereferenced char at the ith index of rhs */
	cmpl $'\0', %edx 				/* Check if the ith char of rhs is not '\0'. If it is '\0', jump off the for loop */
	je .LcheckPrefixOfOther 		/* If rhs[i] is '\0', we should jump to check if lhs or rhs has a prefix of each other to compare. */

	cmpl %edx, %r11d 				/* Compare rhs[i] and lhs[i] */
	jg .LlhsGreaterThanRhs 			/* If lhs[i] is greater than rhs[i], then jump to return 1 */

	cmpl %edx, %r11d 				/* Compare rhs[i] and lhs[i] */
	jl .LrhsGreaterThanLhs 			/* If rhs[i] is greater than lhs[i], then jump to return -1; */
	
	addl $1, %r10d 					/* Increment index i */
	jmp .LcharCompareLoop 			/* Continue with the loop */

		/* From this point, we are comparing if one string is a prefix of the other. */
		/* Here, index i is the last char of of lhs or rhs. */
		/* Specifically, index i will be the last index of the shorter one. */
		/* If lhs[i] != '\0', then it means lhs is bigger because it has more chars after */
		/* Likewise, if rhs[i] != '\0', then it means rhs is bigger because it has more chars after */
.LcheckPrefixOfOther:
	leal (%rdi, %r10, 1), %edx 		/* Calculate the address of lhs[i] */
	movzbl (%rdx), %r11d 			/* Store lhs[i] */
	cmpl $'\0', %r11d 				/* Check if lhs[i] is not '\0' */
	jne .LlhsGreaterThanRhs 		/* If lhs[i] != '\0', then jump return 1 because it means lhs is bigger than rhs */

	leal (%rsi, %r10, 1), %ecx 		/* Calculate the address of rhs[i] */
	movzbl (%rcx), %edx 			/* Store rhs[i] */
	cmpl $'\0', %edx 				/* Check if rhs[i] is not '\0' */
	jne .LrhsGreaterThanLhs 		/* If rhs[i] != '\0', then jump return -1 because it means rhs is bigger than lhs */

	movl $0, %eax 					/* Here, every char in string are the same, so return 0 */
	ret

.LlhsGreaterThanRhs:
	movl $1, %eax 					/* This part implies that lhs is greater than rhs. So return 1 */
	ret

.LrhsGreaterThanLhs:
	movl $-1, %eax					/* This part implies that rhs is greater than lhs. So return -1 */
	ret

/*
 * Copy NUL-terminated source string to the destination buffer.
 *
 * C function prototype:
 *    void wc_str_copy(unsigned char *dest, const unsigned char *source);
 */
	.globl wc_str_copy
wc_str_copy:
	jmp .Lstr_copy_loop /* go into for loop to copy the contents iteratively */
	
.Lstr_copy_loop:
	movb (%rsi), %r11b /* Store source[i] to %r11 */
	cmpb $0, %r11b /* Check if source[i] is a null terminator */
	je .Lstr_copy_loop_done
	movb %r11b, (%rdi) /* Put source[i] into dest[i] */
	incq %rdi
	incq %rsi
	jmp .Lstr_copy_loop

.Lstr_copy_loop_done:
	movb $0, (%rdi) /* Put null terminator to dest in the end */
	ret

/*
 * Return 1 if the character code in c is a whitespace character,
 * false otherwise.
 *
 * For the purposes of this function, a whitespace character is one of
 *
 *   ' '
 *   '\t'
 *   '\r'
 *   '\n'
 *   '\f'
 *   '\v'
 *
 * C function prototype:
 *    int wc_isspace(unsigned char c);
 */
	.globl wc_isspace
wc_isspace:
	cmpb $' ', %dil 				/* Checks if c is a ' ' */
	je .Lis_space 					/* If c is a ' ', jump to Lis_space to return 1 */

	cmpb $'\t', %dil 				/* Checks if c is a '\t' */
	je .Lis_space 					/* If c is a '\t', jump to Lis_space to return 1 */

	cmpb $'\r', %dil 				/* Checks if c is a '\r' */
	je .Lis_space 					/* If c is a '\r', jump to Lis_space to return 1 */

	cmpb $'\n', %dil 				/* Checks if c is a '\n' */
	je .Lis_space 					/* If c is a '\n', jump to Lis_space to return 1 */

	cmpb $'\f', %dil 				/* Checks if c is a '\f' */
	je .Lis_space 					/* If c is a '\f', jump to Lis_space to return 1 */

	cmpb $11, %dil 					/* Checks if c is a '\v'. The number 11 is the decimal representation of \v */
	je .Lis_space 					/* If c is a '\v', jump to Lis_space to return 1 */

	movl $0, %eax 					/* if not '\t', '\r', '\n', '\f', or '\v', then return 0 */
	ret

.Lis_space:
	movl $1, %eax 					/* If jumped to here, it means it is a space character. So return 1. */
	ret

/*
 * Return 1 if the character code in c is an alphabetic character
 * ('A' through 'Z' or 'a' through 'z'), 0 otherwise.
 *
 * C function prototype:
 *    int wc_isalpha(unsigned char c);
 */
	.globl wc_isalpha
wc_isalpha:
	cmpb $'A', %dil 				/* Check if c is greater than or equal to 'A'. If c < 'A', it means it is not greater or equal to 'A', so not an upper case letter. */
	jl .Lcheck_lower_case 			/* If c < 'A', then jump to Lcheck_lower_case to check if it's lower case */

	cmpb $'Z', %dil 				/* Check if c is less than or equal to 'Z'. If c > 'Z', it means it is not less than or equal to 'Z', so not an upper case letter. */
	jg .Lcheck_lower_case 			/* If c > 'Z', then jump to Lcheck_lower_case to check if it's lower case */

	movl $1, %eax 					/* Here, it means it is an upper case letter, so let's return 1 */
	ret

.Lcheck_lower_case:
	cmpb $'a', %dil 				/* Here, it is not an upper case, so check if c is a lower case. (check if it's greater or equal to 'a' to be alphebetic) */
	jl .Lnot_alphabetic 			/* If c is less than 'a', then it is not a lower case (also not an upper case), so jump to return 0. */

	cmpb $'z', %dil 				/* Here, it is not an upper case, so check if c is lower case. (check if it's less than or equal to 'z' to be alphabetic) */
	jg .Lnot_alphabetic 			/* If c is greater than 'z', then it is not a lower case (also not an upper case) */

	movl $1, %eax 					/* Here, it means it is a lower case letter, so let's return 1 */ 
	ret

.Lnot_alphabetic:
	movl $0, %eax 					/* Here, it means it is neither a lower or upper, so let's return 0. */
	ret

/*
 * Read the next word from given input stream, storing
 * the word in the array pointed-to by w. (This array should be
 * assumed to be MAX_WORDLEN+1 elements in size.) Return 1
 * if a word is read successfully, 0 otherwise.
 *
 * For the purposes of this function, a word is a sequence of
 * 1 or more non-whitespace characters.
 *
 * If a sequence of non-whitespace characters has more than
 * MAX_WORDLEN characters, then only the first MAX_WORDLEN
 * characters in the sequence should be stored in the array.
 *
 * C function prototype:
 *    int wc_readnext(FILE *in, unsigned char *w);
 */
	.globl wc_readnext
wc_readnext:
	/* TODO: implement */
	ret

/*
 * Convert the NUL-terminated character string in the array
 * pointed-to by w so that every letter is lower-case.
 *
 * C function prototype:
 *    void wc_tolower(unsigned char *w);
 */
	.globl wc_tolower
wc_tolower:
	/* TODO: implement */
	ret

/*
 * Remove any non-alphaabetic characters from the end of the
 * NUL-terminated character string pointed-to by w.
 *
 * C function prototype:
 *    void wc_trim_non_alpha(unsigned char *w);
 */
	.globl wc_trim_non_alpha
wc_trim_non_alpha:
	/* TODO: implement */
	ret

/*
 * Search the specified linked list of WordEntry objects for an object
 * containing the specified string.
 *
 * If a matching object is found, set the int variable pointed-to by
 * inserted to 0 and return a pointer to the matching object.
 *
 * If a matching object is not found, allocate a new WordEntry object,
 * set its next pointer to point to what head points to (i.e., so the
 * new object is at the head of the list), set the variable pointed-to
 * by inserted to 1, and return a pointer to the new node. Note that
 * the new node should have its count value set to 0. (It is the caller's
 * job to update the count.)
 *
 * C function prototype:
 *    struct WordEntry *wc_find_or_insert(struct WordEntry *head, const unsigned char *s, int *inserted);
 */
	.globl wc_find_or_insert
wc_find_or_insert:
	/* TODO: implement */
	ret

/*
 * Find or insert the WordEntry object for the given string (s), returning
 * a pointer to it. The head of the linked list which contains (or should
 * contain) the entry for s is the element of buckets whose index is the
 * hash code of s mod num_buckets.
 *
 * Returns a pointer to the WordEntry object in the appropriate linked list
 * which represents s.
 *
 * C function prototype:
 *    struct WordEntry *wc_dict_find_or_insert(struct WordEntry *buckets[], unsigned num_buckets, const unsigned char *s);
 */
	.globl wc_dict_find_or_insert
wc_dict_find_or_insert:
	/* TODO: implement */
	ret

/*
 * Free all of the nodes in given linked list of WordEntry objects.
 *
 * C function prototype:
 *    void wc_free_chain(struct WordEntry *p);
 */
	.globl wc_free_chain
wc_free_chain:
	/* TODO: implement */
	ret

/*
vim:ft=gas:
*/
