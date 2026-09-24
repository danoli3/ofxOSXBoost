# openFrameworks validation example

This project is intentionally stored without generated IDE files. Use the
openFrameworks Project Generator and select `ofxOSXBoost`, or run:

```bash
projectGenerator -posx -aofxOSXBoost -o/path/to/openFrameworks .
```

The app calls `boost::filesystem::path::filename()`, which requires the
compiled Boost.Filesystem library. A successful build therefore verifies both
the XCFramework headers and static library link.
