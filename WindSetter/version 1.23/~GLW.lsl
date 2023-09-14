//Variables protocol
//xyVariable  xy=variable type  Variable=variable name
//Variable type xy
//x: g-global l-local c-constant p-parameter
//y: s-string i-integer f-float v-vector r-rotation a-array/list
//Variable
//The variable starts in uppercase
//Constants "c" are in uppercase 
//
integer swdbg=0;
//==>Constant values
vector cvPOSTEXTG=<-0.01061, -0.01025, 0.06739>;    //<-0.01061, -0.01025, 0.05591>;  //big hud position text
vector cvPOSTEXTS=<-0.01061, -0.01025, 0.04>;   //small hud position text
vector cvPOSTEXTA=<-0.01061, -0.01025, 0.239>;   //no attached positon text
vector tamdef=<0.015,0.3086,0.385>;
vector cvLOCKCOLOR=<1.0,0.345,0.345>;
vector cvEDITCOLOR=<0.314,1.0,0.314>;
vector notecolor=<0.83,0.8,0.514>;

//==>Textures Id
key ckTEXNUMBERS="8f049f1e-8604-5f33-03a0-edf5023982ce";
key ckTEXEFFECTS="3390e7a0-f47f-707a-34ae-a86ba3ff0b89"; 

//==>Links Numbers
integer giROOT=1;
integer giPANELBASE;
integer giPANELCURRENT;
integer giPANELWAVES;
integer giPANELOTHER;
integer giPANELAREA;
integer giPANELCIRCLE;
integer giICON;
integer giTEXT;

//==>global variables
//General vars
integer giCast;
integer giStart;
integer giEvent;
integer giDialogChannel; 
integer giInputChannel; 
integer giSayMode0=1; //1-llShout
integer giSayMode1; //1-llRegionSay
integer giSayMode2; //1-llWhisper
key gkTarget;  //Race Director
key gkClicTarget; 
//fields work vars
integer giPanel=1; //number of panel 1-base 2-wav&cur
integer giField; //field of panel
integer giValor; //field actual value
integer giValorv; //field old value
string gsValor;
//work vars
vector gvHudPos;
integer giLastHudSize;  //0-icon  1-small  2-big
string racemsg;
vector gtam;
vector gpos;
integer icono;
integer listenHandle;
integer listenHandle2;
//config notecards Menu vars
integer giTmap;  //Total notecards number
integer giTpag;  //Total Menu pags number
integer giNmap;   //Actual menu pag number
//
string gsNoteName;  //Note Name
integer timerMenu=-1;

vector sizeDef=<0.01,0.18082,0.22602>;
vector posDef=<0.00000, -0.09267, -0.17838>;

//Base Panel object vars
integer giWndDirection;
integer giWndSpeed;
integer giWndGusts;
integer giWndShift;
integer giWndPeriod;
//Waves Panel object vars
integer giWavHeight;  //*10
integer giWavSpeed;
integer giWavLength;
integer giWavVarHeight;
integer giWavVarLength;
integer giWavSpeedEffects=1;
integer giWavSteerEffects=1;
//Currents Panel object vars
integer giCurSpeed;      //*10
integer giCurDirection;
//Others Panel object vars;
integer giGenSailMode;
string gsGenExtra1;
string gsGenExtra2;
string gsGenName;
string gsGenKey;
integer giGenWaterDepth;
integer giGenUpdBoatPos;

//others values
string gsGenEventType;   //extra data for event (type wave type currents. not use. always "" 
key gkOwner;

string gsVarAreas;  
string gsVarAreasItems;  
string gsVarAreasWind;  
string gsVarCircles;
string gsVarCirclesItems;  
string gsVarCirclesWind;  


//==>General Functions 
getLinkNums() 
{
    integer i;
    integer linkcount=llGetNumberOfPrims();
    string str;
    for (i=1;i<=linkcount;++i) {
        str=llGetLinkName(i);
        if (str=="panelbase") giPANELBASE=i;
        else if (str=="panelwaves") giPANELWAVES=i;
        else if (str=="panelcurrent") giPANELCURRENT=i;
        else if (str=="panelother") giPANELOTHER=i;
        else if (str=="panelarea") giPANELAREA=i;
        else if (str=="panelcircle") giPANELCIRCLE=i;
        else if (str=="icon") giICON=i;
        else if (str=="text") giTEXT=i;
    }
}

sendCast(key pkTarget)
{
    if(giStart){   //the event is initiate
        if(giCast){  //is broadcast ==> stop
            llSetLinkPrimitiveParamsFast(giROOT,[PRIM_COLOR,3,<1,1,1>,1.0]);
            llMessageLinked(LINK_THIS,3014,"",pkTarget);   //stop cast
            llMessageLinked(LINK_THIS, 4000, "cast", "");  //notify the menu script that the cast button is off
            llMessageLinked(LINK_THIS, 6000, "cast", "");  //notify the vars menu script that the cast button is off
            giCast=0;
        }else if(giEvent){  //Event exist, broadcast is stop  ==> start broadcast
            llMessageLinked(LINK_THIS,3015,sendData(0),(string)giSayMode0+(string)giSayMode1+(string)giSayMode2+(string)pkTarget);   //start cast
        }else{
            fsay(pkTarget,"No event has been created, you cannot broadcast");
        }
    }else{ 
        fsay(pkTarget,"You have to start the event");
    }
}


