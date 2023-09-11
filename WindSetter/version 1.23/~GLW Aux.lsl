// constants
/*
integer CHANNEL=0;
integer TIMERINTERVAL=10;  // in seconds
integer MAXLISTENTIME=60;  // in seconds
integer RACETIMEOUT=7200;  // in seconds
integer BLACKLISTTIMEOUT=600;  // in seconds
integer EMAILSCRIPTCOUNT=10;  // change this number if you dont have 10 email scripts
integer    MSGTYPE_SENDCRWWC=701;
integer    MSGTYPE_SENDRCWWC=702;
integer LONGTOUCH=8;
float knots2ms=0.514;
float ms2knots=1.945;

integer listenTimeOut=0;
integer raceTimeOut=0; 
*/
integer swdbg;
//settings
integer giMenuoutregion=0;
integer giAutolock=1;
integer giAutounlock=1;
integer giAutolocktime=30;
integer giAutolocktype=1;
integer giInterval=3;
integer giIntervalMsg=30;
integer giDirectorMsg=1;
integer giPeriod;
list    gaAdmins=[];
string   gsServer;

// variables for reading notecards  
key     gkRequestInFlight;
integer giCurrentLine;
string  gsCurrentName;
string  csNOTESETTINGS="~GLW Settings";
string  csNOTEGLWTEMP="~GLW Template";
integer giLoadNote=0;   //0-disabled  1-load settings  2-load template  3-load notecard 
//listas de trabajo
list    gaGlwv=[];         
//
key     gkTarget;

//default variables and values
//definition commands they are all for compatibility with wwc, but glw only uses up to ciGlwdefn position
list caGlwdefc=["wind dir","wind speed","wind gusts","wind shifts","wind period","wave speed","wave height variance","wave length variance","wave height","wave length","wave effects","current dir","current speed","sail mode","name","key","extra1","extra2","water depth","update pos","event type",
"wavex","wavey","wind system","wave system","current system","crew size","class","version","speed","wind rate","mode"];
integer ciGlwdefn=20; //number of valid elements in caGLWdefc
list gaGlwdefv=[0,15,0,0,60,3,0,0,0,50,2,0,0,2,"","","","",0,0,""];  //default values

//Local Variations data
string gsGlwAreas;
string gsGlwCircles;

//GLW==>
// variables racing
integer  giGlwEventNum=0;
string   gsGlwDirectorName="";
key      gkGlwDirectorKey="";
string   raceLocked="";
list     rLocalFluctuations=[];
list     cLocalFluctuations=[];
//<=GLW
integer  giStarted;

// operational variables
integer rLocalsReceived=0;
integer cLocalsReceived=0;

integer giSwInitData;

integer uSubStringLastIndex(string psHay, string psPin)
{
    integer liIndex2 = -1;
    integer liIndex;
    if (psPin == "")    
        return 0;
    while (~liIndex)
    {
        liIndex = llSubStringIndex( llGetSubString(psHay, ++liIndex2, -1), psPin);
        liIndex2 += liIndex;
    }
    return liIndex2;
}

init()
{
    giGlwEventNum=0;
    giStarted=0;
    gsGlwDirectorName="";
    gkGlwDirectorKey="";
    raceLocked="";
    giLoadNote=0;
    gaGlwv=gaGlwdefv;
    gsGlwAreas="";  
    gsGlwCircles="";       
    if(swdbg) llOwnerSay(llGetScriptName()+": "+(string)llGetFreeMemory());
    giSwInitData++;
    if(giSwInitData==2) setDisplays("");
}

readfirstNCLine(integer piMode, string psName) 
{
    giLoadNote=piMode;
    giCurrentLine=0; 
    gsCurrentName="";
    if (llGetInventoryType(psName)!=INVENTORY_NOTECARD){
        llSay(0, "Unable to find the '"+psName+"' notecard. Default settings will be loaded.");
        if(giLoadNote<3) init();
        else giLoadNote=0;
    }else{ 
        gsCurrentName=psName;
        gkRequestInFlight=llGetNotecardLine(gsCurrentName, giCurrentLine);
    }
}

