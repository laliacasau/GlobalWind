key ckTEXNUMBERS="8f049f1e-8604-5f33-03a0-edf5023982ce";
key ckTEXEFFECTS="3390e7a0-f47f-707a-34ae-a86ba3ff0b89"; 

vector cvPOSPANELONG=<0.00340,-0.29649, 0.00860>;   
vector cvPOSPANELONS=<0.00340,-0.19057,0.0055>;  //<-0.00189,-0.00060,0.0055>;
vector cvPOSPANELOFF=<0.0,-0.00060,0.0087>;
vector cvPanelSizeG=<0.01958, 0.20921, 0.34554>;
vector cvPanelSizeS=<0.01246, 0.13313, 0.21989>;  //<0.01246, 0.22456, 0.21988>;

vector cvPOSTEXTG=<-0.01061, 0.04576, 0.10109>;  //big hud position text
vector cvPOSTEXTS=<-0.01061, -0.01025, 0.14226>; //small hud position text
vector cvPOSTEXTA=<-0.01061, -0.01025, 0.239>;   //no attached positon text
vector cvPOSVARTEXTG=<-0.01061, -0.2913, 0.096>;  //big hud position text
vector cvPOSVARTEXTS=<-0.01061, -0.19057, 0.05194>;  //<-0.01061, 0.02946, 0.05194>;   //small hud position text
vector cvPOSVARTEXTA=<-0.01061, -0.01025, 0.239>;   //no attached positon text

integer giPANELAREA;
integer giPANELCIRCLE;
integer giTEXT;
integer giPANELVARDATA;
integer giPANELVARWIND;
integer giPANELVARWAV;
integer giPANELVARCUR;
integer giVARTEXT;

//Area Panel object vars;
//active,sim1,globalx,globaly,sim2,globalx,globaly,margin:wind dir,wind speed,wind gusts,wind shifts,wind period,wave height,wave speed, wave length, wave height variance,wave length variance,wave speed effect, wave steer effect,12-current speed,current dir,depth

integer swdbg;
string gsAreaSimSW;
//integer giAreaPosSW_x;
//integer giAreaPosSW_y;
integer giAreaGlobalPosSW_x;
integer giAreaGlobalPosSW_y;
string gsAreaSimNE;
//integer giAreaPosNE_x;
//integer giAreaPosNE_y;
integer giAreaGlobalPosNE_y;
integer giAreaGlobalPosNE_x;
integer giAreaSimNE;
integer giAreaMargin;
integer giAreaActiv;
integer giAreaOver;

//area variations vars
list gaVarAreas;       //list of strings where the main values ​​of each area variation are stored. Each variation is a string.
list gaVarAreasData;   //list of strings where the wind values ​​of each area variation are stored. Each variation is a string.
list gaVarAreasParams;
integer giVarAreaItem;
integer giVarAreaTotal;
key gkRequestSimSWPos;
key gkRequestSimNEPos;
//integer giPanelVars;  //open var panel
//integer giPanelVarsEdit;  //Edit field var panel
integer giAreaMod;

//Circle Panel object vars;
//active,sim1,posx,posy,globalx,globaly,sim2,posx,posy,globalx,globaly,radius,margin:wind,,,,,wav,,,,,,,cur,,depth
string gsCirSimCenter;
integer giCirPosCenter_x;
integer giCirPosCenter_y;
integer giCirGlobalPosCenter_x;
integer giCirGlobalPosCenter_y;
string gsCirSimRadius;
integer giCirPosRadius_x;
integer giCirPosRadius_y;
integer giCirGlobalPosRadius_y;
integer giCirGlobalPosRadius_x;
integer giCirRadius;
integer giCirMargin;
integer giCirActiv;
integer giCirOver;

//circle variations vars
list gaVarCircles;      //list of strings where the main values ​​of each circle variation are stored. Each variation is a string.
list gaVarCirclesData;  //list of strings where the wind values ​​of each circle variation are stored. Each variation is a string.
list gaVarCircleParams;
integer giVarCirItem; //>
integer giVarCirTotal;
key gkRequestCenterPos;
key gkRequestRadiusPos;
integer giPanelVars;  //open var panel
integer giPanelVarsEdit;  //Edit field var panel
integer giCircleMod;


//general vars
integer giCast;
integer giField;
integer giValor;
integer giValorv;
integer giPanel;
integer giLastHudSize;

integer giDelItem; //>

getLinkNums() 
{
    integer i;
    integer linkcount=llGetNumberOfPrims();
    string str;
    for (i=1;i<=linkcount;++i) {
        str=llGetLinkName(i);
        if (str=="panelarea") giPANELAREA=i;
        else if (str=="panelcircle") giPANELCIRCLE=i;
        else if (str=="text") giTEXT=i;
        else if (str=="vartext") giVARTEXT=i;
        else if (str=="panelvardata") giPANELVARDATA=i;
        else if (str=="panelvarwind") giPANELVARWIND=i;
        else if (str=="panelvarwave") giPANELVARWAV=i;
        else if (str=="panelvarcur") giPANELVARCUR=i;
    }
}

fsay(key pkTarget, string tex)
{
    integer nn=llGetAttached();
    if(nn==0 && llGetAgentSize(pkTarget)==ZERO_VECTOR) llInstantMessage(pkTarget,tex);
    else llRegionSayTo(pkTarget,0,tex);
}

