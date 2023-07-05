#! /usr/bin/env dash

# ==============================================================================
# test09.sh
# Test the pigs-status check.
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

# PIGS STATUS BEFORE PIG INITIALIZE
cat > "$expected_output" <<EOF
pigs-status: error: pigs repository directory .pig not found
EOF

pigs-status > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

pigs-init > /dev/null 2>&1
touch a b c d e f g h i j
pigs-add a b c d e f g h i > /dev/null 2>&1 # j untracked
pigs-commit -m "test" > /dev/null 2>&1
rm i                                        # i file deleted (not in root)
pigs-rm --force h > /dev/null               # h file deleted, deleted in index (not in root and index)

pigs-rm --force --cached g > /dev/null 2>&1 # g deleted from index (work diff from repo, not staged)
echo line1 > g



# k added to index, file deleted
touch k > /dev/null
pigs-add k > /dev/null
rm k                                        
 


pigs-status

echo "$0: pigs-status test passed!"