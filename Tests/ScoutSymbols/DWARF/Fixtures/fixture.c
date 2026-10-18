static int square(int value) {
    return value * value;
}

int sum_of_squares(int count) {
    int total = 0;
    for (int index = 0; index < count; index++) {
        total += square(index);
    }
    return total;
}

int main(void) {
    return sum_of_squares(4);
}
