$ !
$ VERIFY = F$VERIFY(0)
$ !
$ DEVICE         = F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DEVICE")
$ ROOT           = "''DEVICE'''F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,"DIRECTORY")'"
$ SRC_ROOT       = "''DEVICE'''F$PARSE("[.SOURCE]",,,"DIRECTORY")'"
$ BRIDGE_SRC     = "''DEVICE'''F$PARSE("[.SOURCE.BRIDGE]",,,"DIRECTORY")'"
$ DISPATCHER_SRC = "''DEVICE'''F$PARSE("[.SOURCE.DISPATCHERS]",,,"DIRECTORY")'"
$ METHOD_SRC     = "''DEVICE'''F$PARSE("[.SOURCE.METHODS]",,,"DIRECTORY")'"
$ MODEL_SRC      = "''DEVICE'''F$PARSE("[.SOURCE.MODELS]",,,"DIRECTORY")'"
$ STUB_SRC       = "''DEVICE'''F$PARSE("[.SOURCE.STUBS]",,,"DIRECTORY")'"
$ SYNEXPDIR      = "''DEVICE'''F$PARSE("[.PROTO]",,,"DIRECTORY")'"
$ OBJDIR         = "''DEVICE'''F$PARSE("[.OBJ]",,,"DIRECTORY")'"
$ RPSDIR         = "''DEVICE'''F$PARSE("[.REPOSITORY]",,,"DIRECTORY")'"
$ !
$ SET DEF 'ROOT
$ !
$ DEFINE/NOLOG HOST_SRC       'SRC_ROOT
$ DEFINE/NOLOG BRIDGE_SRC     'BRIDGE_SRC
$ DEFINE/NOLOG DISPATCHER_SRC 'DISPATCHER_SRC
$ DEFINE/NOLOG METHOD_SRC     'METHOD_SRC
$ DEFINE/NOLOG MODEL_SRC      'MODEL_SRC
$ DEFINE/NOLOG STUB_SRC       'STUB_SRC
$ DEFINE/NOLOG SYNEXPDIR      'SYNEXPDIR
$ DEFINE/NOLOG SYNIMPDIR      'SYNEXPDIR
$ DEFINE/NOLOG BRIDGE_OBJ     'OBJDIR
$ DEFINE/NOLOG BRIDGE_EXE     'ROOT
$ !
$ DEFINE/NOLOG RPSMFIL        "''RPSDIR'RPSMAIN.ISM"
$ DEFINE/NOLOG RPSTFIL        "''RPSDIR'RPSTEXT.ISM"
$ !
$ SET PROMPT="$ "
$ SET CONTROL=Y
$ !
$ DIR:==DIR/SIZ/DAT
$ !
