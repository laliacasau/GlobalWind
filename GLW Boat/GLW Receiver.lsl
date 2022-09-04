// GLW Global Wind Last change 9Jun22
// Created by Lalia (LaliaCasau Resident) 2022
// Based on WWC By Mothgirl Dibou Last change 2008
// Based on BWind By Becca Mouillez
// GLW Receiver 1.1
//
//VARIABLE NAMING
//I am using the Azn Min (itoibo) system with some variation, which uses two letters to describe the scope and data type of each variable.
//The first letter is the scope: g-global l-local c-constant p-parameter
//The second letter is the data type: i-integer f-float s-string k-key v-vector r-rotation a-array(list)  
//
//CONSTANTS ===========>
string csServerDir="/glw120/";
float cfWindShiftsFactor=0.5;     //Wind Shift Factor always positive  <1 decrease   >1 increase   0.5=half   2.0=double 
float cfWindGustsFactor=1.5;     //Wind Gusts Factor always positive  <1 decrease   >1 increase    0.5=half   2.0=double 

integer ciGlwChannel=-15368945;
integer   ciSetterTimeOut=7200;  //find setter timeout in seconds  default 5 minutes
integer   ciSetterTimerInterval=60; //timer interval for timeout find setter in seconds default 60 sec  
integer   ciHttpTimeOut=60;  //in seconds
float   cfTimerInterval=1.0;  //in seconds
float   cfKt2Ms=0.514444;
/*
integer MSGTYPE_GLWPARAMS=70001;
integer MSGTYPE_RESET=70003;
integer MSGTYPE_SAILING=70004;
integer MSGTYPE_MOORED=70005;
integer MSGTYPE_BOATPARAMS=70006;
integer MSGTYPE_GLWINICIO=70007;
integer MSGTYPE_WINDINFO=70008;
integer MSGTYPE_RECOVERY=70009;
integer MSGTYPE_MYWIND=70010;  //mywind/cruising mode, personal wind 
integer MSGTYPE_GLWIND=70011;  //glwind mode, for cruises 
integer MSGTYPE_RACING=70012;  //racing mode, for races
integer MSGTYPE_WORLDWIND=70013;  //world wind mode, to sailing
*/
//<======== CONSTANTS

//GLW Data ===>
string   gsGlwDirectorKey;
string   gsGlwEventNum;
string   gsGlwDirectorName;

integer  giGlwWndDir;     //degrees
integer  giGlwWndSpeed=15;   //kt
integer  giGlwWndGusts;   //0-100%
integer  giGlwWndShifts;  //degrees
integer  giGlwWndPeriod=60;  //seconds

integer  giGlwWavSpeed=5;    //kt
integer  giGlwWavHeightVariance;  //%
integer  giGlwWavLengthVariance;  //%
float    gfGlwWavHeight;   //meters wave height from sea level to the crest = 1/2 Total wave height
integer  giGlwWavLength=50;    //meters
integer  giGlwWavEffects=3;

integer  giGlwCrtDir;       //degrees
float    gfGlwCrtSpeed;   //kt

integer  giGlwSailMode=2;
string   gsGlwEventName;
string   gsGlwExtra1;
string   gsGlwExtra2;
integer  giGlwWaterDepth;   //meters
integer  giGlwUpdBoatPos;
string   gsGlwEventType;            //future options are not used 

//WIND FOR LOCAL VARIATIONS REFERENCE ===>
integer giVarMode=-1;
integer  giVarWndDir;
integer  giVarWndSpeed;   //kt
integer  giVarWndGusts;   //0-100%
integer  giVarWndShifts;  //degrees
integer  giVarWndPeriod;  //seconds
integer  giVarWavSpeed;    //kt
integer  giVarWavHeightVariance;  //%
integer  giVarWavLengthVariance;  //%
float    gfVarWavHeight;   //meters wave height from sea level to the crest = 1/2 Total wave height
integer  giVarWavLength;    //meters
integer  giVarWavEffects;
integer  giVarCrtDir;       //degrees
float    gfVarCrtSpeed;   //kt
integer  giVarWaterDepth;  
//<===OVERLAP WIND FOR LOCAL VARIATIONS

//sims data only for giSystemMode==12 for local variations
integer giSimActualIndex;
integer giDataSimActual;    //0-actual sim normal  other-datasim number
string gsDataSim; //000000000  type sim data for sim1..sin9  0=default data wind  other=special data wind
string gsDataSim0;  //normal data wind
string gsDataSimActual;  //sim actual data wind
list gaDataSimWinds; //all local variations
integer giVarsType;  //kind of local variations for this sim   10-Area no border 11-Area border  20-Circle no border  21-Circle border
integer giVars1; //for areas margin Nord, for circles center X
integer giVars2; //for areas margin East, for circles center Y
integer giVars3; //for areas margin South, for circles radius
integer giVars4; //for areas margin West, for circles margin
integer giVarsTemp;
integer giVarsOverlap; //for areas and circle overlapping variations
integer giWindSimPosX;  //sim coordinate X in which the wind data is reference, center of 8 wind sims
integer giWindSimPosY;  //sim coordinate Y in which the wind data is reference, center of 8 wind sims



// operational variables
integer  giStatus;  //0-do not listen  1-waiting windsetter signal   2-waiting windsetter parameters  3-parameters from windsetter received  4-connect to server
integer  giSystemMode; //0-no use server  1-glw noserver without variations  11-glw server without variations  12-glw server with variations
integer  giNTimeOut;
string   gsIdEvent;
string   gsIdBoat;

// wind variables
integer  giTrueWindDir;
integer  giTrueWindSpeed;  //kt

// boat variables
float    gfDepth;
vector   globalPos;
float    globalTime;

// current variables
float    gfCurrentSpeed;
integer  giCurrentDir;

// waves variables
float    gfWaveHeight;
float    gfWaveHeightMax;

//control variables
integer  giCalcCurrentInterval=1;   //3;
integer  giCounter;

//windshadow
float   gfReduceRate=0.2;
integer giSailArea=25;  /// may not be zero;
string  gsBoatLength2Bow="1.5";
string  gsBoatLength2Stern="2.1";
float   gfMaxWindShadow=0.6;
float   gfMaxWindBend=15;  // in degrees
float   gfWindBend;
integer giSendBtPosCounter;
integer giSendBtPosInterval=3;
list    gaShadowingBoats=[];
integer giShadowChannel=-8001;

//news vars
string  gsUrlBoat;
integer glwHandle;
integer giShadowHandle;
key     gkUrlRequestId;   //request initial url windsetter request data
key     gkUrlRequestCId;  //request url change region 
key     gkUrlRequestRId;  //request url recovery
key     gkUrlRequestSId;  //request initial url server request data
key     gkHttpSrvSendUrl;
key     gkHttpSrvAddBoat;
key     gkHttpSrvEndBoat;
key     gkHttpSrvCrgBoat;
key     gkHttpRecovery;
key     gkUrlRequestWId;
key     gkHttpSrvAddBoatWorld;
key     gkUrlRequestCIdWorld;
key     gkHttpSayEvent;
key     gkHttpReqEventId;
integer giSailingMode;     //0-moored   1-sailing
integer giWindMode;   //0-mywind  1-glw cruise 2-glw racing  3-world wind
key     gkHelm;   //Helm key, to whom the messages are directed
string  gsMyServer;
string  gsServer;
string  gsMaster;
string  gsNoteName;
integer giNoteLine;
key     gkNoteLineId;
key     gkOwner;
string  gsOwnerName;
integer giSayChannel=6;
integer giSayHandle;
string  gsBoatId;
integer giUpdPosTimer;
integer giWavesIncPeriod;
integer giHudsChannel;
integer giSwSimCross;
string  gsParams2Boat;
integer giSwSendParams2Hud=1;   //0=no send params   1=send params

//timer vars
//calcWind
float gfWindMultiplier;
float gfAnglepos;
float gfAngletime;
float gfWindShadow;
float gfShadow;
float gfBend;
float gfTempgusts;
integer giNumShadowBoats;
integer giWndPeriod;
integer giTempWndShifts;
integer giTempWndGusts;
//currents
float gfTempCrtSpeed;
integer giTempWaterDepth;
//calc wave
float gfTheta;
float gfOffset;
float gfMultiplier;
integer giNumber;
integer giWavePeriod;
float gfwaveCycle;
integer giWaveLength;
float gfTempWavHeight;
integer giTempWavLengthVariance;
integer giTempWavHeightVariance;
integer giTempWavSpeed;
integer giTempWavEffects;
//tempvars
integer giN;
integer giUnixTime;
vector gvShadowVelocity;
string gsShadowTack;
string gsShadowvar;
vector gvAxs;
integer giWindAngle;
vector gvWindVector;
float gfMarginFactor;
float gfMarginFactorTemp;
vector gvLocalPos;
float gfCircleDistance;
float gfTemp;
integer giTemp;
integer giTempDir;
string  gsNewParams2Boat;