readNextNCLine(string psLine) 
{
    string ls;
    integer li=llSubStringIndex(psLine, "#");
    if (li!=0) { 
        if (li>0) ls=llGetSubString(psLine,0,li-1);
        else ls=psLine;
        ls=llStringTrim(ls, STRING_TRIM);
        if (ls!="") {
            if (llSubStringIndex(ls,"=")>0){ 
                if(giLoadNote==1){   //settings
                    interpretSettings(ls);
                }else if(giLoadNote==2){   //glw template
                    interpretGLWTemp(ls);
                }else if(giLoadNote==3){   //wind note 
                    interpretNote(ls);
                }
            }else if(giLoadNote==3){   //wind note 
                interpretNote(ls);     //wwc notecards 
            }else{ 
                llSay(0, gsCurrentName+" note malformed line: " + ls);
            }
        }
    }
    giCurrentLine++;
    gkRequestInFlight=llGetNotecardLine(gsCurrentName, giCurrentLine);
}

interpretSettings(string psText) //interpret the lines of the settings notecard 
{
    list laParts=llParseString2List(psText, ["="], []);
    if (llGetListLength(laParts)!=2) {
        return;
    }

    string lsKeystring=llList2String(laParts, 0);
    lsKeystring=llToLower(llStringTrim(lsKeystring,STRING_TRIM));
    string lsValue=llList2String(laParts, 1);
    lsValue=llStringTrim(lsValue,STRING_TRIM);
    
    if (lsKeystring=="" || lsValue=="") return;

    if (lsKeystring=="admin") {
        gaAdmins+=lsValue;
        return;
    }
    if (lsKeystring=="autolock") {
        giAutolock=(integer)lsValue;
        return;
    }
    if (lsKeystring=="autounlock") {
        giAutounlock=(integer)lsValue;
        return;
    }
    if (lsKeystring=="autolocktime") {
        giAutolocktime=60*(integer)lsValue;
        return;
    }
    if (lsKeystring=="autolocktype") {
        giAutolocktype=(integer)lsValue;
        return;
    }
    if (lsKeystring=="menuoutregion") {
        giMenuoutregion=(integer)lsValue;
        return;
    }
    if (lsKeystring=="interval") {
        giInterval=(integer)lsValue;
        return;
    }
    if (lsKeystring=="intervalmsg") {
        giIntervalMsg=(integer)lsValue;
        return;
    }
    if (lsKeystring=="directormsg") {
        giDirectorMsg=(integer)lsValue;
        return;
    }
    if (lsKeystring=="period") {
        giPeriod=(integer)lsValue;
        return;
    }
    if (lsKeystring=="server") {
        if(gsServer=="") gsServer=lsValue;
        llMessageLinked(LINK_THIS, 1201, gsServer, "");  //send server url to setter script
        return;
    }
    llOwnerSay("Settings: Unknown keyword: \""+lsKeystring+"\"");    
}

interpretGLWTemp(string psText)    //interpret the lines of the glw template notecard
{
    integer liType;
    list laParts=llParseString2List(psText, ["="], []);
    if (llGetListLength(laParts)!=2) {
        return;
    }

    string lsKeystring=llList2String(laParts, 0);
    lsKeystring=llToLower(llStringTrim(lsKeystring,STRING_TRIM));
    string lsValue=llList2String(laParts, 1);
    lsValue=llStringTrim(lsValue,STRING_TRIM);
    
    if (lsKeystring=="" || lsValue=="") return;
    
    integer li=llListFindList(caGlwdefc,[lsKeystring]);  //find key in default array keys
    if(li>=0){ 
        if(li<ciGlwdefn){  //>ciGlwdefn ignore keys
            //llOwnerSay(lsKeystring+"="+lsValue);
            if(li==8 || li==12) gaGlwdefv=llListReplaceList(gaGlwdefv,[(integer)((float)lsValue*10)],li,li);     //wave height || current speed
            else{
                liType=llGetListEntryType(gaGlwdefv,li);
                if(liType==TYPE_INTEGER) gaGlwdefv=llListReplaceList(gaGlwdefv,[(integer)lsValue],li,li);
                else if(liType==TYPE_STRING) gaGlwdefv=llListReplaceList(gaGlwdefv,[lsValue],li,li);
                else if(liType==TYPE_FLOAT) gaGlwdefv=llListReplaceList(gaGlwdefv,[(float)lsValue],li,li);
            }
        }
    }else{ 
        llSay(0, "WWC Template: Unknown keyword: \""+lsKeystring+"\""); 
    }
}

