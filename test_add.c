#define STATUS_ADDR ((volatile int *)0x100)

int multiply_by_add(int val, int count) {
    volatile int sum = 0; // Tells GCC: "Do not optimize this into a multiply!"
    for(int i = 0; i < count; i++) {
        sum = sum + val;
    }
    return sum;
}

void my_main() {
    int success = 1;

    // Removed 'volatile' to allow compiler optimization.
    // If this passes, your CPU has a Data Hazard.
    int a = 15;
    int b = 10;
    if ((a + b) != 25) success = 0;
    if ((a - b) != 5)  success = 0;

    // Test Comparisons explicitly
    int u = 16;
    int s = -16;
    
    // If  CPU has an ALU signedness bug, this specific check will fail
    if (s > a) success = 0; 

    // Test Jumps and Control Flow
    if (multiply_by_add(5, 4) != 20) success = 0; 

    // Final Output
    if (success == 1) {
        *STATUS_ADDR = 1; // Success!
    } else {
        *STATUS_ADDR = 0; // Failed.
    }

    while(1);
}