putvalor(integer piMode) //save field value into variable  0 save in work vars   1 save in data vars
{
    //use: giField, giValor, giValorv
    //llOwnerSay("putvalor "+(string)giPanel+"  "+(string)giPanelVarsEdit+"  "+(string)giField+"  "+(string)giValor+"  "+(string)giValorv); 
    
    if(giPanel!=5 && giPanel!=6) return;
    
    integer liNum=-1;
    if(giField>0 && (giValor>=0 || giValor==-2)){ 
        liNum=giValor;
        if(giPanelVarsEdit){  //if it is an auxiliary panel
            integer liField;
            string lsNum=(string)liNum;
            if(liNum==-2) lsNum="";
            if(giPanelVarsEdit==9) liField=giField;
            else if(giPanelVarsEdit==10) liField=giField+5;
            else if(giPanelVarsEdit==11) liField=giField+12;
            if(giPanel==5){
                gaVarAreasParams=llListReplaceList(gaVarAreasParams,[lsNum],liField-1,liField-1); //save vars panels fields
                giAreaMod=2;
            }else{
                gaVarCircleParams=llListReplaceList(gaVarCircleParams,[lsNum],liField-1,liField-1); //save vars panels fields
                giCircleMod=2;
            }
            //llOwnerSay(llDumpList2String(gaVarCircleParams,","));
        }else if(giPanel==5){
            if(giField==1 && giValor>=0) giAreaMargin=liNum;   //save margin field
            if(giAreaMod==0) giAreaMod=1;
        }else if(giPanel==6){
            if(giField==1 && giValor>=0) giCirMargin=liNum;   //save margin field
            if(giCircleMod==0) giCircleMod=1;
        }
    }else if(giField>0 && giValor=-1){
        liNum=giValorv;
    }
    if(liNum>=0 || liNum==-2){
        integer liPanel=giPanel;
        if(giPanelVarsEdit) liPanel=giPanelVarsEdit;
        putnum2(liPanel,giField,liNum);
        putColor(liPanel);
        resetValues();
    }   

    if(giPanel==5){
        if(giVarAreaItem>0 && piMode==1 && giAreaMod>0){
            //llOwnerSay("save item "+(string)giVarAreaItem);
            //lsData=active,sim1,corner1x,corner1y,sim2,corner2x,corner2y,margin
            string lsData=(string)giAreaActiv+","+gsAreaSimSW+","+(string)giAreaGlobalPosSW_x+","+(string)giAreaGlobalPosSW_y+","+
                        gsAreaSimNE+","+(string)giAreaGlobalPosNE_x+","+(string)giAreaGlobalPosNE_y+","+(string)giAreaMargin+","+(string)giAreaOver;
            if(lsData!=llList2String(gaVarAreas,giVarAreaItem-1)){ 
                gaVarAreas=llListReplaceList(gaVarAreas,[lsData],giVarAreaItem-1,giVarAreaItem-1);
            }
    
            if(giAreaMod==2){  //if the wind has changed
                //lsData=wind,,,,,wav,,,,,,,cur,,depth
                lsData=llDumpList2String(gaVarAreasParams,",");
                if(lsData!=llList2String(gaVarAreasData,giVarAreaItem-1)){ 
                    gaVarAreasData=llListReplaceList(gaVarAreasData,[lsData],giVarAreaItem-1,giVarAreaItem-1);
                }
            }
            giAreaMod=0;
        } 
    }else{
        if(giVarCirItem>0 && piMode==1 && giCircleMod>0){
            //llOwnerSay("save item "+(string)giVarCirItem);
            //lsData=active,sim1,global1x,global1y,sim2,global2x,global2y,radius,margin,over:wind,,,,,wav,,,,,,,cur,,depth
            string lsData=(string)giCirActiv+","+gsCirSimCenter+","+
                        (string)(giCirGlobalPosCenter_x+giCirPosCenter_x)+","+(string)(giCirGlobalPosCenter_y+giCirPosCenter_y)+","+
                        gsCirSimRadius+","+
                        (string)(giCirGlobalPosRadius_x+giCirPosRadius_x)+","+(string)(giCirGlobalPosRadius_y+giCirPosRadius_y)+","+
                        (string)giCirRadius+","+(string)giCirMargin+","+(string)giCirOver;
            if(lsData!=llList2String(gaVarCircles,giVarCirItem-1)){ 
                gaVarCircles=llListReplaceList(gaVarCircles,[lsData],giVarCirItem-1,giVarCirItem-1);
            }
    
            if(giCircleMod==2){
                //lsData=",,,,,,,,,,,,,";  //wind,,,,,wav,,,,,,,cur,,depth   15 items       
                lsData=llDumpList2String(gaVarCircleParams,",");
                if(lsData!=llList2String(gaVarCirclesData,giVarCirItem-1)){ 
                    gaVarCirclesData=llListReplaceList(gaVarCirclesData,[lsData],giVarCirItem-1,giVarCirItem-1);
                }
            }
            giCircleMod=0;
        } 
    }
}

putnum2(integer piPanel, integer piFace, integer piData)
{
    //llOwnerSay("putnum="+(string)piPanel+"  "+(string)piFace+"  "+(string)piData);
    integer liLink;
    if(piPanel==5) liLink=giPANELAREA;
    else if(piPanel==6) liLink=giPANELCIRCLE;
    else if(piPanel==9) liLink=giPANELVARWIND;
    else if(piPanel==10) liLink=giPANELVARWAV;
    else if(piPanel==11) liLink=giPANELVARCUR;
    if(liLink>0 && piFace>0){
        vector lvTemp;
        if(piPanel==5 && piFace==2){  //active area 
            if(piData) lvTemp=<0,1,0>;
            else lvTemp=<1,1,1>;
            llSetLinkPrimitiveParamsFast(giPANELAREA,[PRIM_COLOR,piFace,lvTemp,1.0]);
        }else if(piPanel==5 && piFace==3){  //over area
            if(piData==1) lvTemp=<0,1,0>;
            else if(piData==2) lvTemp=<1,0,0>;
            else lvTemp=<1,1,1>;
            llSetLinkPrimitiveParamsFast(giPANELAREA,[PRIM_COLOR,piFace,lvTemp,1.0]);
        }else if(piPanel==6 && piFace==2){  //active circle
            if(piData) lvTemp=<0,1,0>;
            else lvTemp=<1,1,1>;
            llSetLinkPrimitiveParamsFast(giPANELCIRCLE,[PRIM_COLOR,piFace,lvTemp,1.0]);
        }else if(piPanel==6 && piFace==3){  //over area 
            if(piData==1) lvTemp=<0,1,0>;
            else if(piData==2) lvTemp=<1,0,0>;
            else lvTemp=<1,1,1>;
            llSetLinkPrimitiveParamsFast(giPANELCIRCLE,[PRIM_COLOR,piFace,lvTemp,1.0]);
        }else if(piPanel==10 && piFace==1){ //Waves Height field 1 decimal 
            if(piData<10) lvTemp=<0.07035*(piData%14),-0.03515*26,0.0>;
            else lvTemp=<0.07035*(piData%14),-0.03515*(integer)(piData/14),0.0>;
            llSetLinkPrimitiveParamsFast(liLink,[PRIM_TEXTURE,piFace,ckTEXNUMBERS,<1.0,1.0,0.0>,lvTemp,0.0]);                 
        }else if(piPanel==11 && piFace==1){ //Currents speed field 1 decimal 
            if(piData<10) lvTemp=<0.07035*(piData%14),-0.03515*26,0.0>;
            else lvTemp=<0.07035*(piData%14),-0.03515*(integer)(piData/14),0.0>;
            llSetLinkPrimitiveParamsFast(liLink,[PRIM_TEXTURE,piFace,ckTEXNUMBERS,<1.0,1.0,0.0>,lvTemp,0.0]);             
        }else if(piPanel==10 && piFace>=6){  //wave speed face 6 and steer face 7 effects
            piData++;
            if(piData==-1) piData=0;
            llSetLinkPrimitiveParamsFast(giPANELVARWAV,[PRIM_TEXTURE,piFace,ckTEXEFFECTS,<1.0,1.0,0.0>,<piData*0.0636,0,0>,0.0]); 
        }else if(piPanel>7){ //variations data panels
            if(piData==-2) lvTemp=<0.07035*(360%14),-0.03515*(integer)(360/14),0.0>;  //not have value white space
            else lvTemp=<0.07035*(piData%14),-0.03515*(integer)(piData/14),0.0>;
            llSetLinkPrimitiveParamsFast(liLink,[PRIM_TEXTURE,piFace,ckTEXNUMBERS,<1.0,1.0,0.0>,lvTemp,0.0]); 
        }else{
            llSetLinkPrimitiveParamsFast(liLink,[PRIM_TEXTURE,piFace,ckTEXNUMBERS,<1.0,1.0,0.0>,<0.07035*(piData%14),-0.03515*(integer)(piData/14),0.0>,0.0]); 
        }
    }
}

