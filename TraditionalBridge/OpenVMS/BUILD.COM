$ !
$ @SETUP.COM
$ !
$ !-------------------------------------------------------------
$ WRITE SYS$OUTPUT "Prototyping the routines we're going to call..."
$ !
$ PROTOFILE = F$SEARCH("SYNEXPDIR:*.DBP")
$ IF PROTOFILE .NES. "" THEN DELETE/NOLOG/NOCONF SYNEXPDIR:*.DBP;*
$ !
$ DBLPROTO -OUT=BRIDGE BRIDGE_SRC:*.DBL
$ DBLPROTO -OUT=DISPATCHERS DISPATCHER_SRC:*.DBL
$ DBLPROTO -OUT=METHODS METHOD_SRC:*.DBL
$ DBLPROTO -OUT=MODELS MODEL_SRC:*.DBL
$ !
$ !-------------------------------------------------------------
$ WRITE SYS$OUTPUT "Compiling traditional bridge code..."
$ !
$ DBL/NOWARN/OBJ=BRIDGE_OBJ:HOST.OBJ -
 BRIDGE_SRC:ArgumentDataDefinition.dbl+ -
 BRIDGE_SRC:Convert.dbl+ -
 BRIDGE_SRC:DataObjectBase.dbl+ -
 BRIDGE_SRC:DataObjectMetadataBase.dbl+ -
 BRIDGE_SRC:FieldDataDefinition.dbl+ -
 BRIDGE_SRC:Json.dbl+ -
 BRIDGE_SRC:Logger.dbl+ -
 BRIDGE_SRC:RoutineDispatcher.dbl+ -
 BRIDGE_SRC:Serializer.dbl+ -
 BRIDGE_SRC:SerializerV11.dbl+ -
 BRIDGE_SRC:StringDictionary.dbl+ -
 DISPATCHER_SRC:MethodDispatcher.dbl+ -
 DISPATCHER_SRC:MyApiDispatcher.dbl+ -
 DISPATCHER_SRC:MyApiMethodDispatchers+ -
 METHOD_SRC:AddTwoNumbers.dbl+ -
 METHOD_SRC:CustomerIO.dbl+ -
 METHOD_SRC:GetEnvironment.dbl+ -
 METHOD_SRC:GetLogicalName.dbl+ -
 METHOD_SRC:ItemIO.dbl;+ -
 METHOD_SRC:OrderIO.dbl;+ -
 METHOD_SRC:OrderItemIO.DBL;+ -
 METHOD_SRC:VendorIO.dbl;+ -
 MODEL_SRC:Customer.dbl;+ -
 MODEL_SRC:CustomerMetaData.dbl;+ -
 MODEL_SRC:Item.dbl;+ -
 MODEL_SRC:ItemMetaData.dbl;+ -
 MODEL_SRC:Order.dbl;+ -
 MODEL_SRC:OrderMetaData.dbl;+ -
 MODEL_SRC:OrderItem.dbl;+ -
 MODEL_SRC:OrderItemMetaData.dbl;+ -
 MODEL_SRC:Vendor.dbl;+ -
 MODEL_SRC:VendorMetaData.dbl;+ -
 HOST_SRC:host.dbl
$ !
$ !-------------------------------------------------------------
$ WRITE SYS$OUTPUT "Linking traditional bridge code..."
$ !
$ LINK/MAP=HOST.MAP/EXE=BRIDGE_EXE:HOST.EXE BRIDGE_OBJ:HOST.OBJ,BRIDGE_EXE:BRIDGE/OPT
$ !
$ EXIT