//others

list     gaHttpHeaders=[HTTP_METHOD,"POST",
                    HTTP_MIMETYPE,"text/csv",
                    HTTP_BODY_MAXLENGTH,15048,
                    HTTP_VERIFY_CERT,TRUE,
                    HTTP_VERBOSE_THROTTLE,TRUE,
                    HTTP_PRAGMA_NO_CACHE,TRUE];

loadDataEvent(integer piMode, string pData)  //piMode=0-initial data from server 1-change region
{
    //llOwnerSay("loaddataevent1 "+(string)piMode+"  "+pData);
    list la1=llParseString2List(pData,["#"],[]);

    integer li=1;                           //glw or racing wind     OK,NNNN#nnnnnnnnn#sims wind data
    if(giWindMode==3 && piMode==0) li=2;   //world wind initial   OK,NNNN#base wind#nnnnnnnnn#sims wind data
    gsDataSim=llList2String(la1,li);        //9 sims state
    gaDataSimWinds=llParseString2List(llList2String(la1,li+1),["$"],[]);  //load local variations into an list

    giSimActualIndex=4;
    vector lvPos=llGetRegionCorner();  
    giWindSimPosX=(integer)(lvPos.x/256);  //x position of the central sim of the wind data matrix
    giWindSimPosY=(integer)(lvPos.y/256);  //y position of the central sim of the wind data matrix

    if(piMode==1){   //change region. receive the data when changing region
        giDataSimActual=(integer)llGetSubString(gsDataSim,giSimActualIndex,giSimActualIndex);
    }else{  //initial data from server
        gsIdBoat=llGetSubString(llList2String(la1,0),3,-1);
        if(giWindMode==3) gsDataSim0=llList2String(la1,1);   //if world wind save Base Wind
        if(llGetSubString(gsDataSim,giSimActualIndex,giSimActualIndex)=="0"){   // the current sim is base wind type
            giVarsType=giVars1=giVars2=giVars3=giVars4=giVarsOverlap=0;
            //llOwnerSay("loaddataevent2 "+gsDataSim0);
            if(giDataSimActual!=0 || giWindMode==3) saveGlwData(3,gsDataSim0);  //load base wind type 
            giDataSimActual=0;
            gsDataSimActual="";
        }else{    // the current sim is not base wind type
            giDataSimActual=(integer)llGetSubString(gsDataSim,giSimActualIndex,giSimActualIndex);  //actual wind num element
            gsDataSimActual=llList2String(gaDataSimWinds,giDataSimActual-1);  //actual wind data
            list la2=llParseString2List(gsDataSimActual,[":"],[]);  //local variations data parameters for this sim
            list la3=llCSV2List(llList2String(la2,0));  //data for margins
            giVarsType=llList2Integer(la3,0);  //0-no vars  10-full area  11-margin Area   20-full circle   21-margin circle
            giVars1=llList2Integer(la3,1);  //area margin nord or circle center X
            giVars2=llList2Integer(la3,2);  //area margin east or circle center Y
            giVars3=llList2Integer(la3,3);  //area margin south or circle radius
            giVars4=llList2Integer(la3,4);  //area margin west or circle margin
            giVarsOverlap=llList2Integer(la3,5); //is overlap, saveGlwData need this variable
            saveGlwData(3,llList2String(la2,1));   //load local variations wind for this sim
        }
    }
}

saveGlwData(integer piType, string psData) {   //save parameters  type 0-initial  1-recovery  2-update data modif 3-save server data sim
    //llOwnerSay("saveglwdata1 "+(string)piType+"    "+psData);
    list laCols=llCSV2List(psData);
    if(llGetListLength(laCols)>10){
        integer liIndex;   //piType==0 or 1 =>  liIndex=0
        if(piType==2) liIndex=4;  //laCols element 0 is idevent  update
        else if(piType==3) liIndex=5;  //laCols element 0 is wind dir   server data

        if(piType<3){   //for initial or recovery or modif  save general data and base wind
            if(piType<2){  //initial o recovery
                gsDataSim="000000000";
                gsGlwDirectorKey=llList2String(laCols,0);
                gsGlwEventNum=llList2String(laCols,1);
                gsIdEvent=llList2String(laCols,2);
                gsServer=llList2String(laCols,3);
                gsGlwDirectorName=llList2String(laCols,4);
                vector lvPos=llGetRegionCorner();
                giWindSimPosX=(integer)(lvPos.x/256);
                giWindSimPosY=(integer)(lvPos.y/256);
            }
            giGlwSailMode=llList2Integer(laCols,18-liIndex);
            gsGlwEventName=llList2String(laCols,19-liIndex);
            gsGlwExtra1=llList2String(laCols,20-liIndex);
            gsGlwExtra2=llList2String(laCols,21-liIndex);
            giGlwWaterDepth=llList2Integer(laCols,22-liIndex);
            giGlwUpdBoatPos=llList2Integer(laCols,23-liIndex);
            gsGlwEventType=llList2String(laCols,24-liIndex);
            giSystemMode=llList2Integer(laCols,25-liIndex);
            if(piType==1) gsIdBoat=llList2String(laCols,26);  //if it is not recovery type this column does not exist
            
            float lfTemp2=llList2Integer(laCols,13-liIndex)/20.0;  //receive data*10 and total wave height value/10/2 
            list laTemp2=llListReplaceList(laCols,[lfTemp2],13-liIndex,13-liIndex);  //replace correct value
            lfTemp2=llList2Integer(laCols,17-liIndex)/10.0;   //receive data*10
            laTemp2=llListReplaceList(laTemp2,[lfTemp2],17-liIndex,17-liIndex);  //replace correct value

            if(piType==2) gsDataSim0=llList2CSV(llList2List(laTemp2,1,21)); //save default params update data
            else gsDataSim0=llList2CSV(llList2List(laTemp2,5,25));  //save default params start and recovery

            gfWaveHeightMax=gfWaveHeight=gfCurrentSpeed=0;  
            giCurrentDir = giGlwCrtDir;         
            
            if(giGlwUpdBoatPos==60) giUpdPosTimer=0;   //update periodical position. 60 seconds is 0 seconds 
            else giUpdPosTimer=giGlwUpdBoatPos;
            
            llMessageLinked(LINK_THIS, 70007, "glw", //MSGTYPE_GLWINICIO
                (string)piType+","+gsGlwEventName+","+gsGlwDirectorName+","+
                gsGlwExtra1+","+gsGlwExtra2+","+(string)giWindMode+","+(string)giHudsChannel);
        }

        if(giVarsOverlap==1){
            if(giVarMode<1){
                //save old Wind for local variations 
                giVarWndDir=giGlwWndDir;
                giVarWndSpeed=giGlwWndSpeed;
                giVarWndGusts=giGlwWndGusts;
                giVarWndShifts=giGlwWndShifts;
                giVarWndPeriod=giGlwWndPeriod;
                giVarWavSpeed=giGlwWavSpeed;
                giVarWavHeightVariance=giGlwWavHeightVariance;
                giVarWavLengthVariance=giGlwWavLengthVariance;
                gfVarWavHeight=gfGlwWavHeight;
                giVarWavLength=giGlwWavLength;
                giVarWavEffects=giGlwWavEffects;
                if(gfGlwCrtSpeed>0) giVarCrtDir=giGlwCrtDir;
                else giVarCrtDir=llList2Integer(laCols,16-liIndex);
                gfVarCrtSpeed=gfGlwCrtSpeed;
                giVarWaterDepth=giGlwWaterDepth;
                giVarMode=1;  //overlap variables reference is load witch overlap wind data 
            }
        }else if(giVarMode!=0 || piType==2){ // If it is loaded with wind other than the base, load the base wind
            list laTemp=llCSV2List(gsDataSim0);   //gsDataSim0 is base wind
            giVarWndDir=llList2Integer(laTemp,0);
            giVarWndSpeed=llList2Integer(laTemp,1);
            giVarWndGusts=llList2Integer(laTemp,2);
            giVarWndShifts=llList2Integer(laTemp,3);
            giVarWndPeriod=llList2Integer(laTemp,4);
            giVarWavSpeed=llList2Integer(laTemp,5);
            giVarWavHeightVariance=llList2Integer(laTemp,6);
            giVarWavLengthVariance=llList2Integer(laTemp,7);
            gfVarWavHeight=llList2Integer(laTemp,8);
            giVarWavLength=llList2Integer(laTemp,9);
            giVarWavEffects=llList2Integer(laTemp,10);
            giVarCrtDir=llList2Integer(laTemp,11);
            gfVarCrtSpeed=llList2Integer(laTemp,12);
            giVarWaterDepth=llList2Integer(laTemp,17);
            giVarMode=0;   //overlap variables reference is load witch base wind data 
        }
        
        giGlwWndDir=llList2Integer(laCols,5-liIndex);
        giGlwWndSpeed=llList2Integer(laCols,6-liIndex);
        giGlwWndGusts=llList2Integer(laCols,7-liIndex);
        giGlwWndShifts=llList2Integer(laCols,8-liIndex);
        giGlwWndPeriod=llList2Integer(laCols,9-liIndex);
        
        giGlwWavSpeed=llList2Integer(laCols,10-liIndex);   //kt
        giGlwWavHeightVariance=llList2Integer(laCols,11-liIndex);
        giGlwWavLengthVariance=llList2Integer(laCols,12-liIndex);
        gfGlwWavHeight=llList2Integer(laCols,13-liIndex)/20.0;  //receive data*10 and total wave height value/10/2
        giGlwWavLength=llList2Integer(laCols,14-liIndex);
        giGlwWavEffects=llList2Integer(laCols,15-liIndex);
        
        giGlwCrtDir=llList2Integer(laCols,16-liIndex);
        gfGlwCrtSpeed=llList2Integer(laCols,17-liIndex)/10.0;   //receive data*10
    }
    //llOwnerSay("saveglwdata2 "+(string)giVarWndDir+"    "+(string)giVarWndSpeed+"    "+(string)giGlwWndDir+"    "+(string)giGlwWndSpeed);
}

