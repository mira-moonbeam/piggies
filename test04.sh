#! /usr/bin/env dash

# ==============================================================================
# test04.sh
# Test the pigs-show command.
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

cat > "$expected_output" <<EOF
EOF

pigs-add a > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output" <<EOF
Committed as commit 0
EOF

pigs-commit -m 'test' > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# BAD SHOWS

# Bad commit number
cat > "$expected_output" <<EOF
pigs-show: error: commit has to be a non-negative integer
EOF

pigs-show c:bad > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# No commit of that number
cat > "$expected_output" <<EOF
pigs-show: error: unknown commit '1'
EOF

pigs-show 1:a > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# Bad filename
cat > "$expected_output" <<EOF
pigs-show: error: 'b' not found in commit 0
EOF

pigs-show 0:b > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# All good
cat > "$expected_output" <<EOF
line 1
EOF

pigs-show 0:a > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi


echo "$0: pigs-show test passed!"