inicio()
{
    llMessageLinked(LINK_THIS, 4000, "inicio", "");  //to Menu script
    llMessageLinked(LINK_THIS, 3017, "", "");  //to Aux script load default data
    giLastHudSize=2;
    giSayMode0=1;
    giSayMode1=0;
    giSayMode2=0;
    giPanel=1;
    resetValues();
}

integer isCast()
{
    if(giCast){
        return 1;
    }else return 0;
}

displayText(integer piMode)
{
    if(piMode==1){
        if(llGetAttached()==0){
            string lsTex="NAME: "+gsGenName+"\nKEY: "+gsGenKey+"\nEXTRA1: "+gsGenExtra1+"\nEXTRA2: "+gsGenExtra2+"\n";
            llSetLinkPrimitiveParamsFast(giTEXT, [PRIM_TEXT, lsTex, <1.0,1.0,0.0>, 1.0,PRIM_POS_LOCAL,cvPOSTEXTA]);
        }else if(giLastHudSize==2){
            string lsTex="NAME: "+gsGenName+"\nKEY: "+gsGenKey+"\nEXTRA1: "+gsGenExtra1+"\nEXTRA2: "+gsGenExtra2+"\n";
            llSetLinkPrimitiveParamsFast(giTEXT, [PRIM_TEXT, lsTex, <0.10,0.10,0.10>, 1.0,PRIM_POS_LOCAL,cvPOSTEXTG]);
        }else if(giLastHudSize==1){
            string lsTex="NAME: "+gsGenName+"\nKEY: "+gsGenKey+"\nEXTRA1: "+gsGenExtra1+"\nEXTRA2: "+gsGenExtra2+"\n";
            llSetLinkPrimitiveParamsFast(giTEXT, [PRIM_TEXT, lsTex, <0.10,0.10,0.10>, 1.0,PRIM_POS_LOCAL,cvPOSTEXTS]);
        }else{
            llSetLinkPrimitiveParamsFast(giTEXT, [PRIM_TEXT, "", <0.10,0.10,0.10>, 0.0]);
        }
    }else{
        llSetLinkPrimitiveParamsFast(giTEXT, [PRIM_TEXT, "", <0.10,0.10,0.10>, 0.0]);
    }
}

setTouch0(integer piFace, integer piElement, key pkTarget)  //touch on panel 0 root prim
{
    if(piFace==0){   //background
        putvalor();
        if(piElement==2){  // Send button
            if(giStart){   //event is initiate
                if(giEvent){  //event number>0
                    llMessageLinked(LINK_THIS, 5001, "rdata", "2935"); //read data variations for send modif. Return 2935 number
                }else{
                    fsay(pkTarget,"No event has been created, you cannot send modifications");
                }
            }else{
                fsay(pkTarget,"There is no event registered, press Start Button");
            }    
        }else if(piElement==3) {}   // default button
        else if(piElement==4){   // scan button
            if(!giStart) llOwnerSay("You can't scan ships if you're not in an event");
            else llMessageLinked(LINK_THIS, 1900, "scan", "");  //to GLW setter script
        }else if(piElement==5) {   //finish button
            if(giStart) fstop(gkTarget);
        }else if(piElement==6) llMessageLinked(LINK_THIS,3012,sendData(0),pkTarget);   //print button
    }else if(piFace==1){   //tabs, panel=piElement
        putvalor();  //save the last editing field
        giPanel=piElement;
        resetValues();  //reset editing fiels variables
        if(piElement==4){   //tab4
            displayText(1);
        }
    }else if(piFace==2){   //start button
        putvalor();
        gkTarget=pkTarget;
        if(giStart==0){
            if(gsGenKey!=""){
                llMessageLinked(LINK_THIS, 1225, gsGenKey, pkTarget);
            }else{
                llMessageLinked(LINK_THIS, 5001, "rdata", "2931"); //read data variations for start  receive 2931 number
            }
        }else{
            fsay(pkTarget,"Press the Finish button to close the event");
        }
    }else if(piFace==3){   //cast button
        putvalor();
        sendCast(pkTarget);
    }else if(piFace>3){  //sim, shout, whisper
        if(!piElement){
            giSayMode0=giSayMode1=giSayMode2=0;
            llSetLinkPrimitiveParamsFast(giROOT,[PRIM_COLOR,4,<1,1,1>,1.0,PRIM_COLOR,5,<1,1,1>,1.0,PRIM_COLOR,6,<1,1,1>,1.0]);
        }
        if(piFace==4){   //say sim
            giSayMode1=1;
            llSetLinkPrimitiveParamsFast(giROOT,[PRIM_COLOR,4,<0,1,0>,1.0]);
        }else if(piFace==5){  //shout
            giSayMode0=1;
            llSetLinkPrimitiveParamsFast(giROOT,[PRIM_COLOR,5,<0,1,0>,1.0]);
        }else if(piFace==6){  //whisper
            giSayMode2=1;
            llSetLinkPrimitiveParamsFast(giROOT,[PRIM_COLOR,6,<0,1,0>,1.0]);
        }  
        if(giCast) llMessageLinked(LINK_THIS,1214,(string)giSayMode0+(string)giSayMode1+(string)giSayMode2,"");  //glw setter    
    }
}