resetVars()
{
    gsGlwDirectorKey=gsGlwEventNum=gsIdEvent=gsServer=gsGlwDirectorName="";
    giGlwWndDir=0;
    giGlwWndSpeed=15;
    giGlwWndGusts=0;
    giGlwWndShifts=0;
    giGlwWndPeriod=60;
    giGlwWavSpeed=5;
    giGlwWavHeightVariance=0;
    giGlwWavLengthVariance=0;
    gfGlwWavHeight=0.0;
    giGlwWavLength=50;
    giGlwWavEffects=3;
    giGlwCrtDir=0;
    gfGlwCrtSpeed=0.0;
    giGlwSailMode=2;
    gsGlwEventName=gsGlwExtra1=gsGlwExtra2="";
    giGlwWaterDepth=0;
    giGlwUpdBoatPos=0;
    gsGlwEventType="";
    giSystemMode=0;
    giVarMode=-1;
    gsIdBoat="";
    gsParams2Boat=gsNewParams2Boat="";        
}
  
windsetterListen(integer piMode, integer piType) //piMode=0-Close  1-Open glw from windsetter  2-Open racing from windsetter  3-world wind  
{
    if(piMode>0){  //open
        resetVars(); 
        giStatus=1;
        giWindMode=piMode;
        llReleaseURL(gsUrlBoat);                      //free url boat
        gsUrlBoat="";
        llListenRemove(glwHandle);
        if(piMode==3){  //world wind
            gkUrlRequestWId=llRequestURL();            //request new url boat
        }else{
            gkUrlRequestId=llRequestURL();                //request new url boat
            glwHandle=llListen(ciGlwChannel,"","","");    //turn on listening to the windsetter
            giNTimeOut=llGetUnixTime()+ciSetterTimeOut;
            giCounter=0;
            llSetTimerEvent(ciSetterTimerInterval);             //timer for timeout
        }
    }else{  //close
        llReleaseURL(gsUrlBoat);            //frees url boat
        gsUrlBoat="";
        gsGlwEventNum="";
        giStatus=0;
        giWindMode=0;
        llListenRemove(glwHandle);        //remove handle
        llSetTimerEvent(0.0);             //stop timer
        if(gkHelm){
            if(piType==1) llRegionSayTo(gkHelm,0,"WindSetter timeout");
            else if(piType==2) llRegionSayTo(gkHelm,0,"Server timeout");
            else if(piType==4) llRegionSayTo(gkHelm,0,"URL request denied");   //bad url 
        }        
    }
}

