#! /usr/bin/env dash

# ==============================================================================
# test07.sh
# Test the pigs-rm command errors.
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

# PIGS RM BEFORE PIG INITIALIZE
cat > "$expected_output" <<EOF
pigs-rm: error: pigs repository directory .pig not found
EOF

pigs-rm a > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

pigs-init> /dev/null 2>&1

pigs-add a > /dev/null 2>&1
pigs-commit -m 'test'> /dev/null 2>&1

# ERROR: Change in WORKING vs REPO AND INDEX
echo line2 >> a

cat > "$expected_output" <<EOF
pigs-rm: error: 'a' in the repository is different to the working file
EOF

pigs-rm a> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# ERROR: Change in WORKING and INDEX vs REPO
pigs-add a > /dev/null 2>&1

cat > "$expected_output" <<EOF
pigs-rm: error: 'a' has staged changes in the index
EOF

pigs-rm a> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# ERROR: Change in WORKING vs INDEX and INDEX vs REPO
echo lin3 >> a

cat > "$expected_output" <<EOF
pigs-rm: error: 'a' in index is different to both the working file and the repository
EOF

pigs-rm a> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi


cat > "$expected_output" <<EOF
pigs-rm: error: 'a' in index is different to both the working file and the repository
EOF

pigs-rm --cached a> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# CRITICAL ERRORS (UN FORCE-ABLE)
#  ERROR: Filename doesnt exist
cat > "$expected_output" <<EOF
pigs-rm: error: 'b' is not in the pigs repository
EOF

pigs-rm b> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# ERROR: File only exists in index
pigs-rm --cached --force a > /dev/null 2>&1
cat > "$expected_output" <<EOF
pigs-rm: error: 'a' is not in the pigs repository
EOF

pigs-rm a> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

pigs-rm --force a> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

echo "$0: pigs-rm errors test passed!"