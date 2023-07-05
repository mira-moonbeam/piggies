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

pigs-add c d e f g h i > /dev/null 2>&1     # j untracked, c same as repo (not gonna change it)
pigs-commit -m "test" > /dev/null 2>&1

rm i                                        # i file deleted (not in root)

pigs-rm --force h > /dev/null               # h file deleted, deleted in index (not in root and index)

echo line1 > g
pigs-rm --force --cached g > /dev/null 2>&1 # g deleted from index (work diff from repo, not in index)

echo line1 > f                              # f file changed, not staged for commit (work diff from repo, index same as repo)

echo line1 > e
pigs-add e > /dev/null 2>&1 
echo line3 > e                              # e file changed, different changes staged for commit

echo line 1 > d
pigs-add d > /dev/null 2>&1                 # d file changed, changes staged for commit

pigs-add a b > /dev/null 2>&1               # b added to index (never committed)
echo line 1 > a                             # a added to index, file changed

touch k > /dev/null
pigs-add k > /dev/null
rm k                                        # k added to index, file deleted              

# NOW CHECK STATUS
cat > "$expected_output" <<EOF
a - added to index, file changed
b - added to index
c - same as repo
d - file changed, changes staged for commit
e - file changed, different changes staged for commit
f - file changed, changes not staged for commit
g - deleted from index
h - file deleted, deleted from index
i - file deleted
j - untracked
k - added to index, file deleted
EOF

pigs-status > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

echo "$0: pigs-status test passed!"