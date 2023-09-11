rotation cvKB=<0.57582, 0.04939, 0.95131, 0.56989>;   //keyboard coords

rotation crP6BCIRCLE=<0.02373, 0.60941, 0.24596, 0.76740>;  //add del circle button LB_x,LB_y,RT_x,RT_y
rotation crP6BMAP=<0.48157, 0.61199, 0.69765, 0.76529>;  //center radius map button 
rotation crP6BDETECT=<0.17455, 0.43741, 0.56528, 0.59020>;  //get detect point button 
rotation crP6BPANELS=<0.73599, 0.58957, 0.99707, 0.90146>;  //lateral panels buttons 
rotation crP6BARROWS=<0.28035, 0.69614, 0.44491, 0.77096>;  //lateral panels buttons 
rotation crP6BSAVE=<0.25097, 0.61725, 0.46226, 0.67011>;  //lateral panels buttons 
rotation crP6MARGIN=<0.29887, 0.28043, 0.51115, 0.35976>;  //margin field fast keys
//fast keys in vars wind panel P9
rotation crP9ROSE=<0.53329, 0.67894, 0.95158, 0.93124>;  //speed fast keys 
rotation crP9SPEED=<0.50410, 0.57227, 0.80566, 0.64649>;  //speed fast keys
rotation crP9GUSTS=<0.49904, 0.44387, 0.88344, 0.48497>;  //gusts fast keys
rotation crP9SHIFT=<0.49924, 0.27395, 0.88835, 0.31856>;  //shift fast keys
rotation crP9PERIOD=<0.50410, 0.07141, 0.76189, 0.14885>;  //speed fast keys   
//fast keys in vars wave panel PA
rotation crPAHEIGHT=<0.51530, 0.74297, 0.88827, 0.81449>;  
rotation crPASPEED=<0.50974, 0.57722, 0.81590, 0.64177>;  
rotation crPALENGTH=<0.49839, 0.44732, 0.89375, 0.48428>;  
rotation crPAVHEIGHT=<0.50417, 0.26996, 0.88270, 0.31762>;  
rotation crPAVLENGTH=<0.50417, 0.10973, 0.88827, 0.14383>;  
//fast keys in vars currents panel PB
rotation crPBSPEED=<0.50421, 0.74638, 0.87162, 0.81789>;  
rotation crPBROSE=<0.52065, 0.46412, 0.93842, 0.71248>;  
rotation crPBWDEPTH=<0.50977, 0.24614, 0.91058, 0.31422>;  
rotation crPBDEPTH=<0.69905, 0.35555, 0.92728, 0.41372>;  
//map buttons panel 7
rotation crP7BREQZONE=<0.02077, 0.59083, 0.70431, 0.73618>;  
rotation crP7BSIMZONE=<0.17608, 0.39261, 0.92213, 0.54788>;  
rotation crP7BMAPZONE=<0.08020, 0.04254, 0.88912, 0.39261>;  

vector cvPOSPANELONG=<0.00340,-0.29649, 0.00860>;   
vector cvPOSPANELONS=<-0.00189,-0.00060,0.0055>;
vector cvPOSPANELOFF=<0.0,-0.00060,0.0087>;
vector cvSizeMin=<0.01,0.01,0.01>;
vector cvPanelSizeG=<0.01958, 0.20921, 0.34554>;
vector cvPanelSizeS=<0.01246, 0.22456, 0.21988>;
rotation crBPANELX=<0.89855, 0.94071, 1.0, 1.0>;

integer giVarAreaItem;
integer giVarAreaTotal;
integer giVarCirItem;
integer giVarCirTotal;

integer giInputChannel;
integer giDialogChannel;
integer giListenHandle2;
integer giDelItem;
integer giPanel;
integer giPanelVars;
integer giField;
integer giCast;
integer giInputPanel;
integer giIsLock;
list gaAdmins;
integer swdbg;


//link objects
integer giPANELAREA;
integer giPANELCIRCLE;
integer giPANELMAP;
integer giPANELVARDATA;
integer giPANELVARWIND;
integer giPANELVARWAV;
integer giPANELVARCUR;
integer giVARTEXT;
integer giTEXT;


//Map Panel 7 =======>
//vector cvPOSTEXTG=<-0.01061, 0.04576, 0.10109>;  //big hud position text
vector cvPOSTEXTG=<-0.01061, 0.04576, 0.08361>;  //big hud position text
vector cvPOSTEXTS=<-0.01061, -0.01025, 0.14226>; //small hud position text
vector cvPOSTEXTA=<-0.01061, -0.01025, 0.239>;   //no attached positon text

string gsMapSimSW;
integer giMapGlobalPosSW_x;
integer giMapGlobalPosSW_y;
string gsMapSimNE;
integer giMapGlobalPosNE_x;
integer giMapGlobalPosNE_y;

integer giLastHudSize;
key gkRequestSimSWPos;
key gkRequestSimNEPos;
string gsUsbMap;
string gsUsbProgress;
integer giCurrentLine;
key gkRequestNoteId;
key gkRequestCornerId;
integer giTotRoute;
list gaRoute;
list gaRoute2;
string gsVarAreasItems;
string gsVarAreasWind;
string gsVarCirclesItems;
string gsVarCirclesWind;
integer giWindDir;        //base wind dir for wind speed variations map
integer giWindSpeed;      //base wind speed for wind dir variations map  
integer giCurrentSpeed;        //base current dir for current dir variations map
integer giCurrentDir;        //base current dir for current speed variations map
integer giWaveHeight;    //base wave height for waves variations map
integer giMapSwMap=1;
integer giMapSwCourse=1;
integer giMapSwVars=1;
integer giMapSwSquare;
integer giMapOffsetWest;
integer giMapOffsetNorth;
integer giMapOffsetEast;
integer giMapOffsetSouth;

//===============>AUXILIAR FUNCTIONS FOR LOCAL VARIATIONS
fsay(key pkTarget, string tex)
{
    integer nn=llGetAttached();
    if(pkTarget){
        if(nn==0 && llGetAgentSize(pkTarget)==ZERO_VECTOR) llInstantMessage(pkTarget,tex);
        else llOwnerSay(tex);
        //else llRegionSayTo(pkTarget,0,tex); 
    }else{
        if(nn==0) llSay(0,tex);
        else llOwnerSay(tex);
        //else llRegionSayTo(pkTarget,0,tex);
    }
}

