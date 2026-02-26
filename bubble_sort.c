#define STATUS_ADDR ((volatile int *)0x100)

// Function: Bubble sort an array
// Torture tests: Nested loops, memory loads/stores, pointer math, and unpredictable branches.
void bubble_sort(int *arr, int n) {
    int i, j, temp;
    for (i = 0; i < n - 1; i++) {
        for (j = 0; j < n - i - 1; j++) {
            // Load-to-use hazard followed by a branch!
            if (arr[j] > arr[j + 1]) {
                // Heavy memory swapping
                temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
}

// Function: Compute Fibonacci sequence
// Torture tests: Tight ALu data dependencies and backwards looping.
int compute_fib(int n) {
    if (n <= 1) return n;
    int a = 0, b = 1, c = 0;
    for(int i = 2; i <= n; i++) {
        c = a + b;
        a = b;
        b = c;
    }
    return b;
}

void my_main() {
    int success = 1;

    // --- TEST 1: Array Sorting ---
    // Note: We assign values manually to avoid the compiler inserting a memcpy() call
    int data[5];
    data[0] = 45;
    data[1] = 12;
    data[2] = 89;
    data[3] = 2;
    data[4] = 33;

    bubble_sort(data, 5);
    
    // Check if the array is perfectly sorted: {2, 12, 33, 45, 89}
    if (data[0] != 2)  success = 0;
    if (data[1] != 12) success = 0;
    if (data[2] != 33) success = 0;
    if (data[3] != 45) success = 0;
    if (data[4] != 89) success = 0;

    // --- TEST 2: Mathematical Sequence ---
    // The 10th Fibonacci number is 55
    if (compute_fib(10) != 55) success = 0;

    // Final Output
    if (success == 1) {
        *STATUS_ADDR = 1; // Success!
    } else {
        *STATUS_ADDR = 0; // Failed.
    }

    while(1);
}