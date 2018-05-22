/*
* Instruction Fetch Stage - TestBench
* Anderson Contreras
*/

#include <iostream>

#include "Vstage_if.h"
#include "testbench.h"


#define OK_COLOR    "\033[0;32m"
#define ERROR_COLOR "\033[0;31m"
#define NO_COLOR    "\033[m"


#define SEL_ADDR        0
#define STALL           1
#define BRANCH_ADDR     2
#define MIS_ADDR_EXC    3
#define OUTPUT          4

#define SEL_ADDR_PC4    0
#define SEL_ADDR_BR     1
#define STALL_ON        1
#define STALL_OFF       0

#define TOTAL_TESTS 15

using namespace std;

class SIMULATIONTB: public Testbench<Vstage_if> {
  public:
    // -----------------------------------------------------------------------------
    // Testbench constructor
    SIMULATIONTB(double frequency=1e6, double timescale=1e-9): Testbench(frequency, timescale) {}

    int Simulate(unsigned long max_time=1000000){
      Reset();


      // Test data   [Addr_Src | Stall | Branch Address | Exception Flag | Output]
      int unsigned data[TOTAL_TESTS][5] = {                    //                  OUTPUT   | STALL | EXCEPTION
        {SEL_ADDR_PC4, STALL_OFF, 0x00004000, 0, 0x00000004},  // PC = PC + 4  = 0x00000004 |  NO   |    NO
        {SEL_ADDR_PC4, STALL_OFF, 0xDEADF00D, 0, 0x00000008},  // PC = PC + 4  = 0x00000008 |  NO   |    NO
        {SEL_ADDR_PC4, STALL_ON,  0x00000000, 0, 0x00000008},  // PC = PC      = 0x00000008 |  YES  |    NO
        {SEL_ADDR_PC4, STALL_ON,  0x00000000, 0, 0x00000008},  // PC = PC      = 0x00000008 |  YES  |    NO
        {SEL_ADDR_PC4, STALL_ON,  0x00000000, 0, 0x00000008},  // PC = PC      = 0x00000008 |  YES  |    NO
        {SEL_ADDR_BR,  STALL_OFF, 0x00040000, 0, 0x00040000},  // PC = BR_ADDR = 0x00040000 |  NO   |    NO
        {SEL_ADDR_BR,  STALL_OFF, 0x00050001, 1, 0x00050001},  // PC = BR_ADDR = 0x00050001 |  NO   |    YES
        {SEL_ADDR_BR,  STALL_ON,  0x00000004, 1, 0x00050001},  // PC = PC      = 0x00050001 |  YES  |    YES
        {SEL_ADDR_BR,  STALL_OFF, 0x00000080, 0, 0x00000080},  // PC = BR_ADDR = 0x00000080 |  NO   |    NO
        {SEL_ADDR_PC4, STALL_OFF, 0x00000080, 0, 0x00000084},  // PC = PC + 4  = 0x00000084 |  NO   |    NO
        {SEL_ADDR_BR,  STALL_OFF, 0x0000DEAD, 1, 0x0000DEAD},  // PC = BR_ADDR = 0x0000DEAD |  NO   |    YES
        {SEL_ADDR_PC4, STALL_ON,  0x00000000, 1, 0x0000DEAD},  // PC = PC      = 0x0000DEAD |  YES  |    YES
        {SEL_ADDR_BR,  STALL_ON,  0xABCDEF00, 1, 0x0000DEAD},  // PC = PC      = 0x0000DEAD |  YES  |    YES
        {SEL_ADDR_BR,  STALL_OFF, 0xABCDEF00, 0, 0xABCDEF00},  // PC = BR_ADDR = 0xABCDEF00 |  NO   |    NO
        {SEL_ADDR_PC4, STALL_OFF, 0x00000000, 0, 0xABCDEF04}}; // PC = PC + 4  = 0xABCDEF04 |  NO   |    NO
      
      for (int num_test = 0; num_test < TOTAL_TESTS; num_test++) {
        m_core->branch_addr_i = data[num_test][BRANCH_ADDR];
        m_core->sel_addr_i    = data[num_test][SEL_ADDR];
        m_core->stall_i       = data[num_test][STALL] ;

        Tick();

        if((m_core->mis_addr_exc_o != data[num_test][MIS_ADDR_EXC]) ||
           (m_core->pc_o != data[num_test][OUTPUT]))
          return num_test;
      }
    }
};

int main(int argc, char **argv, char **env) {
  std::unique_ptr<SIMULATIONTB> tb(new SIMULATIONTB());

  tb->OpenTrace("stage_if.vcd");

  int ret = tb->Simulate();

  printf("\nStage IF Testbench:\n");

  if(ret == TOTAL_TESTS)
    printf(OK_COLOR "[OK]" NO_COLOR " Test Passed! ");
  else
    printf(ERROR_COLOR "[FAILED]" NO_COLOR " Test Failed! ");

  printf("Complete: %d/%d\n", ret, TOTAL_TESTS);

  exit(0);
}