interpretNote(string psText) 
{
    integer liType;
    integer liWwcNote=0;
    integer li=llSubStringIndex(psText,"=");
    if (li<0) {
        liWwcNote=1;  //wwc notecards
        li=uSubStringLastIndex(psText," "); //wwc notecards
    }
    if (li<=0 || li==llStringLength(psText)-1){  //It is the beginning or the end of the line
        return;
    }
    string lsKeystring=llGetSubString(psText,0,li-1);
    lsKeystring=llToLower(llStringTrim(lsKeystring,STRING_TRIM));
    string lsValue=llGetSubString(psText,li+1,-1);
    lsValue=llStringTrim(lsValue,STRING_TRIM);
    
    if (lsKeystring=="" || lsValue=="") return;
    
    if(liWwcNote==1){
        if(llGetSubString(lsKeystring,0,3)=="race") lsKeystring=llGetSubString(lsKeystring,5,-1);   //wwc notecards
        else if(llGetSubString(lsKeystring,0,5)=="cruise")  lsKeystring=llGetSubString(lsKeystring,7,-1);  //wwc notecards
    }
    li=llListFindList(caGlwdefc,[lsKeystring]);  //find keystring in list keys
    if(li>=0){ 
        if(li<ciGlwdefn){  //>ciGlwdefn ignore keys
            if(li==8 || li==12) gaGlwv=llListReplaceList(gaGlwv,[(integer)((float)lsValue*10)],li,li);     //wave height || current speed
            else{
                liType=llGetListEntryType(gaGlwdefv,li);
                if(liType==TYPE_INTEGER) gaGlwv=llListReplaceList(gaGlwv,[(integer)lsValue],li,li);
                else if(liType==TYPE_STRING) gaGlwv=llListReplaceList(gaGlwv,[lsValue],li,li);
                else if(liType==TYPE_FLOAT) gaGlwv=llListReplaceList(gaGlwv,[(float)lsValue],li,li);
            }
        }
    }else if(lsKeystring=="area"){     //local variation area
        integer liIdx=llSubStringIndex(lsValue,":");
        if(liIdx<5){ 
            llOwnerSay("Area without colon: "+lsValue);
            return;
        }
        string lsA=llGetSubString(lsValue,0,liIdx-1);   //Variation parameters
        integer liN=llGetListLength(llCSV2List(lsA));   //number of variation parameters
        if(liN>=8){ 
            if(llGetSubString(lsValue,-1,-1)==":"){  //If the colon is at the end of the line, it is bad.
                llOwnerSay("Poorly built area: "+lsA);
            }else{
                if(gsGlwAreas!="") gsGlwAreas+="$$";
                list laT=llCSV2List(llGetSubString(lsValue,liIdx+1,-1));
                gsGlwAreas+=lsA+":"+llDumpList2String(laT,",");
                //gsGlwAreas+=lsA+":"+llGetSubString(lsValue,liIdx+1,-1);
            }
        }else llOwnerSay("Poorly built area: "+lsA);
    }else if(lsKeystring=="circle"){     //local variation circle 
        integer liIdx=llSubStringIndex(lsValue,":");
        if(liIdx<5){ 
            llOwnerSay("Circle without colon: "+lsValue);
            return;
        }
        string lsA=llGetSubString(lsValue,0,liIdx-1);
        integer liN=llGetListLength(llCSV2List(lsA));
        if(liN>=9){ 
            if(llGetSubString(lsValue,-1,-1)==":"){ 
                llOwnerSay("Poorly built circle: "+lsA);
            }else{
                if(gsGlwCircles!="") gsGlwCircles+="$$";
                list laT=llCSV2List(llGetSubString(lsValue,liIdx+1,-1));
                gsGlwCircles+=lsA+":"+llDumpList2String(laT,",");
                //gsGlwCircles+=lsA+":"+llGetSubString(lsValue,liIdx+1,-1);
            }
        }else llOwnerSay("Poorly built circle: "+lsA);
    }else{ 
        llSay(0, "GLW Note: Unknown keyword: \""+lsKeystring+"\""); 
    }
}

verifyNote()
{
    verifyglw();
    setDisplays(gsCurrentName);
    //fSay(gkTarget,"The "+gsCurrentName+" notecard has been loaded");
}

