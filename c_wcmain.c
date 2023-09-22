#include <stdio.h>
#include <stdint.h>
#include "wcfuncs.h"

// Suggested number of buckets for the hash table
#define HASHTABLE_SIZE 13249

// TODO: prototypes for helper functions

int main(int argc, char **argv) {
  // stats (to be printed at end)
FILE *in = fopen(argv[1], "r");
//printf("Attempting to open file: %s\n", argv[1]);
if (!in) {
    perror("Failed to open file");
    return 1;
}  
struct WordEntry * buckets[HASHTABLE_SIZE] = {NULL};
  uint32_t total_words = 0;
  uint32_t unique_words = 0;
  const unsigned char *best_word = (const unsigned char *) "";
  uint32_t best_word_count = 0;
  unsigned char ch[MAX_WORDLEN + 1];

  while (wc_readnext(in, ch)) {
    wc_tolower(ch);
    wc_trim_non_alpha(ch);
    struct WordEntry * result = wc_dict_find_or_insert(buckets, HASHTABLE_SIZE, ch);
    if (result->count == 0) {
      unique_words += 1;
    }
    total_words += 1;
    result->count += 1;
    //printf("%s", result->word);

    if (wc_str_compare(best_word, (const unsigned char *) "") == 0 || result->count > best_word_count) {
      best_word = result->word;
      best_word_count = result->count;
    }
  }

  // TODO: implement

  printf("Total words read: %u\n", (unsigned int) total_words);
  printf("Unique words read: %u\n", (unsigned int) unique_words);
  printf("Most frequent word: %s (%u)\n", (const char *) best_word, best_word_count);
  fclose(in);
  // TODO: make sure file is closed (if one was opened)
  // TODO: make sure memory is freed
  for (int i = 0; i < HASHTABLE_SIZE; i++) {
    wc_free_chain(buckets[i]);
  }
  return 0;
}

// TODO: definitions of helper functions