default
{
    state_entry()
    {
        gkOwner=llGetOwner();
        gsOwnerName=llKey2Name(gkOwner);
        resetVars();
        giStatus=0;
        gaShadowingBoats=[];
        giWindMode=0;
        giHudsChannel = -300 - (integer)("0x" + llGetSubString( (string)llGetKey(), -7, -1) );
        //loadNotecard========>
        gsNoteName="GLW Settings";
        if(llGetInventoryType(gsNoteName)==INVENTORY_NONE){
            llSay(0,"does not exist "+gsNoteName+" notecard");
            gsNoteName="";
        }else{ 
            giNoteLine=0;
            gkNoteLineId=llGetNotecardLine(gsNoteName,giNoteLine);
        }        
        //<========loadNotecard
        llOwnerSay(llGetScriptName()+" ready ("+(string)llGetFreeMemory()+" free)");    
    }
    
    on_rez(integer p){ 
        if(gkOwner!=llGetOwner()) llResetScript(); 
    }
    
    changed(integer change)
    {
        if(change & CHANGED_REGION)
        {
            if(giStatus>=3){ 
                vector lvPos;
                //load the save data of the current sim
                if(giSystemMode==12){  //wind with variations
                    vector lvPos=llGetRegionCorner();  
                    lvPos.x=(integer)(lvPos.x/256);  //x position of actual sim
                    lvPos.y=(integer)(lvPos.y/256);  //y position of actual sim
                    giSimActualIndex=(integer)((lvPos.y-(giWindSimPosY-1))*3+(lvPos.x-(giWindSimPosX-1)));  //position new sim from 0 to 8
                    if(giSimActualIndex>=0 && giSimActualIndex<=8){ //The current sim is inside the wind matrix
                        //change wind to new sim
                        integer liNewIndex=(integer)llGetSubString(gsDataSim,giSimActualIndex,giSimActualIndex);  //list number for giSimActualIndex
                        if(liNewIndex==0){  //base wind
                            giVarsType=giVars1=giVars2=giVars3=giVars4=giVarsOverlap=0;    
                            //llOwnerSay("changed "+(string)giDataSimActual+"     "+gsDataSim0);
                            if(giDataSimActual!=0) saveGlwData(3,gsDataSim0);   //if the current wind is not the base wind, load the base wind
                            giDataSimActual=0;
                            gsDataSimActual="";
                        }else{  //variations wind
                            giDataSimActual=liNewIndex;  //wind data register num
                            gsDataSimActual=llList2String(gaDataSimWinds,giDataSimActual-1);  //data for actual sim
                            list la2=llParseString2List(gsDataSimActual,[":"],[]);  //local variations data parameters for this sim
                            list la3=llCSV2List(llList2String(la2,0));  //data for margins
                            giVarsType=llList2Integer(la3,0);
                            giVars1=llList2Integer(la3,1);
                            giVars2=llList2Integer(la3,2);
                            giVars3=llList2Integer(la3,3);
                            giVars4=llList2Integer(la3,4);
                            giVarsOverlap=llList2Integer(la3,5);   //saveGlwData function need this variable
                            saveGlwData(3,llList2String(la2,1));   //load local variations wind for this sim
                        }
                    }else{
                        if(giDataSimActual!=0) saveGlwData(3,gsDataSim0);   //load base wind
                    }
                }else{
                    if(giDataSimActual!=0) saveGlwData(3,gsDataSim0);   //load base wind
                }
                
                lvPos=llGetPos();  //reuse the lvPos variable
                if((lvPos.x>250.0 && lvPos.y>250.0) || (lvPos.x<5.0 && lvPos.y<5.0) || (lvPos.x>250.0 && lvPos.y<5.0) || (lvPos.x<5.0 && lvPos.y>250.0)){    //ifs near a simcorner 
                    llResetTime();
                    giSwSimCross=2;   // new url request with a 2 sec delay
                }else{  //It's not near a simcorner
                    giSwSimCross=0;
                    llReleaseURL(gsUrlBoat);            //frees url boat
                    gsUrlBoat="";
                    gkUrlRequestCId=llRequestURL();     //request a new url
                }
            }
        }
    }    

    link_message(integer sender_num, integer num, string str, key id) 
    {
        if(str!="glw") return;
        
        if(num==70005) {    //MSGTYPE_MOORED moored
            giSailingMode=0;
            llListenRemove(giShadowHandle);
            if((giStatus==0 || giStatus>=3) && giGlwUpdBoatPos==0) llSetTimerEvent(0.0);
            gsParams2Boat=gsNewParams2Boat="";
        }else if(num==70004) {    //MSGTYPE_SAILING raise
            giSailingMode=1;
            llListenRemove(giShadowHandle);
            giShadowHandle=llListen(giShadowChannel,"","","");
            gsParams2Boat=gsNewParams2Boat="";
            if(giStatus>=3 && giGlwUpdBoatPos==0) llSetTimerEvent(cfTimerInterval);
        }else if(num==70006) {    //MSGTYPE_BOATPARAMS params
            list l=llCSV2List((string)id);
            giSailArea=llList2Integer(l,0);
            gsBoatLength2Bow=llList2String(l,1);
            gsBoatLength2Stern=llList2String(l,2);
            if(llGetListLength(l)>3){
                giSwSendParams2Hud=llList2Integer(l,3);
            }
        }else if(num==70010) {    //MSGTYPE_MYWIND mywind mode 
            if(giStatus==4){
                if(gsServer!="" && gsIdEvent!="" && gsIdBoat!="") gkHttpSrvEndBoat=llHTTPRequest(gsServer+csServerDir+"glwEndBoat.php",gaHttpHeaders,gsIdEvent+","+gsIdBoat);
                llListenRemove(giSayHandle);
            }
            llOwnerSay("Personal Wind mode");
            windsetterListen(0,0);
        }else if(num==70011) {  //MSGTYPE_GLWIND cruise glwind mode
            string lsParam=llStringTrim((string)id, STRING_TRIM);
            if(llStringLength(lsParam)>3){
                llOwnerSay("Looking Event key");
                resetVars();
                giWindMode=1;
                if(gsMaster!="") gkHttpReqEventId=llHTTPRequest(gsMaster+csServerDir+"glwReqEventId.php",gaHttpHeaders,llGetSubString(lsParam,4,-1));
            }else{
                llOwnerSay("Looking windsetter");
                windsetterListen(1,0);
            }
        }else if(num==70012) {  //MSGTYPE_RACING racing glwind mode
            string lsParam=llStringTrim((string)id, STRING_TRIM);
            if(llStringLength(lsParam)>6){
                llOwnerSay("Looking Event key");
                resetVars();
                giWindMode=2;
                if(gsMaster!="") gkHttpReqEventId=llHTTPRequest(gsMaster+csServerDir+"glwReqEventId.php",gaHttpHeaders,llGetSubString(lsParam,7,-1));
            }else{
                llOwnerSay("Looking windsetter");
                windsetterListen(2,0);
            }
        }else if(num==70013) {    //MSGTYPE_WORLDWIND world wind mode 
            llOwnerSay("world wind mode");
            windsetterListen(3,0);
        }else if(num==70009) {    //MSGTYPE_RECOVERY recovery command 
            resetVars(); 
            if(gsMaster!="") gkHttpRecovery=llHTTPRequest(gsMaster+csServerDir+"glwRecovery.php",gaHttpHeaders,(string)gkOwner);
        }else if(num==70003) {    //MSGTYPE_RESET reset command  
            llResetScript();
        }else if(num==70008) {    //MSGTYPE_WINDINFO info command 
            //printData=========>
            if(giWindMode==0){ 
                llOwnerSay("You are in Personal Wind Mode");
                return;
            }
            string lsTex;
            if(giWindMode==1) lsTex="Cruise";
            else if(giWindMode==2) lsTex="Race";
            else if(giWindMode==3) lsTex="World";
            lsTex=lsTex+" Wind Mode\nDirector="+gsGlwDirectorName
                +"\nEvent="+gsGlwEventNum+" "+gsGlwEventName
                +"\nWIND Dir="+(string)giGlwWndDir
                +"\n Speed="+(string)giGlwWndSpeed
                +"\n Gusts="+(string)giGlwWndGusts
                +"\n Shifts="+(string)giGlwWndShifts
                //+"\n Period="+(string)giGlwWndPeriod
                +"\nWAVE Height="+(string)gfGlwWavHeight
                +"\n Speed="+(string)giGlwWavSpeed
                +"\n Length="+(string)giGlwWavLength
                +"\n Height Var="+(string)giGlwWavHeightVariance
                +"\n Length Var="+(string)giGlwWavLengthVariance;
                
            if(giGlwWavEffects==0) lsTex+="\n No";
            else if(giGlwWavEffects==1) lsTex+="\n Steer";
            else if(giGlwWavEffects==2) lsTex+="\n Speed";
            else if(giGlwWavEffects==3) lsTex+="\n Speed and Steer"; 
        
            lsTex+=" Effects\nCurrents Dir="+(string)giGlwCrtDir
                +"\n Speed="+(string)gfGlwCrtSpeed
                //+"\nSail mode="+(string)giGlwSailMode
                //+"\nExtra1="+(string)gsGlwExtra1
                //+"\nExtra2="+(string)gsGlwExtra2
                +"\nWater Depth="+(string)giGlwWaterDepth;
                //+"\nUpdate Pos="+(string)giGlwUpdBoatPos; 
            llOwnerSay(lsTex);
            //<========printData
        }
    }

    listen(integer piChannel, string psName, key pkId, string psMsg) {
        if(piChannel==giShadowChannel){    //received windshadow parameters. Only receive if it is saling
            if (llGetSubString(psMsg,0,5)=="BtPos,") {
                //calcWindShadow============>
                list laBtPosData=llCSV2List(psMsg);
                //llOwnerSay("Receiver listen shadow "+llDumpList2String(laBtPosData,",")+"     "+(string)pkId);
                if(llGetListLength(laBtPosData)>=9) {
                    vector lvPos = <llList2Float(laBtPosData,1), llList2Float(laBtPosData,2), globalPos.z>;
                    float lfDistance = llVecDist(lvPos,globalPos);
                    vector lvBearingVec = llVecNorm(lvPos-globalPos);
                    float lfOtherBoatSize=llList2Float(laBtPosData,5) + llList2Float(laBtPosData,6);
                    float lfOtherBoatSailArea=llList2Float(laBtPosData,3);
                    vector lvOtherBoatVelocity=<llList2Float(laBtPosData,7), llList2Float(laBtPosData,8),0>;
                    float lfEffect=0.0;
                    float lfShadow=0.0;
                    float lfBend=0.0;
                    float lfBearingToWind=0.0;
                    float lfBearing = llAcos(lvBearingVec.x)*RAD_TO_DEG;
                    if(llAsin(lvBearingVec.y)<0.0) lfBearing=(360.0-lfBearing);
                    lfBearing=(lfBearing*-1.0)+90; // convert to compass angle
                    lfBearingToWind=lfBearing-giTrueWindDir;
                    while(lfBearingToWind>180) lfBearingToWind-=360;
                    while(lfBearingToWind<-180) lfBearingToWind+=360;
                    if(llFabs(lfBearingToWind)<90.0) {
                        float lfOtherBoatCourse;
                        float lfOtherBoatCourseToWind;
                        float lfOurBearingFromOtherBoat;
                        if (lvOtherBoatVelocity==<0,0,0>) return;  // no use computing anything, since the speed is never exactly zero
                        lvOtherBoatVelocity=llVecNorm(lvOtherBoatVelocity);
                        lfOtherBoatCourse=llAcos(lvOtherBoatVelocity.x)*RAD_TO_DEG;
                        if(llAsin(lvOtherBoatVelocity.y)<0.0) lfOtherBoatCourse=(360.0-lfOtherBoatCourse);
                        lfOtherBoatCourse=(lfOtherBoatCourse*-1.0)+90; // convert to compass angle
                        if(lfOtherBoatSize<=1.0) lfOtherBoatSize=1.0;
                        if(lfDistance<lfOtherBoatSize) lfDistance=lfOtherBoatSize;
                        lfEffect=(lfOtherBoatSize/lfDistance)* // bigger lfDistance->less effect
                            (lfOtherBoatSize/((float)gsBoatLength2Bow+(float)gsBoatLength2Stern))* // bigger boat->more effect
                            lfOtherBoatSailArea/giSailArea;  // other sail bigger->more effect, our sail bigger->less effect
                        lfShadow=(llCos(lfBearingToWind*2.5*DEG_TO_RAD))*  // relative bearing of 0 degrees->max shadow
                            lfEffect*
                            gfMaxWindShadow; // because a windshadow can never be 100%
            
                        lfOtherBoatCourseToWind=lfOtherBoatCourse-giTrueWindDir;
                        while(lfOtherBoatCourseToWind>180) lfOtherBoatCourseToWind-=360;
                        while(lfOtherBoatCourseToWind<-180) lfOtherBoatCourseToWind+=360;
                        lfOurBearingFromOtherBoat = (lfBearing+180)-lfOtherBoatCourse;
                        while(lfOurBearingFromOtherBoat>180) lfOurBearingFromOtherBoat-=360;
                        while(lfOurBearingFromOtherBoat<-180) lfOurBearingFromOtherBoat+=360;
                        if(lfOtherBoatCourseToWind>30 && lfOtherBoatCourseToWind<80) {
                            if(lfOurBearingFromOtherBoat>120 && lfOurBearingFromOtherBoat<180) lfBend=(1.0-llSin(llFabs((lfOurBearingFromOtherBoat-150.0)*3.0*DEG_TO_RAD)))*1.25;
                        } else if(lfOtherBoatCourseToWind<-30 && lfOtherBoatCourseToWind>-80) {
                            if(lfOurBearingFromOtherBoat<-120 && lfOurBearingFromOtherBoat>-180) lfBend=(1.0-llSin(llFabs((lfOurBearingFromOtherBoat+150.0)*3.0*DEG_TO_RAD)))*1.25;
                        }
                        lfBend = lfBend * lfBend * lfEffect * gfMaxWindBend;
                        lfShadow-=(lfBend*0.03);  // as the bend gets bigger the shadow is smaller
                        if(lfShadow<0.0) lfShadow=0.0;
                        //llOwnerSay((string)lfShadow+"  "+(string)lfBend+"   "+(string)pkId);
                        //addWindShadowToList======>
                        integer liNumShadowBoats=llGetListLength(gaShadowingBoats);
                        integer liN;
                        for(;liN<liNumShadowBoats;liN+=3) {
                            if(llList2String(gaShadowingBoats,liN)==(string)pkId) {  //pkId=Otherboat key
                                gaShadowingBoats=llListReplaceList(gaShadowingBoats, [pkId, lfShadow, lfBend], liN, liN+2);
                                return;
                            }
                        }
                        gaShadowingBoats+=[pkId, lfShadow, lfBend];  //pkId=Otherboat key
                        //<================addWindShadowToList
                    }
                }
                //<=============calcWindShadow                
            }
            return;
        }else if(piChannel==giSayChannel){
            gkHttpSayEvent=llHTTPRequest(gsServer+csServerDir+"glwSayEvent.php",gaHttpHeaders,gsIdEvent+","+llGetDisplayName(pkId)+":: "+psMsg);
            return;
        }
        if(giStatus==1){
            if(ciGlwChannel!=0 && piChannel==ciGlwChannel) {   //parametersreceived=1 waiting WindSetter message
                if (llGetSubString(psMsg,0,5)=="GLWind") {   //receive windsetter notice
                    list laL=llCSV2List(psMsg);
                    string lsDirectorKey=llList2String(laL,1);
                    string lsEventNum=llList2String(laL,2);
                    giStatus=2;  //glwSetter notice received
                    string lsDesc=llGetObjectName();
                    integer li=llSubStringIndex(lsDesc,"#");
                    if(li>0) gsBoatId=llGetSubString(lsDesc,li+1,li+6);
                    else gsBoatId="";
                    if(llList2String(laL,0)=="GLWindReg"){ //send parameters request Internal Region
                        llRegionSayTo(pkId, ciGlwChannel-1, "glwReq,"+lsDirectorKey+","+lsEventNum+","+gsUrlBoat+","+(string)giWindMode+","+llGetDisplayName(gkOwner)+","+gsBoatId);   
                    }else{                                //send parameters request  External Region
                        llShout(ciGlwChannel-1, "glwReq,"+lsDirectorKey+","+lsEventNum+","+gsUrlBoat+","+(string)giWindMode+","+llGetDisplayName(gkOwner)+","+gsBoatId);   //send parameters request  External Region
                    }
                    llListenRemove(glwHandle);
                    giNTimeOut=llGetUnixTime()+ciHttpTimeOut;
                    llSetTimerEvent(ciSetterTimerInterval);   //timeout http windsetter
                    llOwnerSay("You have accepted the event of "+llList2String(laL,3));
                }
            }
        }
     }

    http_request(key id, string method, string psBody)
    {
        psBody=llStringTrim(psBody, STRING_TRIM); 
        //llOwnerSay("===============> "+psBody);
        if(id==gkUrlRequestId || id==gkUrlRequestSId || id==gkUrlRequestCId || id==gkUrlRequestRId || id==gkUrlRequestWId){  //receive new url 
            if (method == URL_REQUEST_GRANTED){   //url ok
                gsUrlBoat = psBody;
                if(id==gkUrlRequestCId){   //change region
                    //llOwnerSay("Change Region send "+gsIdBoat+"  "+gsUrlBoat);
                    if(giWindMode==3){   //world wind
                        if(gsIdBoat!="") gkHttpSrvCrgBoat=llHTTPRequest(gsMyServer+csServerDir+"glwReqSimDataWorld.php",gaHttpHeaders,gsIdBoat+","+gsUrlBoat);
                    }else{
                        //llOwnerSay("request change sim: "+gsServer+csServerDir+"glwReqSimData.php,"+gsIdEvent+","+gsIdBoat+","+gsUrlBoat);
                        if(gsIdBoat!="") gkHttpSrvCrgBoat=llHTTPRequest(gsServer+csServerDir+"glwReqSimData.php",gaHttpHeaders,gsIdEvent+","+gsIdBoat+","+gsUrlBoat);
                    }
                }else if(id==gkUrlRequestRId){   //Recovery
                    if(gsServer!="" && giSystemMode>10){ 
                        gkHttpSrvAddBoat=llHTTPRequest(gsServer+csServerDir+"glwAddBoat.php",gaHttpHeaders,gsIdEvent+","+gsUrlBoat+","+(string)llGetKey()+","+(string)giWindMode);
                    }
                }else if(id==gkUrlRequestWId){   //world wind
                    if(gsMyServer!=""){ 
                        gkHttpSrvAddBoatWorld=llHTTPRequest(gsMyServer+csServerDir+"glwAddBoatWorld.php",gaHttpHeaders,gsUrlBoat+","+(string)llGetKey()+","+(string)giWindMode);
                    }
                }
                if(giSailingMode==1 && giSystemMode>0) llSetTimerEvent(cfTimerInterval);        
            }else if(method==URL_REQUEST_DENIED){ 
                windsetterListen(0,4);
            }
        }else if (method == "POST"){
            string params=llGetHTTPHeader(id,"x-query-string");
            string clave=llGetSubString(params,0,9);

            if (clave=="glwSetData") { //receive initial parameters course from setter
                giNTimeOut=0;
                saveGlwData(0,psBody);
                llHTTPResponse(id,200,"OK");
                giStatus=3;
                if(gsServer!="" && giSystemMode>10){ 
                    gkHttpSrvAddBoat=llHTTPRequest(gsServer+csServerDir+"glwAddBoat.php",gaHttpHeaders,gsIdEvent+","+gsUrlBoat+","+(string)llGetKey()+","+(string)giWindMode);
                }
                if(giSailingMode==1 && giSystemMode>0) llSetTimerEvent(cfTimerInterval);
            }else if (clave=="glwUpdData") { //receive data modifications from server 
                string idBoat=llGetSubString(params,11,-1);
                saveGlwData(2,psBody);
                llHTTPResponse(id,200,"OK"+idBoat);
                //llOwnerSay("glwupddata "+(string)idBoat+"  "+psBody);
            }else if (clave=="glwScaData") { //scan   send boat position data to server 
                string idBoat=llGetSubString(params,11,-1);
                vector lvPos=llGetPos();  
                vector lvSimPos=llGetRegionCorner();
                llHTTPResponse(id,200,"OK,"+(string)idBoat+","+llGetRegionName()+","+
                                (string)((integer)(lvSimPos.x/256))+","+(string)((integer)(lvSimPos.y/256))+","+
                                (string)((integer)lvPos.x)+","+(string)((integer)lvPos.y)+","+
                                (string)giWindMode+","+(string)giGlwWndDir+","+(string)giGlwWndSpeed);
            }else if (clave=="glwSayData") { //say receive message event
                string idBoat=llGetSubString(params,11,-1);
                llOwnerSay("/me ::"+psBody); 
                llHTTPResponse(id,200,"OK,"+(string)idBoat);
            }else{
                llHTTPResponse(id,404,"KO");
            }
        }
    }
    
    http_response(key pkId, integer piStatus, list paMetaData, string psBody)
    {
        psBody=llStringTrim(psBody, STRING_TRIM); 
        if(pkId==gkHttpSrvSendUrl){
        }else if(pkId==gkHttpSrvAddBoat){
            //llOwnerSay("receiver add boat data: "+psBody);
            if(llGetSubString(psBody,0,1)=="OK"){
                loadDataEvent(0,psBody);   //intial wind from server
                giStatus=4;
                llOwnerSay("Boat registered event #"+(string)gsIdEvent); 
                if(giGlwUpdBoatPos>0){   //if update position periodically 
                    llSetTimerEvent(cfTimerInterval);
                }
                if(giSayChannel!=0){ 
                    llListenRemove(giSayHandle);
                    giSayHandle=llListen(giSayChannel,"",gkOwner,"");   //activate the communication channel
                }
            }else if(llGetSubString(psBody,0,2)=="KO1"){
                llOwnerSay("Error register Boat, event not exist");
            }else{
                llOwnerSay("Error register Boat");
                //llOwnerSay(psBody);
            }
        }else if(pkId==gkHttpSrvAddBoatWorld){    //receive data to boat world wind
            //llOwnerSay("receiver world add boat data: "+psBody);
            if(llGetSubString(psBody,0,1)=="OK"){
                loadDataEvent(0,psBody);   //intial World wind from server
                giStatus=4;
                llOwnerSay("Boat World Wind registered");
            }else{
                llOwnerSay("Error register Boat");
                //llOwnerSay(psBody);
            }
        }else if(pkId==gkHttpSrvEndBoat){
            if(llGetSubString(psBody,0,1)=="OK"){
                llOwnerSay("Boat unregister event #"+(string)gsIdEvent);
            }
        }else if (pkId==gkHttpSrvCrgBoat) { //receive response+data for change Region   OK#000000000#datasim1#datasim2#...#datasim9
            //llOwnerSay("Change Sim Receive "+psBody);
            if(llGetSubString(psBody,0,1)=="OK"){
                if(giWindMode==3){   //world wind
                    loadDataEvent(1,psBody);   //wind from server change region
                }else{
                    if(giSystemMode==12){  //evento with variations
                        loadDataEvent(1,psBody);   //wind from server change region
                    }
                }
            }else{ 
                llOwnerSay("Region Change Error");
                //llOwnerSay("response change sim "+psBody);
            }
        }else if(pkId==gkHttpReqEventId){   //receive request event id data
            if(llGetSubString(psBody,0,2)=="OK0"){    //The event have been found
                giNTimeOut=0;
                saveGlwData(1,llGetSubString(psBody,3,-1));
                giStatus=3;
                llOwnerSay("the "+gsGlwEventName+" event loaded. Waiting...");
                gkUrlRequestRId=llRequestURL();    //Retrieve the url of the boat. Use the same key as recovery   
            }else if(llGetSubString(psBody,0,1)=="OK"){    //event not found
                llOwnerSay("Event Key not found "+llGetSubString(psBody,3,-1));
            }else{ 
                llOwnerSay("Request Event Key Error");
                //llOwnerSay(psBody);
            }
        }else if(pkId==gkHttpRecovery){   //receive recovery data
            if(llGetSubString(psBody,0,2)=="OK0"){    //The boat and the event have been found
                giNTimeOut=0;
                giWindMode=(integer)llGetSubString(psBody,3,3);
                saveGlwData(1,llGetSubString(psBody,5,-1));
                giStatus=3;
                llOwnerSay("the "+gsGlwEventName+" event loaded. Waiting...");
                gkUrlRequestRId=llRequestURL();    //Retrieve the url of the boat   
            }else if(llGetSubString(psBody,0,1)=="OK"){    //boat or event not found
                llOwnerSay("Recovery not found "+llGetSubString(psBody,3,-1));
            }else{ 
                llOwnerSay("Recovery Error");
                //llOwnerSay(psBody);
            }
        }else if(pkId==gkHttpSayEvent){
            //llOwnerSay(psBody);
        }
    }
    
    dataserver(key pkQuery_id, string psData)  
    {
        if (pkQuery_id == gkNoteLineId){
            if (psData == EOF){
                gkNoteLineId = NULL_KEY;
                gsNoteName="";
            }else{
                //readNextLine===========>
                if(psData!=""){
                    string lsS;
                    integer liN=llSubStringIndex(psData,"#");
                    if(liN>0) lsS=llGetSubString(psData,0,liN-1);
                    else if(liN<0) lsS=psData;
                    lsS=llStringTrim(lsS,STRING_TRIM);
                    if(lsS!=""){
                        integer n=llSubStringIndex(lsS,"=");
                        if(n>0 && n<llStringLength(lsS)-1){
                            string lsClave=llStringTrim(llGetSubString(lsS,0,n-1),STRING_TRIM);  //clave
                            string lsData=llStringTrim(llGetSubString(lsS,n+1,-1),STRING_TRIM);  //clave
                            if(lsClave=="server"){
                                gsMyServer=lsData;
                            }else if(lsClave=="master"){
                                gsMaster=lsData;
                            }else if(lsClave=="saychannel"){
                                if(lsData!="") giSayChannel=(integer)lsData;
                            }
                        }
                    }
                }
                gkNoteLineId=llGetNotecardLine(gsNoteName, ++giNoteLine);                
                //<==============readNextLine
            }
        }
    }

    timer() {
        if(giStatus<3) {
            if(giStatus==1) {    //wait windsetter timeout
                if(llGetUnixTime()>giNTimeOut) {
                   windsetterListen(0,1);
                }
            } else if(giStatus==2) {    //wait server timeout
                if(llGetUnixTime()>giNTimeOut) {
                   windsetterListen(0,2);
                }
            }
            return;
        }
        
        //send position update periodically ==>
        if(giGlwUpdBoatPos>0){
            if(llGetUnixTime()%giGlwUpdBoatPos==0){   //All ships are updated at the same time
                llHTTPRequest(gsServer+csServerDir+"glwUpdPos.php",gaHttpHeaders,gsIdEvent+","+gsIdBoat);  //update periodical position
            }
        }
        //<==
            
        if(giSailingMode==0 || giStatus<3) return;   //If it is moored or has not received the parameters from the windsetter return
        
        globalPos=llGetPos()+llGetRegionCorner();
        ++giCounter;
        
        //Calc Local Variations Margins
        if(giSystemMode==12){  //system with local variations
            if(giVarsType==11){  //margin areas
                //select the position, with margin, closest to the edge of the sim
                gvLocalPos=llGetPos();
                gfMarginFactor=1.0;
                if(gvLocalPos.y>255-giVars1){   //north margin
                    if(giVars1>0){                    
                        gfMarginFactorTemp=(255-gvLocalPos.y)/giVars1;
                        if(gfMarginFactorTemp<gfMarginFactor) gfMarginFactor=gfMarginFactorTemp;
                    }
                }
                if(gvLocalPos.x>255-giVars2){   //east margin
                    if(giVars2>0){                    
                        gfMarginFactorTemp=(255-gvLocalPos.x)/giVars2;
                        if(gfMarginFactorTemp<gfMarginFactor) gfMarginFactor=gfMarginFactorTemp;  // It is smaller than the previous
                    }
                }
                if(gvLocalPos.y<giVars3){   //south margin
                    if(giVars3>0){                    
                        gfMarginFactorTemp=gvLocalPos.y/giVars3;
                        if(gfMarginFactorTemp<gfMarginFactor) gfMarginFactor=gfMarginFactorTemp;  // It is smaller than the previous
                    }
                }
                if(gvLocalPos.x<giVars4){   //West margin
                    if(giVars4>0){                    
                        gfMarginFactorTemp=gvLocalPos.x/giVars4;
                        if(gfMarginFactorTemp<gfMarginFactor) gfMarginFactor=gfMarginFactorTemp; // It is smaller than the previous
                    }
                }
            }else if(giVarsType==21){  //margin circles 
                gfCircleDistance = llVecDist(globalPos,<giVars1,giVars2,globalPos.z>);  //distance to center circle
                if(gfCircleDistance>giVars3){ //radius,  is outside the circle
                    gfMarginFactor=0;  //base wind
                }else if(gfCircleDistance<giVars3-giVars4){   //radius, margin is inside the circle
                    gfMarginFactor=1;  //local wind
                }else{  //is in margin zone
                    gfMarginFactor=(giVars3-gfCircleDistance)/giVars4; //factor margin
                }
                //llOwnerSay("Distance "+(string)gfCircleDistance+"    "+(string)gfMarginFactor);
            }else{
                gfMarginFactor=1.0;
            }
        }else{
            gfMarginFactor=0.0;
        }

        //CALC WIND ===>
        //calc wind shifts
        if(gfMarginFactor==1.0){ 
            giTrueWindDir=giGlwWndDir;
            giTempWndShifts=giGlwWndShifts;
        }else if(gfMarginFactor==0.0){ 
            giTrueWindDir=giVarWndDir;
            giTempWndShifts=giVarWndShifts;
        }else{
            if(giGlwWndDir<=giVarWndDir){
                if(llAbs(giVarWndDir-giGlwWndDir)<llAbs(giGlwWndDir+360-giVarWndDir)) giTempDir=giGlwWndDir-giVarWndDir;
                else  giTempDir=giGlwWndDir+360-giVarWndDir;
            }else{    //giGlwWndDir>giVarWndDir
                if(llAbs(giGlwWndDir-giVarWndDir)<llAbs(giGlwWndDir-(giVarWndDir+360))) giTempDir=giGlwWndDir-giVarWndDir;
                else  giTempDir=giGlwWndDir-(giVarWndDir+360);
            }
            giTrueWindDir=giVarWndDir+(integer)(giTempDir*gfMarginFactor);
            giTempWndShifts=giVarWndShifts+(integer)(0.5+(giGlwWndShifts-giVarWndShifts)*gfMarginFactor);
        }
        
        if(giTempWndShifts>0){
            gfAnglepos=(((integer)(globalPos.x/10)%360+(integer)(globalPos.y/10)%360)/2.0)*DEG_TO_RAD;   //angle for position  
            giWndPeriod=giVarWndPeriod+(integer)(0.5+(giGlwWndPeriod-giVarWndPeriod)*gfMarginFactor);
            gfAngletime=TWO_PI*(llGetUnixTime()%giWndPeriod)/giWndPeriod;     //angle for time
            //multiplayer calc  All equal sailors
            gfWindMultiplier=llSin(gfAngletime-gfAnglepos)+0.4*llSin(2*gfAngletime-gfAnglepos)+0.8*llSin(3*gfAngletime-gfAnglepos)+0.8*llSin(5*gfAngletime-gfAnglepos);                                       gfTemp=cfWindShiftsFactor*gfWindMultiplier/1.5;  //2.0 multiplier shifts level as 1.0
            giTrueWindDir+=(integer)(giTempWndShifts*gfTemp);
        }
        if(giTrueWindDir>=360) giTrueWindDir-=360;
        else if(giTrueWindDir<0) giTrueWindDir+=360;
        //
    
        //windspeed
        //calc wind speed gusts
        giTrueWindSpeed=giVarWndSpeed+(integer)(0.5+(giGlwWndSpeed-giVarWndSpeed)*gfMarginFactor);
        giTempWndGusts=giVarWndGusts+(integer)(0.5+(giGlwWndGusts-giVarWndGusts)*gfMarginFactor);
        
        //llOwnerSay("glw "+(string)giGlwWndGusts+"  var "+(string)giVarWndGusts+"  total "+(string)giTempWndGusts);
        
        if(giTempWndGusts>0){
            gfAnglepos=(((integer)(globalPos.x/10)%360+(integer)(globalPos.y/10)%360)/2.0)*DEG_TO_RAD;   //angle for position
            giWndPeriod=giVarWndPeriod+(integer)(0.5+(giGlwWndPeriod-giVarWndPeriod)*gfMarginFactor);
            gfAngletime=TWO_PI*(llGetUnixTime()%giGlwWndPeriod)/giGlwWndPeriod;     //angle for time
            //multiplayer calc  All equal runners
            gfWindMultiplier=llSin(gfAngletime-gfAnglepos)+0.4*llSin(2*gfAngletime-gfAnglepos)+0.8*llSin(3*gfAngletime-gfAnglepos)+0.8*llSin(5*gfAngletime-gfAnglepos);               
            gfTempgusts=cfWindGustsFactor*gfWindMultiplier/2.16;  //2.16 multiplier gusts level as 1.0
            if(llFabs(gfTempgusts)>1.0){ 
                if(gfTempgusts<0) gfTempgusts=-1.0;
                else gfTempgusts=1.0;
            }
            giTrueWindSpeed+=llRound(giTrueWindSpeed*giTempWndGusts*gfTempgusts/100.0);
        }
        if (giTrueWindSpeed<0) giTrueWindSpeed=0;
        if (giTrueWindSpeed>35) giTrueWindSpeed=35;
        //

        //Shadow Wind
        //output gfWindBend, giTrueWindSpeed  
        giNumShadowBoats=llGetListLength(gaShadowingBoats);
        gfWindBend=0.0;
        if(giNumShadowBoats>0){
            gfWindShadow=0.0;
            for(giN=0;giN<giNumShadowBoats;giN+=3) {
                gfShadow=llList2Float(gaShadowingBoats,giN+1);  //shadow wind speed effect
                gfBend=llList2Float(gaShadowingBoats,giN+2);    //shadow wind dir effect
                gfWindShadow+=gfShadow;   //sum effect all boats
                gfWindBend+=gfBend;         //sum effect all boats
                gfShadow=gfShadow*(1.0-gfReduceRate);  //reduces the effect for the next interaction. How often is the next interaction?
                gfBend=gfBend*(1.0-gfReduceRate);     //reduces the effect for the next interaction. How often is the next interaction?
                if(gfShadow<0.1 && gfBend<1.0) {
                    gaShadowingBoats=llDeleteSubList(gaShadowingBoats,giN,giN+2);    //delete boat from list
                } else {
                    gaShadowingBoats=llListReplaceList(gaShadowingBoats,[gfShadow,gfBend],giN+1,giN+2);   //update boat in the list 
                }
            }
            if(gfWindShadow>gfMaxWindShadow) gfWindShadow=gfMaxWindShadow;
            if(gfWindBend>gfMaxWindBend) gfWindBend=gfMaxWindBend;
            if(gfWindShadow>0.0) giTrueWindSpeed=llRound(giTrueWindSpeed*(1.0-gfWindShadow));  //revisar integers y floats
        }
        //<==== CALC WIND

        //calc depth ======>
        giTempWaterDepth=giVarWaterDepth+(integer)(0.5+(giGlwWaterDepth-giVarWaterDepth)*gfMarginFactor);
        if(giTempWaterDepth>0) {
            gfDepth=llWater(ZERO_VECTOR)-llGround(ZERO_VECTOR);
            if(gfDepth<0) gfDepth=0;
        }
        //<====== calc depth
        
        // calcCurrent ===>
        if(gfMarginFactor==1.0) gfTempCrtSpeed=gfGlwCrtSpeed;
        else if(gfMarginFactor==0.0) gfTempCrtSpeed=gfVarCrtSpeed;
        else gfTempCrtSpeed=gfVarCrtSpeed+((gfGlwCrtSpeed-gfVarCrtSpeed)*gfMarginFactor);
        //llOwnerSay("calc current "+(string)gfTempCrtSpeed+"    "+(string)gfVarCrtSpeed+"      "+(string)gfGlwCrtSpeed);
        if(gfTempCrtSpeed>0.0){ 
            if(giCounter%giCalcCurrentInterval==0){
                if(gfMarginFactor==1.0) giCurrentDir=giGlwCrtDir; 
                else if(gfMarginFactor==0.0) giCurrentDir=giVarCrtDir; 
                else{ 
                    if(giGlwCrtDir<=giVarCrtDir){
                        if(llAbs(giVarCrtDir-giGlwCrtDir)<llAbs(giGlwCrtDir+360-giVarCrtDir)) giTempDir=giGlwCrtDir-giVarCrtDir;
                        else  giTempDir=giGlwCrtDir+360-giVarCrtDir;
                    }else{    //giGlwCrtDir>giVarCrtDir
                        if(llAbs(giGlwCrtDir-giVarCrtDir)<llAbs(giGlwCrtDir-(giVarCrtDir+360))) giTempDir=giGlwCrtDir-giVarCrtDir;
                        else  giTempDir=giGlwCrtDir-(giVarCrtDir+360);
                    }
                    giCurrentDir=giVarCrtDir+(integer)(giTempDir*gfMarginFactor);
                    if(giCurrentDir>=360) giCurrentDir-=360;
                    else if(giCurrentDir<0) giCurrentDir+=360;
                }                
                
                if(giTempWaterDepth>0) {
                    gfMultiplier = gfDepth/giTempWaterDepth;
                    if(gfMultiplier>2.5) gfMultiplier=2.5;
                    if(gfMultiplier<0.0) gfMultiplier=0.0;
                    gfCurrentSpeed=gfTempCrtSpeed*(gfMultiplier+0.5)/1.5; // varies between 0.33 and 2.0 times the default current speed 
                }else{
                    gfCurrentSpeed=gfTempCrtSpeed;
                }
            }
        }else{
            gfCurrentSpeed=0.0;
        }
        //<=== calcCurrent

        // calcWaveHeight ===>
        if(gfMarginFactor==1.0) gfTempWavHeight=gfGlwWavHeight;
        else if(gfMarginFactor==0.0) gfTempWavHeight=gfVarWavHeight;
        else gfTempWavHeight=gfVarWavHeight+((gfGlwWavHeight-gfVarWavHeight)*gfMarginFactor);
        //llOwnerSay("calc wave "+(string)gfTempWavHeight+"    "+(string)gfVarWavHeight+"      "+(string)gfGlwWavHeight+"    "+(string)gfMarginFactor);
        if(gfTempWavHeight>0.0){    //if waves height = 0  no waves effect
            giUnixTime=llGetUnixTime()-1648000000;
            //The if is just to prevent division by 0, it will only be = 0 on a reset
            if(giWavePeriod>0) gfwaveCycle=TWO_PI*((giUnixTime+giWavesIncPeriod)%giWavePeriod)/giWavePeriod;     //time to angle in radians
            else gfwaveCycle=PI;  //recalculate the wave
            if(gfwaveCycle==PI){    //IMPORTANT The wave only change if the wave is in the valley, at the lowest point. 180 degrees
                gfWaveHeightMax=gfTempWavHeight;
                if(giTempWaterDepth>0) {   //up or down waves max height depend of depth. If the reference depth is 0 there is no effect 
                    if(gfDepth>0){
                        gfMultiplier = (giTempWaterDepth/gfDepth);
                        if(gfMultiplier>2.5) gfMultiplier=2.5;
                        if(gfMultiplier<0.0) gfMultiplier=0.0;
                        gfWaveHeightMax=gfTempWavHeight*((gfMultiplier+0.5)/1.5); // varies between 0.3 and 2.0 times the default wave height. Depth variation
                    }
                }
                giWaveLength=giVarWavLength+(integer)(0.5+(giGlwWavLength-giVarWavLength)*gfMarginFactor);
                gfTempWavHeight=gfVarWavHeight+((gfGlwWavHeight-gfVarWavHeight)*gfMarginFactor);
                giTempWavLengthVariance=giVarWavLengthVariance+(integer)(0.5+(giGlwWavLengthVariance-giVarWavLengthVariance)*gfMarginFactor);
                giTempWavHeightVariance=giVarWavHeightVariance+(integer)(0.5+(giGlwWavHeightVariance-giVarWavHeightVariance)*gfMarginFactor);
                giTempWavSpeed=giVarWavSpeed+(integer)(0.5+(giGlwWavSpeed-giVarWavSpeed)*gfMarginFactor);
                if(giTempWavLengthVariance>0 || giTempWavHeightVariance>0){   //calc variances
                    string lsWaveVarSerie="00010000100101001000000100100001";    //serial waves
                    if(llGetSubString(lsWaveVarSerie,giNumber,giNumber)=="1"){   //this wave parameters change
                        gfTheta=TWO_PI*(llGetUnixTime()%120)/120;     //continuous sinusoidal value 2 minute cycle
                        gfOffset=(llSin(gfTheta)+llSin(gfTheta*2)+llSin(gfTheta*3))/2.0;     //continuous variation value for each period  values -1..1
                        if(giTempWavLengthVariance>0){   //calc waves length
                            giWaveLength=llRound(giWaveLength+(giWaveLength*(giTempWavLengthVariance/100.0)*gfOffset));
                        }
                        if(giTempWavHeightVariance>0){
                            gfWaveHeightMax=gfWaveHeightMax+(gfTempWavHeight*(giTempWavHeightVariance/100.0)*gfOffset);  //add or substract height variance to max height wave
                        }
                    }
                    giNumber++;
                    if(giNumber==31) giNumber=0;
                }                
                giWavePeriod=llRound(((float)giWaveLength/(giTempWavSpeed*cfKt2Ms))/4.0)*4;     //wave period  length/speed and multiple of 4
                if(giWavePeriod<12) giWavePeriod=12;    //minimum value for the period of the wave
                giWavesIncPeriod=(integer)((((giUnixTime/giWavePeriod)+0.5)*giWavePeriod)-giUnixTime);  //Add an addend so that the new wave starts at 180 degrees
                //llOwnerSay((string)(gfwaveCycle*RAD_TO_DEG)+"    "+(string)giWavePeriod+"  "+(string)giUnixTime+"   "+(string)giWavesIncPeriod);
            }
            gfWaveHeight=gfWaveHeightMax*llCos(gfwaveCycle);    //factor between -1 and 1. Actual wave height

            if(gfMarginFactor>0.5) giTempWavEffects=giGlwWavEffects;
            else giTempWavEffects=giVarWavEffects;
        }else{
            gfWaveHeight=0.0;
            gfWaveHeightMax=0.0;
        }
        //<=== calcWaveHeight
        
        //send params to boat
        gsNewParams2Boat=(string)giTrueWindDir+","+(string)giTrueWindSpeed+","+
            (string)giCurrentDir+","+(string)gfCurrentSpeed+","+
            (string)gfWaveHeight+","+(string)gfWaveHeightMax+","+(string)giTempWavEffects+","+(string)llRound(gfWindBend);
            
        if(gsNewParams2Boat!=gsParams2Boat){
            llMessageLinked(LINK_THIS, 70001, "glw", gsNewParams2Boat); //MSGTYPE_GLWPARAMS
            if(giSwSendParams2Hud) llWhisper(giHudsChannel,gsNewParams2Boat);            
            gsParams2Boat=gsNewParams2Boat;
        }
            
        //send shadow message     
        if(giSailingMode==1) {
            if(++giSendBtPosCounter>(giSendBtPosInterval+(llGetListLength(gaShadowingBoats)/4))) {
                giSendBtPosCounter=0;
                //sendBtPosMessage ===>
                gvShadowVelocity=llGetVel();
                if(giTrueWindDir>180) giWindAngle-=360;
                else giWindAngle=giTrueWindDir;
                gvWindVector=<llSin(giWindAngle*DEG_TO_RAD),llCos(giWindAngle*DEG_TO_RAD),0.0>;
                gvAxs = llRot2Fwd(llGetRot())%llVecNorm(gvWindVector);
                if(gvAxs.z<0) gsShadowTack = "S";       
                else gsShadowTack = "P";
                gsShadowvar="BtPos,"+(string)((integer)globalPos.x)+","+(string)((integer)globalPos.y)+","+
                  (string)giSailArea+","+gsShadowTack+","+gsBoatLength2Bow+","+gsBoatLength2Stern+","+
                  llGetSubString((string)gvShadowVelocity.x,0,3)+","+llGetSubString((string)gvShadowVelocity.y,0,3);
                llSay(giShadowChannel,gsShadowvar);
                //<===sendBtPosMessage
            }
        }

        if(giSwSimCross){
            if(llGetTime()>giSwSimCross){   //get new url after delay
                giSwSimCross=0;
                llReleaseURL(gsUrlBoat);            //frees url boat
                gsUrlBoat="";
                gkUrlRequestCId=llRequestURL();     //request a new url
            }
        }
        
    }
}