verifyglw() 
{
//list caGlwdefc="0-wind dir","1-wind speed","2-wind gusts","3-wind shifts","4-wind period","5-wave speed","6-wave height variance","7-wave length variance","8-wave height","9-wave length","10-wave effects","11-current dir","12-current speed","13-sail mode","14-name","15-extra1","16-extra2","17-waterdepth","18-update pos","19-system mode"
    integer type;
    integer i;
    integer vn;
    float vf;
    string vs;
    integer n;
    float f;
    string s;
    for(i=0;i<ciGlwdefn;i++){ 
        type=llGetListEntryType(gaGlwdefv,i);
        if(type==TYPE_INTEGER){ 
            vn=llList2Integer(gaGlwv,i);
            n=vn;
        }else if(type==TYPE_STRING){ 
            vs=llList2String(gaGlwv,i);
            s=vs;
        }else if(type==TYPE_FLOAT){ 
            vf=llList2Float(gaGlwv,i);
            f=vf;
        }
        if(i==0 || i==11){  //wind, current dir
            if(vn<0 && vn>359) n=0;
        }else if(i==1){  //speed
            if(vn<5) n=5;
            else if(vn>30) n=30;
        }else if(i==2 || i==6 || i==7){ //gusts and variances
            if(vn<0) n=0;
            else if(vn>100) n=100;
        }else if(i==3){ //shifts
            if(vn<0) n=0;
            else if(vn>180) n=180;
        }else if(i==4){  //period
            if(vn<30) n=30;
            else if(vn>120) n=120;
        }else if(i==5){ //wave speed
            if(vn<3) n=3;
            else if(vn>15) n=15;
        }else if(i==8){  //wave height
            if(vn<0) n=0;
            else if(vn>50) n=50;
        }else if(i==9){ //wave length
            if(vn<10) n=10;
            else if(vn>100) n=100;
        }else if(i==10){ //wave effects
            if(vn>3) n=3;
        }else if(i==12){ //current speed
            if(vn<0) n=0;
            else if(vn>60) n=60;
        //}else if(i==24){  //race speed
        //    if(vf<1.0) f=1.0;
        //    else if(f>2.0) f=2.0;
        }else if(i==13){  //race mode
            if(vn<0 || vn>3) n=0; 
        }else if(i>=14 && i<=16){  //name,extra1,extra2
            s=(string)llCSV2List(vs);  // cleaned up string (no commas)
        }else if(i==17){  //water depth
            if(vn!=0 && vn!=-1 && (vn<5 || vn>15)) n=10; 
        }else if(i==18){  //update pos
            if(vn!=0 && (vn<5 || vn>60)) n=60; 
        }
        if(type==TYPE_INTEGER && n!=vn) gaGlwv=llListReplaceList(gaGlwv,[n],i,i);
        else if(type==TYPE_STRING && s!=vs) gaGlwv=llListReplaceList(gaGlwv,[s],i,i);
        else if(type==TYPE_FLOAT && f!=vf) gaGlwv=llListReplaceList(gaGlwv,[f],i,i);
    }    
}

integer realAngle2LslAngle(integer realAngle) {
    integer lslAngle= (realAngle-90)*-1;
    while(lslAngle>=360) lslAngle-=360;
    while(lslAngle<0) lslAngle+=360;
    return lslAngle;
}

fSay(key k, string p)
{
    llOwnerSay(p);
}

string pad(integer num, integer len)
{
    return(llGetSubString(llGetSubString("000",0,len-1)+(string)num,-len,-1));    
}

string formfloat(string ps)
{
    integer n=llStringLength(ps)-1;
    integer i;
    for(i=n;i>0;i--){
        if(llGetSubString(ps,i,i)!="0"){
            if(llGetSubString(ps,i,i)==".") ps=llGetSubString(ps,0,i+1); 
            else ps=llGetSubString(ps,0,i);
            i=0;
        }
    }
    return(ps);
}

fPrint(string psData, key pk) 
{
    list la=llCSV2List(psData);
    integer n;
    integer i;
    string s;
    float lf;
    n=llGetListLength(la)-1;
    fSay(pk," ");
    fSay(pk,"GLW Base Parameters");
    for(i=0;i<n;i++){
        if(llGetListEntryType(gaGlwdefv,i)==TYPE_FLOAT) s=formfloat(llList2String(la,i));
        else if(i==8 || i==12){ 
            lf=(float)llList2String(la,i)/10;
            if(lf<10) s=llGetSubString((string)lf,0,2);
            else s=llGetSubString((string)lf,0,3);
        }else s=llList2String(la,i);
        if(s!="" || i==14 || i==15 || i==16){ 
            fSay(pk,llList2String(caGlwdefc,i)+"="+s);  //print button 
        }
    }
}

