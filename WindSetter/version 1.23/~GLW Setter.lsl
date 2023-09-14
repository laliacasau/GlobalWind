//revisar eventkey en el servidor al enviar datos en el start y en la devolucion de datos del recovery

integer swdbg;
integer  ciGlwChannel=-15368945;
string   csServerDir="/glw122/";
integer  ciTIMERINTERVAL=1;  // in seconds
integer   ciDebug=1;

string   gsServer;
string   gsIdEvent;

// GLW data ===>
string   gsGlwDirectorKey;
string   gsGlwEventNum;
string   gsGlwDirectorName;

integer  giGlwWndDir;
integer  giGlwWndSpeed=15;   //knots
integer  giGlwWndGusts;
integer  giGlwWndShifts;
integer  giGlwWndPeriod=60;  //gfGlwWndChangeRate=1;
integer  giGlwWavSpeed=3; //knots
integer  giGlwWavHeightVariance;
integer  giGlwWavLengthVariance;
integer  giGlwWavHeight;  //*10
integer  giGlwWavLength=50;  //meters
integer  giGlwWavEffects=3;
integer  giGlwCrtDir;
integer  giGlwCrtSpeed;  //*10
integer  giGlwSailMode;
string   gsGlwEventName;
string   gsGlwEventKey;
string   gsGlwExtra1;
string   gsGlwExtra2;
integer  giGlwWaterDepth=10;
integer  giGlwUpdBoatPos;
string   gsGlwEventType;

//float    gfSpeedMultiplier=1.5;
list     LocalFluctuations=[];
list     Competitors=[];

integer  giBroadcastPeriodCounter=0;
integer  giBroadcastPeriod=0;
key      gkHttpRequest0;
key      gkHttpSrvAddEvent;
key      gkHttpSrvEndEvent;
key      gkHttpSrvUpdEvent;
key      gkHttpSrvRUpdEvent;
key      gkHttpSrvScanEvent;
key      gkHTTPSrvUpdEventUrl;
key      gkHttpSayEvent;
key      gkHttpSrvRecovery;
key      gkHttpSrvSignEvent;
key      gkHttpSrvReqMap;
key      gkHttpSrvRegionSW;
key      gkHttpSrvRegionNE;
key      gkHttpSrvFEventKey;
string   gsMsgGLW;
integer  giInterval;
integer  giIntervalMsg;
integer  giIntervalCount;
integer  giIntervalMsgCount;
integer  giDirectorMsg;
string   gsSayType;
integer  giHandle;
integer  giStarted=0;
integer  giSystemMode; //0-no use server  1-glw no server without variations  11-glw server without variations  12-glw server with variations
integer  giStatus;   //0-No Start Button  1-Push Start Button   3-start on broadcast off  4-start on broadcast on
integer  giCastTimer;
integer  giModTimer;
integer  giSignTimer;
integer  giPollTimes;
integer  giSayChannel=7;
integer  giSayHandle;
string   gsUrlSetter;
key      urlRequestId;
key      urlRequestCId;
key      urlRequestRId;
string   gsVariations;
integer  giCounter;
string   gsRecoveryId;

//map
integer giSW_x;
integer giSW_y;
integer giNE_x;
integer giNE_y;
string  gsMapUsb;
string  gsVarAreas;
string  gsVarCircles;
integer giMapWindDir;
integer giMapWindSpeed;
integer giMapCurrentSpeed;  
integer giMapCurrentDir;  
integer giMapWaveHeight; 
integer giOffsetWest;  
integer giOffsetNorth;  
integer giOffsetEast;  
integer giOffsetSouth; 
integer giMapSwMap;
integer giMapSwCourse;
integer giMapSwVars;

list     caHttpHeaders=[HTTP_METHOD,"POST",
                    HTTP_MIMETYPE,"text/csv",
                    HTTP_BODY_MAXLENGTH,4000,
                    HTTP_VERIFY_CERT,TRUE,
                    HTTP_VERBOSE_THROTTLE,TRUE,
                    HTTP_PRAGMA_NO_CACHE,TRUE];

init()
{
    giStatus=0;
    giBroadcastPeriodCounter=0;
    giBroadcastPeriod=0;
    gkHttpRequest0="";
    gkHttpSrvAddEvent="";
    gkHttpSrvEndEvent="";
    gkHttpSrvScanEvent="";
    gkHttpSrvRecovery="";
    gkHttpSrvReqMap="";
    gkHttpSrvRegionSW="";
    gkHttpSrvRegionNE=""; 
    gkHttpSrvFEventKey="";  
    gsMsgGLW="";
    giInterval=3;
    giIntervalMsg=15;
    giIntervalCount=0;
    giIntervalMsgCount=0;
    giDirectorMsg=1;
    giHandle=0;    
    giStarted=0;
    giSystemMode=0;
    gsMsgGLW="";
    //setWaterDepth();
    gsServer="";
    gsGlwDirectorKey="";
    gsGlwEventNum="";    
    gsIdEvent="";
    
    giGlwWndDir=0;
    giGlwWndSpeed=15;
    giGlwWndGusts=0;
    giGlwWndShifts=0;
    giGlwWndPeriod=60;
    giGlwWavSpeed=3;
    giGlwWavHeightVariance=0;
    giGlwWavLengthVariance=0;
    giGlwWavHeight=0;
    giGlwWavLength=50;
    giGlwCrtDir=0;
    giGlwCrtSpeed=0;
    giGlwSailMode=2;
    gsGlwEventName="";
    gsGlwEventKey="";
    gsGlwExtra1="";
    gsGlwExtra2="";
    giGlwWaterDepth=10;
    giGlwUpdBoatPos=3;
    gsGlwEventType="";
    gsVariations="";
}

