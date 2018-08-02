/*
  simulate input from encoder and call feedback_step for each t time and output result.
*/

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>

void feedback_step(int change_time, int step_count) {
  printf("%d %d\n", change_time, step_count);
}

int main(void) {
    FILE* fp = fopen("mill-270.vcd", "r");
    if (fp == NULL)
        exit(EXIT_FAILURE);

    char* line = NULL;
    size_t len = 0;
    ssize_t read;
    int next_time = 0;
    int dt = 10000; // uS
    int change_time;
    int step_count = 0;
    while ((read = getline(&line, &len, fp)) != -1) {
        if (line[0] == '#') {
          sscanf(line, "#%d ", &change_time);
          if (change_time >= next_time) {
            feedback_step(change_time, step_count);
            next_time += dt;
          }
          ++step_count;
        }
    }

    fclose(fp);
    if (line)
        free(line);
    exit(EXIT_SUCCESS);
}
