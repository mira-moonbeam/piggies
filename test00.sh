#! /usr/bin/env dash

# ==============================================================================
# test00.sh
# Test the pigs-init command.
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

# CREATE SECOND PIGS REPO ALREADY EXISTS
cat > "$expected_output" <<EOF
pigs-init: error: .pig already exists
EOF

pigs-init > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# CHECK CONTENTS
cat > "$expected_output" <<EOF
commits
index
log
status
EOF

ls .pig > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

echo "$0: pigs-init test passed!"