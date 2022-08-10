$ ! 
$ ! LAUNCH.COM (Launches a Harmony Core Traditional Bridge process)
$ ! 
$ VERIFY = F$VERIFY(0)
$ !
$ DEVICE = F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DEVICE")
$ ROOT   = "''DEVICE'''F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DIRECTORY")'"
$ SET DEFAULT 'ROOT
$ !
$ LOGLEVEL="''P1'"
$ !
$ DEFINE:==DEFINE/NOLOG
$ !
$ DEFINE HARMONY_LOG_LEVEL "''LOGLEVEL'"
$ !
$ WRITE SYS$OUTPUT ""
$ !
$ !------------------------------------------------------------------------
$ ! To enable creation of process crash dumps with $ ANAL/PROCESS_DUMP <file>.DMP
$ !
$ !SET PROCESS/DUMP
$ !DEFINE/USER SIG_CORE "1"
$ !DEFINE/USER DBG$IMAGE_DSF_PATH synergyde$root:[dbl.bin]
$ !DEFINE/USER SYS$ERROR ERROR.LOG
$ !------------------------------------------------------------------------
$ !
$ DEFINE/USER SYS$INPUT SYS$COMMAND
$ !
$ RUN HOST.EXE
$ !