putkey(key pkTarget, integer piNumKey)
{
    //use giPanel, giField, giValor, giValorv
    //llOwnerSay("putkey "+(string)giPanel+"  "+(string)giPanelVarsEdit+"  "+(string)giField+"   "+(string)giValor+"   "+(string)giValorv+"   "+(string)piNumKey);
    if(giField==0){ 
        fsay(pkTarget, "You have not selected any field");
        return;
    }
    integer liNum;
    if(piNumKey<0){  //del, esc, enter
        if(piNumKey==-2){  //esc
            liNum=-1;
            if(giValorv>=0){  
                if(giPanelVarsEdit){
                    putnum2(giPanelVarsEdit,giField,giValorv);
                    putColor(giPanelVarsEdit);
                }else{
                    putnum2(giPanel,giField,giValorv);
                    putColor(giPanel);
                }
            }
            resetValues();
        }else if(piNumKey==-1){ //del
            if(giValor==-1) liNum=giValorv;
            else liNum=giValor;
            if(liNum<10){
                if(giPanelVarsEdit) liNum=-2;   //white space for vars panel
                else liNum=0;
            }else liNum=(integer)(liNum/10);
        }else if(piNumKey==-3){ //enter
            liNum=-1;
            if(giValor>=0 || giValor==-2){
                putvalor(0);
            }
            if(giPanelVarsEdit) putColor(giPanelVarsEdit);
            else putColor(giPanel);
            resetValues();
        }
    }else{   //clic number key
        if(giValor<=0) liNum=piNumKey;
        else{ 
            liNum=(integer)((string)giValor+(string)piNumKey);
            if(liNum>359) liNum=-1;
        }
        //liNum=verifyField(pkTarget, giPanel, giField, liNum);
    }
    if(liNum>=0){ 
        giValor=liNum;
        if(giPanelVarsEdit) putnum2(giPanelVarsEdit,giField,giValor);
        else putnum2(giPanel,giField,giValor);
    }else if(liNum==-2){
        giValor=liNum;
        putnum2(giPanelVarsEdit,giField,giValor);
    }
    //output giField, giValor, giValorv
}

resetValues()
{
    giValor=-1;
    giValorv=-1;
    giField=0;
    giPanelVarsEdit=0;
}