setTouch1(integer piFace)   //touch on panel 1 base
{
    putvalor();
    giField=piFace;
    putColor(1);
    llSetLinkPrimitiveParamsFast(giPANELBASE,[PRIM_COLOR,piFace,<0,1,0>,1.0]);
    if(giField==1) giValorv=giWndDirection;
    else if(giField==2) giValorv=giWndSpeed;
    else if(giField==3) giValorv=giWndGusts;
    else if(giField==4) giValorv=giWndShift;
    else if(giField==5) giValorv=giWndPeriod;
    giValor=-1;
}

setField1(string psData, integer piField) //Fields panel base 1
{
    if(piField==1){                    
        giWndDirection=(integer)psData;
        putnum(1,1,giWndDirection);
    }else if(piField==2){
        giWndSpeed=(integer)psData;
        putnum(1,2,giWndSpeed);
    }else if(piField==3){
        giWndGusts=(integer)psData;
        putnum(1,3,giWndGusts);
    }else if(piField==4){
        giWndShift=(integer)psData;
        putnum(1,4,giWndShift);
    }else if(piField==5){
        giWndPeriod=(integer)psData;
        putnum(1,5,giWndPeriod);
    }
    putColor(1);
    resetValues();
}

setTouch2(integer piFace)   //touch on panel 2 Waves
{
    putvalor();
    giField=piFace;
    putColor(2);
    llSetLinkPrimitiveParamsFast(giPANELWAVES,[PRIM_COLOR,piFace,<0,1,0>,1.0]);
    if(giField==1) giValorv=giWavHeight;
    else if(giField==2) giValorv=giWavSpeed;
    else if(giField==3) giValorv=giWavLength;
    else if(giField==4) giValorv=giWavVarHeight;
    else if(giField==5) giValorv=giWavVarLength;
    giValor=-1;
}

setField2(string psData, integer piField) //Fields panel base 1
{
    if(piField==1){                    
        giWavHeight=(integer)psData;
        putnum(2,1,giWavHeight);
    }else if(piField==2){
        giWavSpeed=(integer)psData;
        putnum(2,2,giWavSpeed);
    }else if(piField==3){
        giWavLength=(integer)psData;
        putnum(2,3,giWavLength);
    }else if(piField==4){
        giWavVarHeight=(integer)psData;
        putnum(2,4,giWavVarHeight);
    }else if(piField==5){
        giWavVarLength=(integer)psData;
        putnum(2,5,giWavVarLength);
    }else if(piField==6){
        if(psData=="0") giWavSteerEffects=!giWavSteerEffects;
        else giWavSpeedEffects=!giWavSpeedEffects; 
        putnum(2,6,giWavSteerEffects*1+giWavSpeedEffects*2);
    }
    putColor(2);
    resetValues();
}

setTouch3(integer piField)   //touch on panel 3 currents 
{
    putvalor();
    giField=piField;
    putColor(2);
    llSetLinkPrimitiveParamsFast(giPANELCURRENT,[PRIM_COLOR,piField,<0,1,0>,1.0]);
    if(giField==1) giValorv=giCurSpeed;
    else if(giField==2) giValorv=giCurDirection;
    giValor=-1;
}

setField3(string psData, integer piField) //Fields panel currents
{
    if(piField==1){                    
        giCurSpeed=(integer)psData;
        putnum(3,1,giCurSpeed);
    }else if(piField==2){
        giCurDirection=(integer)psData;
        putnum(3,2,giCurDirection);
    }
    putColor(3);
    resetValues();
}

setField4(string psData, integer piField)  //fields panel 4 Others
{
    if(piField<10){
        if(piField==1){    //depth                
            giGenWaterDepth=(integer)psData;
            putnum(4,1,giGenWaterDepth);
        }else if(piField==2){  //sail mode
            giGenSailMode=(integer)psData;
            putnum(4,2,giGenSailMode);
        }else if(piField==3){  //update pos
            giGenUpdBoatPos=(integer)psData;
            putnum(4,3,giGenUpdBoatPos);
        }
    }else if(piField==10){
        giGenWaterDepth=(integer)psData;
        putnum(4,1,giGenWaterDepth);
    }else{
        if(piField==11) gsGenName=psData;
        else if(piField==12) gsGenExtra1=psData;
        else if(piField==13) gsGenExtra2=psData;
        else if(piField==14) gsGenKey=psData;
        putnum(4,0,0);
    }
}

