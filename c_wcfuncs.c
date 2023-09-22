// Important: do not add any additional #include directives!
// The only C library functions that may be used are
//
// - fgetc
// - malloc
// - free

#include <limits.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "wcfuncs.h"

// Compute a hash code for the given NUL-terminated
// character string.
//
// The hash algorithm should be implemented as follows:
//
// uint32_t hash_code = 5381
// for each character c of w in order {
//   hash_code = hash_code * 33 + c
// }
//
// Note that the character values should be treated as
// being unsigned (in the range 0..255)
uint32_t wc_hash(const unsigned char *w) {
  uint32_t hash_code = 5381;
  for (int i = 0; w[i] != '\0'; i++) {
    hash_code = hash_code * 33 + w[i];
  }
 return hash_code;
  // TODO: implement
}

// Compare two strings lexicographically. Return
//
// - a negative value if lhs string is less than rhs string
// - 0 if lhs string is identical to rhs string
// - a positive value if lhs string is greater than rhs string
//
// Lexicographical comparison is a generalization of alphabetical
// order, but using character codes. If one string is a prefix
// of the other, it is considered as "less than". E.g.,
// "hi" would compare as less than "high".
int wc_str_compare(const unsigned char *lhs, const unsigned char *rhs) {
  int i;
  for (i = 0; lhs[i] != '\0' || rhs[i] != 0; i++) {
    if(lhs[i] > rhs[i]) {
      return 1;
    }
    else if(rhs[i] > lhs[i]) {
      return -1;
    }
  }
  if (lhs[i] != '\0') {
    return 1;
  }
  else if (rhs[i] != '\0') {
    return -1;
  }
  else {
    return 0;
  }
  // TODO: implement
}

// Copy NUL-terminated source string to the destination buffer.
void wc_str_copy(unsigned char *dest, const unsigned char *source) {
  int i;
  for (i = 0; source[i] != '\0'; i++) {
    dest[i] = source[i];
  }
  dest[i] = '\0';

  // TODO: implement
}

// Return 1 if the character code in c is a whitespace character,
// false otherwise.
//
// For the purposes of this function, a whitespace character is one of
//
//   ' '
//   '\t'
//   '\r'
//   '\n'
//   '\f'
//   '\v'
int wc_isspace(unsigned char c) {
    if (c == ' ' || c == '\t' || c == '\r' || c == '\n' || c == '\f' || c == '\v') {
        return 1;  // True: c is a whitespace character
    } else {
        return 0;  // False: c is not a whitespace character
    }
}

// Return 1 if the character code in c is an alphabetic character
// ('A' through 'Z' or 'a' through 'z'), 0 otherwise.
int wc_isalpha(unsigned char c) {
    if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')) {
        return 1;  // True: c is an alphabetic character
    } else {
        return 0;  // False: c is not an alphabetic character
    }
}

// Read the next word from given input stream, storing
// the word in the array pointed-to by w. (This array should be
// assumed to be MAX_WORDLEN+1 elements in size.) Return 1
// if a word is read successfully, 0 otherwise.
//
// For the purposes of this function, a word is a sequence of
// 1 or more non-whitespace characters.
//
// If a sequence of non-whitespace characters has more than
// MAX_WORDLEN characters, then only the first MAX_WORDLEN
// characters in the sequence should be stored in the array.
int wc_readnext(FILE *in, unsigned char *w) {
    int i = 0;
    unsigned char ch = fgetc(in);
    
    // Skip whitespace characters
    while (!feof(in) && wc_isspace(ch)) {
        ch = fgetc(in);
    }

    // If we reached the end of the file while skipping whitespace, return 0
    if (feof(in)) {
        return 0;
    }

    // Read characters into w until a space character is found or MAX_WORDLEN - 1 characters are read
    while (!feof(in) && !wc_isspace(ch) && i < MAX_WORDLEN - 1) {
        w[i++] = ch;
        ch = fgetc(in);
    }
    
    w[i] = '\0';  // Null-terminate the string
    return 1;
}


// Convert the NUL-terminated character string in the array
// pointed-to by w so that every letter is lower-case.
void wc_tolower(unsigned char *w) {
    for (int i = 0; w[i] != '\0'; i++) {
        if (w[i] >= 'A' && w[i] <= 'Z') {
            w[i] = w[i] + ('a' - 'A');
        }
    }
}

// Remove any non-alphaabetic characters from the end of the
// NUL-terminated character string pointed-to by w.
int wtf;
void wc_trim_non_alpha(unsigned char *w) {
    // Find the end of the string (just before the NUL-terminator)
    int i;
    for (i = 0; w[i] != '\0'; i++);

    // Move backwards, trimming non-alphabetic characters
    while (i > 0 && !wc_isalpha(w[i-1])) {
        i--;
    }
    w[i] = '\0';
  // if (strcmp((const char *)w, (const char *)"the") == 0) {
  //  printf("%s \n", w);
  //  wtf++;
  //  printf("%d", wtf);
  // }
}
// Search the specified linked list of WordEntry objects for an object
// containing the specified string.
//
// If a matching object is found, set the int variable pointed-to by
// inserted to 0 and return a pointer to the matching object.
//
// If a matching object is not found, allocate a new WordEntry object,
// set its next pointer to point to what head points to (i.e., so the
// new object is at the head of the list), set the variable pointed-to
// by inserted to 1, and return a pointer to the new node. Note that
// the new node should have its count value set to 0. (It is the caller's
// job to update the count.)
struct WordEntry *wc_find_or_insert(struct WordEntry *head, const unsigned char *s, int *inserted) {
  struct WordEntry *curr = head;
  while(curr != NULL) {
    if (wc_str_compare(curr->word, s) == 0) {
      *inserted = 0;
      return curr;
    }
    curr = curr->next;
  }
  struct WordEntry *we = malloc(sizeof(struct WordEntry));
  wc_str_copy(we->word, s);
  we->next = head;
  we->count = 0;
  *inserted = 1;
  return we;

}

// Find or insert the WordEntry object for the given string (s), returning
// a pointer to it. The head of the linked list which contains (or should
// contain) the entry for s is the element of buckets whose index is the
// hash code of s mod num_buckets.
//
// Returns a pointer to the WordEntry object in the appropriate linked list
// which represents s.
struct WordEntry *wc_dict_find_or_insert(struct WordEntry *buckets[], unsigned num_buckets, const unsigned char *s) {
    uint32_t hash_val = wc_hash(s);
    unsigned int bucket_index = hash_val % num_buckets;

    int inserted;
    struct WordEntry *result = wc_find_or_insert(buckets[bucket_index], s, &inserted);

    // Only update the bucket head if a new word was inserted.
    if (inserted) {
        buckets[bucket_index] = result;
    }

    return result;
}

// Free all of the nodes in given linked list of WordEntry objects.
void wc_free_chain(struct WordEntry *p) {
  while(p != NULL) {
    struct WordEntry * next = p->next;
    free(p);
    p = next;
  }
}