//psData=baseWindData+"##"+VarAreasItems+"##"+VarAreasWind+"##"+VarCircleItems+"##"+VarCircleWind
fWrite(string psData, key pk) 
{
    //llOwnerSay("Aux fwrite "+psData);
    list laData=llParseStringKeepNulls(psData,["##"],[]);
    list laWork=llCSV2List(llList2String(laData,0));   //baseWindData
    integer liN;
    integer li;
    string ls;
    float lf;
    string note;
    liN=llGetListLength(laWork)-1;
    fSay(pk," ");
    fSay(pk,"GLW Base Parameters");
    for(li=0;li<liN;li++){
        if(llGetListEntryType(gaGlwdefv,li)==TYPE_FLOAT) ls=formfloat(llList2String(laWork,li));
        else if(li==8 || li==12){ 
            lf=(float)llList2String(laWork,li)/10;
            if(lf<10) ls=llGetSubString((string)lf,0,2);
            else ls=llGetSubString((string)lf,0,3);
        }else ls=llList2String(laWork,li);
        if(ls!="" || li==14 || li==15 || li==16){ 
            ls=llList2String(caGlwdefc,li)+"="+ls+"\n";
            if(llStringLength(note+ls)>1000){ 
                fSay(pk,"\n"+note);
                note="";
            }
            note+=ls;
        }
    }
    list laItems=llParseString2List(llList2String(laData,1),["$$"],[]);
    list laWinds;
    integer noteLen;
    liN=llGetListLength(laItems);
    if(liN>0){
        laWinds=llParseString2List(llList2String(laData,2),["$$"],[]);
        for(li=0;li<liN;li++){
            ls="\narea="+llList2String(laItems,li)+":"+llList2String(laWinds,li);
            if(noteLen+llStringLength(ls)>1000){ 
                fSay(pk,"\n"+note);
                note="";
                noteLen=0;
            }
            note+=ls;
            noteLen+=llStringLength(ls);
        }
    }
    laItems=llParseString2List(llList2String(laData,3),["$$"],[]);
    liN=llGetListLength(laItems);
    noteLen=0;
    if(liN>0){
        laWinds=llParseString2List(llList2String(laData,4),["$$"],[]);
        for(li=0;li<liN;li++){
            ls="\ncircle="+llList2String(laItems,li)+":"+llList2String(laWinds,li);
            if(noteLen+llStringLength(ls)>1000){ 
                fSay(pk,"\n"+note);
                note="";
                noteLen=0;
            }
            note+=ls;
            noteLen+=llStringLength(ls);
        }
    }
    fSay(pk,"\n"+note);
}

//gaGlwv=["wind dir","wind speed","wind gusts","wind shifts","wind period","wave speed","wave height variance","wave length variance","wave height","wave length","wave effects","current dir","current speed","sail mode","name","extra1","extra2","water depth","update pos","system mode",
fStart(key pkTarget)  //start wind from GLW script
{
    if(giGlwEventNum<=0) giGlwEventNum=1000+(integer)llFrand(9000);
    gkGlwDirectorKey=pkTarget;
    gsGlwDirectorName=llKey2Name(gkGlwDirectorKey);
    
    giStarted=1;
    llMessageLinked(LINK_THIS, 1200, "", "");    //init event
    llMessageLinked(LINK_THIS, 1201, gsServer, "");  //send server url to setter script
    //llMessageLinked(LINK_THIS, 1202, llList2CSV(gaGlwv), gsGlwAreas+"##"+gsGlwCircles);  //send data event to GLW Setter  
    llMessageLinked(LINK_THIS, 1202, llDumpList2String(gaGlwv,","),gsGlwAreas+"##"+gsGlwCircles);  //send data event to GLW Setter  
    llMessageLinked(LINK_THIS, 1203, (string)giInterval+","+(string)giIntervalMsg+","+(string)giDirectorMsg+","+(string)giPeriod,"");  //send data controls 
    llMessageLinked(LINK_THIS, 1211, (string)giGlwEventNum, (string)gkGlwDirectorKey+","+gsGlwDirectorName);  //start event
    //llOwnerSay(llDumpList2String(gaGlwv,",")+"##"+gsGlwAreas+"##"+gsGlwCircles);
}

