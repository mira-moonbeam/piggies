#! /usr/bin/env dash

# ==============================================================================
# test02.sh
# Test the pigs-commit command with various arguments.
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

# COMMIT BEFORE PIG INITIALIZE
cat > "$expected_output" <<EOF
pigs-commit: error: pigs repository directory .pig not found
EOF

pigs-commit -a -m 'test' > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# CREATE PIGS REPO
cat > "$expected_output" <<EOF
Initialized empty pigs repository in .pig
EOF

pigs-init > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# CHECK IT EXISTS
if [ ! -d ".pig" ]; then
    echo "Failed test: You didn't actually make a pigs repo LOL"
    exit 1
fi

# NOTHING TO COMMIT
cat > "$expected_output" <<EOF
nothing to commit
EOF

pigs-commit -a -m 'test' > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# ADD FILES TO INDEX (already tested in test01)
cat > "$expected_output" <<EOF
EOF

pigs-add a b > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# case: commit message provided without -a flag
cat > "$expected_output" <<EOF
Committed as commit 0
EOF

pigs-commit -m 'test' > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# IMPROPER ARGS

# case: empty commit message
cat > "$expected_output" <<EOF
pigs-commit: error: message argument is not assigned a value
EOF

pigs-commit -m '' > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test: Empty commit msg"
    exit 1
fi

# case: flags and message in wrong order
cat > "$expected_output" <<EOF
pigs-commit: error: should have arguments in style [-a] -m [commit-message]
EOF

pigs-commit -m -a 'test' > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# case: flags in wrong order
cat > "$expected_output" <<EOF
pigs-commit: error: should have arguments in style [-a] -m [commit-message]
EOF

pigs-commit -m -a 'test' > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi


echo "$0: pigs-commit args test passed!"