putkey(key pkTarget, integer piNumKey)
{
    //use giPanel, giField, giValor, giValorv
    //llOwnerSay((string)giPanel+"  "+(string)giField+"   "+(string)giValor);
    if(giField==0){ 
        fsay(pkTarget, "You have not selected any field");
        return;
    }
    integer liNum;
    if(piNumKey<0){  //del, esc, enter
        if(piNumKey==-2){  //esc
            liNum=-1;
            llSetLinkPrimitiveParamsFast(giROOT,[PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            if(giValorv>=0) putnum(giPanel,giField,giValorv);
            resetValues();
            putColor(giPanel);
        }else if(piNumKey==-1){ //del
            if(giValor==-1) liNum=giValorv;
            else liNum=giValor;
            if(liNum<10) liNum=0;
            else liNum=(integer)(liNum/10);
        }else if(piNumKey==-3){ //enter
            liNum=-1;
            if(giValor>=0){
                putvalor();
            }
            resetValues();
            putColor(giPanel);
        }
    }else{   //clic number key
        if(giValor==0 || giValor==-1) liNum=piNumKey;
        else{ 
            liNum=(integer)((string)giValor+(string)piNumKey);
            if(liNum>359) liNum=-1;
        }
        //liNum=verifyField(pkTarget, giPanel, giField, liNum);
    }
    if(liNum>=0){ 
        giValor=liNum;
        putnum(giPanel,giField,giValor);
    }
    //output giField, giValor, giValorv
}
/*
integer verifyField(key pkTarget, integer piPanel, integer piField, integer piNum)
{
    if(piPanel==1){
        if(piField==1){
            if(piNum==360) piNum=0;
            else if(piNum>360){ 
                fsay(pkTarget, "Direction can not exceed 360");
                piNum=-1;
            }
        }else if(piField==2){
            if(piNum>35){ 
                fsay(pkTarget, "Speed must be between 5 and 35");    
                piNum=-1;
            }
        }else if(piField==3){
            if(piNum>100){ 
                fsay(pkTarget, "Gusts can not exceed 100");
                piNum=-1;
            }
        }else if(piField==4){
            if(piNum>180){ 
                fsay(pkTarget, "Shift can not exceed 180");
                piNum=-1;
            }
        }
    }else if(piPanel==2){
    }
    return piNum;
}
*/

putnum(integer piPanel, integer piFace, integer piData)
{
    integer liLink;
    if(piPanel==1) liLink=giPANELBASE;
    else if(piPanel==2) liLink=giPANELWAVES;
    else if(piPanel==3) liLink=giPANELCURRENT;
    else if(piPanel==4) liLink=giPANELOTHER;
    if(liLink>0){ 
        if(piPanel==4 && piFace==1 && piData==-1){  //panel others Water Depth -1 value put A
            llSetLinkPrimitiveParamsFast(liLink,[PRIM_TEXTURE,piFace,ckTEXNUMBERS,<1.0,1.0,0.0>, <0.07035*12, -0.03515*25, 0.0>, 0.0]); 
        }else if(piPanel==2 && piFace==1){ //Waves Height field 1 decimal
            if(piData<10) llSetLinkPrimitiveParamsFast(liLink,[PRIM_TEXTURE,piFace,ckTEXNUMBERS,<1.0,1.0,0.0>,<0.07035*(piData%14),-0.03515*26,0.0>,0.0]);
            else llSetLinkPrimitiveParamsFast(liLink,[PRIM_TEXTURE,piFace,ckTEXNUMBERS,<1.0,1.0,0.0>,<0.07035*(piData%14),-0.03515*(integer)(piData/14),0.0>,0.0]); 
        }else if(piPanel==2 && piFace==6){ //effects
            llSetLinkPrimitiveParamsFast(giPANELWAVES,[PRIM_TEXTURE,6,ckTEXEFFECTS,<1.0,1.0,0.0>,<piData*0.0636,0,0>,0.0]);     
        }else if(piPanel==3 && piFace==1){  //Currents speed field 1 decimal
            if(piData<10) llSetLinkPrimitiveParamsFast(liLink,[PRIM_TEXTURE,piFace,ckTEXNUMBERS,<1.0,1.0,0.0>,<0.07035*(piData%14),-0.03515*26,0.0>,0.0]);
            else llSetLinkPrimitiveParamsFast(liLink,[PRIM_TEXTURE,piFace,ckTEXNUMBERS,<1.0,1.0,0.0>,<0.07035*(piData%14),-0.03515*(integer)(piData/14),0.0>,0.0]); 
        }else if(piPanel==4 && piFace==0){  //name extra1 extra2
            displayText(1);
        }else{
            llSetLinkPrimitiveParamsFast(liLink,[PRIM_TEXTURE,piFace,ckTEXNUMBERS,<1.0,1.0,0.0>,<0.07035*(piData%14),-0.03515*(integer)(piData/14),0.0>,0.0]); 
        }
    }
}
        


fsay(key pkTarget, string tex)
{
    integer nn=llGetAttached();
    if(pkTarget){
        if(nn==0 && llGetAgentSize(pkTarget)==ZERO_VECTOR) llInstantMessage(pkTarget,tex);
        else llOwnerSay(tex);
    }else{
        if(nn==0) llSay(0,tex);
        else llOwnerSay(tex);
    }
}

putvalor() //save field value
{
    //use: giField, giValor, giValorv
    integer liNum=-1;
    if(giField>0 && giValor>=0){ 
        liNum=giValor;
        if(giPanel==1){
            if(giField==1) giWndDirection=giValor; 
            else if(giField==2) giWndSpeed=giValor;
            else if(giField==3) giWndGusts=giValor;
            else if(giField==4) giWndShift=giValor;
        }else if(giPanel==2){
            if(giField==1) giWavHeight=giValor; 
            else if(giField==2) giWavSpeed=giValor;
            else if(giField==3) giWavLength=giValor;
            else if(giField==4) giWavVarHeight=giValor;
            else if(giField==5) giWavVarLength=giValor;
        }else if(giPanel==3){
            if(giField==1) giCurSpeed=giValor;
            else if(giField==2) giCurDirection=giValor;
        }else if(giPanel==4){
            //if(giField==1) gsGenName=gsValor; 
            //else if(giField==2) gsGenExtra1=gsValor;
            //else if(giField==3) gsGenExtra2=gsValor;
            //else if(giField==4) giGenSailMode=giValor;
        }
    }else if(giField>0 && giValor=-1){
        liNum=giValorv;
    }
    if(liNum>=0){
        putnum(giPanel,giField,liNum);
        resetValues();
        putColor(giPanel);
    }    
}

resetValues()
{
    giValor=-1;
    giValorv=-1;
    giField=0;
}

string setcommand()
{
    string msgGLW="GLW sailors your wind today is "+(string)giWndDirection+"º "+(string)giWndSpeed+"kt.";
    if(giWndGusts>0) msgGLW+=" Gusts:"+(string)giWndGusts;
    if(giWndShift>0) msgGLW+=" Shift:"+(string)giWndShift;
    return (string)giWndDirection+","+(string)giWndSpeed+","+(string)giWndGusts+","+(string)giWndShift+","+msgGLW;
}

fstart()
{
    giStart=1;             //Hud is in start mode
    llSetLinkPrimitiveParamsFast(giROOT,[PRIM_COLOR,2,<0,1,0>,1.0]);
    string ls=sendData(1)+"##"+gsVarAreas+"##"+gsVarCircles;
    //llOwnerSay("GLW fstart "+ls);
    llMessageLinked(LINK_THIS,3011,ls,gkTarget);  //data to Aux
}

string sendData(integer piMode)
{
    integer liWaterDepth=giGenWaterDepth;
    if(piMode){
        if(liWaterDepth==-1){
            liWaterDepth=(integer)(llWater(ZERO_VECTOR)-llGround(ZERO_VECTOR));
            if(liWaterDepth<5) liWaterDepth=5;
        } 
    }
    string ls=(string)giWndDirection+","+(string)giWndSpeed+","+(string)giWndGusts+","+(string)giWndShift+","+(string)giWndPeriod+","+
            (string)giWavSpeed+","+(string)giWavVarHeight+","+(string)giWavVarLength+","+(string)giWavHeight+","+(string)giWavLength+","+(string)(giWavSteerEffects*1+giWavSpeedEffects*2)+","+
            (string)giCurDirection+","+(string)giCurSpeed+","+
            (string)giGenSailMode+","+gsGenName+","+gsGenKey+","+gsGenExtra1+","+gsGenExtra2+","+(string)liWaterDepth+","+(string)giGenUpdBoatPos+","+gsGenEventType;
    return ls;
}

string pad(integer num, integer len)
{
    return(llGetSubString(llGetSubString("000",0,len-1)+(string)num,-len,-1));    
}

fstop(key pkTarget)  //stop event
{
    if(timerMenu<0) llSetTimerEvent(0.0);
    llMessageLinked(LINK_THIS,3010,"stop",pkTarget); // sw=1;
    giStart=0;
    if(giCast){
        giCast=0;
        llSetLinkPrimitiveParamsFast(giROOT,[PRIM_COLOR,3,<1,1,1>,1.0]);
        llMessageLinked(LINK_THIS,3014,"",pkTarget);   //stop cast
        llMessageLinked(LINK_THIS, 4000, "cast", "");  //notify the menu script that the cast button is off
    }        
    llSetLinkPrimitiveParamsFast(giROOT,[PRIM_COLOR,2,<1,1,1>,1.0]);
    gkTarget=NULL_KEY;
}

putColor(integer piMode)
{
    if(piMode==0) llSetLinkPrimitiveParamsFast(LINK_SET,[PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
    else if(piMode==1) llSetLinkPrimitiveParamsFast(giPANELBASE,[PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
    else if(piMode==2) llSetLinkPrimitiveParamsFast(giPANELWAVES,[PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
    else if(piMode==3) llSetLinkPrimitiveParamsFast(giPANELCURRENT,[PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
    else if(piMode==4) llSetLinkPrimitiveParamsFast(giPANELOTHER,[PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
}

integer verifydata(key pkTarget)
{
    if(giWndDirection>359) giWndDirection=0;
    if(giWndSpeed<5) giWndSpeed==5;
    if(giWndSpeed>35) giWndSpeed=35;
    if(giWndGusts>100) giWndGusts=100;
    if(giWndShift>180) giWndShift=180;
    if(giWndPeriod<30) giWndPeriod=30; 
    if(giWndPeriod>120) giWndPeriod=120;
    if(giWavHeight>50) giWavHeight=50;
    if(giWavSpeed<3) giWavSpeed=3;
    if(giWavSpeed>15) giWavSpeed=15;
    if(giWavLength<10) giWavLength=10; 
    if(giWavLength>100) giWavLength=100;
    if(giWavVarHeight>100) giWavVarHeight=100;
    if(giWavVarLength>100) giWavVarLength=100;
    if(giCurSpeed>60) giCurSpeed=60;
    if(giCurDirection>359) giCurDirection=0;

    list laItems;
    list laWinds;
    integer liNItems;
    integer liN;
    integer liTotalItems;
    string lsRet;
    gsVarAreas="";
    if(gsVarAreasItems!=""){
        laItems=llParseString2List(gsVarAreasItems,["$$"],[]);  //variation data
        laWinds=llParseString2List(gsVarAreasWind,["$$"],[]);   //variation wind data
        liNItems=llGetListLength(laItems);
        liTotalItems=liNItems;
        if(liTotalItems>20){
            liTotalItems=liNItems=20;
            fsay(pkTarget,"You have exceeded the maximum number of Local Variations (20) will be truncated");
        }
        for(liN=0;liN<liNItems;liN++){
            lsRet=verifydataVar(1,llList2String(laItems,liN),llList2String(laWinds,liN));  //verify Area item
            if(lsRet!=""){
                if(gsVarAreas!="") gsVarAreas+="$$"+lsRet;
                else gsVarAreas+=lsRet;
            }
        }
    }
    gsVarAreasItems=""; //are no longer needed free memory
    gsVarAreasWind=""; //are no longer needed free memory
    gsVarCircles="";
    if(gsVarCirclesItems!=""){
        laItems=llParseString2List(gsVarCirclesItems,["$$"],[]);
        laWinds=llParseString2List(gsVarCirclesWind,["$$"],[]);
        liNItems=llGetListLength(laItems);
        liTotalItems+=liNItems;
        if(liTotalItems>20){
            liNItems=20-(liTotalItems-liNItems);
            liTotalItems=20;
            fsay(pkTarget,"You have exceeded the maximum number of Local Variations (20) will be truncated.");
        }
        for(liN=0;liN<liNItems;liN++){
            lsRet=verifydataVar(2,llList2String(laItems,liN),llList2String(laWinds,liN));  //verify circle item
            if(lsRet!=""){
                if(gsVarCircles!="") gsVarCircles+="$$"+lsRet;
                else gsVarCircles+=lsRet;
            }
        }
    }
    gsVarCirclesItems=""; //are no longer needed free memory
    gsVarCirclesWind="";  //are no longer needed free memory
    return 0;
}

string verifydataVar(integer piType, string psDataI, string psDataW) //verify the item area and circle
{
    list laDataI=llCSV2List(psDataI);  //item data list
    string lsNItem=llList2String(laDataI,0);  //item number
    integer sw=1;
    if(piType==1){  //area active,sim1,cornerx,cornery,sim2,cornerx,cornery,margin
        if(llList2String(laDataI,1)=="");   //sim SW name
        else if(llList2String(laDataI,2)==""); //corner position x
        else if(llList2String(laDataI,3)==""); //corner position y
        else if(llList2String(laDataI,4)==""); //sim NE name
        else if(llList2String(laDataI,5)==""); //corner position x
        else if(llList2String(laDataI,6)==""); //corner position y
        else if((llAbs(llList2Integer(laDataI,5)/256-llList2Integer(laDataI,2)/256)+1)*(llAbs(llList2Integer(laDataI,6)/256-llList2Integer(laDataI,3)/256)+1)>100) sw=2;
        else sw=0;
    }else{   //circle active,sim1,globalx,globaly,sim2,globalx,globaly,radius,margin
        if(llList2String(laDataI,1)=="");   //sim center name
        else if(llList2String(laDataI,2)==""); //global position x
        else if(llList2String(laDataI,3)==""); //global position y
        else if(llList2String(laDataI,7)==""); //radius
        else if(llList2String(laDataI,8)==""); //margin
        else if(llList2Integer(laDataI,7)<30 || llList2Integer(laDataI,7)>1000) sw=3;
        else sw=0;
    }
    if(sw>0){ 
        string lsText;
        if(sw==2) lsText="The Area Item number "+lsNItem+" has exceeded 100 sims";
        else if(sw==3) lsText="The Circle Item number "+lsNItem+" has wrong radius";
        else if(piType==1) lsText="The Area Item number "+lsNItem+" is wrong";
        else lsText="The Circle Item number "+lsNItem+" is wrong";
        fsay("",lsText+", will be discarded");
        return "";
    }else{
        list laDataW=llCSV2List(psDataW);
        string ls;
        integer liN;
        integer liT=llGetListLength(laDataW);
        string lsRes;
        for(liN=0;liN<liT;liN++){
            ls=llList2String(laDataW,liN);
            if(ls!=""){
                lsRes=verifydataVarWind(liN,(integer)ls); 
                if(lsRes!=ls) laDataW=llListReplaceList(laDataW,[lsRes],liN,liN);
            }
        }
        //return psDataI+":"+llList2CSV(laDataW);
        return psDataI+":"+llDumpList2String(laDataW,",");
    }  
}  
            
string verifydataVarWind(integer piNum, integer piDataW)  //verify field of item
{
    if(piNum==0){  //wind
        if(piDataW>359) piDataW=0;
    }else if(piNum==1){  //speed
        if(piDataW<5) piDataW=5;
        else if(piDataW>35) piDataW=35;
    }else if(piNum==2){ //gusts
        if(piDataW>100) piDataW=100;
    }else if(piNum==3){  //shift
        if(piDataW>180) piDataW=180;
    }else if(piNum==4){ //period
        if(piDataW<30) piDataW=30;
        else if(piDataW>120) piDataW=120;
    }else if(piNum==5){  //wav height  *10
        if(piDataW>50) piDataW=50;
    }else if(piNum==6){  //wav speed
        if(piDataW<3) piDataW=3;
        else if(piDataW>15) piDataW=15;
    }else if(piNum==7){  //wav length
        if(piDataW<10) piDataW=10;
        else if(piDataW>100) piDataW=100;
    }else if(piNum==8){  //wav var height
        if(piDataW>100) piDataW=100;
    }else if(piNum==9){  //wav var length
        if(piDataW>100) piDataW=100;
    }else if(piNum==10){  //cur speed
        if(piDataW>60) piDataW=60;
    }else if(piNum==11){  //cur direction
        if(piDataW>359) piDataW=0;
    }
    return (string)piDataW; 
}


//psData="wind dir","wind speed","wind gusts","wind shifts","wind period","wave speed","wave height variance","wave length variance","wave height","wave length","wave effects","current dir","current speed","sail mode","name","key","extra1","extra2","water depth","update pos","system mode","notecard"
//values 0,15,0,0,60,3,0,0,0,50,3,0,0,2,"","","","",0,0,"",""
displayNote(integer piPanel, string psData)
{
    //llOwnerSay("displayNote "+psData);
    list l=llCSV2List(psData);
    integer liIndex;
    if(piPanel==1 || piPanel==0){
        giWndDirection=(integer)llList2String(l,0);
        giWndSpeed=(integer)llList2String(l,1);
        giWndGusts=(integer)llList2String(l,2);
        giWndShift=(integer)llList2String(l,3);
        giWndPeriod=(integer)llList2String(l,4);
        putnum(1,1,giWndDirection);
        putnum(1,2,giWndSpeed);
        putnum(1,3,giWndGusts);
        putnum(1,4,giWndShift);
        putnum(1,5,giWndPeriod);
    }
    if(piPanel==2 || piPanel==0){
        if(piPanel==0) liIndex=5;
        giWavSpeed=(integer)llList2String(l,liIndex+0);
        giWavVarHeight=(integer)llList2String(l,liIndex+1);
        giWavVarLength=(integer)llList2String(l,liIndex+2);
        giWavHeight=(integer)llList2String(l,liIndex+3);
        giWavLength=(integer)llList2String(l,liIndex+4);
        integer liEffect=(integer)llList2String(l,liIndex+5);
        giWavSpeedEffects=giWavSteerEffects=0;
        if(liEffect==1 || liEffect==3) giWavSteerEffects=1;
        if(liEffect==2 || liEffect==3) giWavSpeedEffects=1;
        putnum(2,1,giWavHeight);
        putnum(2,2,giWavSpeed);
        putnum(2,3,giWavLength);
        putnum(2,4,giWavVarHeight);
        putnum(2,5,giWavVarLength);
        putnum(2,6,giWavSteerEffects*1+giWavSpeedEffects*2);    
    }
    if(piPanel==3 || piPanel==0){
        if(piPanel==0) liIndex=11;
        giCurDirection=(integer)llList2String(l,liIndex+0);
        giCurSpeed=(integer)llList2String(l,liIndex+1);
        putnum(3,1,giCurSpeed);
        putnum(3,2,giCurDirection);
    }
    if(piPanel==4 || piPanel==0){
        if(piPanel==0) liIndex=13;
        giGenSailMode=(integer)llList2String(l,liIndex+0);
        gsGenName=llList2String(l,liIndex+1);
        gsGenKey=llList2String(l,liIndex+2);
        gsGenExtra1=llList2String(l,liIndex+3);
        gsGenExtra2=llList2String(l,liIndex+4);
        giGenWaterDepth=(integer)llList2String(l,liIndex+5);
        giGenUpdBoatPos=(integer)llList2String(l,liIndex+6);
        gsGenEventType=llList2String(l,liIndex+7);      
        putnum(4,0,0);
        putnum(4,1,giGenWaterDepth);
        putnum(4,2,giGenSailMode);
        putnum(4,3,giGenUpdBoatPos);
    }
    putColor(1); 
    if(giPanel==4) displayText(1);
    else displayText(0);
    if(piPanel>0) llOwnerSay("The panel has been successfully restored");  //update panel
    else if(llList2String(l,21)=="") llOwnerSay("GLW Setter is ready");   //name notecard is empty load first data state entry
    else llOwnerSay("The "+llList2String(l,21)+" notecard has been loaded");  //load notecard
}

default
{
    state_entry()
    {
        llLinksetDataWrite("ISDsetini",(string)swdbg);
        llResetOtherScript("~GLW Menu");
        llResetOtherScript("~GLW Aux");
        llResetOtherScript("~GLW Setter");
        llResetOtherScript("~GLW Variations");
        llResetOtherScript("~GLW Var Menu");
        giDialogChannel = -1 - (integer)("0x" + llGetSubString( (string)llGetKey(), -7, -1) );
        giInputChannel = giDialogChannel-100;
        getLinkNums();
        gkOwner=llGetOwner();
        llSetLinkPrimitiveParamsFast(giTEXT, [PRIM_TEXT, "", <0.10,0.10,0.10>, 0.0]);        
        llSleep(1.0);
        inicio();
        if(swdbg) llOwnerSay(llGetScriptName()+": "+(string)llGetFreeMemory()); 
    }
    
    on_rez(integer param)
    {
        if(gkOwner!=llGetOwner()) llResetScript();
    }
    
    link_message(integer piSender_num, integer piNum, string psStr, key pkData)
    {
        //llOwnerSay((string)piNum);
        if(piNum>=2000 && piNum<3000){
            if(piNum>=2900){
                if(piNum==2910) setTouch0((integer)llGetSubString(psStr,0,0),(integer)llGetSubString(psStr,1,-1),pkData); //touch box  button, panel, key
                else if(piNum==2901) setField1(psStr,(integer)((string)pkData));
                else if(piNum==2911) setTouch1((integer)psStr); //panel 1 face click inside the field
                else if(piNum==2902) setField2(psStr,(integer)((string)pkData)); //panel 2
                else if(piNum==2912) setTouch2((integer)psStr); //panel 2 face  click inside the field
                else if(piNum==2903) setField3(psStr,(integer)((string)pkData)); //panel 3
                else if(piNum==2913) setTouch3((integer)psStr); //panel 3 face  click inside the field 
                else if(piNum==2904) setField4(psStr,(integer)((string)pkData)); //panel 4
                else if(piNum==2981) putkey(pkData, (integer)psStr);
                else if(piNum==2982) putkey(pkData, (integer)psStr); 
                else if(piNum==2983){ 
                    llMessageLinked(LINK_THIS, 6983, (string)giWndDirection+","+(string)giWndSpeed+","+
                            (string)giCurSpeed+","+(string)giCurDirection+","+(string)giWavHeight, "");
                }else if(piNum==2931){  //receive data areas from variations and verify data for start
                    gsVarAreasItems=psStr;
                    gsVarAreasWind=pkData;
                    //llOwnerSay("GLW area data "+gsVarAreasItems+":"+gsVarAreasWind);
                    llMessageLinked(LINK_THIS, 5002, "rdata", "2931"); //read data variations circles  receive 2932 number
                }else if(piNum==2932){  //receive data circles from variations and verify data for start
                    gsVarCirclesItems=psStr;
                    gsVarCirclesWind=pkData;
                    //llOwnerSay("GLW circle data "+gsVarCirclesItems+":"+gsVarCirclesWind);
                    if(verifydata(gkTarget)==0) fstart();
                }else if(piNum==2933){  //receive data areas from variations and verify data for write note
                    gsVarAreasItems=psStr;
                    gsVarAreasWind=pkData;
                    llMessageLinked(LINK_THIS, 5002, "rdata", "2933"); //read data variations circles
                }else if(piNum==2934){  //receive data circles from variations and verify data for write note
                    string ls=sendData(0)+"##"+gsVarAreasItems+"##"+gsVarAreasWind+"##"+psStr+"##"+(string)pkData;
                    llMessageLinked(LINK_THIS,3018,ls,gkClicTarget); //data to Aux
                    gsVarAreasItems="";
                    gsVarAreasWind="";
                }else if(piNum==2935){  //receive data areas from variations and verify data for send modif
                    gsVarAreasItems=psStr;
                    gsVarAreasWind=pkData;
                    //llOwnerSay("area data "+gsVarAreasItems+":"+gsVarAreasWind);
                    llMessageLinked(LINK_THIS, 5002, "rdata", "2935"); //read data variations circles. receive 2935 number
                }else if(piNum==2936){  //receive data circles from variations and verify data for send modif 
                    gsVarCirclesItems=psStr;
                    gsVarCirclesWind=pkData;
                    //llOwnerSay("circle data "+gsVarCirclesItems+":"+gsVarCirclesWind);
                    if(verifydata(gkTarget)==0){ 
                        string ls=sendData(1)+"##"+gsVarAreas+"##"+gsVarCircles;
                        llMessageLinked(LINK_THIS,3016,ls,gkTarget);
                    }
                }else if(piNum==2937){  //verify Event Key
                    if(psStr=="1") llMessageLinked(LINK_THIS, 5001, "rdata", "2931"); //read data variations for start receive 2931 number
                    else if(psStr=="2") fsay(gkTarget,"The event has not been created because the Event Key already exists");
                }
            }else if(psStr=="dispNote"){  //From Aux load note 
                if(piNum==2000){
                    list laVar=llParseStringKeepNulls(pkData,["##"],[]);  //data##areas##circles
                    displayNote(0,llList2String(laVar,0)); 
                    gsVarAreas=llList2String(laVar,1);   //Areas
                    gsVarCircles=llList2String(laVar,2);   //Circles
                    llMessageLinked(LINK_THIS,5990,gsVarAreas,gsVarCircles);  //send data notecars to variations script
                }else{ 
                    displayNote(piNum-2000,pkData);
                }
            }else if(psStr=="event"){  //From Setter script
                giEvent=piNum-2000;    //1 event is created   0 event is not created
            //}else if(psStr=="clean"){  //From Menu script
            //    clean(piNum-2000, pkData);
            }else if(psStr=="icon"){
                if(piNum==2000) giLastHudSize=0;  //reduce icon
                else if(piNum==2002) giLastHudSize=2;   //big hud
                else if(piNum==2001) giLastHudSize=1;   //small hud
                if(giPanel==4) displayText(1);                 
            }else if(psStr=="cast"){  //form Aux
                giCast=piNum-2000;    //broadcast is on or off
            }else if(psStr=="write"){  //form menu
                putvalor();
                gkClicTarget=pkData;
                llMessageLinked(LINK_THIS, 5001, "rdata", "2933"); //read data variations for write note
            }else if(psStr=="reset"){  //From Menu
                llResetScript();
            }else if(psStr=="recovery"){  //From setter
                gsVarAreas="";
                gsVarCircles="";
                list laVar=llParseStringKeepNulls(pkData,["##"],[]);
                displayNote(0,llList2String(laVar,1));
                string lsV=llList2String(laVar,2);   //Areas
                if(lsV!="") gsVarAreas=lsV;   //Areas
                lsV=llList2String(laVar,3);   //Circles
                if(lsV!="") gsVarCircles=lsV;   //Circles
                laVar=llCSV2List(llList2String(laVar,0));
                gkTarget=(key)llList2String(laVar,0);     //Director Key
                string lsIdEvent=llList2String(laVar,1);
                giStart=1;             //Hud is in start mode
                giEvent=1;             //hud have an event 
                llSetLinkPrimitiveParamsFast(giROOT,[PRIM_COLOR,2,<0,1,0>,1.0]); //paint start button
                llOwnerSay("#"+lsIdEvent+" '"+gsGenName+"' Event Successful Recovery.");

            }
        }
    }  
}
