#! /usr/bin/env dash

# ==============================================================================
# test01.sh
# Test the pigs-add command.
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
echo hey > .badFile
echo rawr > ho^rrend0usn4me
mkdir badDir

# ADDING ANYTHING BEFORE REPO CREATION/ PIGS INITIALIZATION
cat > "$expected_output" <<EOF
pigs-add: error: pigs repository directory .pig not found
EOF

pigs-add a > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output" <<EOF
pigs-add: error: pigs repository directory .pig not found
EOF

pigs-add badDir > "$actual_output" 2>&1
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

# ADD FILES TO THE STAGING AREA
cat > "$expected_output" <<EOF
EOF

pigs-add a > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output" <<EOF
EOF

pigs-add a b > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# CHECK STAGING AREA AND ITS CONTENTS
if [ ! -f ".pig/index/a" ]; then
    echo "Failed test: You didn't actually copy the files lol"
    exit 1
fi

if [ ! -f ".pig/index/b" ]; then
    echo "Failed test: You didn't actually copy the files lol"
    exit 1
fi

if ! diff ".pig/index/b" "b" > /dev/null; then
    echo "Failed test: You didn't actually copy the files lol"
    exit 1
fi

# ADD CHANGED FILE
echo new line > a
pigs-add a

if ! diff ".pig/index/a" "a" > /dev/null; then
    echo "Failed test: You didn't actually copy the files lol"
    exit 1
fi

# ADD A DIRECTORY
cat > "$expected_output" <<EOF
pigs-add: 'badDir' is a repository and not a file
EOF

pigs-add badDir > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# ADD BAD FILENAME
cat > "$expected_output" <<EOF
pigs-add: error: '.badFile' bad filename.
EOF

pigs-add .badFile > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output" <<EOF
pigs-add: error: 'ho^rrend0usn4me' bad filename.
EOF

pigs-add ho^rrend0usn4me > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# ADD NONO-EXISTENT FILE
cat > "$expected_output" <<EOF
pigs-add: error: can not open 'crazyFile'
EOF

pigs-add crazyFile > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"

if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

echo "$0: pigs-add test passed!"