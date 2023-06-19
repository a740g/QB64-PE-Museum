# BIN2INCLUDE

This is a GUI adaptation of the code made by Dav for QB64 (<http://www.qbasicnews.com/dav/files/basfile.bas>) (originally in QBasic (<http://www.qbasicnews.com/dav/files/bin2bas.bas>)) that would turn any file into a .bas file that could then be included in QB64 code to be compiled and create the original file once again.
This program can accept a drag and drop onto the program window itself.
This is now a viable option for compressing a file! Thanks, Dav!

There can be a problem with an output file being too large to create at runtime. This is not an issue with the code or the input file itself. If you run into a memory problem, look at the SOLUTION TO MEMORY ISSUE.

# SOLUTION TO MEMORY ISSUE

If necessary, you can compile the code that this program creates by uncommenting #lang "qb" and removing the line with the IF FILEEXISTS and the corresponding line with the END IF. You can then compile the code in FreeBasic and it can handle larger files than QB64 is able to.