printVarsParams(integer piType, string psItemsData, string psWindsData, key pkTarget ) //display variations parameters in params panel Areas and Circles
{
    list caWindNames=["Wnd Dir","Wnd Speed","Wnd Gusts","Wnd Shift","Wnd Period",
                   "Wav Height","Wav Speed","Wav Length","Var Height","Var Length",
                   "steer effect","speed effect","Cur Speed","Cur Dir","Water Depth"];
    list caItemNames;
    if(piType==5) caItemNames=["Active","Sim SW","Sim NE","Margin","Overlap"];  //areas
    else caItemNames=["Active","Center","Radius","Margin","Overlap"];  //areas
        
    list laItemsData=llParseString2List(psItemsData,["$$"],[]);                   
    list laWindsData=llParseString2List(psWindsData,["$$"],[]);                   

    string lsTex;
    integer liItems=llGetListLength(laItemsData);
    integer liItem;
    list laIData;
    integer liParams;
    integer liParam;
    string lsVal;
    integer liNum;
    integer liValue1;
    integer liValue2;

    fsay(pkTarget," ");
    if(piType==5) fsay(pkTarget,"GLW Area Items Parameters");
    else fsay(pkTarget,"GLW Circle Items Parameters");

    for(liItem=0;liItem<liItems;liItem++){
        laIData=llCSV2List(llList2String(laItemsData,liItem));
        if(piType==5) lsTex="Area Item #"+(string)(liItem+1)+": ";
        else lsTex="Circle Item #"+(string)(liItem+1)+": ";
        lsTex+=llList2String(caItemNames,0)+": ";
        if((integer)llList2String(laIData,0)==0) lsTex+="No";
        else lsTex+="Yes";
        lsTex+="; "+llList2String(caItemNames,1)+": "+llList2String(laIData,1);   //sim name
        if(piType==5){ //area
            lsTex+="; "+llList2String(caItemNames,2)+": "+llList2String(laIData,4);  //sim NE name
            lsTex+="; "+llList2String(caItemNames,3)+": "+llList2String(laIData,7);  //margin
            lsTex+="; "+llList2String(caItemNames,4)+": ";
            if(llList2String(laIData,8)=="0") lsTex+="No";  //overlap
            else if(llList2String(laIData,8)=="1") lsTex+="Yes";  //overlap
            else if(llList2String(laIData,8)=="2") lsTex+="Ignore";  //overlap
        }else{   //circle
            liValue1=(integer)llList2String(laIData,2);
            liValue1=liValue1-((integer)(liValue1/256.0)*256);
            liValue2=(integer)llList2String(laIData,2);
            liValue2=liValue2-((integer)(liValue2/256.0)*256);
            lsTex+=" ("+(string)liValue1+","+(string)liValue2+")";   //local coords
            lsTex+="; "+llList2String(caItemNames,2)+": "+llList2String(laIData,7);  //radious
            lsTex+="; "+llList2String(caItemNames,3)+": "+llList2String(laIData,8);  //margin
            lsTex+="; "+llList2String(caItemNames,4)+": ";
            if(llList2String(laIData,9)=="0") lsTex+="No";  //overlap
            else if(llList2String(laIData,9)=="1") lsTex+="Yes";  //overlap
            else if(llList2String(laIData,9)=="2") lsTex+="Ignore";  //overlap
        }
        fsay(pkTarget,lsTex);
        lsTex="";
        laIData=llCSV2List(llList2String(laWindsData,liItem));
        lsTex="Wind Data: ";
        liParams=llGetListLength(laIData);
        liNum=0;
        for(liParam=0;liParam<liParams;liParam++){
            lsVal=llList2String(laIData,liParam);
            if(lsVal!=""){
                if(liParam==10 || liParam==11){
                    if(lsVal=="0") lsVal="No";
                    else if(lsVal=="1") lsVal="Yes";
                }
                if(liNum>0)lsTex+="; ";
                lsTex+=llList2String(caWindNames,liParam)+": "+lsVal;
                liNum++;
            }
        }
        if(liNum==0) lsTex+="No Variations";
        fsay(pkTarget,lsTex);
    }
}
//<===============AUXILIAR FUNCTIONS FOR LOCAL VARIATIONS

getLinkNums() 
{
    integer i;
    integer linkcount=llGetNumberOfPrims();
    string str;
    for (i=1;i<=linkcount;++i) {
        str=llGetLinkName(i);
        if (str=="panelarea") giPANELAREA=i;
        else if (str=="panelcircle") giPANELCIRCLE=i;
        else if (str=="panelmap") giPANELMAP=i;
        else if (str=="vartext") giVARTEXT=i;
        else if (str=="panelvardata") giPANELVARDATA=i;
        else if (str=="panelvarwind") giPANELVARWIND=i;
        else if (str=="panelvarwave") giPANELVARWAV=i;
        else if (str=="panelvarcur") giPANELVARCUR=i;
        else if (str=="text") giTEXT=i;
    }
}

integer keyboard(vector pvST)
{
    float cx;
    float cy;
    integer x=0;
    integer y=0;
    integer n=0;
    float IncX=(cvKB.z-cvKB.x)/3;
    float IncY=(cvKB.s-cvKB.y)/4;
    for(y=1;y<5;y++){
        cy=cvKB.y+(IncY*y);
        for(x=1;x<4;x++){
            cx=cvKB.x+(IncX*x);
            if(pvST.x<cx && pvST.y<cy && n==0){ 
                n=(y-1)*3+x;
            }
        }
    }
    if(n==2) n=0;
    else if(n==1){ 
        if(pvST.y<cvKB.y+IncY/2) n=-2;
        else n=-1;
    }else if(n==3) n=-3;
    else n=n-3;
    return n;
}

touchNumber3(integer piPanel, vector pvST, rotation prCoord, integer piCols, integer piRows, string psNumbers, integer piChars, integer piField)
{
    integer n;
    if(piCols>1){
        n=(integer)((pvST.x-prCoord.x) / ((prCoord.z-prCoord.x)/piCols));
        if(piRows>1){ 
            if(pvST.y-prCoord.y < (prCoord.s-prCoord.y)/2) n+=piCols;
        }
        n=(integer)llGetSubString(psNumbers,n*piChars,n*piChars+piChars-2);
    }else{
        n=piRows-(integer)((pvST.y-prCoord.y) / ((prCoord.s-prCoord.y)/piRows))-1;
        n=(integer)llGetSubString(psNumbers,n*piChars,n*piChars+piChars-2);
    }
    llMessageLinked(LINK_THIS,5915+piPanel,(string)n,(string)piField);   //num=5920 to 5926
}

