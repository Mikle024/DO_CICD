#!/bin/bash

i=0
suc=0
fail=0
PATTERN_1="Hello"
PATTERN_2="world"
TESTS_FILES=tests/test_files/*.txt
PATTERN_FILE=tests/test_files/pattern.txt
COUNTER=0

testing() {
    i=$((i+1))
    grep $var $PATTERN_1 $TESTS_FILES > 1
    ./s21_grep $var $PATTERN_1 $TESTS_FILES > 2

    diff 1 2 > /dev/null

    if [ $? -eq 0 ]; then
        echo "\033[32mTest $i. $var: SUCCESSFUL\033[0m"
        suc=$((suc+1))
    else
        echo "\033[31mTest $i. $var: FAILED\033[0m"
        fail=$((fail+1))
    fi
    echo "---------------------------------------------------"
}

for var1 in v c l n h o; do
    var="-$var1"
    testing
done

for var1 in n h; do
    for var2 in v c l n h o; do
        if [ "$var1" != "$var2" ]; then
            var="-$var1 -$var2"
            testing
        fi
    done
done

echo "\033[31mFAIL: $fail\033[0m"
echo "\033[32mSUCCESS: $suc\033[0m"
echo "ALL: $i"

rm 1 2

if [ "$fail" -gt 0 ]; then
    exit 1
else
    exit 0
fi