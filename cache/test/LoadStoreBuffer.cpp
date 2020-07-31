#include "LoadStoreBuffer.h"

static auto top = new Top;

PRETEST_HOOK [] {
    top->reset();
};

WITH LOG {
    Pipeline p(top);

    p.write(0x12345678, 0x87654321);
    p.inspect(0x11223344);
    p.wait(256);
} AS("simple test");