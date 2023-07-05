#! /usr/bin/env dash

# ==============================================================================
# test08.sh
# Test the pigs-rm command.
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
echo hello > b

pigs-init> /dev/null 2>&1

pigs-add a > /dev/null 2>&1
pigs-commit -m 'test'> /dev/null 2>&1

pigs-add b > /dev/null 2>&1
pigs-commit -m 'second com' > /dev/null 2>&1

# Simple remove
cat > "$expected_output" <<EOF
EOF

pigs-rm a> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# CHECK
cat > "$expected_output" <<EOF
b
EOF

ls .> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

ls .pig/index> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# CACHE OPTION
cat > "$expected_output" <<EOF
EOF

pigs-rm --cached b> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# CHECK
ls .pig/index> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output" <<EOF
b
EOF

ls .> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# remake some files and directories
echo line 1 > a

pigs-init> /dev/null 2>&1

pigs-add a > /dev/null 2>&1
pigs-commit -m 'test'> /dev/null 2>&1

pigs-add b > /dev/null 2>&1
pigs-commit -m 'second com' > /dev/null 2>&1

# CACHE WORK DESPITE (staged changes in index) and (repo diff from working file)
echo line3 >> b
cat > "$expected_output" <<EOF
EOF

pigs-rm --cached b> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

pigs-add b > /dev/null 2>&1
cat > "$expected_output" <<EOF
EOF

pigs-rm --cached b> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

# FORCE CACHE
pigs-add b > /dev/null 2>&1
echo line4 >> b

cat > "$expected_output" <<EOF
pigs-rm: error: 'b' in index is different to both the working file and the repository
EOF

pigs-rm --cached b> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test"
    exit 1
fi

cat > "$expected_output" <<EOF
EOF

pigs-rm --force --cached b> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test aa"
    exit 1
fi

# CHECK
cat > "$expected_output" <<EOF
a
b
EOF

ls . > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test aa"
    exit 1
fi

cat > "$expected_output" <<EOF
a
EOF

ls .pig/index > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test aa"
    exit 1
fi

# FORCE
pigs-add b > /dev/null 2>&1

cat > "$expected_output" <<EOF
EOF

pigs-rm --force b> "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test aa"
    exit 1
fi

# CHECK
cat > "$expected_output" <<EOF
a
EOF

ls . > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test aa"
    exit 1
fi

cat > "$expected_output" <<EOF
a
EOF

ls .pig/index > "$actual_output" 2>&1
sed -i 's|^.*/||' "$actual_output"
if ! diff "$expected_output" "$actual_output"; then
    echo "Failed test aa"
    exit 1
fi

echo "$0: pigs-rm test passed!"