setTouch(integer piPanel, key pkTarget, vector pvST)  //panel circle and area
{
    integer liNumField;
    if(pvST.x>crP6BCIRCLE.x && pvST.y>crP6BCIRCLE.y && pvST.x<crP6BCIRCLE.z && pvST.y<crP6BCIRCLE.s){   //add del item button
        llMessageLinked(LINK_THIS,5980,"","");  //hidenPanelVars();
        if(pvST.y-crP6BCIRCLE.y < (crP6BCIRCLE.s-crP6BCIRCLE.y)/2.0){ //del item
            liNumField=11;  //del button
            llListenRemove(giListenHandle2);
            if(piPanel==5 && giVarAreaItem>0){
                giListenHandle2=llListen(giDialogChannel,"",pkTarget,"");
                giDelItem=100+giVarAreaItem;
                llDialog(pkTarget, "Are you sure to delete the AREA item #"+(string)giVarAreaItem+"?", ["[Yes]","[No]"],giDialogChannel);
            }else if(piPanel==6 && giVarCirItem>0){
                giListenHandle2=llListen(giDialogChannel,"",pkTarget,"");
                giDelItem=200+giVarCirItem;
                llDialog(pkTarget, "Are you sure to delete the CIRCLE item #"+(string)giVarCirItem+"?", ["{Yes}","{No}"],giDialogChannel);
            }
        }else{
            if(giVarAreaTotal+giVarCirTotal==20){ 
                fsay(pkTarget,"You can only add 20 Local Variations");
                return;
            }
            liNumField=10; //add item button
            llMessageLinked(LINK_THIS,5800+piPanel,"",(string)liNumField);   //to variations field 10 
        }
        return;
    }
    
    if((piPanel==5 && giVarAreaItem==0) || (piPanel==6 && giVarCirItem==0)){ 
        llOwnerSay("You have to add some item");
        return;
    }

    if(pvST.x>cvKB.x && pvST.y>cvKB.y && pvST.x<cvKB.z && pvST.y<cvKB.s){   //teclado
        llMessageLinked(LINK_THIS,5981,(string)keyboard(pvST),pkTarget);
        return;
    }
    if(pvST.x>crP6BARROWS.x && pvST.y>crP6BARROWS.y && pvST.x<crP6BARROWS.z && pvST.y<crP6BARROWS.s){   //arrows buttons
        if(pvST.x-crP6BARROWS.x < (crP6BARROWS.z-crP6BARROWS.x)/2.0) liNumField=22;  //left arrow button
        else liNumField=23; //right arrow button
        llMessageLinked(LINK_THIS,5800+piPanel,"",(string)liNumField);   //to variations 5805, 5806
        return;
    }
    if(pvST.x>crP6BMAP.x && pvST.y>crP6BMAP.y && pvST.x<crP6BMAP.z && pvST.y<crP6BMAP.s){   //center/radius/SW/NE map button
        if(pvST.y-crP6BMAP.y < (crP6BMAP.s-crP6BMAP.y)/2.0) liNumField=13;  //radius/NE map button
        else liNumField=12;    
        if(llGetAttached()>0){                                             //center/SE map button
            llMessageLinked(LINK_THIS,5800+piPanel,"",(string)liNumField);   //to variations 
        }else{
            llRegionSayTo(pkTarget,0,"This function only works when the hud is attached.");    
        }
        return;
    }
    if(pvST.x>crP6BDETECT.x && pvST.y>crP6BDETECT.y && pvST.x<crP6BDETECT.z && pvST.y<crP6BDETECT.s){   //get detect point button
        if(pvST.x-crP6BDETECT.x < (crP6BDETECT.z-crP6BDETECT.x)/2.0)  liNumField=14;  //get button
        else liNumField=15; //detect button
        if(pvST.y-crP6BDETECT.y < (crP6BDETECT.s-crP6BDETECT.y)/2.0) liNumField+=2;  //radius/NE button
        //else //center
        if(liNumField==14 || liNumField==16){  //gets buttons
            giInputPanel=piPanel;
            giField=liNumField;
            giListenHandle2 = llListen( giInputChannel, "", "", "");     
            llTextBox(pkTarget, "LM: ", giInputChannel);  //???
        }else{   //detect buton
            llMessageLinked(LINK_THIS,5800+piPanel,"",(string)liNumField);   //to variations 
        }
        return;
    }
    if(pvST.x>crP6BPANELS.x && pvST.y>crP6BPANELS.y && pvST.x<crP6BPANELS.z && pvST.y<crP6BPANELS.s){   //auxiliar panels buttons
        float lfHField=(crP6BPANELS.s-crP6BPANELS.y)/4.0;
        if(pvST.y-crP6BPANELS.y < lfHField) liNumField=21; //current button
        else if(pvST.y-crP6BPANELS.y < lfHField*2) liNumField=20;  //wav button
        else if(pvST.y-crP6BPANELS.y < lfHField*3) liNumField=19; //wind button
        else liNumField=18;    //show button
        llMessageLinked(LINK_THIS,5800+piPanel,"",(string)liNumField);   //5805,5806 to variations 
        return;
    }
    if(pvST.x>crP6MARGIN.x && pvST.y>crP6MARGIN.y && pvST.x<crP6MARGIN.z && pvST.y<crP6MARGIN.s){   //margin field fast keys
        touchNumber3(piPanel,pvST,crP6MARGIN,3,2,"000,025,050,075,100,100",4,1);
        return;
    }
    if(pvST.x>crP6BSAVE.x && pvST.y>crP6BSAVE.y && pvST.x<crP6BSAVE.z && pvST.y<crP6BSAVE.s){   //save item
        llMessageLinked(LINK_THIS,5982,(string)piPanel,"");
        return;
    }
}



