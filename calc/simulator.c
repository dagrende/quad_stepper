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
double ev, nev;
double pmp, mp, nmp;  // motor position
double mv, nmv;
double ma;
double ndmp;

void feedback_step(long t, long dt, long ep) {
  nep = 2 * ep - pep;     // extrapolate to get next encoder pos
  nev = (nep - ep) / dt;  // calc velocity to reach the next encoder pos

  ndmp = nep - mp;  // next motor travel to catch up with encoder pos

  nmv = ndmp / dt;
  ma = (nmv - mv) / dt;
  nmp = mp + nmv * dt;

  printf("  [%15.8f, %15.8f, %15.8f, %15.8f, %15.8f],\n", t / 1000000000.0, 1.0 * ep, mp, mv, ma);
  pep = ep;

  pmp = mp;
  mp = nmp;
  mv = nmv;
}

const long clkf = 53200000; // fpga clk freq Hz
const int k = xxx; // clk ticks per motor step
const int mpe = 24; // motor turn pulses per encoder turn pulses (200*32*6/1600)
int m = 3;
int d = 5;
int
// return next period in fpga clock ticks, given millisecond time and encoder position
// vars are clkf - clock freq in Hz
//
float mtd = m / d;
int pep;
int pmp;
long pt;
int get_next_period(long t, int ep, int mp) {
  int dt = pt - t;
  int mep = m * mpe * ep;
  int dmp = d * mp;
  int dem = mep - dmp;  // 0 if encoder and motor in sync
  int mdiff = (2 * mep - pep - dmp) / d;  // wanted motor movement during dt
  int nmv = mdiff / dt; // motor velocity
  int period = k / nmv;
  // use freq instead, calculated from nmv
  // in fpga generate the freq by adding the freq value to a reg and gen a pulse when reaching a threshold - like bresenham

  pep = ep;
  pmp = mp;
  pt = t;

  return period;
}

int main(int argc, char** argv) {
  printf("let rowData = [\n");

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
