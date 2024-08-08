---
title: Test results

---

## Reports by version

- [14.2.0-1](/docs/tests/14.2.0-1/)
- [14.1.0-1](/docs/tests/14.1.0-1/)
- [13.3.0-1](/docs/tests/13.3.0-1/)
- [12.4.0-1](/docs/tests/12.4.0-1/)
- [11.5.0-1](/docs/tests/11.5.0-1/)

## Notes

### GNU/Linux

Both x64 and arm64 are fine, except static **sleepy-threads-cv**.

#### Failed test sleepy-threads-cv

This issue affects only static test cases,
the non-static ones are fine.
It seems to be an incompatibility with older GLIBC versions
([#115421](https://gcc.gnu.org/bugzilla/show_bug.cgi?id=115421)).

### macOS

Both x64 and arm64 are fine, except **overload-new-cpp**.

#### Failed test overload-new-cpp

The two test cases fail only when garbage
collected sections are is used and not static (to be investigated, see
[#132](https://github.com/iains/gcc-darwin-arm64/issues/132)).

### Mingw-w64 Windows x86_64

There are more failing tests that on macOS and GNU/Linux.

#### Failed test autoimport-main

This problem reported by the Mingw-w64 runtime
seems to be related to LTO, the other test cases are fine.

#### Failed test hello-weak1-c

Weak symbols seem not supported, probably
the LTO test cases pass because the weak symbols are resolved.

#### Failed test overload-new-cpp

All non-static test cases fail, all static pass.

#### Failed test throwcatch-main

This problem reported by the Mingw-w64 runtime
seems to be related to LTO, the other test cases are fine.

#### Failed test unwind-weak-cpp

Possibly related to the weak symbols issues.

#### Failed test weak-duplicate-c

Weak symbols seem not supported, probably
the LTO test cases pass because the weak symbols are resolved.

#### Failed test weak-use-c

Weak symbols seem not supported, probably
the LTO test cases pass because the weak symbols are resolved.
