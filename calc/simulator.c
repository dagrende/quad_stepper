/*
  simulate input from encoder and call feedback_step for each t time and output result.
*/

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>

//const long dt_goal = 10000000; // nS
const long dt_goal = 50000000; // nS = 0.05s = 20Hz
long end_time = 1 * 1000000000;

double pep, ep, nep;  // encoder position (prev, now, next)
double pmp, mp, nmp;  // motor position
double mv, nmv;
double ndmp;

void feedback_step(long t, long dt, long ep) {
  nep = 2 * ep - pep; // extrapolate to get next encoder pos
  ndmp = nep - mp;  // next motor travel to catch up with encoder pos
  nmv = ndmp / dt;
  nmp = mp + nmv * dt;

  printf("[%10.8f, %f, %f],\n", t / 1000000000.0, 1.0 * ep, mp);
  pep = ep;
  pmp = mp;
  mp = nmp;
}

int main(int argc, char** argv) {
  printf("let rowData = [");

  FILE* fp = fopen(argv[1], "r");
  if (fp == NULL)
      exit(EXIT_FAILURE);

  char* line = NULL;
  size_t len = 0;
  ssize_t read;
  long next_time = 0;
  long pt, t;
  long step_count = 0;
  while ((read = getline(&line, &len, fp)) != -1) {
    if (next_time >= end_time) {
      break;
    }
    if (line[0] == '#') {
      pt = t;
      sscanf(line, "#%ld ", &t);
      if (t >= next_time) {
        feedback_step(t, t - pt, step_count);
        next_time += dt_goal;
      }
      ++step_count;
    }
  }
  printf("];");
  fclose(fp);
  if (line)
    free(line);
  exit(EXIT_SUCCESS);
}