//psData=["wind dir","wind speed","wind gusts","wind shifts","wind period","wave speed","wave height variance","wave length variance","wave height","wave length","wave effects","current dir","current speed","sail mode","name","extra1","extra2","water depth","update pos","system mode"##Vars Areas##Vars Circles
fModif(string psData, key pkTarget)  //modif wind from GLW script
{
    list laData=llParseStringKeepNulls(psData,["##"],[]);
    string laOldData=llDumpList2String(gaGlwv,",");
    integer liMod;  //0-no modifications    1-modifications
    string lsControl;   //XYZ  X-winddata  Y-Area Vars   Z-Circles Vars    value=0-no modified  1-modified
    string lsSend;
    if(llList2String(laData,0)!=laOldData){
        liMod=1;
        gaGlwv=llCSV2List(llList2String(laData,0));
        lsControl="1";
    }else{
        lsControl="0";
    }
    lsSend=llList2String(laData,0);
    /*
    integer liI;
    integer liM;
    for(liI=0;liI<ciGlwdefn;liI++){
        if(llList2String(laOldData,liI)!=llList2String(gaGlwv,liI)){ 
            liMod=1;   //check for differences
            liI=ciGlwdefn;
            gaGlwv=laOldData;
        }
    }
    laOldData=[];
    */
    if(llList2String(laData,1)!=gsGlwAreas){
        liMod=1;
        gsGlwAreas=llList2String(laData,1);
        lsControl+="1";
        lsSend+="##"+gsGlwAreas;
    }else{
        lsControl+="0";    
        lsSend+="##";    
    }
    if(llList2String(laData,2)!=gsGlwCircles){
        liMod=1;
        gsGlwCircles=llList2String(laData,2);
        lsControl+="1";
        lsSend+="##"+gsGlwCircles;
    }else{
        lsControl+="0";        
        lsSend+="##";
    }
    if(liMod){ //ther are modifications
        lsSend=lsControl+"##"+lsSend;
        //llOwnerSay("Aux "+lsSend);
        llMessageLinked(LINK_THIS, 1216,lsSend,pkTarget);  //send data event to GLW Setter  
    }else{ 
        llOwnerSay("No modifications");
    }
}

fCast(string psData, string psData2)  //Cast wind from GLW script
{
    list laL=llCSV2List(psData);
    integer liI;
    integer liMod;
    for(liI=0;liI<ciGlwdefn;liI++){
        if(liI!=17){   //water depth
            if(llList2String(laL,liI)!=llList2String(gaGlwv,liI)){ 
                llOwnerSay(llList2String(caGlwdefc,liI)+" has been modified");
                liMod=1;   //check for differences
                liI=ciGlwdefn;
            }
        }
    }
    if(!liMod){ 
        llMessageLinked(LINK_THIS, 1213,llGetSubString(psData2,0,2),(key)llGetSubString(psData2,3,-1)); //start shoutcast
        llSetLinkPrimitiveParamsFast(1,[PRIM_COLOR,3,<0,1,0>,1.0]);
        llMessageLinked(LINK_THIS, 4001, "cast", "");  //notify the menu script that the cast button is on
        llMessageLinked(LINK_THIS, 2001, "cast", "");  //notify the GLW script that the cast button is on
        llMessageLinked(LINK_THIS, 6001, "cast", "");  //notify the vars menu script that the cast button is on
    }else{ 
        llOwnerSay("There are changes in the data. You have to send the data first. Press the Send button.");
    }
}

restPanel(integer piPanel, key pkTarget)
{
    list laData;
    if(piPanel==1) laData=llList2List(gaGlwv,0,4);
    else if(piPanel==2) laData=llList2List(gaGlwv,5,10);
    else if(piPanel==3) laData=llList2List(gaGlwv,11,12);
    else if(piPanel==4) laData=llList2List(gaGlwv,13,20);
    llMessageLinked(LINK_THIS, 2000+piPanel, "dispNote", llDumpList2String(laData,","));    
}

