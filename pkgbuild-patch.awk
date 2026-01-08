#!/usr/bin/env awk -f

BEGIN {
    if (ARGC != 3) {
        print "Usage: " ARGV[0] " PKGBUILD gtk_unit_scale.patch" > "/dev/stderr"
        exit 1
    }
    patch_file = ARGV[2]
    patch_name = (ARGV[2] ~ /.*\//) ? substr(ARGV[2], rindex(ARGV[2], "/") + 1) : ARGV[2]
    delete ARGV[2]  # Avoid awk treating it as input file

    # Compute b2sum of patch file
    cmd = "b2sum " patch_file " 2>/dev/null"
    if ((cmd | getline b2sum) > 0) {
        split(b2sum, parts, " ")
        b2sum = parts[1]
    } else {
        print "Error: Could not compute b2sum for " patch_file > "/dev/stderr"
        exit 1
    }
    close(cmd)

    # Flags to track state
    in_prepare = 0
    in_source = 0
    in_b2sum = 0
    source_added = 0
    b2sum_added = 0
    git_apply_added = 0
}

# Detect start of prepare function
/^prepare\(\).*$/ { in_prepare = 1; }

# Detect and patch end of prepare
/^}/ {
  if (in_prepare && !git_apply_added) {
    print "  git apply -3 ../" patch_name
    git_apply_added = 1
    in_prepare = 0
  }
}

/\)[[:space:]]*$/ {
  if (in_source) {
    sub(/\)[[:space:]]*$/, "")
    print
    print "  \"" patch_name "\""
    print ")"
    in_source = 0
    source_added = 1
    next
  }
  if (in_b2sum) {
    sub(/\)[[:space:]]*$/, "")
    print
    print "  '" b2sum "'"
    print ")"
    in_b2sum = 0
    b2sum_added = 1
    next
  }
}

# Print current line
{ print }

# Append line to source and b2sums arrays 
/^source=\(/ { 
  if (!source_added) {
    in_source = 1
  }
}

/^b2sums=\(.*/ { 
  if (!b2sum_added) {
    in_b2sum = 1
  }
}

# Check that the patch applied successfully
END {
    if (in_prepare) {
        print "Failed to match end of prepare section" 
        exit 1
    }
    if (in_source) {
        print "Failed to match end of source section" 
        exit 1
    }
    if (in_b2sum) {
        print "Failed to match end of b2sum section" 
        exit 1
    }
    if (!source_added) {
        print "Failed to patch source array" 
        exit 1
    }
    if (!b2sum_added) {
        print "Failed to patch b2sum array" 
        exit 1
    }
    if (!git_apply_added) {
        print "Failed to patch prepare() function" 
        exit 1
    }
}