fSay(key k, string p)
{
    llOwnerSay(p);
}

//psData="0-wind dir","1-wind speed","2-wind gusts","3-wind shifts","4-wind period","5-wave speed","6-wave height variance","7-wave length variance","8-wave height","9-wave length","10-wave effects","11-current dir","12-current speed","13-mode","14-name","15-extra1","16-extra2","17-waterdepth","18-update pos","19-event type"
loadData(string psData)
{
    //load or update data from Aux string
    list laData=llCSV2List(psData);
    giGlwWndDir=(integer)llList2String(laData,0);
    giGlwWndSpeed=(integer)llList2String(laData,1);
    giGlwWndGusts=(integer)llList2String(laData,2);
    giGlwWndShifts=(integer)llList2String(laData,3);
    giGlwWndPeriod=(integer)llList2String(laData,4);
    
    giGlwWavSpeed=(integer)llList2String(laData,5);
    giGlwWavHeightVariance=(integer)llList2String(laData,6);
    giGlwWavLengthVariance=(integer)llList2String(laData,7);
    giGlwWavHeight=(integer)llList2String(laData,8);
    giGlwWavLength=(integer)llList2String(laData,9);
    giGlwWavEffects=(integer)llList2String(laData,10);
    
    giGlwCrtDir=(integer)llList2String(laData,11);
    giGlwCrtSpeed=(integer)llList2String(laData,12);
    
    giGlwSailMode=(integer)llList2String(laData,13);
    gsGlwEventName=llList2String(laData,14);
    gsGlwEventKey=llList2String(laData,15);
    gsGlwExtra1=llList2String(laData,16);
    gsGlwExtra2=llList2String(laData,17);
    giGlwWaterDepth=(integer)llList2String(laData,18);
    giGlwUpdBoatPos=(integer)llList2String(laData,19);
    gsGlwEventType=llList2String(laData,20);
}

//"0-wind dir","1-wind speed","2-wind gusts","3-wind shifts","4-wind period","5-wave speed","6-wave height variance","7-wave length variance","8-wave height","9-wave length","10-wave effects","11-current dir","12-current speed","13-mode","14-name","key(only to server)","15-extra1","16-extra2","17-waterdepth","18-update pos","19-ones type"
string httpData(integer piMode){  //piMode:  0-Server  1-Boat
    //prepare string to server or to boat 
    string lsRet="";
    if(gsGlwDirectorKey!="" && gsGlwEventNum!="") {
        lsRet=gsGlwDirectorKey+","+
            gsGlwEventNum+","+
            gsIdEvent+","+
            gsServer+","+
            gsGlwDirectorName+","+

            (string)giGlwWndDir+","+
            (string)giGlwWndSpeed+","+
            (string)giGlwWndGusts+","+
            (string)giGlwWndShifts+","+
            (string)giGlwWndPeriod+","+
        
            (string)giGlwWavSpeed+","+
            (string)giGlwWavHeightVariance+","+
            (string)giGlwWavLengthVariance+","+
            (string)giGlwWavHeight+","+
            (string)giGlwWavLength+","+
            (string)giGlwWavEffects+","+
            
            (string)giGlwCrtDir+","+
            (string)giGlwCrtSpeed+","+

            (string)giGlwSailMode+","+
            gsGlwEventName+",";
        if(piMode==0) lsRet+=gsGlwEventKey+",";
        lsRet+=gsGlwExtra1+","+
            gsGlwExtra2+","+
            (string)giGlwWaterDepth+","+
            (string)giGlwUpdBoatPos+","+
            gsGlwEventType+","+
            (string)giSystemMode;
            
            //llOwnerSay("Setter send: "+lsRet);
    }
    return lsRet;
}

startEvent(string psEventNum, string psData)  //push start button 
{
    giStatus=1;
    giStarted=1;
    gsGlwEventNum=psEventNum;
    gsGlwDirectorKey=llGetSubString(psData,0,35);
    gsGlwDirectorName=llGetSubString(psData,37,-1);
    //setWaterDepth();
    if(gsServer!=""){ 
        if(gsVariations=="##") giSystemMode=11;   //no local variations
        else giSystemMode=12;      //there are local variations
        string ls=httpData(0)+"##"+gsVariations;  //data to send to server
        //llOwnerSay("data to server "+ls);
        gkHttpSrvAddEvent=llHTTPRequest(gsServer+csServerDir+"glwAddEvent.php",caHttpHeaders,ls);  //send data to server add event
    }else{
        giSystemMode=1;
        giStatus=3;
    }
}

