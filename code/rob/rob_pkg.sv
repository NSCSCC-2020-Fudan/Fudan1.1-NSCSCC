//  Package: rob_pkg
//
package rob_pkg;
    import common::*;
    import decode_pkg::*;
    //  Group: Parameters
    parameter ROB_ADDR_LEN = $clog2(PREG_NUM);
    parameter ROB_TABLE_LEN = 2 ** ROB_ADDR_LEN;

    //  Group: Typedefs
    typedef logic[ROB_ADDR_LEN:0] rob_ptr_t;
    typedef logic[ROB_ADDR_LEN-1:0] rob_addr_t;
    typedef union packed{
        struct packed {
        	word_t zeros;
            word_t data;
        } alu;
        struct packed {
            vaddr_t addr;
            word_t data;
        } mem;
        struct packed {
        	logic [30:0] zeros;
            logic branch_taken;
            word_t pcbranch;
        } branch;
        struct packed {
            word_t hi;
            word_t lo;
        } mult;
    } entry_data_t;
    typedef struct packed{
        logic complete;
        preg_addr_t preg;
        creg_addr_t creg;
        entry_data_t data;
        word_t pcplus8;
        control_t ctl;
        logic in_delay_slot;
        exception_pkg::exception_info_t exception;
    } entry_t;
    typedef entry_t[2**ROB_ADDR_LEN-1:0] rob_table_t;
endpackage: rob_pkg
