#!/bin/bash

F1="tests/test_files/test1.txt"
F2="tests/test_files/test2.txt"
F3="tests/test_files/test3.txt"

i=0
suc=0
fail=0

echo "---------------------------------------------------"
echo "No-flag test"
i=$((i+1))
cat "$F1" > 1 && ./s21_cat "$F1" > 2 && if diff -q 1 2;
then echo "\033[32mTest 1 SUCCESSFUL\033[0m"; suc=$((suc+1));
else echo "\033Test 1 FAILED\033[0m";  fail=$((fail+1)); fi

echo "---------------------------------------------------"

echo "Test flag -b"
i=$((i+1))
cat -b "$F1" > 1 && ./s21_cat -b "$F1" > 2 && if diff -q 1 2;
then echo "\033[32mTest 2 SUCCESSFUL\033[0m"; suc=$((suc+1));
else echo "\033Test 2 FAILED\033[0m"; fail=$((fail+1)); fi

echo "---------------------------------------------------"

echo "Test flag (GNU: --number-nonblank)"
i=$((i+1))
cat -b "$F1" > 1 && ./s21_cat --number-nonblank "$F1" > 2 && if diff -q 1 2;
then echo "\033[32mTest 3 SUCCESSFUL\033[0m"; suc=$((suc+1));
else echo "\033Test 3 FAILED\033[0m"; fail=$((fail+1)); fi

echo "---------------------------------------------------"

echo "Test flag -e"
i=$((i+1))
cat -e "$F1" > 1 && ./s21_cat -e "$F1" > 2 && if diff -q 1 2;
then echo "\033[32mTest 4 SUCCESSFUL\033[0m"; suc=$((suc+1));
else echo "\033Test 4 FAILED\033[0m"; fail=$((fail+1)); fi

echo "---------------------------------------------------"

echo "Test flag -E"
i=$((i+1))
cat -e "$F1" > 1 && ./s21_cat -Ev "$F1" > 2 && if diff -q 1 2;
then echo "\033[32mTest 5 SUCCESSFUL\033[0m"; suc=$((suc+1));
else echo "\033Test 5 FAILED\033[0m"; fail=$((fail+1)); fi

echo "---------------------------------------------------"

echo "Test flag -n"
i=$((i+1))
cat -n "$F1" > 1 && ./s21_cat -n "$F1" > 2 && if diff -q 1 2;
then echo "\033[32mTest 6 SUCCESSFUL\033[0m"; suc=$((suc+1));
else echo "\033Test 6 FAILED\033[0m"; fail=$((fail+1)); fi

echo "---------------------------------------------------"

echo "Test flag (GNU: --number)"
i=$((i+1))
cat -n "$F1" > 1 && ./s21_cat --number "$F1" > 2 && if diff -q 1 2;
then echo "\033[32mTest 7 SUCCESSFUL\033[0m"; suc=$((suc+1));
else echo "\033Test 7 FAILED\033[0m"; fail=$((fail+1)); fi

echo "---------------------------------------------------"

echo "Test flag -s"
i=$((i+1))
cat -s "$F1" > 1 && ./s21_cat -s "$F1" > 2 && if diff -q 1 2;
then echo "\033[32mTest 8 SUCCESSFUL\033[0m"; suc=$((suc+1));
else echo "\033Test 8 FAILED\033[0m"; fail=$((fail+1)); fi
echo "---------------------------------------------------"

echo "Test flag (GNU: --squeeze-blank)"
i=$((i+1))
cat -s "$F1" > 1 && ./s21_cat --squeeze-blank "$F1" > 2 && if diff -q 1 2;
then echo "\033[32mTest 9 SUCCESSFUL\033[0m"; suc=$((suc+1));
else echo "\033Test 9 FAILED\033[0m"; fail=$((fail+1)); fi

echo "---------------------------------------------------"

echo "Test flag -t"
i=$((i+1))
cat -t "$F1" > 1 && ./s21_cat -t "$F1" > 2 && if diff -q 1 2;
then echo "\033[32mTest 10 SUCCESSFUL\033[0m"; suc=$((suc+1));
else echo "\033Test 10 FAILED\033[0m"; fail=$((fail+1)); fi

echo "---------------------------------------------------"

echo "Test flag -T"
i=$((i+1))
cat -t "$F1" > 1 && ./s21_cat -Tv "$F1" > 2 && if diff -q 1 2;
then echo "\033[32mTest 11 SUCCESSFUL\033[0m"; suc=$((suc+1));
else echo "\033Test 11 FAILED\033[0m"; fail=$((fail+1)); fi

echo "---------------------------------------------------"

echo "Test multi-flags -bestv"
i=$((i+1))
cat -bestv "$F1" > 1 && ./s21_cat -bestv "$F1" > 2 && if diff -q 1 2;
then echo "\033[32mTest 12 SUCCESSFUL\033[0m"; suc=$((suc+1));
else echo "\033Test 12 FAILED\033[0m"; fail=$((fail+1)); fi

echo "---------------------------------------------------"

echo "No-flag test two files"
i=$((i+1))
cat "$F1" "$F2" > 1 && ./s21_cat "$F1" "$F2" > 2 && if diff -q 1 2;
then echo "\033[32mTest 13 SUCCESSFUL\033[0m"; suc=$((suc+1));
else echo "T\033est 13 FAILED\033[0m"; fail=$((fail+1)); fi

echo "---------------------------------------------------"

echo "\033[31mFAIL: $fail\033[0m"
echo "\033[32mSUCCESS: $suc\033[0m"
echo "ALL TESTS: $i"

rm 1 2

if [ "$fail" -gt 0 ]; then
  exit 1
else
  exit 0
fi