//psData=Control##Data##Areas##Circles
modEvent(string psData, key pkTarget)
{
    list laData=llParseStringKeepNulls(psData,["##"],[]);
    string lsControl=llList2String(laData,0);
    string lsData=llList2String(laData,1);
    if(llGetSubString(lsControl,0,0)=="1") loadData(lsData);
    
    if(llGetSubString(lsControl,1,2)!="00"){
        string lsVars=llList2String(laData,2)+"##"+llList2String(laData,3);
        if((gsVariations=="##" && lsVars!="##") || (gsVariations!="##" && lsVars=="##")){
            lsControl="1"+llGetSubString(lsControl,1,2);
        }
        gsVariations=lsVars;
        if(gsVariations=="##") giSystemMode=11;   //no local variations
        else giSystemMode=12;      //there are local variations    
    }
    lsData+=","+(string)giSystemMode;      //add systemmode var
    if(gsIdEvent!=""){
        llOwnerSay("Updating boats with mods...");
        lsData=lsControl+"##"+gsIdEvent+","+lsData+"##"+llList2String(laData,2)+"##"+llList2String(laData,3);
        llOwnerSay("setter upd to server "+lsData);
        gkHttpSrvUpdEvent=llHTTPRequest(gsServer+csServerDir+"glwUpdEvent.php",caHttpHeaders,lsData);  //send data to server update event
    }else{
        llOwnerSay("There is no active event"); 
    }
}

startCast(string pSayType)
{
    gsSayType=pSayType;
    giStatus=4;
    giBroadcastPeriodCounter=0;
    giIntervalCount=giInterval;
    giIntervalMsgCount=giIntervalMsg;
    giHandle=llListen(ciGlwChannel-1,"","","");       //listen channel input receive boat wind request
    if(giBroadcastPeriod==0) fSay(gsGlwDirectorKey,"Broadcast started");
    else fSay(gsGlwDirectorKey,"Broadcasting for "+(string)giBroadcastPeriod+" seconds");
    /*
    if(llGetSubString(gsSayType,0,0)=="1"){  //shout 100m
        llShout(ciGlwChannel,"GLWindReg"+","+gsGlwDirectorKey+","+gsGlwEventNum+","+(string)gsGlwDirectorName);  //send wind signal
    }
    if(llGetSubString(gsSayType,1,1)=="1"){   //region say
        llRegionSay(ciGlwChannel,"GLWindReg"+","+gsGlwDirectorKey+","+gsGlwEventNum+","+(string)gsGlwDirectorName);  //send wind signal
    }
    if(gsSayType=="001"){  //personal wind
        llWhisper(ciGlwChannel,"GLWindReg"+","+gsGlwDirectorKey+","+gsGlwEventNum+","+(string)gsGlwDirectorName);  //send wind signal
    }
    */
    gsMsgGLW="GLW sailors your wind today is "+(string)giGlwWndDir+"º "+(string)giGlwWndSpeed+"kt. Say 'glw' or 'racing'";
    
    giCastTimer=1;
    if(giModTimer==0)llSetTimerEvent(ciTIMERINTERVAL);
}

stopCast()
{
    giCastTimer=0;
    giStatus=3;
    llListenRemove(giHandle);
    fSay(gsGlwDirectorKey,"Broadcast stopped");
}

requestMap(string psStr)
{
    list laData=llCSV2List(psStr);
    giSW_x=llList2Integer(laData,0);
    giSW_y=llList2Integer(laData,1);
    giNE_x=llList2Integer(laData,2);
    giNE_y=llList2Integer(laData,3);
    giOffsetWest=llList2Integer(laData,4);
    giOffsetNorth=llList2Integer(laData,5);
    giOffsetEast=llList2Integer(laData,6);
    giOffsetSouth=llList2Integer(laData,7);
    giMapSwMap=llList2Integer(laData,8);
    giMapSwCourse=llList2Integer(laData,9);
    giMapSwVars=llList2Integer(laData,10);
    giMapWindDir=llList2Integer(laData,11);
    giMapWindSpeed=llList2Integer(laData,12);
    giMapCurrentSpeed=llList2Integer(laData,13);     
    giMapCurrentDir=llList2Integer(laData,14);     
    giMapWaveHeight=llList2Integer(laData,15);     

    integer liDist_x=giNE_x-giSW_x+1+giOffsetWest+giOffsetEast;
    integer liDist_y=giNE_y-giSW_y+1+giOffsetSouth+giOffsetNorth;
    integer liTotSims=liDist_x*liDist_y;
    integer liTotCalls=3;
    integer liSimCalls=liTotSims;
    if(liTotSims>100 && giMapSwMap==1){
        liSimCalls=100;  //sims that recover by call
        liTotCalls=(integer)(liTotSims/liSimCalls)+3;    
    }
    llOwnerSay("Request Map "+(string)liTotSims+" Sims");
    string ls="1,"+(string)liTotCalls+","+(string)liSimCalls+",,"+(string)giSW_x+","+(string)giSW_y+","+(string)giNE_x+","+(string)giNE_y+
        ","+(string)giOffsetWest+","+(string)giOffsetNorth+","+(string)giOffsetEast+","+(string)giOffsetSouth+","+(string)giMapSwMap;
    llOwnerSay("Request Map Fase: 1/"+(string)liTotCalls);
    gkHttpSrvReqMap=llHTTPRequest(gsServer+csServerDir+"glwReqMap.php",caHttpHeaders,ls);
}

