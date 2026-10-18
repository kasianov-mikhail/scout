static inline __attribute__((always_inline)) int square(int value) {
    return value * value;
}

static inline __attribute__((always_inline)) int sum_of_squares(int first, int second) {
    return square(first) + square(second);
}

__attribute__((noinline)) int compute(int first, int second) {
    return sum_of_squares(first, second) * 2;
}

int main(int argc, char **argv) {
    return compute(argc, argc + 1);
}