putColor(integer piPanel)
{
    if(piPanel==5) llSetLinkPrimitiveParamsFast(giPANELAREA,[PRIM_COLOR,1,<1,1,1>,1.0]);
    else if(piPanel==6) llSetLinkPrimitiveParamsFast(giPANELCIRCLE,[PRIM_COLOR,1,<1,1,1>,1.0]);
    else if(piPanel==9) llSetLinkPrimitiveParamsFast(giPANELVARWIND,[PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
    else if(piPanel==10) llSetLinkPrimitiveParamsFast(giPANELVARWAV,[PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
    else if(piPanel==11) llSetLinkPrimitiveParamsFast(giPANELVARCUR,[PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
    else if(piPanel==0){
        llSetLinkPrimitiveParamsFast(giPANELAREA,[PRIM_COLOR,1,<1,1,1>,1.0]);
        llSetLinkPrimitiveParamsFast(giPANELCIRCLE,[PRIM_COLOR,1,<1,1,1>,1.0]);
        llSetLinkPrimitiveParamsFast(giPANELVARWIND,[PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
        llSetLinkPrimitiveParamsFast(giPANELVARWAV,[PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
    }
}


loadItemVars()  //load vars data in work variables
{
    if(giPanel==5){
        list laVars=llCSV2List(llList2String(gaVarAreas,giVarAreaItem-1));  //Area data
        giAreaActiv=(integer)llList2String(laVars,0);
        gsAreaSimSW=llList2String(laVars,1);
        giAreaGlobalPosSW_x=(integer)llList2String(laVars,2);
        giAreaGlobalPosSW_y=(integer)llList2String(laVars,3);
        gsAreaSimNE=llList2String(laVars,4);
        giAreaGlobalPosNE_x=(integer)llList2String(laVars,5);
        giAreaGlobalPosNE_y=(integer)llList2String(laVars,6);
        giAreaMargin=(integer)llList2String(laVars,7);
        giAreaOver=(integer)llList2String(laVars,8);
        displayText(giPanel);
        putnum2(5,1,giAreaMargin);
        putnum2(5,2,giAreaActiv);
        putnum2(5,3,giAreaOver);
        
        gaVarAreasParams=llCSV2List(llList2String(gaVarAreasData,giVarAreaItem-1));   //areas params wind
        integer liN;
        string lsVal;
        for(liN=0;liN<15;liN++){
            lsVal=llList2String(gaVarAreasParams,liN);
            if(lsVal=="") lsVal="-2";
            if(liN<5) putnum2(9,liN+1,(integer)lsVal);  //var wind panel
            else if(liN<12) putnum2(10,liN-4,(integer)lsVal);  //var wav panel
            else putnum2(11,liN-11,(integer)lsVal);  //var current panel
        }    
    }else if(giPanel==6){
        list laVars=llCSV2List(llList2String(gaVarCircles,giVarCirItem-1));  //circle data
        giCirActiv=(integer)llList2String(laVars,0);
        gsCirSimCenter=llList2String(laVars,1);

        integer liValue=(integer)llList2String(laVars,2);
        giCirGlobalPosCenter_x=(integer)(liValue/256.0)*256;  //Sim Global Coords x
        giCirPosCenter_x=liValue-giCirGlobalPosCenter_x;      //local coords  x

        liValue=(integer)llList2String(laVars,3);
        giCirGlobalPosCenter_y=(integer)(liValue/256.0)*256;   //Sim Global Coords y
        giCirPosCenter_y=liValue-giCirGlobalPosCenter_y;       //local coords y 

        gsCirSimRadius=llList2String(laVars,4);
        
        liValue=(integer)llList2String(laVars,5);
        giCirGlobalPosRadius_x=(integer)(liValue/256.0)*256;  //Sim Global Coords x
        giCirPosRadius_x=liValue-giCirGlobalPosRadius_x;    //local coords  x
        
        liValue=(integer)llList2String(laVars,6);
        giCirGlobalPosRadius_y=(integer)(liValue/256.0)*256;   //Sim Global Coords y
        giCirPosRadius_y=liValue-giCirGlobalPosRadius_y;       //local coords y 

        giCirRadius=(integer)llList2String(laVars,7);
        giCirMargin=(integer)llList2String(laVars,8);
        giCirOver=(integer)llList2String(laVars,9);
        displayText(giPanel);
        putnum2(6,1,giCirMargin);
        putnum2(6,2,giCirActiv);
        putnum2(6,3,giCirOver);
        
        gaVarCircleParams=llCSV2List(llList2String(gaVarCirclesData,giVarCirItem-1));   //circle params wind
        integer liN;
        string lsVal;
        for(liN=0;liN<15;liN++){
            lsVal=llList2String(gaVarCircleParams,liN);
            if(lsVal=="") lsVal="-2";
            if(liN<5) putnum2(9,liN+1,(integer)lsVal);  //var wind panel
            else if(liN<12) putnum2(10,liN-4,(integer)lsVal);  //var wav panel
            else putnum2(11,liN-11,(integer)lsVal);  //var current panel
        }    
    }
}

displayText(integer piPanel)  //display text data 
{
    if(piPanel==5){  //Areas
        string lsTex="Area "+(string)giVarAreaItem+"/"+(string)giVarAreaTotal+"\n";
        lsTex+="SW: "+gsAreaSimSW+"\nNE: "+gsAreaSimNE;
        if(llGetAttached()==0){
            llSetLinkPrimitiveParamsFast(giTEXT, [PRIM_TEXT, lsTex, <1.0,1.0,0.0>, 1.0,PRIM_POS_LOCAL,cvPOSTEXTA]);
        }else if(giLastHudSize==2){
            llSetLinkPrimitiveParamsFast(giTEXT, [PRIM_TEXT, lsTex, <0.10,0.10,0.10>, 1.0,PRIM_POS_LOCAL,cvPOSTEXTG]);
        }else if(giLastHudSize==1){
            llSetLinkPrimitiveParamsFast(giTEXT, [PRIM_TEXT, lsTex, <1.0,1.0,0.0>, 1.0,PRIM_POS_LOCAL,cvPOSTEXTS]);
        }else{
            llSetLinkPrimitiveParamsFast(giTEXT, [PRIM_TEXT, "", <0.10,0.10,0.10>, 0.0]);
        }
    }else if(piPanel==6){  //circles
        string lsTex="Circle "+(string)giVarCirItem+"/"+(string)giVarCirTotal+"\n";
        if(giLastHudSize!=1) lsTex+="Center: ";
        lsTex+=gsCirSimCenter+" "+(string)giCirPosCenter_x+","+(string)giCirPosCenter_y+
            "\nRadius: "+(string)giCirRadius+" m.";
        if(llGetAttached()==0){
            llSetLinkPrimitiveParamsFast(giTEXT, [PRIM_TEXT, lsTex, <1.0,1.0,0.0>, 1.0,PRIM_POS_LOCAL,cvPOSTEXTA]);
        }else if(giLastHudSize==2){
            llSetLinkPrimitiveParamsFast(giTEXT, [PRIM_TEXT, lsTex, <0.10,0.10,0.10>, 1.0,PRIM_POS_LOCAL,cvPOSTEXTG]);
        }else if(giLastHudSize==1){
            llSetLinkPrimitiveParamsFast(giTEXT, [PRIM_TEXT, lsTex, <1.0,1.0,0.0>, 1.0,PRIM_POS_LOCAL,cvPOSTEXTS]);
        }else{
            llSetLinkPrimitiveParamsFast(giTEXT, [PRIM_TEXT, "", <0.10,0.10,0.10>, 0.0]);
        }
    }
}

displayParams(integer piMode) //display variations parameters in params panel
{
    if(piMode==0){
        llSetLinkPrimitiveParamsFast(giVARTEXT, [PRIM_TEXT, "", <0.10,0.10,0.10>, 0.0,PRIM_POS_LOCAL,ZERO_VECTOR]);
        return;
    }

    list caTextParams=["Wnd Dir","Wnd Speed","Wnd Gusts","Wnd Shift","Wnd Period",
                   "Wav Height","Wav Speed","Wav Length","Var Height","Var Length",
                   "speed effect","steer effect","Cur Speed","Cur Dir","Water Depth"];
    
    integer liLen;
    if(piMode==1) liLen=llGetListLength(gaVarAreasParams);
    else liLen=llGetListLength(gaVarCircleParams);
    string lsTex;
    integer li;
    integer liNum;
    string lsVal;
    for(li=0;li<liLen;li++){
        if(piMode==1) lsVal=llList2String(gaVarAreasParams,li);
        else lsVal=llList2String(gaVarCircleParams,li);
        if(lsVal!=""){
            if(li==10 || li==11){
                if(lsVal=="0") lsVal="No";
                else if(lsVal=="1") lsVal="Yes";
            }
            lsTex+=llList2String(caTextParams,li)+": "+lsVal+"\n";
            liNum++;
        }
    }
    if(lsTex=="") lsTex="No Variations";
    vector lv;
    if(giLastHudSize==1) lv=cvPOSVARTEXTS;
    else lv=cvPOSVARTEXTG;
    lv.z-=0.01324*liNum;
    llSetLinkPrimitiveParams(giVARTEXT, [PRIM_TEXT, lsTex, <0.10,0.10,0.10>, 1.0,PRIM_POS_LOCAL,lv]);
}

hidenPanelVars()
{
    integer liPanel;
    if(giPanelVars==1){
        displayParams(0);
        liPanel=giPANELVARDATA;
    }else if(giPanelVars==2) liPanel=giPANELVARWIND;
    else if(giPanelVars==3) liPanel=giPANELVARWAV;
    else if(giPanelVars==4) liPanel=giPANELVARCUR;

    if(liPanel>0) llSetLinkPrimitiveParamsFast(liPanel,[PRIM_POS_LOCAL,cvPOSPANELOFF,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]);
    giPanelVars=0;
}

setTouchF(integer piEditPanel, integer piLinkPanel, integer piField)   //touch on panels inside the field
{
    //llOwnerSay("setTouchF "+(string)piEditPanel+"  "+(string)piLinkPanel+"  "+(string)piField+"  "+(string)giAreaMargin);
    putvalor(0);
    if((piEditPanel==5 && giVarAreaItem==0) || (piEditPanel==6 && giVarCirItem==0)) return;  //there is no item created
    
    giField=piField;
    putColor(piEditPanel);
    giPanelVarsEdit=0;
    llSetLinkPrimitiveParamsFast(piLinkPanel,[PRIM_COLOR,piField,<0,1,0>,1.0]);  //color green
    if(piEditPanel==5 && giField==1){ 
        giValorv=giAreaMargin;
        if(giAreaMod==0) giAreaMod=1;
    }else if(piEditPanel==6 && giField==1){ 
        giValorv=giCirMargin;
        if(giCircleMod==0) giCircleMod=1;
    }else if(piEditPanel>7){   //aux panels
        giPanelVarsEdit=piEditPanel;  //save panel to display
        integer liField;
        if(giPanelVarsEdit==9) liField=giField;
        else if(giPanelVarsEdit==10) liField=giField+5;
        else if(giPanelVarsEdit==11) liField=giField+12;
        string lsValue;
        if(giPanel==5) lsValue=llList2String(gaVarAreasParams,liField-1);
        else lsValue=llList2String(gaVarCircleParams,liField-1);
        if(lsValue=="") giValorv=-2;
        else giValorv=(integer)lsValue;
        
        
        if(liField==11 || liField==12){
            llSetLinkPrimitiveParamsFast(piLinkPanel,[PRIM_COLOR,piField,<1,1,1>,1.0]);  //for effects field restore color
            giValorv++;
            if(giValorv<0) giValorv=0;
            lsValue=(string)giValorv;
            if(giValorv==2){ 
                giValorv=-2;
                lsValue="";
            }
            if(giPanel==5){
                gaVarAreasParams=llListReplaceList(gaVarAreasParams,[lsValue],liField-1,liField-1);
                giAreaMod=2;
            }else{
                gaVarCircleParams=llListReplaceList(gaVarCircleParams,[lsValue],liField-1,liField-1);
                giCircleMod=2;
            }
            putnum2(10,giField,giValorv);
            resetValues();
        }
    }
    giValor=-1;
}

setField5(string psData, integer piField)  //fields panel 5 Areas buttons and rapid keys
{
    //llOwnerSay("setField5 *"+psData+"*    "+(string)piField);
    if(piField==10){  //add Area
        putvalor(1);
        gaVarAreas+="1,,,,,,,,0";   //active,sim1,corner1x,corner1y,sim2,corner1x,corner1y,margin,overlap   9 items
        gaVarAreasData+=",,,,,,,,,,,,,,";  //wind,,,,,wav,,,,,,cur,,depth   15 items
        //gaVarCirclesData+="270,15,20,25,120,,,,,,,,,,";  //wind,,,,,wav,,,,,,,cur,,depth   15 items
        giVarAreaTotal=llGetListLength(gaVarAreas);
        giVarAreaItem=giVarAreaTotal;
        llMessageLinked(LINK_THIS,6905,(string)giVarAreaItem,(string)giVarAreaTotal);
        loadItemVars();
    }

    if(giVarAreaItem==0) return;
    if(piField<10){
        if(piField==1){    //margin
            giAreaMargin=(integer)psData;
            if(giAreaMod==0) giAreaMod=1;
            putnum2(5,1,giAreaMargin);
        }else if(piField==2){  //activ
            if(giAreaActiv){
                giAreaActiv=0;
                llSetLinkPrimitiveParamsFast(giPANELAREA,[PRIM_COLOR,piField,<1,1,1>,1.0]);
            }else{
                giAreaActiv=1;
                llSetLinkPrimitiveParamsFast(giPANELAREA,[PRIM_COLOR,piField,<0,1,0>,1.0]);
            }
            if(giAreaMod==0) giAreaMod=1;
        }else if(piField==3){  //overlap
            if(giAreaOver==0){
                giAreaOver=1;   //overlap on   green
                llSetLinkPrimitiveParamsFast(giPANELAREA,[PRIM_COLOR,piField,<0,1,0>,1.0]);
            }else if(giAreaOver==1){
                giAreaOver=2;   //ignore overlap   red
                llSetLinkPrimitiveParamsFast(giPANELAREA,[PRIM_COLOR,piField,<1,0,0>,1.0]);
            }else if(giAreaOver==2){
                giAreaOver=0;   //overlap off  transparent
                llSetLinkPrimitiveParamsFast(giPANELAREA,[PRIM_COLOR,piField,<1,1,1>,1.0]);
            }
            if(giAreaMod==0) giAreaMod=1;
        }
    }else if(piField==12){ //display SW in map
        if(gsAreaSimSW!="") llMapDestination(gsAreaSimSW,<125,125,25>,ZERO_VECTOR);
        else llOwnerSay("SW Sim is not defined");
    }else if(piField==13){ //display NE in map
        if(gsAreaSimNE!="") llMapDestination(gsAreaSimNE,<125,125,25>,ZERO_VECTOR);
        else llOwnerSay("NE Sim is not defined");
    }else if(piField==14 || piField==16){  //get SW sim/ get NE sim
        //psData="http://maps.secondlife.com/secondlife/Chub/183/148/22" style
        list laParse=llParseString2List(psData,["/"],[]);
        integer liTotal=llGetListLength(laParse);
        if(piField==14){
            gsAreaSimSW=llUnescapeURL(llList2String(laParse,liTotal-4));
            //giAreaPosSW_x=(integer)llList2String(laParse,liTotal-3);
            //giAreaPosSW_y=(integer)llList2String(laParse,liTotal-2);
            gkRequestSimSWPos=llRequestSimulatorData(gsAreaSimSW,DATA_SIM_POS);
        }else{
            gsAreaSimNE=llUnescapeURL(llList2String(laParse,liTotal-4));
            gkRequestSimNEPos=llRequestSimulatorData(gsAreaSimNE,DATA_SIM_POS);
        }
        if(giAreaMod==0) giAreaMod=1;
        displayText(5);
    }else if(piField==15 || piField==17){  //detect SW sim/ detect NE sim
        if(llGetAttached()==0) llOwnerSay("This function is for Hud attached");
        else{
            if(piField==15){
                gsAreaSimSW=llGetRegionName();
                gkRequestSimSWPos=llRequestSimulatorData(gsAreaSimSW,DATA_SIM_POS);
            }else{
                gsAreaSimNE=llGetRegionName();
                gkRequestSimNEPos=llRequestSimulatorData(gsAreaSimNE,DATA_SIM_POS);
            }
            if(giAreaMod==0) giAreaMod=1;
            displayText(5);
        }
    }else if(piField>=18 && piField<=21){  //auxiliar panels buttons
        integer liPanelVarsOld=giPanelVars;
        hidenPanelVars();
        if(liPanelVarsOld!=1 && piField==18){
            putvalor(1);
            if(giLastHudSize==1) llSetLinkPrimitiveParamsFast(giPANELVARDATA,[PRIM_SIZE,cvPanelSizeS,PRIM_POS_LOCAL,cvPOSPANELONS,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            else llSetLinkPrimitiveParamsFast(giPANELVARDATA,[PRIM_SIZE,cvPanelSizeG,PRIM_POS_LOCAL,cvPOSPANELONG,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            displayParams(1);
            giPanelVars=1;
        }else if(liPanelVarsOld!=2 && piField==19){
            if(giLastHudSize==1) llSetLinkPrimitiveParamsFast(giPANELVARWIND,[PRIM_SIZE,cvPanelSizeS,PRIM_POS_LOCAL,cvPOSPANELONS,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            else llSetLinkPrimitiveParamsFast(giPANELVARWIND,[PRIM_SIZE,cvPanelSizeG,PRIM_POS_LOCAL,cvPOSPANELONG,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            giPanelVars=2;
        }else if(liPanelVarsOld!=3 && piField==20){
            if(giLastHudSize==1) llSetLinkPrimitiveParamsFast(giPANELVARWAV,[PRIM_SIZE,cvPanelSizeS,PRIM_POS_LOCAL,cvPOSPANELONS,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            else llSetLinkPrimitiveParamsFast(giPANELVARWAV,[PRIM_SIZE,cvPanelSizeG,PRIM_POS_LOCAL,cvPOSPANELONG,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            giPanelVars=3;
        }else if(liPanelVarsOld!=4 && piField==21){
            if(giLastHudSize==1) llSetLinkPrimitiveParamsFast(giPANELVARCUR,[PRIM_SIZE,cvPanelSizeS,PRIM_POS_LOCAL,cvPOSPANELONS,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            else llSetLinkPrimitiveParamsFast(giPANELVARCUR,[PRIM_SIZE,cvPanelSizeG,PRIM_POS_LOCAL,cvPOSPANELONG,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            giPanelVars=4;
        }
    }else if(piField==22 || piField==23){  //arrows area
        putvalor(1); 
        if(piField==22){
            if(giVarAreaItem>1){
                giVarAreaItem--;
                llMessageLinked(LINK_THIS,6905,(string)giVarAreaItem,"");  //update area item in menu var script
                loadItemVars();
                if(giPanelVars==1) displayParams(1);
            }
        }else{
            if(giVarAreaItem<giVarAreaTotal){ 
                giVarAreaItem++;
                llMessageLinked(LINK_THIS,6905,(string)giVarAreaItem,"");
                loadItemVars();
                if(giPanelVars==1) displayParams(1);
            }
        } 
    }
}

setField6(string psData, integer piField)  //fields panel 6 Circles  buttons and rapid keys
{
    //llOwnerSay("setField6 *"+psData+"*    "+(string)piField);
    if(piField==10){  //add circle
        putvalor(1);
        gaVarCircles+="1,,,,,,,,,0";   //active,sim1,global1x,global1y,sim2,global2x,global2y,radius,margin,overlap   10 items
        gaVarCirclesData+=",,,,,,,,,,,,,,";  //wind,,,,,wav,,,,,,cur,,depth   15 items
        //gaVarCirclesData+="270,15,20,25,120,,,,,,,,,,";  //wind,,,,,wav,,,,,,,cur,,depth   15 items
        giVarCirTotal=llGetListLength(gaVarCircles);
        giVarCirItem=giVarCirTotal;
        llMessageLinked(LINK_THIS,6906,(string)giVarCirItem,(string)giVarCirTotal);
        loadItemVars();
    }

    if(giVarCirItem==0) return;
    if(piField<10){
        if(piField==1){    //margin
            giCirMargin=(integer)psData;
            if(giCircleMod==0) giCircleMod=1;
            putnum2(6,1,giCirMargin);
        }else if(piField==2){  //activ
            if(giCirActiv){
                giCirActiv=0;
                llSetLinkPrimitiveParamsFast(giPANELCIRCLE,[PRIM_COLOR,piField,<1,1,1>,1.0]);
            }else{
                giCirActiv=1;
                llSetLinkPrimitiveParamsFast(giPANELCIRCLE,[PRIM_COLOR,piField,<0,1,0>,1.0]);
            }
            if(giCircleMod==0) giCircleMod=1; // something has change
        }else if(piField==3){  //overlap
            if(giCirOver==0){
                giCirOver=1;   //overlap on   green
                llSetLinkPrimitiveParamsFast(giPANELCIRCLE,[PRIM_COLOR,piField,<0,1,0>,1.0]);
            }else if(giCirOver==1){
                giCirOver=2;   //ignore overlap   red
                llSetLinkPrimitiveParamsFast(giPANELCIRCLE,[PRIM_COLOR,piField,<1,0,0>,1.0]);
            }else if(giCirOver==2){
                giCirOver=0;   //overlap off  transparent
                llSetLinkPrimitiveParamsFast(giPANELCIRCLE,[PRIM_COLOR,piField,<1,1,1>,1.0]);
            }
            if(giCircleMod==0) giCircleMod=1;   //something has change
            
        }
    }else if(piField==12){ //display center in map
        //llOwnerSay(llGetRegionName()+"   "+gsCirSimCenter+"   "+(string)giCirPosCenter_x+"   "+(string)giCirPosCenter_y); 
        vector v=<giCirPosCenter_x,giCirPosCenter_y,25>;
        if(gsCirSimCenter!="") llMapDestination(gsCirSimCenter,v,ZERO_VECTOR);
        else llOwnerSay("Center is not defined");
    }else if(piField==13){ //display radius in map
        if(gsCirSimRadius!="") llMapDestination(gsCirSimRadius,<giCirPosRadius_x,giCirPosRadius_y,25>,ZERO_VECTOR);
        else llOwnerSay("Radius is not defined");
    }else if(piField==14 || piField==16){  //get center point/ get radium point
        //psData="http://maps.secondlife.com/secondlife/Chub/183/148/22" style
        list laParse=llParseString2List(psData,["/"],[]);
        integer liTotal=llGetListLength(laParse);
        if(piField==14){
            gsCirSimCenter=llUnescapeURL(llList2String(laParse,liTotal-4));
            giCirPosCenter_x=(integer)llList2String(laParse,liTotal-3);
            giCirPosCenter_y=(integer)llList2String(laParse,liTotal-2);
            gkRequestCenterPos=llRequestSimulatorData(gsCirSimCenter,DATA_SIM_POS);
        }else{
            gsCirSimRadius=llUnescapeURL(llList2String(laParse,liTotal-4));
            giCirPosRadius_x=(integer)llList2String(laParse,liTotal-3);
            giCirPosRadius_y=(integer)llList2String(laParse,liTotal-2);
            gkRequestRadiusPos=llRequestSimulatorData(gsCirSimRadius,DATA_SIM_POS);
        }
        if(giCircleMod==0) giCircleMod=1;
        displayText(6);
    }else if(piField==15 || piField==17){  //detect center point/ detect radium point
        if(llGetAttached()==0) llOwnerSay("This function is for Hud attached");
        else{
            if(piField==15){
                gsCirSimCenter=llGetRegionName();
                vector lvPos=llGetPos();
                giCirPosCenter_x=(integer)lvPos.x;
                giCirPosCenter_y=(integer)lvPos.y;
                gkRequestCenterPos=llRequestSimulatorData(gsCirSimCenter,DATA_SIM_POS);
            }else{
                gsCirSimRadius=llGetRegionName();
                vector lvPos=llGetPos();
                giCirPosRadius_x=(integer)lvPos.x;
                giCirPosRadius_y=(integer)lvPos.y;
                gkRequestRadiusPos=llRequestSimulatorData(gsCirSimRadius,DATA_SIM_POS);
            }
            if(giCircleMod==0) giCircleMod=1;
            displayText(6);
        }
    }else if(piField>=18 && piField<=21){  //auxiliar panels buttons
        integer liPanelVarsOld=giPanelVars;
        hidenPanelVars();
        if(liPanelVarsOld!=1 && piField==18){
            putvalor(1);
            if(giLastHudSize==1) llSetLinkPrimitiveParamsFast(giPANELVARDATA,[PRIM_SIZE,cvPanelSizeS,PRIM_POS_LOCAL,cvPOSPANELONS,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            else llSetLinkPrimitiveParamsFast(giPANELVARDATA,[PRIM_SIZE,cvPanelSizeG,PRIM_POS_LOCAL,cvPOSPANELONG,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            displayParams(2);
            giPanelVars=1;
        }else if(liPanelVarsOld!=2 && piField==19){
            if(giLastHudSize==1) llSetLinkPrimitiveParamsFast(giPANELVARWIND,[PRIM_SIZE,cvPanelSizeS,PRIM_POS_LOCAL,cvPOSPANELONS,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            else llSetLinkPrimitiveParamsFast(giPANELVARWIND,[PRIM_SIZE,cvPanelSizeG,PRIM_POS_LOCAL,cvPOSPANELONG,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            giPanelVars=2;
        }else if(liPanelVarsOld!=3 && piField==20){
            if(giLastHudSize==1) llSetLinkPrimitiveParamsFast(giPANELVARWAV,[PRIM_SIZE,cvPanelSizeS,PRIM_POS_LOCAL,cvPOSPANELONS,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            else llSetLinkPrimitiveParamsFast(giPANELVARWAV,[PRIM_SIZE,cvPanelSizeG,PRIM_POS_LOCAL,cvPOSPANELONG,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            giPanelVars=3;
        }else if(liPanelVarsOld!=4 && piField==21){
            if(giLastHudSize==1) llSetLinkPrimitiveParamsFast(giPANELVARCUR,[PRIM_SIZE,cvPanelSizeS,PRIM_POS_LOCAL,cvPOSPANELONS,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            else llSetLinkPrimitiveParamsFast(giPANELVARCUR,[PRIM_SIZE,cvPanelSizeG,PRIM_POS_LOCAL,cvPOSPANELONG,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
            giPanelVars=4;
        }
    }else if(piField==22 || piField==23){  //arrows circle
        putvalor(1); 
        if(piField==22){
            if(giVarCirItem>1){
                giVarCirItem--;
                llMessageLinked(LINK_THIS,6906,(string)giVarCirItem,"");
                loadItemVars();
                if(giPanelVars==1) displayParams(2);

            }
        }else{
            if(giVarCirItem<giVarCirTotal){ 
                giVarCirItem++;
                llMessageLinked(LINK_THIS,6906,(string)giVarCirItem,"");
                loadItemVars();
                if(giPanelVars==1) displayParams(2);
            }
        } 
    }
}

setFieldP(integer piPanel, string psData, integer piField)  //put fields vars panels rapid keys
{
    if(piPanel==9){   //vars panel
        if(piField>=1 && piField<=5){
            if(giPanel==5){   //areas panel
                gaVarAreasParams=llListReplaceList(gaVarAreasParams,[psData],piField-1,piField-1);
                giAreaMod=2;
            }else{     //circles panel
                gaVarCircleParams=llListReplaceList(gaVarCircleParams,[psData],piField-1,piField-1);
                giCircleMod=2;
            }
            putnum2(piPanel,piField,(integer)psData);
        }
    }else if(piPanel==10){
        if(piField>=1 && piField<=5){  
            if(giPanel==5){
                gaVarAreasParams=llListReplaceList(gaVarAreasParams,[psData],piField+4,piField+4);
                giAreaMod=2;
            }else{  
                gaVarCircleParams=llListReplaceList(gaVarCircleParams,[psData],piField+4,piField+4);
                giCircleMod=2;
            }
            putnum2(piPanel,piField,(integer)psData);
        }
    }else if(piPanel==11){
        if(piField>=1 && piField<=3){  
            if(giPanel==5){
                gaVarAreasParams=llListReplaceList(gaVarAreasParams,[psData],piField+11,piField+11);
                giAreaMod=2;
            }else{  
                gaVarCircleParams=llListReplaceList(gaVarCircleParams,[psData],piField+11,piField+11);
                giCircleMod=2;
            }
            putnum2(piPanel,piField,(integer)psData);
        }
    }
}

default
{
    state_entry()
    {
        swdbg=(integer)llLinksetDataRead("ISDsetini");
        getLinkNums();
        giLastHudSize=2;
        putnum2(5,1,0);
        putnum2(6,1,0);
        //putColor(0);
        if(swdbg) llOwnerSay(llGetScriptName()+": "+(string)llGetFreeMemory());
    }

    link_message(integer piSender_num, integer piNum, string psStr, key pkTarget)
    {
        //llOwnerSay("variations link msg "+(string)piNum+"  "+psStr+"   "+(string)pkTarget);
        if(piNum>=5000 && piNum<6000){
            if(piNum>5800){  //menu options and load notecard
                if(piNum==5910){
                    if((integer)llGetSubString(psStr,0,0)==1){   //tabs,
                        putvalor(1);  //save the last editing field
                        giPanel=(integer)llGetSubString(psStr,1,2);
                        resetValues();  //reset editinG fiels variables
                        if(giPanel==5 || giPanel==6){
                            loadItemVars();
                        }
                        giPanelVars=0;
                    }
                }else if(piNum==5805){
                    setField5(psStr,(integer)((string)pkTarget));
                }else if(piNum==5806){
                    setField6(psStr,(integer)((string)pkTarget));
                }else if(piNum==5815){
                    if(psStr=="1") setTouchF(5,giPANELAREA,(integer)psStr);  //margin field
                    else if(psStr=="2" || psStr=="3") setField5("",(integer)psStr);   //active, overlap field
                }else if(piNum==5816){
                    if(psStr=="1") setTouchF(6,giPANELCIRCLE,(integer)psStr);  //margin field
                    else if(psStr=="2" || psStr=="3") setField6("",(integer)psStr);   //active, overlap field
                }else if(piNum>5817 && piNum<=5821){   //auxiliar panels
                    setTouchF(piNum-5810,(integer)((string)pkTarget),(integer)psStr); 
                }else if(piNum==5920){
                    setField5(psStr,(integer)((string)pkTarget));
                }else if(piNum==5921){
                    setField6(psStr,(integer)((string)pkTarget));
                }else if(piNum>5922 && piNum<=5927){
                    setFieldP(piNum-5915,psStr,(integer)((string)pkTarget));   //fase 0 in vars panels
                }else if(piNum==5980){
                    hidenPanelVars();
                }else if(piNum==5981){
                    putkey(pkTarget, (integer)psStr);
                }else if(piNum==5982){  //save item
                    if(psStr=="5"){ 
                        if(giAreaMod==0) giAreaMod=1;
                    }else{
                        if(giCircleMod==0) giCircleMod=1;
                    }
                    putvalor(1);
                    llOwnerSay("The item has been saved"); 
                }else if(piNum==5983){  //delete item
                    integer liItem=(integer)((string)pkTarget);
                    if(giPanel==5){
                        if((integer)psStr==5 && liItem==giVarAreaItem){
                            gaVarAreas=llDeleteSubList(gaVarAreas,liItem-1,liItem-1);
                            gaVarAreasData=llDeleteSubList(gaVarAreasData,liItem-1,liItem-1);
                            giVarAreaTotal=llGetListLength(gaVarAreas);
                            if(giVarAreaItem>giVarAreaTotal){ 
                                giVarAreaItem=giVarAreaTotal;
                            }
                            llMessageLinked(LINK_THIS,6905,(string)giVarAreaItem,(string)giVarAreaTotal);
                            loadItemVars();
                        }
                    }else if(giPanel==6){
                        if((integer)psStr==6 && liItem==giVarCirItem){
                            gaVarCircles=llDeleteSubList(gaVarCircles,liItem-1,liItem-1);
                            gaVarCirclesData=llDeleteSubList(gaVarCirclesData,liItem-1,liItem-1);
                            giVarCirTotal=llGetListLength(gaVarCircles);
                            if(giVarCirItem>giVarCirTotal){ 
                                giVarCirItem=giVarCirTotal;
                            }
                            llMessageLinked(LINK_THIS,6906,(string)giVarCirItem,(string)giVarCirTotal);
                            loadItemVars();
                        }
                    }
                }else if(piNum==5990){  //load notecard
                    //llOwnerSay("Variations 5990: "+psStr+" // "+(string)pkTarget);
                    gaVarAreas=[];
                    gaVarAreasData=[];
                    gaVarCircles=[];
                    gaVarCirclesData=[];
                    list laVars;
                    integer liVars;
                    integer liN;
                    integer liColon;
                    string lsItem;
                    if(psStr!=""){
                        laVars=llParseString2List(psStr,["$$"],[]);
                        liVars=llGetListLength(laVars);
                        for(liN=0;liN<liVars;liN++){
                            lsItem=llList2String(laVars,liN);
                            liColon=llSubStringIndex(lsItem,":");
                            gaVarAreas+=llGetSubString(lsItem,0,liColon-1);
                            gaVarAreasData+=llGetSubString(lsItem,liColon+1,-1);
                        }
                        giVarAreaTotal=liVars;
                        giVarAreaItem=1;
                    }else{
                        giVarAreaTotal=0;
                        giVarAreaItem=0;
                    }
                    llMessageLinked(LINK_THIS,6905,(string)giVarAreaItem,(string)giVarAreaTotal);
                    
                    if((string)pkTarget!=""){
                        laVars=llParseString2List((string)pkTarget,["$$"],[]);
                        liVars=llGetListLength(laVars);
                        for(liN=0;liN<liVars;liN++){
                            lsItem=llList2String(laVars,liN);
                            liColon=llSubStringIndex(lsItem,":");
                            gaVarCircles+=llGetSubString(lsItem,0,liColon-1);
                            gaVarCirclesData+=llGetSubString(lsItem,liColon+1,-1);
                        }
                        giVarCirTotal=liVars;
                        giVarCirItem=1;
                    }else{
                        giVarCirTotal=0;
                        giVarCirItem=0;
                    }
                    llMessageLinked(LINK_THIS,6906,(string)giVarCirItem,(string)giVarCirTotal);
                    if(giPanel==5 || giPanel==6) loadItemVars();
                }
            }else if(psStr=="icon"){
                if(piNum==5000) giLastHudSize=0;   //reduce icon
                else if(piNum==5002) giLastHudSize=2;   //increase big
                else if(piNum==5001) giLastHudSize=1;   //increase small
                displayText(giPanel);
            }else if(psStr=="print"){   //send data to menu var for print to chat
                putvalor(1);
                if(piNum==5005){  //area data
                    llMessageLinked(LINK_THIS, 6505, (string)pkTarget+";"+llDumpList2String(gaVarAreas,"$$"), llDumpList2String(gaVarAreasData,"$$"));  //send data to Aux script
                }else{  //circle data
                    llMessageLinked(LINK_THIS, 6506, (string)pkTarget+";"+llDumpList2String(gaVarCircles,"$$"), llDumpList2String(gaVarCirclesData,"$$"));  //send data to Aux script
                }
            }else if(psStr=="rdata"){   //request areas or circles data from GLW to 2931-start  2933-write note  2935-modif data   6931-map
                                        //5001-areas   5002-circles
                //llOwnerSay("rdata "+(string)piNum+"   "+(string)pkTarget);
                putvalor(1);
                integer liNum;
                if(piNum==5001) liNum=llGetListLength(gaVarAreas);  //areas  number of variations
                else liNum=llGetListLength(gaVarCircles);   //circles
                integer liN;
                string lsDataItem;
                string lsDataWind;
                string lsItem;
                integer liCode=(integer)((string)pkTarget);  //2931,2933,2935,6931
                if(liNum>0){
                    for(liN=0;liN<liNum;liN++){
                        if(piNum==5001) lsItem=llList2String(gaVarAreas,liN);   //extracts an item from the Areas list corresponding to a variation
                        else lsItem=llList2String(gaVarCircles,liN);    //extracts an item from the Circles list corresponding to a variation
                        if(liCode==2933 || (integer)llGetSubString(lsItem,0,0)>0){    //if item is enabled  or  write note
                            if(lsDataItem!=""){ 
                                lsDataItem+="$$";
                                lsDataWind+="$$";
                            }
                            if(liCode==2933) lsDataItem+=lsItem;   //write note
                            else lsDataItem+=(string)(liN+1)+llGetSubString(lsItem,1,-1);  //add item number in string  //start
                            
                            if(piNum==5001) lsDataWind+=llList2String(gaVarAreasData,liN);
                            else lsDataWind+=llList2String(gaVarCirclesData,liN);
                        }
                    }
                }
                //llOwnerSay("var rdata "+(string)piNum+"   "+(string)liCode+"    "+lsDataItem+"   "+lsDataWind);
                if(piNum==5001) llMessageLinked(LINK_THIS, liCode, lsDataItem, lsDataWind);  //send area data to GLW or var menu script
                else llMessageLinked(LINK_THIS, liCode+1, lsDataItem, lsDataWind);  //send circles data to GLW or var menu script
                
            }
        }
    }
    
    dataserver(key query_id, string data)
    {
        integer liPanel;
        if (query_id == gkRequestSimSWPos){
            vector lvData=(vector)data;
            giAreaGlobalPosSW_x=(integer)lvData.x;
            giAreaGlobalPosSW_y=(integer)lvData.y;
            if(giAreaMod==0) giAreaMod=1;
            liPanel=5;
        }else if (query_id == gkRequestSimNEPos){
            vector lvData=(vector)data;
            giAreaGlobalPosNE_x=(integer)lvData.x;
            giAreaGlobalPosNE_y=(integer)lvData.y;
            if(giAreaMod==0) giAreaMod=1;
            liPanel=5;
        }else if (query_id == gkRequestCenterPos){
            vector lvData=(vector)data;
            giCirGlobalPosCenter_x=(integer)lvData.x;
            giCirGlobalPosCenter_y=(integer)lvData.y;
            if(giCircleMod==0) giCircleMod=1;
            liPanel=6;
        }else if (query_id == gkRequestRadiusPos){
            vector lvData=(vector)data;
            giCirGlobalPosRadius_x=(integer)lvData.x;
            giCirGlobalPosRadius_y=(integer)lvData.y;
            if(giCircleMod==0) giCircleMod=1;
            liPanel=6;
        }
        
        if(liPanel==5){
            if(giAreaGlobalPosSW_x>0 && giAreaGlobalPosSW_y>0 && giAreaGlobalPosNE_x>0 && giAreaGlobalPosNE_y>0){
                //send data to vars menu to give notice if you exceed 100 sims
                llMessageLinked(LINK_THIS, 6507, (string)giAreaGlobalPosSW_x+","+(string)giAreaGlobalPosSW_y+","+(string)giAreaGlobalPosNE_x+","+(string)giAreaGlobalPosNE_y, "");  
            }
        }else if(liPanel==6){ //calcRadius
            if(giCirGlobalPosCenter_x>0 && giCirGlobalPosRadius_x>0){
                giCirRadius=(integer)llVecDist(
                    <giCirGlobalPosCenter_x+giCirPosCenter_x,giCirGlobalPosCenter_y+giCirPosCenter_y,0>,
                    <giCirGlobalPosRadius_x+giCirPosRadius_x,giCirGlobalPosRadius_y+giCirPosRadius_y,0>);
                if(giCirRadius<30 || giCirRadius>1000) llOwnerSay("The radius has to be between 30 and 1000 meters");
                displayText(6);
            }
        }
    }
}