requestMapNext(string psBody)
{
    list laMap=llCSV2List(psBody);
    integer liNumCalls=llList2Integer(laMap,1);
    integer liTotCalls=llList2Integer(laMap,2);
    integer liSimCalls=llList2Integer(laMap,3);
    string lsFile=llList2String(laMap,4);
    string lsUrl=llList2String(laMap,5);
    string lsMsg;
    //llOwnerSay("response map: "+psBody);
    if(liNumCalls<liTotCalls-2){   //paint maps
        liNumCalls++;
        lsMsg=(string)(liNumCalls)+","+(string)liTotCalls+","+(string)liSimCalls+","+lsFile+","+
                (string)giSW_x+","+(string)giSW_y+","+(string)giNE_x+","+(string)giNE_y+
                ","+(string)giOffsetWest+","+(string)giOffsetNorth+","+(string)giOffsetEast+","+(string)giOffsetSouth;
        //llOwnerSay("map "+lsMsg);
        gkHttpSrvReqMap=llHTTPRequest(gsServer+csServerDir+"glwReqMap.php",caHttpHeaders,lsMsg);
        llOwnerSay("Request map Fase: "+(string)liNumCalls+"/"+(string)liTotCalls);
    }else if(liNumCalls==liTotCalls-2){   //paint route
        liNumCalls++;
        if(gsMapUsb!="" && giMapSwCourse==1){
            lsMsg=(string)(liNumCalls)+","+(string)liTotCalls+","+(string)liSimCalls+","+lsFile+","+
                    (string)giSW_x+","+(string)giSW_y+","+(string)giNE_x+","+(string)giNE_y+
                    ","+(string)giOffsetWest+","+(string)giOffsetNorth+","+(string)giOffsetEast+","+(string)giOffsetSouth+
                    ","+(string)giMapSwMap+"##"+gsMapUsb;
            gkHttpSrvReqMap=llHTTPRequest(gsServer+csServerDir+"glwReqMapUsb.php",caHttpHeaders,lsMsg);
            //llOwnerSay("route "+lsMsg);
        }else{
            lsMsg="OK,"+(string)(liNumCalls)+","+(string)liTotCalls+","+(string)liSimCalls+","+lsFile+","+lsUrl;
            llMessageLinked(LINK_THIS,1221,lsMsg,"");
        }
        llOwnerSay("Request map Fase: "+(string)liNumCalls+"/"+(string)liTotCalls);
    }else if(liNumCalls==liTotCalls-1){   //paint vars
        liNumCalls++;
        if((gsVarAreas!="" || gsVarCircles!="") && giMapSwVars==1){
            lsMsg=(string)(liNumCalls)+","+(string)liTotCalls+","+(string)liSimCalls+","+lsFile+","+
                    (string)giSW_x+","+(string)giSW_y+","+(string)giNE_x+","+(string)giNE_y+
                    ","+(string)giOffsetWest+","+(string)giOffsetNorth+","+(string)giOffsetEast+","+(string)giOffsetSouth+","+(string)giMapSwMap+
                    ","+(string)giMapWindDir+","+(string)giMapWindSpeed+","+(string)giMapCurrentSpeed+","+(string)giMapCurrentDir+","+(string)giMapWaveHeight+
                    "##"+gsVarAreas+"##"+gsVarCircles;
            //llOwnerSay("vars "+lsMsg);
            gkHttpSrvReqMap=llHTTPRequest(gsServer+csServerDir+"glwReqMapVars.php",caHttpHeaders,lsMsg);
        }else{
            lsMsg="OK,"+(string)(liNumCalls)+","+(string)liTotCalls+","+(string)liSimCalls+","+lsFile+","+lsUrl;
            llMessageLinked(LINK_THIS,1221,lsMsg,"");
        }
        llOwnerSay("Request map Fase: "+(string)liNumCalls+"/"+(string)liTotCalls);
    }else if(liNumCalls==liTotCalls){   //end
        //llOwnerSay("Final Map: "+psBody);
        llOwnerSay("Final Map: "+lsUrl);
    }    
}