setTouchP(integer piPanel, integer piLinkPanel, vector pvST)  //touch on panels face 0  rapid keys
{
    if(piPanel==9){  //vars wind panel
        if(pvST.x>crP9ROSE.x && pvST.y>crP9ROSE.y && pvST.x<crP9ROSE.z && pvST.y<crP9ROSE.s){   //rose
            integer x=(integer)((pvST.x-crP9ROSE.x) / ((crP9ROSE.z-crP9ROSE.x)/3));
            integer y=(integer)((pvST.y-crP9ROSE.y) / ((crP9ROSE.s-crP9ROSE.y)/3));
            integer n=y*3+x;
            n=(integer)llGetSubString("225,180,135,270,000,090,315,000,045",n*4,n*4+2);
            llMessageLinked(LINK_THIS,5915+piPanel,(string)n,"1");
        }else if(pvST.x>crP9SPEED.x && pvST.y>crP9SPEED.y && pvST.x<crP9SPEED.z && pvST.y<crP9SPEED.s){   //speed field fast keys
            touchNumber3(piPanel,pvST,crP9SPEED,3,2,"08,11,15,18,21,25",3,2);
        }else if(pvST.x>crP9GUSTS.x && pvST.y>crP9GUSTS.y && pvST.x<crP9GUSTS.z && pvST.y<crP9GUSTS.s){   //gusts field fast keys
            touchNumber3(piPanel,pvST,crP9GUSTS,4,1,"00,10,25,50",3,3);
        }else if(pvST.x>crP9SHIFT.x && pvST.y>crP9SHIFT.y && pvST.x<crP9SHIFT.z && pvST.y<crP9SHIFT.s){   //shift field fast keys
            touchNumber3(piPanel,pvST,crP9SHIFT,4,1,"00,10,20,30",3,4);
        }else if(pvST.x>crP9PERIOD.x && pvST.y>crP9PERIOD.y && pvST.x<crP9PERIOD.z && pvST.y<crP9PERIOD.s){   //period field fast keys
            touchNumber3(piPanel,pvST,crP9PERIOD,2,2,"030,060,090,120",4,5);
        }
    }else if(piPanel==10){  //vars wav panel
        if(pvST.x>crPAHEIGHT.x && pvST.y>crPAHEIGHT.y && pvST.x<crPAHEIGHT.z && pvST.y<crPAHEIGHT.s){   //height field fast keys
            touchNumber3(piPanel,pvST,crPAHEIGHT,3,2,"00,05,10,15,20,25",3,1);
        }else if(pvST.x>crPASPEED.x && pvST.y>crPASPEED.y && pvST.x<crPASPEED.z && pvST.y<crPASPEED.s){   //speed field fast keys
            touchNumber3(piPanel,pvST,crPASPEED,3,2,"03,05,08,10,12,15",3,2);
        }else if(pvST.x>crPALENGTH.x && pvST.y>crPALENGTH.y && pvST.x<crPALENGTH.z && pvST.y<crPALENGTH.s){   //length field fast keys
            touchNumber3(piPanel,pvST,crPALENGTH,3,1,"010,050,100",4,3);
        }else if(pvST.x>crPAVHEIGHT.x && pvST.y>crPAVHEIGHT.y && pvST.x<crPAVHEIGHT.z && pvST.y<crPAVHEIGHT.s){   //variance height field fast keys
            touchNumber3(piPanel,pvST,crPAVHEIGHT,4,1,"00,10,20,30",3,4);
        }else if(pvST.x>crPAVLENGTH.x && pvST.y>crPAVLENGTH.y && pvST.x<crPAVLENGTH.z && pvST.y<crPAVLENGTH.s){   //variance length field fast keys
            touchNumber3(piPanel,pvST,crPAVLENGTH,4,1,"00,10,20,30",3,5);
        }
    }else if(piPanel==11){  //vars currents panel
        if(pvST.x>crPBSPEED.x && pvST.y>crPBSPEED.y && pvST.x<crPBSPEED.z && pvST.y<crPBSPEED.s){   //speed field fast keys
            touchNumber3(piPanel,pvST,crPBSPEED,3,2,"00,10,20,30,40,50",3,1);
        }else if(pvST.x>crPBROSE.x && pvST.y>crPBROSE.y && pvST.x<crPBROSE.z && pvST.y<crPBROSE.s){   //rose
            integer x=(integer)((pvST.x-crPBROSE.x) / ((crPBROSE.z-crPBROSE.x)/3));
            integer y=(integer)((pvST.y-crPBROSE.y) / ((crPBROSE.s-crPBROSE.y)/3));
            integer n=y*3+x;
            n=(integer)llGetSubString("225,180,135,270,000,090,315,000,045",n*4,n*4+2);
            llMessageLinked(LINK_THIS,5915+piPanel,(string)n,"2");
        }else if(pvST.x>crPBWDEPTH.x && pvST.y>crPBWDEPTH.y && pvST.x<crPBWDEPTH.z && pvST.y<crPBWDEPTH.s){   //depty field fast keys
            touchNumber3(piPanel,pvST,crPBWDEPTH,4,2,"00,05,06,08,10,15,18,20",3,3);
        }else if(pvST.x>crPBDEPTH.x && pvST.y>crPBDEPTH.y && pvST.x<crPBDEPTH.z && pvST.y<crPBDEPTH.s){   //depth button
            integer li=(integer)(llWater(ZERO_VECTOR)-llGround(ZERO_VECTOR)+0.5);
            if(li<5) li=5;
            llMessageLinked(LINK_THIS,5915+piPanel,(string)li,"3");
        }
    }
}


