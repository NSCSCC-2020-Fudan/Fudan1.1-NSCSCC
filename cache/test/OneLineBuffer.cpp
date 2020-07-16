#include "OneLineBuffer.h"

static auto top = new Top;

PRETEST_HOOK [] {
    top->reset();
};

WITH {
    top->issue_read(2, 4 * 31);

    int count = 0;
    while (!top->inst->sramx_resp_x_data_ok) {
        top->tick();
        top->print_cache();
        count++;
        assert(count < 256);
    }

    assert(top->inst->sramx_resp_x_rdata == 31);
} AS("single read");

WITH TRACE {
    for (int i = 0; i < 256; i++) {
        top->tick();
        top->issue_read(2, 4 * i);

        int count = 0;
        while (!top->inst->sramx_resp_x_addr_ok) {
            top->tick();
            count++;
            assert(count < 100);
        }

        if (!top->inst->sramx_resp_x_data_ok) {
            top->tick();
            top->inst->sramx_req_x_req = 0;
            top->inst->eval();
            while (!top->inst->sramx_resp_x_data_ok) {
                top->tick();
                count++;
                assert(count < 100);
            }
        }

        printf("%x ?= %x\n", top->inst->sramx_resp_x_rdata, i);
        assert(top->inst->sramx_resp_x_rdata == i);
    }
} AS("sequential read");

WITH TRACE {

} AS("single write");