default 
{
    state_entry()
    {
        swdbg=(integer)llLinksetDataRead("ISDsetini");
        init();
        if(swdbg) llOwnerSay(llGetScriptName()+": "+(string)llGetFreeMemory());
    }
    
    listen(integer piChannel, string psName, key pkId, string psMsg)
    {
        if(piChannel==giSayChannel){
            gkHttpSayEvent=llHTTPRequest(gsServer+csServerDir+"glwSayEvent.php",caHttpHeaders,gsIdEvent+","+llGetDisplayName(pkId)+":: "+psMsg);
        }else if(piChannel=ciGlwChannel){
            if(llGetSubString(psMsg,0,5)=="glwReq"){
                list laL=llCSV2List(psMsg);
                if(llList2String(laL,1)==gsGlwDirectorKey && llList2String(laL,2)==gsGlwEventNum){  //boat request 
                    gkHttpRequest0=llHTTPRequest(llList2String(laL,3)+"?glwSetData",[HTTP_METHOD,"POST"],httpData(1));
                    string lsT;
                    string lsN;
                    if(llList2String(laL,4)=="1")lsT="Cruise";
                    else if(llList2String(laL,4)=="2")lsT="Race";
                    if(llList2String(laL,6)!="") lsN=" ("+llList2String(laL,6)+")";
                    if(giDirectorMsg>0) llOwnerSay(llList2String(laL,5)+lsN+" has requested the "+lsT+" wind");
                }
            }        
        }
    }    
    link_message(integer sender_num, integer piNum, string psStr, key pkId)
    {
        if(piNum>=1000 && piNum<2000){
            if(piNum>=1200 && piNum<1300){
                if(piNum==1200) {   //start event
                    init();  //reset values
                }else if(piNum==1201){  //server
                    gsServer=psStr;
                }else if(piNum==1202) {   //load event params from GLWAux
                    loadData(psStr); 
                    gsVariations=(string)pkId; 
                }else if(piNum==1203){    //event aux data
                    list laList=llCSV2List((string)psStr);
                    giInterval=(integer)llList2String(laList,0);
                    giIntervalMsg=(integer)llList2String(laList,1);
                    giDirectorMsg=(integer)llList2String(laList,2);
                    giBroadcastPeriod=(integer)llList2String(laList,3);
                }else if(piNum==1210) {   //event Stoped
                    if(giStatus==4) stopCast();
                    if(gsIdEvent!="") gkHttpSrvEndEvent=llHTTPRequest(gsServer+csServerDir+"glwEndEvent.php",caHttpHeaders,gsIdEvent);  
                    giStarted=0;
                    gsGlwEventNum="";
                    gsGlwDirectorName="";
                    gsGlwDirectorKey="";
                    gsUrlSetter="";
                    gsIdEvent="";
                    giStatus=0;
                    giSignTimer=0;
                    giCastTimer=0;
                    giModTimer=0;
                    llListenRemove(giSayHandle);
                }else if(piNum==1211) {   //event Started
                    llListenRemove(giSayHandle);
                    if(giSayChannel!=0) giSayHandle=llListen(giSayChannel,"","","");
                    startEvent(psStr,(string)pkId);
                }else if(piNum==1212) {   //cast Stopped
                    if(giStatus==4) stopCast();
                }else if(piNum==1213) {   //cast Started
                    if(giStatus==3) startCast(psStr);
                }else if(piNum==1214) {   //mod shout, region, whisper cast message
                    gsSayType=psStr;
                }else if(piNum==1215) {   //request map region name for auto from Var Menu script
                    list laCoord=llCSV2List(psStr);
                    integer liX=llList2Integer(laCoord,0)/256;
                    integer liY=llList2Integer(laCoord,1)/256;
                    string lsUrl="https://cap.secondlife.com/cap/0/b713fe80-283b-4585-af4d-a3b7d9a32492?var=region&grid_x="+(string)liX+"&grid_y="+(string)liY;
                    gkHttpSrvRegionSW=llHTTPRequest(lsUrl,[],"");                
                    liX=llList2Integer(laCoord,2)/256;
                    liY=llList2Integer(laCoord,3)/256;
                    lsUrl="https://cap.secondlife.com/cap/0/b713fe80-283b-4585-af4d-a3b7d9a32492?var=region&grid_x="+(string)liX+"&grid_y="+(string)liY;
                    gkHttpSrvRegionNE=llHTTPRequest(lsUrl,[],"");                
                }else if(piNum==1216) {   //mod data values
                    if(giStatus>2) modEvent(psStr,pkId); 
                }else if(piNum==1217) {   //request map init 
                    gsMapUsb="";
                    gsVarAreas="";
                    gsVarCircles="";
                    giMapWindDir=0;
                    giMapWindSpeed=0;
                    giMapCurrentDir=0;     
                }else if(piNum==1218) {   //request map usb
                    gsMapUsb=psStr;
                }else if(piNum==1219) {   //request map vars
                    gsVarAreas=psStr;
                    gsVarCircles=(string)pkId;
                }else if(piNum==1220) {   //request map start
                    requestMap(psStr);
                }else if(piNum==1221) {   //request map next
                    requestMapNext(psStr);
                }else if(piNum==1225) {   //verify event key
                    if(gsServer!=""){
                        gkHttpSrvFEventKey=llHTTPRequest(gsServer+csServerDir+"glwFindEventKey.php",caHttpHeaders,psStr);
                    }else{
                        llMessageLinked(LINK_THIS, 2937, "1", "");
                    }
                }
            }else if(piNum<1200){
                llOwnerSay("Warning GLW Setter invalid code "+(string)piNum);
                /*
                if(piNum==1101) giGlwWndDir=(integer)psStr;
                else if(piNum==1104) giGlwWndSpeed=(integer)psStr;
                else if(piNum==1105) giGlwWndGusts=(integer)psStr;
                else if(piNum==1106) giGlwWndShifts=(integer)psStr;
                else if(piNum==1107) giGlwWndPeriod=(integer)psStr;
                else if(piNum==1109) giGlwWavSpeed=(integer)psStr;
                else if(piNum==1110) giGlwWavHeightVariance=(integer)psStr;
                else if(piNum==1111) giGlwWavLengthVariance=(integer)psStr;
                else if(piNum==1112) giGlwWavHeight=(integer)psStr;
                else if(piNum==1113) giGlwWavLength=(integer)psStr;
                else if(piNum==1115) giGlwCrtDir=(integer)psStr;
                else if(piNum==1116) giGlwCrtSpeed=(integer)psStr;
                else if(piNum==1118) giGlwSailMode=(integer)psStr;
                else if(piNum==1120) gsGlwEventName=psStr;
                else if(piNum==1122) gsGlwExtra1=psStr;
                else if(piNum==1123) gsGlwExtra2=psStr;
                */
            }else if(piNum==1900){
                if(psStr=="scan"){  //From glw scan button
                    llOwnerSay("Start Event Scan...");
                    gkHttpSrvScanEvent=llHTTPRequest(gsServer+csServerDir+"glwScanEvent.php",caHttpHeaders,gsIdEvent);
                }else if(psStr=="recovery"){  //From menu script
                    llOwnerSay("Recovery the last Event...");
                    gsGlwDirectorKey=(string)pkId;
                    llReleaseURL(gsUrlSetter);                      //frees url boat
                    gsUrlSetter="";
                    gsRecoveryId="";
                    urlRequestRId=llRequestURL();
                }else if(psStr=="recovid"){  //From menu script
                    llReleaseURL(gsUrlSetter);                      //frees url boat
                    gsUrlSetter="";
                    gsRecoveryId=(string)pkId;
                    urlRequestRId=llRequestURL();
                }
            }
        }
    }

    changed(integer change)
    {
        if(change & CHANGED_REGION)
        {
            if(gsIdEvent!=""){
                llReleaseURL(gsUrlSetter);                      //frees url boat
                gsUrlSetter="";
                urlRequestCId=llRequestURL();
            }
        }
    }        
    
    http_request(key id, string method, string psBody)
    {
        psBody=llStringTrim(psBody, STRING_TRIM); 
        if(id==urlRequestId || id==urlRequestCId || id==urlRequestRId){  //receive new url 
            if (method == URL_REQUEST_GRANTED){   //url ok
                gsUrlSetter = psBody;
                if(id==urlRequestRId) gkHttpSrvRecovery=llHTTPRequest(gsServer+csServerDir+"glwWSRecovery.php",caHttpHeaders,gsGlwDirectorKey+","+gsUrlSetter+","+gsRecoveryId);  //recovery
                else gkHTTPSrvUpdEventUrl=llHTTPRequest(gsServer+csServerDir+"glwUpdEventUrl.php",caHttpHeaders,gsIdEvent+","+gsUrlSetter);  //update url
            }else if(method==URL_REQUEST_DENIED){ 
                gsUrlSetter="";
                llRegionSayTo(llGetOwner(),0,"URL request denied");   //bad url
            }
        }else if(method=="POST"){
            string params=llGetHTTPHeader(id,"x-query-string");
            string clave=llGetSubString(params,0,9);
            if (clave=="glwSayData") { //say message event
                string idBoat=llGetSubString(params,11,-1);
                llOwnerSay("/me ::"+psBody); 
                llHTTPResponse(id,200,"OK,"+(string)idBoat);
            }
        }
    }    
    
    http_response(key pkRequest_id, integer piStatus, list paMetadata, string psBody)
    {
        psBody=llStringTrim(psBody, STRING_TRIM);
        if (pkRequest_id == gkHttpSrvAddEvent){
            list laTemp;
            if(llGetSubString(psBody,0,1)=="OK"){
                laTemp=llCSV2List(psBody);
                gsIdEvent=llList2String(laTemp,1);
                string lsEventName=llList2String(laTemp,2);
                llMessageLinked(LINK_THIS,2001,"event","");  // inform GLW script the event is created
                llOwnerSay("Event #"+(string)gsIdEvent+" "+lsEventName+" created successfully");
                llReleaseURL(gsUrlSetter);                      //frees url boat
                gsUrlSetter="";
                urlRequestId=llRequestURL();                //request new url boat
                giSignTimer=llGetUnixTime()+3600;
                llSetTimerEvent(60.0);
            }else{
                gsIdEvent="";
                giSystemMode=1;
                string lsError="";
                laTemp=llParseString2List(psBody,["|"], []);
                if(piStatus==502) lsError=" Bad Gateway";
                else if(piStatus==504) lsError=" Gateway Timeout";
                else if(piStatus==500) lsError=" Internal Server Error";
                else if(piStatus==404) lsError=" Page Not Found";
                lsError+=" "+llList2String(laTemp,1);
                llOwnerSay("An error occurred while creating the event. Status: "+(string)piStatus+"."+lsError);
                if(ciDebug) llOwnerSay("Command: "+llList2String(laTemp,2));
            }
            if(giStatus==1) giStatus=3;
        }else if (pkRequest_id == gkHttpSrvEndEvent){
            if(llGetSubString(psBody,0,1)=="OK") llOwnerSay("Event #"+llGetSubString(psBody,2,-1)+" deleted successfully"); 
            else llOwnerSay(llStringTrim(psBody, STRING_TRIM));
        }else if (pkRequest_id == gkHttpSrvUpdEvent){
            //llOwnerSay("setter http response2 "+(string)piStatus+"   "+psBody);
            gkHttpSrvUpdEvent="";
            if(llGetSubString(psBody,0,1)=="OK"){ 
                list la=llCSV2List(psBody);
                integer modboatok=(integer)llList2String(la,1);
                integer modboattotal=(integer)llList2String(la,2);
                if(modboattotal==-1) llOwnerSay("Event updated successfully");
                else if(modboattotal==0) llOwnerSay("Event updated successfully, There are no registered boats");
                else if(modboatok==modboattotal) llOwnerSay("Event updated successfully, all ships updated "+(string)modboattotal);
                else{
                    llOwnerSay("Event updated successfully, They've been updated "+(string)modboatok+"/"+(string)modboattotal);
                    giModTimer=60;
                    giPollTimes=3;
                    if(giCastTimer==0)llSetTimerEvent(ciTIMERINTERVAL);
                    llOwnerSay("Will try again in 1 minute");
                }
                giSignTimer=llGetUnixTime()+3600;
            }else llOwnerSay(psBody);
        }else if (pkRequest_id == gkHttpSrvRUpdEvent){
            //llOwnerSay("setter http repeat response2 "+(string)piStatus+"   "+psBody);
            gkHttpSrvRUpdEvent="";
            giModTimer=0;
            if(llGetSubString(psBody,0,1)=="OK"){ 
                list la=llCSV2List(psBody);
                integer modboatok=(integer)llList2String(la,1);
                integer modboattotal=(integer)llList2String(la,2);
                if(modboattotal==-1) llOwnerSay("Event updated successfully");
                else if(modboattotal==0) llOwnerSay("Event updated successfully, There are no registered boats");
                else if(modboatok==modboattotal) llOwnerSay("Event updated successfully, all ships updated "+(string)modboattotal);
                else{
                    llOwnerSay("Repeat wind updated, They've been updated "+(string)modboatok+"/"+(string)modboattotal);
                    if(giPollTimes>0){
                        llOwnerSay("Will try again in 1 minute");
                        giModTimer=60;
                        if(giCastTimer==0)llSetTimerEvent(ciTIMERINTERVAL);
                    }else{
                        llOwnerSay("Failed to update all boats");
                    }
                }
            }else{ 
                llOwnerSay(psBody);
            }
        }else if (pkRequest_id == gkHttpSrvScanEvent){
            //llOwnerSay("setter http response2 "+(string)piStatus+"   "+psBody);
            gkHttpSrvScanEvent="";
            if(llGetSubString(psBody,0,1)=="OK"){ 
                list la=llCSV2List(psBody);
                integer modboatok=(integer)llList2String(la,1);
                integer modboattotal=(integer)llList2String(la,2);
                if(modboattotal==0) llOwnerSay("Event scan successfully, There are no registered boats");
                else if(modboatok==modboattotal && modboattotal>0) llOwnerSay("Event scan successfully, all boats scaned. "+(string)modboattotal+" boats");
                else{
                    llOwnerSay("Event scan successfully, They've been scaned "+(string)modboatok+"/"+(string)modboattotal);
                }
                if(modboattotal>0){
                    integer li;
                    string ls;
                    integer liTotal=llGetListLength(la);
                    for(li=3;li<liTotal;li=li+7){
                        if(llList2String(la,li+1)!=""){
                            ls=llList2String(la,li+4);
                            if(ls=="1") ls="Cruise";
                            else if(ls=="2") ls="Race";
                            else if(ls=="3") ls="World";
                            else ls="";
                            llOwnerSay(llList2String(la,li)+" http://maps.secondlife.com/secondlife/"+llList2String(la,li+1)+
                                    "/"+llList2String(la,li+2)+"/"+llList2String(la,li+3)+
                                    " "+ls+" wind DIR:"+llList2String(la,li+5)+"º SPD:"+llList2String(la,li+6)+"kt");
                        }else{
                            llOwnerSay(llList2String(la,li)+" does NOT answer");
                        }
                    }    
                }
            }else llOwnerSay(psBody);
        }else if (pkRequest_id == gkHTTPSrvUpdEventUrl){
            giSignTimer=llGetUnixTime()+3600;
            //llOwnerSay(psBody);
        }else if (pkRequest_id == gkHttpSayEvent){
            //llOwnerSay(psBody);
        }else if (pkRequest_id == gkHttpSrvSignEvent){
            //llOwnerSay(psBody);
        }else if (pkRequest_id == gkHttpSrvRecovery){
            gkHttpSrvRecovery="";
            //llOwnerSay("setter ==> "+psBody);
            if(llGetSubString(psBody,0,2)=="OK0"){ 
                list laParts=llParseStringKeepNulls(psBody,["##"], []);   //OK0##eventdata##Wind##Areas##Circles
                loadData(llList2String(laParts,2));
                list la=llCSV2List(llList2String(laParts,1));
                gsGlwEventNum=llList2String(la,0);
                gsIdEvent=llList2String(la,1);
                gsGlwDirectorKey=llList2String(la,2);
                gsGlwDirectorName=llList2String(la,3);
                giSystemMode=(integer)llList2String(la,4);
                giStatus=3;
                giStarted=1;
                
                gsVariations=llList2String(laParts,3)+"##"+llList2String(laParts,4);
                
                llMessageLinked(LINK_THIS,2000,"recovery",gsGlwDirectorKey+","+gsIdEvent+"##"+llList2String(laParts,2)+"##"+gsVariations);   //send data to GLW Script
                llMessageLinked(LINK_THIS,3000,"recovery",llList2String(laParts,1));   //send data to GLWAux Script
                llMessageLinked(LINK_THIS,5990,llList2String(laParts,3),llList2String(laParts,4));   //send data to GLWVariations Script
                llListenRemove(giSayHandle);
                if(giSayChannel!=0) giSayHandle=llListen(giSayChannel,"","","");
                giSignTimer=llGetUnixTime()+3600;
                llSetTimerEvent(60.0);
            }else if(llGetSubString(psBody,0,2)=="OK1"){  //OK1No events found for this Director
                llOwnerSay(llGetSubString(psBody,3,-1));  
            }else if(llGetSubString(psBody,0,2)=="OK2"){  //OK2More than one event of this Director has been found.... 
                llOwnerSay(llGetSubString(psBody,3,-1));
                llMessageLinked(LINK_THIS, 4000, "recovid", "");
            }else{
                llOwnerSay(llGetSubString(psBody,2,-1));  //KORecovery Error: ....
            }
        }else if(pkRequest_id == gkHttpSrvReqMap){
            gkHttpSrvReqMap="";
            if(llGetSubString(psBody,0,1)=="OK"){
                requestMapNext(psBody);
            }else{
                llOwnerSay("================> "+psBody);
            }
        }else if(pkRequest_id == gkHttpSrvRegionSW){
            list la=llParseString2List(psBody,["'"],[]);
            if(llList2String(la,0)=="var region="){
                llMessageLinked(LINK_THIS,6000,"regionsw",llList2String(la,1));
            }else{
                llMessageLinked(LINK_THIS,6000,"regionsw","End_World");
            }
        }else if(pkRequest_id == gkHttpSrvRegionNE){
            list la=llParseString2List(psBody,["'"],[]);
            if(llList2String(la,0)=="var region="){
                llMessageLinked(LINK_THIS,6000,"regionne",llList2String(la,1));
            }else{
                llMessageLinked(LINK_THIS,6000,"regionne","End_World");
            }
        }else if(pkRequest_id == gkHttpSrvFEventKey){
            if(llGetSubString(psBody,0,2)=="OK0") llMessageLinked(LINK_THIS, 2937, "1", "");   //It has not been found
            else if(llGetSubString(psBody,0,2)=="OK1") llMessageLinked(LINK_THIS, 2937, "2", "");   //event key already exists
            else llOwnerSay("Error find event key");
        } 
    }    
    
    timer() 
    {
        if(giCastTimer>0){
            giBroadcastPeriodCounter+=ciTIMERINTERVAL;
            if(giBroadcastPeriodCounter<giBroadcastPeriod || giBroadcastPeriod==0) {   //broadcasting period or always
                giIntervalCount+=ciTIMERINTERVAL;
                if(giIntervalCount>=giInterval){
                    giIntervalCount=0;
                    if(llGetSubString(gsSayType,0,0)=="1"){  //shout
                        llShout(ciGlwChannel,"GLWindSho"+","+gsGlwDirectorKey+","+gsGlwEventNum+","+(string)gsGlwDirectorName);  //send wind signal
                    }
                    if(llGetSubString(gsSayType,1,1)=="1"){   //region
                        llRegionSay(ciGlwChannel,"GLWindReg"+","+gsGlwDirectorKey+","+gsGlwEventNum+","+(string)gsGlwDirectorName);  //send wind signal
                    }
                    if(gsSayType=="001"){  //whisper
                        llWhisper(ciGlwChannel,"GLWindWhi"+","+gsGlwDirectorKey+","+gsGlwEventNum+","+(string)gsGlwDirectorName);  //send wind signal
                    }
                }
                giIntervalMsgCount+=ciTIMERINTERVAL;
                if(giIntervalMsg>0 && giIntervalMsgCount>=giIntervalMsg){
                    giIntervalMsgCount=0;
                    if(gsSayType=="001") llWhisper(0,gsMsgGLW);    //broadcast event message
                    else llShout(0,gsMsgGLW);
                }
            } else {
                stopCast();
            }
        }
        if(giModTimer>0){
            giModTimer-=ciTIMERINTERVAL;
            if(giModTimer<=0){
                if(gsIdEvent!=""){
                    if(giPollTimes>0){
                        llOwnerSay("Trying to update the boats again");
                        gkHttpSrvRUpdEvent=llHTTPRequest(gsServer+csServerDir+"glwRUpdEvent.php",caHttpHeaders,gsIdEvent);  //send data to server update event
                        giPollTimes--;
                        //if(giPollTimes>0) giModTimer=60;
                    }
                }
            }
        }
        if(giSignTimer!=0 && llGetUnixTime()>giSignTimer){
            giCounter++;
            gkHttpSrvSignEvent=llHTTPRequest(gsServer+csServerDir+"glwSignEvent.php",caHttpHeaders,gsIdEvent+","+(string)giCounter);  //send sign to server to identify that event is active
            giSignTimer=llGetUnixTime()+3600;
        }
        if(giCastTimer<=0 && giModTimer<=0){
            if(giSignTimer==0) llSetTimerEvent(0.0);
            else llSetTimerEvent(60.0);
        }
    }        
}

