//map panel
displayText()
{
    //llOwnerSay("display text "+(string)giLastHudSize);
    string lsTex="SW: "+gsMapSimSW+"\nNE: "+gsMapSimNE+"\nUSB: ";
    if(gsUsbProgress!=""){
        lsTex+=gsUsbProgress;
    }else{
        lsTex+=gsUsbMap;
    }
    lsTex+="\nSims: W:"+(string)giMapOffsetWest+"  N:"+(string)giMapOffsetNorth+"  E:"+(string)giMapOffsetEast+"  S:"+(string)giMapOffsetSouth;
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

setTouch7(key pkTarget, vector pvST)  //panel 7 map
{
    integer liNumField;
    if(pvST.x>crP7BREQZONE.x && pvST.y>crP7BREQZONE.y && pvST.x<crP7BREQZONE.z && pvST.y<crP7BREQZONE.s){   //request, load, corners
        if(pvST.y-crP7BREQZONE.y < (crP7BREQZONE.s-crP7BREQZONE.y)/2.0){
            if(pvST.x-crP7BREQZONE.x < (crP7BREQZONE.z-crP7BREQZONE.x)/2.0){  //load usb
                llMessageLinked(LINK_THIS,4000,"loadusb",pkTarget);
            }else{ //auto detect corners
                integer liN=llGetListLength(gaRoute2);
                if(gsUsbMap=="" || liN<4){
                    llOwnerSay("You have to load a USB card");
                }else{
                    integer li;
                    integer liSW_x=999999;
                    integer liSW_y=999999;
                    integer liNE_x=0;
                    integer liNE_y=0;
                    for(li=0;li<liN;li+=2){
                        if(llList2Integer(gaRoute2,li)<liSW_x) liSW_x=llList2Integer(gaRoute2,li);   
                        if(llList2Integer(gaRoute2,li+1)<liSW_y) liSW_y=llList2Integer(gaRoute2,li+1);   
                        if(llList2Integer(gaRoute2,li)>liNE_x) liNE_x=llList2Integer(gaRoute2,li);   
                        if(llList2Integer(gaRoute2,li+1)>liNE_y) liNE_y=llList2Integer(gaRoute2,li+1);   
                    }
                    liSW_x-=256;
                    liSW_y-=256;
                    liNE_x+=256;
                    liNE_y+=256;
                    if(giMapSwSquare){
                        integer liWitch=liNE_x-liSW_x;
                        integer liHeight=liNE_y-liSW_y;
                        if(liHeight>liWitch){
                            li=(liHeight-liWitch)/2;
                            liSW_x-=li;
                            liNE_x+=li;
                        }else if(liHeight<liWitch){
                            li=(liWitch-liHeight)/2;
                            liSW_y-=li;
                            liNE_y+=li;
                        }
                    }
                    
                    giMapGlobalPosSW_x=liSW_x;
                    giMapGlobalPosSW_y=liSW_y;            
                    giMapGlobalPosNE_x=liNE_x;
                    giMapGlobalPosNE_y=liNE_y;
                    string ls=(string)giMapGlobalPosSW_x+","+(string)giMapGlobalPosSW_y+","+(string)giMapGlobalPosNE_x+","+(string)giMapGlobalPosNE_y;
                    //llOwnerSay("touch7 "+ls);
                    llMessageLinked(LINK_THIS,1215,ls,"");  //request region name
                    
                }        
            }
        }else{   //request map
            if(pvST.x-crP7BREQZONE.x < (crP7BREQZONE.z-crP7BREQZONE.x)/2.0){  //request map
                gsVarAreasItems="";
                gsVarAreasWind="";
                gsVarCirclesItems="";
                gsVarCirclesWind="";  
                giWindDir=0;
                giWindSpeed=0;
                giCurrentSpeed=0;
                giCurrentDir=0;
                giWaveHeight=0;
                llMessageLinked(LINK_THIS, 2983, "", ""); //read wind base direction and speed and current base direction for map
            }
        }
        return;
    }    

    if(pvST.x>crP7BSIMZONE.x && pvST.y>crP7BSIMZONE.y && pvST.x<crP7BSIMZONE.z && pvST.y<crP7BSIMZONE.s){   //sim zone map button
        if(pvST.x-crP7BSIMZONE.x > (crP7BSIMZONE.z-crP7BSIMZONE.x)*0.54){  //display corners button
            if(pvST.y-crP7BSIMZONE.y < (crP7BSIMZONE.s-crP7BSIMZONE.y)/2.0){  //display NE corner button
                if(gsMapSimNE!="") llMapDestination(gsMapSimNE,<125,125,25>,ZERO_VECTOR);
                else llOwnerSay("NE Sim is not defined");
            }else{   //display SW corner button
                if(gsMapSimSW!="") llMapDestination(gsMapSimSW,<125,125,25>,ZERO_VECTOR);
                else llOwnerSay("SW Sim is not defined");
            }
        }else{   //get in and detect buttons
            if(pvST.x-crP7BSIMZONE.x < (crP7BSIMZONE.z-crP7BSIMZONE.x)*0.25){  //get in sim  button
                giInputPanel=7;
                giListenHandle2 = llListen( giInputChannel, "", "", "");     
                if(pvST.y-crP7BSIMZONE.y < (crP7BSIMZONE.s-crP7BSIMZONE.y)/2.0){  //get in NE sim button
                    giField=16;
                    llTextBox(pkTarget, "Put the NE corner LM: ", giInputChannel);
                }else{   //get in SW corner button
                    giField=14;
                    llTextBox(pkTarget, "Put the SW corner LM: ", giInputChannel);
                }
            }else{  //detect corners button            
                if(pvST.y-crP7BSIMZONE.y < (crP7BSIMZONE.s-crP7BSIMZONE.y)/2.0){  //detect NE sim button
                    gsMapSimNE=llGetRegionName();
                    giMapGlobalPosNE_x=0;
                    giMapGlobalPosNE_y=0;
                    gkRequestSimNEPos=llRequestSimulatorData(gsMapSimNE,DATA_SIM_POS);
                }else{   //detect SW corner button
                    gsMapSimSW=llGetRegionName();
                    giMapGlobalPosSW_x=0;
                    giMapGlobalPosSW_y=0;
                    gkRequestSimSWPos=llRequestSimulatorData(gsMapSimSW,DATA_SIM_POS);
                } 
                displayText();
            }
        }
        return;
    }
    if(pvST.x>crP7BMAPZONE.x && pvST.y>crP7BMAPZONE.y && pvST.x<crP7BMAPZONE.z && pvST.y<crP7BMAPZONE.s){   //displzament map buttons
        if(pvST.y-crP7BMAPZONE.y < (crP7BMAPZONE.s-crP7BMAPZONE.y)*0.40){  //South arrows
            if((pvST.x-crP7BMAPZONE.x > (crP7BMAPZONE.z-crP7BMAPZONE.x)*0.45) && 
              (pvST.x-crP7BMAPZONE.x < (crP7BMAPZONE.z-crP7BMAPZONE.x)*0.55)){  
                if(pvST.y-crP7BMAPZONE.y < (crP7BMAPZONE.s-crP7BMAPZONE.y)*0.20){  //Down South arrows
                    giMapOffsetSouth++;
                }else{  //up South arrows
                    giMapOffsetSouth--;
                }
            }
        }else if(pvST.y-crP7BMAPZONE.y > (crP7BMAPZONE.s-crP7BMAPZONE.y)*0.62){  //North arrows
            if((pvST.x-crP7BMAPZONE.x > (crP7BMAPZONE.z-crP7BMAPZONE.x)*0.45) && 
              (pvST.x-crP7BMAPZONE.x < (crP7BMAPZONE.z-crP7BMAPZONE.x)*0.55)){  
                if(pvST.y-crP7BMAPZONE.y > (crP7BMAPZONE.s-crP7BMAPZONE.y)*0.78){  //Up North arrows
                    giMapOffsetNorth++;
                }else{  //Down north arrows
                    giMapOffsetNorth--;
                }
            }
        }else if(pvST.x-crP7BMAPZONE.x < (crP7BMAPZONE.z-crP7BMAPZONE.x)*0.18){  //west arrows
            if(pvST.x-crP7BMAPZONE.x < (crP7BMAPZONE.z-crP7BMAPZONE.x)*0.08){  //left West arrows
                giMapOffsetWest++;
            }else{  //right west arrows
                giMapOffsetWest--;
            }
        }else if(pvST.x-crP7BMAPZONE.x > (crP7BMAPZONE.z-crP7BMAPZONE.x)*0.82){  //east arrows
            if(pvST.x-crP7BMAPZONE.x < (crP7BMAPZONE.z-crP7BMAPZONE.x)*0.91){  //left east arrows
                giMapOffsetEast--;
            }else{  //right east arrows
                giMapOffsetEast++;
            }
        }
        displayText();
    }
}

requestMap()
{
    //llOwnerSay("request map");
    if(giMapGlobalPosSW_x>0 && giMapGlobalPosSW_y>0 && giMapGlobalPosNE_x>0 && giMapGlobalPosNE_y>0){
        integer liSimsNum=llAbs((giMapGlobalPosNE_x/256)-(giMapGlobalPosSW_x/256)+1+giMapOffsetWest+giMapOffsetEast)*
                llAbs((giMapGlobalPosNE_y/256)-(giMapGlobalPosSW_y/256)+1+giMapOffsetSouth+giMapOffsetNorth);
        llOwnerSay("Requesting "+(string)liSimsNum+" sims map...");
        llMessageLinked(LINK_THIS,1217,"",""); //request init

        if(llGetListLength(gaRoute2)>4){
            llMessageLinked(LINK_THIS,1218,llList2CSV(gaRoute2),""); //send usb
        }
        
        if(gsVarAreasItems!="" || gsVarCirclesItems!=""){
            //llOwnerSay("var items");
            list laItems;
            list laWinds;
            integer liNItems;
            integer liN;            
            string lsVarAreas;
            string lsVarCircles;
            if(gsVarAreasItems!=""){
                laItems=llParseString2List(gsVarAreasItems,["$$"],[]);
                laWinds=llParseString2List(gsVarAreasWind,["$$"],[]);
                liNItems=llGetListLength(laItems);
                lsVarAreas=llList2String(laItems,0)+":"+llList2String(laWinds,0);
                for(liN=1;liN<liNItems;liN++){
                    lsVarAreas+="$$"+llList2String(laItems,liN)+":"+llList2String(laWinds,liN);
                }
            }

            if(gsVarCirclesItems!=""){
                laItems=llParseString2List(gsVarCirclesItems,["$$"],[]);
                laWinds=llParseString2List(gsVarCirclesWind,["$$"],[]);
                liNItems=llGetListLength(laItems);
                lsVarCircles=llList2String(laItems,0)+":"+llList2String(laWinds,0);
                for(liN=1;liN<liNItems;liN++){
                    lsVarCircles+="$$"+llList2String(laItems,liN)+":"+llList2String(laWinds,liN);
                }
            }
            //llOwnerSay("GLW circle data "+lsVarCircles);

            llMessageLinked(LINK_THIS,1219,lsVarAreas,lsVarCircles); //send vars
            gsVarAreasItems="";
            gsVarAreasWind="";
            gsVarCirclesItems="";
            gsVarCirclesWind="";
        }

        string ls=(string)(giMapGlobalPosSW_x/256)+","+(string)(giMapGlobalPosSW_y/256)+","+(string)(giMapGlobalPosNE_x/256)+","+(string)(giMapGlobalPosNE_y/256)+
            ","+(string)giMapOffsetWest+","+(string)giMapOffsetNorth+","+(string)giMapOffsetEast+","+(string)giMapOffsetSouth+
            ","+(string)giMapSwMap+","+(string)giMapSwCourse+","+(string)giMapSwVars+
            ","+(string)giWindDir+","+(string)giWindSpeed+","+(string)giCurrentSpeed+","+(string)giCurrentDir+","+(string)giWaveHeight;
        //llOwnerSay("requestmap "+ls);
        llMessageLinked(LINK_THIS,1220,ls,""); //start request
    }
}

readFirstNCLine()  //read usb notecard
{
    giCurrentLine=0;
    gaRoute=[];
    gaRoute2=[];
    llOwnerSay("Loading "+gsUsbMap);
    gkRequestNoteId=llGetNotecardLine(gsUsbMap, giCurrentLine);
}

readNextNCLine(string psData) 
{
    integer liN=llSubStringIndex(psData,",");
    vector lvCoord;
    string lsData= llStringTrim(psData, STRING_TRIM);;
    if(lsData!=""){
        if(liN>=0){
            lsData=llGetSubString(lsData,0,liN-1);
        } 
        liN=llSubStringIndex(lsData,"secondlife/");
        if(liN>=0){
            lsData=llGetSubString(lsData,liN+11,-1);
        }else{
            liN=llSubStringIndex(lsData,"secondlife://");
            if(liN>=0){
                lsData=llGetSubString(lsData,liN+13,-1);
            }
        }
        list mylist=llParseString2List(lsData,["/"],[]);
        if(llGetListLength(mylist)!=4){
            llOwnerSay("Wrong line "+psData);
        }else{
            lvCoord.x=llList2Integer(mylist,1);
            lvCoord.y=llList2Integer(mylist,2);
            lvCoord.z=llList2Integer(mylist,3);
            gaRoute+=[llUnescapeURL(llList2String(mylist,0)),lvCoord]; 
        }
    }
    gkRequestNoteId=llGetNotecardLine(gsUsbMap, ++giCurrentLine);
    gsUsbProgress="Load Line "+(string)giCurrentLine;
    displayText();
}

loadCornerSim()
{
    if(++giCurrentLine<giTotRoute){
        string lv=llList2String(gaRoute,giCurrentLine*2);
        gkRequestCornerId = llRequestSimulatorData(lv,DATA_SIM_POS);    
        gsUsbProgress="Load Data "+(string)giCurrentLine+"/"+(string)giTotRoute;
        displayText();
    }else{
        gaRoute=[];
        gsUsbProgress="";
        llOwnerSay("The route has been loaded");
        displayText();
    }
}

putnum()
{
    if(giPANELMAP>0){
        vector lvTemp;
        if(giMapSwMap) lvTemp=<0,1,0>;
        else lvTemp=<1,1,1>;
        llSetLinkPrimitiveParamsFast(giPANELMAP,[PRIM_COLOR,1,lvTemp,1.0]);
        if(giMapSwCourse) lvTemp=<0,1,0>;
        else lvTemp=<1,1,1>;
        llSetLinkPrimitiveParamsFast(giPANELMAP,[PRIM_COLOR,2,lvTemp,1.0]);
        if(giMapSwVars) lvTemp=<0,1,0>;
        else lvTemp=<1,1,1>;
        llSetLinkPrimitiveParamsFast(giPANELMAP,[PRIM_COLOR,3,lvTemp,1.0]);
        if(giMapSwSquare) lvTemp=<0,1,0>;
        else lvTemp=<1,1,1>;
        llSetLinkPrimitiveParamsFast(giPANELMAP,[PRIM_COLOR,4,lvTemp,1.0]);
    }
}

default
{
    state_entry()
    {
        swdbg=(integer)llLinksetDataRead("ISDsetini");
        getLinkNums();
        giDialogChannel = -2 - (integer)("0x" + llGetSubString( (string)llGetKey(), -7, -1) );
        giInputChannel = giDialogChannel-100;
        giLastHudSize=2;
        putnum();
        if(swdbg) llOwnerSay(llGetScriptName()+": "+(string)llGetFreeMemory());
    }

    touch_start(integer total_number)
    {
        if(giPanel!=5 && giPanel!=6 && giPanel!=7) return;
        
        key lkTarget=llDetectedKey(0);
        integer liLinkPanel=llDetectedLinkNumber(0);
        integer liFace=llDetectedTouchFace(0);
        vector lvST=llDetectedTouchST(0);
        //llOwnerSay("*** "+(string)liLinkPanel+"   "+(string)liFace+"   "+(string)lvST);
        if(giIsLock){
            if(llListFindList(gaAdmins,[(string)lkTarget])<0){ 
                fsay(lkTarget, "This Hud is locked by an Administrator");
                return;
            }
        }
                
        if(!giCast){    //is not blowing
            if(liLinkPanel==giPANELAREA){ 
                if(liFace==0) setTouch(5, lkTarget, lvST); //panel circle face 0
                else llMessageLinked(LINK_THIS,5815,(string)liFace,"");  //1-margin,2-active,3-overlap field
            }else if(liLinkPanel==giPANELCIRCLE){ 
                if(liFace==0) setTouch(6, lkTarget, lvST); //panel circle face 0
                else llMessageLinked(LINK_THIS,5816,(string)liFace,"");  //1-margin,2-active,3-overlap field
            }else if(liLinkPanel==giPANELMAP){ 
                if(liFace==0) setTouch7(lkTarget, lvST); //panel map face 0
                else if(liFace==1){ //map sw map
                    giMapSwMap=!giMapSwMap;
                    putnum();
                }else if(liFace==2){ //map sw course
                    giMapSwCourse=!giMapSwCourse;
                    putnum();
                }else if(liFace==3){ //map sw vars
                    giMapSwVars=!giMapSwVars;
                    putnum();
                }else if(liFace==4){  //map sw square
                    giMapSwSquare=!giMapSwSquare;
                    putnum();
                }
            }else{ 
                integer liPanel;
                if(liLinkPanel==giPANELVARDATA) liPanel=8;
                else if(liLinkPanel==giPANELVARWIND) liPanel=9;
                else if(liLinkPanel==giPANELVARWAV) liPanel=10;
                else if(liLinkPanel==giPANELVARCUR) liPanel=11;
                if(liPanel>0){
                    if(lvST.x>crBPANELX.x && lvST.y>crBPANELX.y){    //clic X  close var params panel
                        llMessageLinked(LINK_THIS,5980,"","");  //hidenPanelVars();
                    }else{
                        if(liFace==0) setTouchP(liPanel,liLinkPanel,lvST);  //touch panel variations face 0 rapid keys
                        else llMessageLinked(LINK_THIS,5810+liPanel,(string)liFace,(string)liLinkPanel); //touch panel variation others faces 
                    }
                }
            }
        }else{
            if(liLinkPanel==giPANELMAP || liLinkPanel==giPANELAREA || liLinkPanel==giPANELCIRCLE || liLinkPanel==giPANELVARDATA || liLinkPanel==giPANELVARWIND || liLinkPanel==giPANELVARWAV || liLinkPanel==giPANELVARCUR){ 
                fsay(lkTarget,"The setter is broadcasting. Press Cast button before continuing");
            }
        }
    } 
    
    link_message(integer piSender_num, integer piNum, string psStr, key pkData)
    {
        //llOwnerSay("var menu link msg "+(string)piNum+"  "+psStr+"   "+(string)pkTarget);
        if(piNum>=6000 && piNum<7000){
            if(piNum==6905){   //save actual area item and actual total area items
                giVarAreaItem=(integer)psStr;
                if((string)pkData!=""){
                    giVarAreaTotal=(integer)((string)pkData);
                }
            }else if(piNum==6906){   //save actual circle item and actual total circle items 
                giVarCirItem=(integer)psStr;
                if((string)pkData!=""){
                    giVarCirTotal=(integer)((string)pkData);
                }
            }else if(piNum==6910){ 
                if((integer)llGetSubString(psStr,0,0)==1){   //tabs,
                    giPanel=(integer)llGetSubString(psStr,1,2);
                    if(giPanel==7){
                        displayText();
                        putnum();
                    }
                }  
            }else if(piNum==6931){  //response to request Variations Areas to Variations script
                gsVarAreasItems=psStr;
                gsVarAreasWind=pkData;
                llMessageLinked(LINK_THIS, 5002, "rdata", "6931"); //read circle data variations for map  
                //llOwnerSay("GLW area data "+gsVarAreasItems+"    "+gsVarAreasWind);
            }else if(piNum==6932){   //response to request Variations circles to Variations script
                gsVarCirclesItems=psStr;
                gsVarCirclesWind=pkData;
                //llOwnerSay("GLW circle data "+gsVarCirclesItems+"    "+gsVarCirclesWind);
                requestMap();
            }else if(piNum==6983){   //response to request wind direction to glw script
                list la=llCSV2List(psStr);
                giWindDir=llList2Integer(la,0);
                giWindSpeed=llList2Integer(la,1);
                giCurrentSpeed=llList2Integer(la,2);
                giCurrentDir=llList2Integer(la,3);
                giWaveHeight=llList2Integer(la,4);                
                llMessageLinked(LINK_THIS, 5001, "rdata", "6931"); //read area data variations for map
            }else if(piNum==6505){    //print variations params from Variations script 
                list la=llParseString2List(psStr,[";"],[]);
                printVarsParams(5,llList2String(la,1), (string)pkData, (key)llList2String(la,0));
            }else if(piNum==6506){    //print variations params from Variations script
                list la=llParseString2List(psStr,[";"],[]);
                printVarsParams(6,llList2String(la,1), (string)pkData, (key)llList2String(la,0));
            }else if(piNum==6507){    //give notice if you exceed 100 sims
                list laData=llCSV2List(psStr);
                integer liNumSims=(llAbs((llList2Integer(laData,2)/256)-(llList2Integer(laData,0)/256))+1)*(llAbs((llList2Integer(laData,3)/256)-(llList2Integer(laData,1)/256))+1);
                if(liNumSims>100) fsay("","The number of Sims in an area cannot exceed 100 Sims. You have "+(string)liNumSims+" Sims");
                //llOwnerSay((string)liNumSims);
            }else if(psStr=="cast"){  
                giCast=piNum-6000;  
            }else if(psStr=="lock"){  
                giIsLock=piNum-6000;  
            }else if(psStr=="admins"){  //From AUX load admin list
                gaAdmins=llCSV2List((string)pkData);  //save admins list
            }else if(psStr=="icon"){   //hud size to map panel
                if(piNum==6000) giLastHudSize=0;   //reduce icon
                else if(piNum==6002) giLastHudSize=2;   //increase big
                else if(piNum==6001) giLastHudSize=1;   //increase small
                if(giPanel==7) displayText();
            }else if(psStr=="loadusb"){   //load usb to map request
                gsUsbMap=(string)pkData;
                readFirstNCLine();
            }else if(psStr=="regionsw"){   //receive map sw region name
                gsMapSimSW=(string)pkData;
                displayText();
            }else if(psStr=="regionne"){   //receive map ne region name
                gsMapSimNE=(string)pkData;
                displayText();
            }
        }
    }    
    
    listen(integer piChannel, string psName, key pkId, string psMessage)
    {
        if(piChannel==giInputChannel){
            psMessage=llStringTrim(psMessage, STRING_TRIM);
            if(psMessage!=""){ 
                if(giField==14 || giField==16){ 
                    if(giInputPanel==5) llMessageLinked(LINK_THIS,5805,psMessage,(string)giField);  //get SW/NE sim 
                    else if(giInputPanel==6) llMessageLinked(LINK_THIS,5806,psMessage,(string)giField);  //get SW/NE sim
                    else if(giInputPanel==7){  //get corners map
                        //psData="http://maps.secondlife.com/secondlife/Chub/183/148/22" style
                        list laParse=llParseString2List(psMessage,["/"],[]);
                        integer liTotal=llGetListLength(laParse);
                        if(giField==14){
                            gsMapSimSW=llUnescapeURL(llList2String(laParse,liTotal-4));
                            gkRequestSimSWPos=llRequestSimulatorData(gsMapSimSW,DATA_SIM_POS);
                        }else{
                            gsMapSimNE=llUnescapeURL(llList2String(laParse,liTotal-4));
                            gkRequestSimNEPos=llRequestSimulatorData(gsMapSimNE,DATA_SIM_POS);
                        }
                        displayText();
                    }
                }
            }
            giField=-1;
            giInputPanel=0;
        }else if(piChannel==giDialogChannel){
            if(psMessage=="[Yes]" || psMessage=="{Yes}"){
                if(giDelItem<200 && psMessage=="[Yes]" ){  //Area  100+item
                    if(giDelItem-100!=giVarAreaItem){ 
                        llOwnerSay("you have changed item or panel");
                    }else{
                        llMessageLinked(LINK_THIS,5983,"5",(string)giVarAreaItem);
                    }
                }else if(psMessage=="{Yes}"){  //Circle  200+item
                    if(giDelItem-200!=giVarCirItem){ 
                        llOwnerSay("you have changed item or panel");
                    }else{
                        llMessageLinked(LINK_THIS,5983,"6",(string)giVarCirItem);
                    }
                }
            }
        }        
    }   
    
    dataserver(key query_id, string data)
    {
        if(query_id==gkRequestNoteId){
            gkRequestNoteId="";
            if(data==EOF){
                giTotRoute=llGetListLength(gaRoute)/2;
                if(giTotRoute>2){
                    giCurrentLine=-1;
                    loadCornerSim();
                }
            }else{
                readNextNCLine(data);
            }
            return;
        }else if(query_id==gkRequestCornerId){
            gkRequestCornerId="";
            vector lvCorner=(vector)data;
            vector lvPos=(vector)llList2String(gaRoute,giCurrentLine*2+1);
            gaRoute2+=[(integer)(lvCorner.x+lvPos.x),(integer)(lvCorner.y+lvPos.y)];
            loadCornerSim();
            return;
        }
        
        integer liPanel;
        if (query_id == gkRequestSimSWPos){
            vector lvData=(vector)data;
            giMapGlobalPosSW_x=(integer)lvData.x;
            giMapGlobalPosSW_y=(integer)lvData.y;
            liPanel=7;
        }else if (query_id == gkRequestSimNEPos){
            vector lvData=(vector)data;
            giMapGlobalPosNE_x=(integer)lvData.x;
            giMapGlobalPosNE_y=(integer)lvData.y;
            liPanel=7;
        }
        
        if(liPanel==7){
            if(giMapGlobalPosSW_x>0 && giMapGlobalPosSW_y>0 && giMapGlobalPosNE_x>0 && giMapGlobalPosNE_y>0){
                //send data to vars menu to give notice if you exceed 1000 sims
                integer liNumSims=(llAbs((giMapGlobalPosNE_x/256)-(giMapGlobalPosSW_x/256))+1)*(llAbs((giMapGlobalPosNE_y/256)-(giMapGlobalPosSW_y/256))+1);
                if(liNumSims>1000) fsay("","The number of Sims in an map cannot exceed 1000 Sims. You have "+(string)liNumSims+" Sims");
            }
        }
    }         
}






