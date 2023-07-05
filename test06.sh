#! /usr/bin/env dash

# ==============================================================================
# test06.sh
# Test the pigs-log command.
# ==============================================================================

# add the current directory to the PATH so scripts
# can still be executed from it after we cd

PATH="$PATH:$(pwd)"

# Create a temporary directory for the test.
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

# Create some files to hold output.

expected_output="$(mktemp)"
actual_output="$(mktemp)"

# Remove the temporary directory when the test is done.

trap 'rm "$expected_output" "$actual_output" -rf "$test_dir"' INT HUP QUIT TERM EXIT

# Make some files and directories
echo line 1 > a
echo hello world > b

cat > "$expected_output" <<EOF
Initialized empty pigs repository in .pig
EOF

pigs-init > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# NO COMMITS
cat > "$expected_output" <<EOF
EOF

pigs-log > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# WITH COMMITS
cat > "$expected_output" <<EOF
EOF

pigs-add a > /dev/null 2>&1
pigs-commit -m 'test'> /dev/null 2>&1

pigs-add b > /dev/null 2>&1
pigs-commit -m 'second com' > /dev/null 2>&1

cat > "$expected_output" <<EOF
1 second com
0 test
EOF

pigs-log > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

echo "$0: pigs-log test passed!"