loadDefault()
{
    gaGlwv=gaGlwdefv;
    llMessageLinked(LINK_THIS, 2000, "dispNote", llDumpList2String(gaGlwv,",")+",");
}

fStop(key pkTarget)
{
    giStarted=0;                
    llSetTimerEvent(0);
    gkGlwDirectorKey="";
    gsGlwDirectorName="";
    giGlwEventNum=0;
    llMessageLinked(LINK_THIS, 1210, "", NULL_KEY);  //stop event 
    llSay(0,"the current event is stopped");              
}

setDisplays(string ps)
{
    llMessageLinked(LINK_THIS, 2000, "dispNote", llDumpList2String(gaGlwv,",")+","+ps+"##"+gsGlwAreas+"##"+gsGlwCircles);
}

default 
{
    state_entry()
    {
        swdbg=(integer)llLinksetDataRead("ISDsetini");
        gaAdmins+=(string)llGetOwner();
        giSwInitData=0;
        readfirstNCLine(1,csNOTESETTINGS);  //load settings notecard
    }

    link_message(integer sender_num, integer piNum, string psStr, key pkId)
    {
        if(piNum>=3000 && piNum<4000){
            if(piNum==3010) fStop(pkId);
            else if(piNum==3011){    //start event
                list la=llParseStringKeepNulls(psStr,["##"],[]);
                gaGlwv=llCSV2List(llList2String(la,0));
                gsGlwAreas=llList2String(la,1);
                gsGlwCircles=llList2String(la,2);
                la=[];
                fStart(pkId);
            }else if(piNum==3012) fPrint(psStr,pkId);  //print button
            else if(piNum==3014){ 
                if(giStarted) llMessageLinked(LINK_THIS, 1212,"",pkId);  //stop cast
            }else if(piNum==3015){
                if(giStarted) fCast(psStr,pkId);   //init cast
            }else if(piNum==3001 && giLoadNote==0){  //load note
                if(giStarted) fSay(pkId,"You can't charge a notecard while at an event");
                else{
                    if((key)pkId){ 
                        gkTarget=pkId;
                        fSay(gkTarget,"Loading "+psStr);
                    }else gkTarget=NULL_KEY;
                    gaGlwv=gaGlwdefv;  //load the list with the default values
                    gsGlwAreas="";
                    gsGlwCircles="";
                    readfirstNCLine(3,psStr);
                }
            }else if(piNum==3002 && giLoadNote==0){  //load default
                if(giStarted) fSay(pkId,"Cannot load default values ​​when an event is started");
                else loadDefault();
            }else if(piNum==3003 && giLoadNote==0){  //panel restore
                if(giStarted) restPanel((integer)psStr,pkId);
                else fSay(pkId,"You can only restore the last data sent in an event.");
            }else if(piNum==3016){ 
                fModif(psStr,pkId);  //modif data. send button
            }else if(piNum==3017){ 
                giSwInitData++;
                if(giSwInitData==2) setDisplays("");
            }else if(piNum==3018){  //write note
                fWrite(psStr,pkId);
            }else if(psStr=="recovery"){
                list la=llCSV2List(pkId);
                giGlwEventNum=(integer)llList2String(la,0);;
                gkGlwDirectorKey=(key)llList2String(la,2);
                gsGlwDirectorName=llList2String(la,3);
                
                gaGlwv=gaGlwdefv;
                gsGlwAreas="";
                gsGlwCircles="";
            }
        }
    }    
    
    dataserver( key queryid, string data ) 
    {
        if(queryid==gkRequestInFlight){
            if(data==EOF){
                if(giLoadNote==3){  //loading wind notecard
                    giLoadNote=0;
                    verifyNote();
                }else{             //loading settings and template
                    gkRequestInFlight=NULL_KEY;
                    if(giLoadNote==1){ //has loaded settings
                        string lsAdmins=llList2CSV(gaAdmins);
                        llMessageLinked(LINK_THIS, 4000, "admins",lsAdmins);   //send admins list to Menu script
                        llMessageLinked(LINK_THIS, 6000, "admins",lsAdmins);   //send admins list to Var Menu script
                        readfirstNCLine(2,csNOTEGLWTEMP);    //load glw template
                    }else{  //has loaded template
                        init();  //initial values
                    }
                }
            }else{
                readNextNCLine(data);
            }
        }
    }
}















