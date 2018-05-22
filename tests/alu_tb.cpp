/*
* ALU Module - TestBench
* Anderson Contreras
*/


#include <iostream>

#include "Valu.h"
#include "testbench.h"


#define OK_COLOR    "\033[0;32m"
#define ERROR_COLOR "\033[0;31m"
#define NO_COLOR    "\033[m"

#define IN0      0
#define IN1      1
#define OP       2
#define OUT      3
#define EQU      4
#define LT       5
#define LTU      6

#define ALU_ADD   0b0000
#define ALU_SUB   0b1000
#define ALU_AND   0b0111
#define ALU_OR    0b0110
#define ALU_XOR   0b0100
#define ALU_SRL   0b0101
#define ALU_SLL   0b0001
#define ALU_SRA   0b1101
#define ALU_SLT   0b0010
#define ALU_SLTU  0b0011


#define TOTAL_TESTS 24


using namespace std;

class SIMULATIONTB: public Testbench<Valu> {
  public:
    // -----------------------------------------------------------------------------
    // Testbench constructor
    SIMULATIONTB(double frequency=1e6, double timescale=1e-9): Testbench(frequency, timescale) {}

    int Simulate(unsigned long max_time=1000000){
      Reset();

      // Test data    [in_0 | in_1 | ALU OP | Output | EQU | LT | LTU]
      int data[TOTAL_TESTS][7] = {                               //             Operation          | Equal | Less than | Less than (unsigned)
        {          5,     6,   ALU_ADD,         11, 0, 1, 1},    // 5 + 6 = 11                     |   0   |     1     |       1
        {        -20,     5,   ALU_ADD,        -15, 0, 1, 0},    // -20 + 5 = -15                  |   0   |     1     |       0
        {       -187,   187,   ALU_ADD,          0, 0, 1, 0},    // -187 + 187 = 0                 |   0   |     1     |       0
        {          4,     3,   ALU_SUB,          1, 0, 0, 0},    // 4 - 3 = 1                      |   0   |     0     |       0
        {        -23,  -127,   ALU_SUB,        104, 0, 0, 0},    // -23 - (-127) = 104             |   0   |     0     |       0
        {         -1,     0,   ALU_SUB,         -1, 0, 1, 0},    // -1 - 0 = -1                    |   0   |     1     |       0
        {        120,   245,   ALU_AND,        112, 0, 1, 1},    // 245 & 120 = 112                |   0   |     1     |       1
        {        540,   540,   ALU_AND,        540, 1, 0, 0},    // 540 & 540 = 540                |   1   |     0     |       0
        {        100,    50,   ALU_OR,         118, 0, 0, 0},    // 100 | 50 = 118                 |   0   |     0     |       0
        {          0,     0,   ALU_OR,           0, 1, 0, 0},    // 0 | 0 = 0                      |   1   |     0     |       0
        {        573,   215,   ALU_XOR,        746, 0, 0, 0},    // 573 ^ 215 = 746                |   0   |     0     |       0
        {       4500,  4500,   ALU_XOR,          0, 1, 0, 0},    // 4500 ^ 4500 = 0                |   1   |     0     |       0
        {       1024,     3,   ALU_SRL,        128, 0, 0, 0},    // 1024 >> 4 = 128                |   0   |     0     |       0
        {-2147483648,     5,   ALU_SRL,   67108864, 0, 1, 0},    // -2147483648 >> 5 = 67108864    |   0   |     1     |       0
        {-2147483648,     5,   ALU_SRA,  -67108864, 0, 1, 0},    // -2147483648 >> 5 = -67108864   |   0   |     1     |       0
        {       2048,     1,   ALU_SRA,       1024, 0, 0, 0},    // 2048 >> 1 = 1024               |   0   |     1     |       0
        {         64,     5,   ALU_SLL,       2048, 0, 0, 0},    // 64 << 5 = 2048                 |   0   |     0     |       0
        {         -2,     1,   ALU_SLL,         -4, 0, 1, 0},    // -2 << 1 = -4                   |   0   |     1     |       0
        {          1,    10,   ALU_SLT,          1, 0, 1, 1},    // 1 < 10 = true                  |   0   |     1     |       1
        {         20,    10,   ALU_SLT,          0, 0, 0, 0},    // 20 < 10 = false                |   0   |     0     |       0
        {        -20,   -10,   ALU_SLT,          1, 0, 1, 1},    // -20 < -10 = true               |   0   |     1     |       1
        {         50,   800,   ALU_SLTU,         1, 0, 1, 1},    // 50 < 800 = true (Unsigned)     |   0   |     1     |       1
        {         30,    20,   ALU_SLTU,         0, 0, 0, 0},    // 30 < 20 = false (Unsigned)     |   0   |     0     |       0
        {        100,  -200,   ALU_SLTU,         1, 0, 0, 1}};   // 100 < -200 = true (Unsigned)   |   0   |     0     |       1


      for (int num_test = 0; num_test < TOTAL_TESTS; num_test++) {
        m_core->in0_i = data[num_test][IN0];
        m_core->in1_i = data[num_test][IN1];
        m_core->op_i  = data[num_test][OP] ;

        Tick();

        if((m_core->out_o != data[num_test][OUT]) || (m_core->equ_o != data[num_test][EQU]) ||
           (m_core->lt_o != data[num_test][LT]) || (m_core->ltu_o != data[num_test][LTU]))
          return num_test;
      }
    }
};


int main(int argc, char **argv, char **env) {
  std::unique_ptr<SIMULATIONTB> tb(new SIMULATIONTB());

  tb->OpenTrace("alu.vcd");

  int ret = tb->Simulate();

  printf("\nALU Testbench:\n");

  if(ret == TOTAL_TESTS)
    printf(OK_COLOR "[OK]" NO_COLOR " Test Passed! ");
  else
    printf(ERROR_COLOR "[FAILED]" NO_COLOR " Test Failed! ");

  printf("Complete: %d/%d\n", ret, TOTAL_TESTS);

  exit(0);
}
