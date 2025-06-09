// Find scoped_guard(identifier) { ... } pattern inside functions
// Matches the exact pattern: scoped_guard(expression) { statements }
//scoped_guard.cocci

@initialize:python@
@@
count = 0

@r1@
position p;
statement s;
@@
scoped_guard@p(...) s

@script:python@
p << r1.p;
@@
count += 1
print(f"Found scoped_guard at {p[0].file}:{p[0].line} (Python count: {count})")

@finalize:python@
@@
print("=" * 50)
print("SCOPED_GUARD USAGE SUMMARY")
print("=" * 50)
print("Total scoped_guard blocks found: %d" % count)
print("=" * 50)
