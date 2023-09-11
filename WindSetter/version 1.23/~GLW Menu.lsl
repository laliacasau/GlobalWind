rotation crBUTB=<0.06012, 0.03863,0.73183, 0.09183>; //buttons Bottom row
rotation crBUTT=<0.05877, 0.09417,0.73183, 0.14836>;  //buttons Top row

rotation crKB=<0.57582, 0.04939, 0.95131, 0.56989>;   //keyboard coords

rotation crICO=<0.74422, 0.95274, 0.78329, 0.99181>; //icono de reduccion
rotation crICP=<0.70515, 0.95274, 0.74422, 0.99181>; //icono de ampliacion pequeño
rotation crICG=<0.66608, 0.95274, 0.70515, 0.99181>; //icono de ampliacion grande 

vector cvPOSPANELONG=<-0.0108, -0.0006, 0.00854>;   
vector cvPOSPANELONG3=<-0.00281, -0.0006, 0.00860>;   
vector cvPOSPANELONS=<-0.00694,-0.00060,0.0055>;
vector cvPOSPANELONS3=<-0.00189,-0.00060,0.0055>;
vector cvPOSPANELOFF=<0.0,-0.00060,0.0087>;
vector cvSizeMin=<0.01,0.01,0.01>;
vector cvPanelSizeG=<0.01958, 0.35289, 0.34554>;
vector cvHudSizeG=<0.02154, 0.38954, 0.48693>;
vector cvPanelSizeS=<0.01246, 0.22456, 0.21988>;
vector cvHudSizeS=<0.01371, 0.24789, 0.30985>;
vector cvPOSTEXT=<-0.01061, -0.01025, 0.05591>;

rotation crP1ROSE=<0.51225, 0.63821, 0.86612, 0.99486>; //wind rose
rotation crP1VEL=<0.30799, 0.64108, 0.49499, 0.71566>;  //Speed
rotation crP1GUS=<0.30224, 0.48815, 0.52952, 0.52576>;  
rotation crP1SHIFT=<0.30560, 0.30031, 0.53527, 0.33841>;
rotation crP1PER=<0.30504, 0.06867, 0.45911, 0.14541>;

rotation crP2HEIGHT=<0.31081, 0.83580, 0.76224, 0.91132>;
rotation crP2SPEED=<0.30919, 0.64681, 0.49028, 0.71904>;
rotation crP2LENGTH=<0.30419, 0.48598, 0.53814, 0.52571>;
rotation crP2VHEIGHT=<0.30131, 0.30073, 0.53490, 0.33758>;
rotation crP2VLENGTH=<0.30668, 0.10886, 0.53624, 0.14647>;

rotation crP3SPEED=<0.30505, 0.80270, 0.61115, 0.88085>;
rotation crP3ROSE=<0.09997, 0.22331, 0.45227, 0.56317>;

rotation crP4BTEXTS=<0.02077, 0.47903, 0.68839, 0.63385>; //name, key, extra 1, extra 2
rotation crP4BDEPTH=<0.77487, 0.32032, 0.96770, 0.37531>;  //depth button
rotation crP4DEPTH=<0.30117, 0.30875, 0.73443, 0.38400>;  //depth values
rotation crP4MODE=<0.30268, 0.15564, 0.41879, 0.19906>;  //sailmode values
rotation crP4UPDPOS=<0.85127, 0.03151, 0.91300, 0.27967>;  //update position values

key ckTEXNUMBERS="8f049f1e-8604-5f33-03a0-edf5023982ce";
key ckTEXTABS="71fff656-7512-763b-5f8c-183191121773";

integer swdbg;
integer giTmap;
integer giNmap;
integer giTpag;
string gsNoteName;
integer giListenHandle;
integer giListenHandle2;
integer giDialogChannel;
integer giInputChannel;
integer giRecovChannel;
integer giTimerMenu;
integer giField;
integer giCast;
integer giPanel;
integer giLastHudSize;
integer giDelEvent;
integer giIsLock;
list gaAdmins;

//map
integer giLoadMode;  //0-GLW notecard   1-USB notecard

//==>Links Numbers
integer giROOT=1;
integer giPANELBASE;
integer giPANELWAVES;
integer giPANELCURRENT;
integer giPANELOTHER;
integer giPANELCIRCLE;
integer giPANELAREA;
integer giPANELMAP;
integer giTEXT;
integer giICON;
integer giPANELVARDATA;
integer giPANELVARWIND;
integer giPANELVARWAV;
integer giPANELVARCUR;
integer giVARTEXT;



notecardCount() //count the configuration notecards
{
    integer liN=llGetInventoryNumber(INVENTORY_NOTECARD);  
    integer liI;
    giTmap=0;  //Total configuration notecards number
    for(liI=0;liI<liN;liI++){
        //discard the system notecards
        if(llGetSubString(llGetInventoryName(INVENTORY_NOTECARD,liI),0,0)!="~") giTmap++;
    }
    giTpag=llCeil(giTmap/9.0);  //Total Menu pags number
    giTmap--;
    giNmap=1;  //actual menu pag number
    gsNoteName="";
}

GenMenuLoad(integer piMap, key pkId){   //Menu Load configuration notecards and usb
    if(piMap<0){
        if(giNmap<=1){
            GenMenuLoad2(1,pkId);
        }else{
            GenMenuLoad2(giNmap-1,pkId);
        }
    }else if(piMap==9){
        GenMenuLoad2(giNmap,pkId);
    }else if(piMap==0){
        notecardCount();
        GenMenuLoad2(1,pkId);
    }else if(piMap==1){
        if(giNmap>=giTpag){
            GenMenuLoad2(giTpag,pkId);
        }else{ 
            GenMenuLoad2(giNmap+1,pkId);
        }
    }else if(piMap==2){
        GenMenuLoad2(giTpag,pkId);
    }
}
    
GenMenuLoad2(integer piPag, key pkId){    //Menu Load configuration notecards
    list    laMenu;
    string  lsItemName;
    integer liTope;
    integer liPmap;
    integer liNum;
    integer liCount;
    string lsOptions;
    if(giLoadMode) lsOptions="Please choose a USB:\n";
    else lsOptions="Please choose a route:\n";
    
    liPmap=(piPag-1)*9;
    if(liPmap+8>giTmap){
        liTope=giTmap;
    }else{
        liTope=liPmap+8;
    }
    giNmap=piPag;
    liCount=liPmap;  
    if(piPag==1 && piPag==giTpag){
        laMenu=["-","Last","-"];
    }else if(piPag==1){
        laMenu=["-","Last",">>"];
    }else if(piPag==giTpag){
        laMenu=["<<","Last","-"];
    }else{
        laMenu=["<<","Last",">>"];
    }
    liNum=0;
    while (liCount<=liTope)
    {
        lsItemName = llGetInventoryName(INVENTORY_NOTECARD, liCount);
        liNum++;
        lsOptions += "\n"+(string)liCount+"-"+llGetSubString(lsItemName,0,45); 
        laMenu +=(string)liCount;
        liCount++;
    }
    laMenu=situaropcmenu(laMenu);
    giListenHandle=llListen(giDialogChannel,"",pkId,"");
    llDialog(pkId, lsOptions,laMenu,giDialogChannel);
    giTimerMenu=120;
    llSetTimerEvent(1);
} 

list situaropcmenu(list paList){    //Menu Load configuration notecards 
    list laLista;
    integer liN=llGetListLength(paList); 
    laLista=llList2List(paList,0,2);
    if(liN>=6){
        laLista+=llList2List(paList,liN-3,liN-1);
        if(liN>=9){
            laLista+=llList2List(paList,liN-6,liN-4);
            if(liN>=12){
                laLista+=llList2List(paList,liN-9,liN-7);
            }else if(liN>9){
                laLista+=llList2List(paList,3,liN-7);
            }
        }else if(liN>6){
            laLista+=llList2List(paList,3,liN-4);
        }
    }else if(liN>3){
        laLista+=llList2List(paList,3,liN-1);
    }
    return laLista;
}

dispMenu(integer piMode, key pkTarget)  //pimode=0-General Menu   1-Confirm stop menu
{
    llListenRemove(giListenHandle);
    giListenHandle=llListen(giDialogChannel,"",pkTarget,"");

    if(piMode) llDialog(pkTarget, "Are you sure to delete the event?", ["[Yes]","[No]"],giDialogChannel);
    else{ 
        string lsLockText;
        if(giIsLock) lsLockText="Unlock";
        else lsLockText="Lock"; 
        llDialog(pkTarget, "Please make a choice", ["Recovery","Reset","Write Note","Close Menu",lsLockText],giDialogChannel);
    }

    giTimerMenu=120;
    llSetTimerEvent(1);
}

hudSize(integer piMode)
{
    integer liP;
    if(giPanel==1) liP=giPANELBASE;
    else if(giPanel==2) liP=giPANELWAVES;
    else if(giPanel==3) liP=giPANELCURRENT;
    else if(giPanel==4) liP=giPANELOTHER;
    else if(giPanel==5) liP=giPANELAREA;
    else if(giPanel==6) liP=giPANELCIRCLE;
    else if(giPanel==7) liP=giPANELMAP;
    
    vector lvIconPos;
    vector lvPanelSize;
    vector lvPanelPosOff;
    vector lvPanelPosOn;
    vector lvHudSize;
    if(piMode==0){  //icon
        lvIconPos=<-0.01080,0.0,0.0>;
        lvPanelSize=cvSizeMin;
        lvPanelPosOff=ZERO_VECTOR;
        lvHudSize=cvSizeMin;
        llSetLinkPrimitiveParamsFast(giTEXT,[PRIM_TEXT,"",<0.10,0.10,0.10>,0.0,PRIM_POS_LOCAL,ZERO_VECTOR]);
    }else if(piMode==1){  //small
        lvIconPos=ZERO_VECTOR;
        lvPanelSize=cvPanelSizeS;
        lvPanelPosOff=cvPOSPANELOFF;
        lvPanelPosOn=cvPOSPANELONS;
        lvHudSize=cvHudSizeS;
    }else if(piMode==2){  //big
        lvIconPos=ZERO_VECTOR;
        lvPanelSize=cvPanelSizeG;
        lvPanelPosOff=cvPOSPANELOFF;
        lvPanelPosOn=cvPOSPANELONG;
        lvHudSize=cvHudSizeG;
    }

    llSetLinkPrimitiveParamsFast(giICON,[PRIM_POS_LOCAL,lvIconPos]);
    llSetLinkPrimitiveParamsFast(giPANELBASE,[PRIM_SIZE,lvPanelSize,PRIM_POS_LOCAL,lvPanelPosOff,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]);
    llSetLinkPrimitiveParamsFast(giPANELWAVES,[PRIM_SIZE,lvPanelSize,PRIM_POS_LOCAL,lvPanelPosOff,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]);
    llSetLinkPrimitiveParamsFast(giPANELCURRENT,[PRIM_SIZE,lvPanelSize,PRIM_POS_LOCAL,lvPanelPosOff,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]);
    llSetLinkPrimitiveParamsFast(giPANELOTHER,[PRIM_SIZE,lvPanelSize,PRIM_POS_LOCAL,lvPanelPosOff,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]);
    llSetLinkPrimitiveParamsFast(giPANELCIRCLE,[PRIM_SIZE,lvPanelSize,PRIM_POS_LOCAL,lvPanelPosOff,PRIM_COLOR,1,<1,1,1>,0.0]);
    llSetLinkPrimitiveParamsFast(giPANELAREA,[PRIM_SIZE,lvPanelSize,PRIM_POS_LOCAL,lvPanelPosOff,PRIM_COLOR,1,<1,1,1>,0.0]);
    llSetLinkPrimitiveParamsFast(giPANELMAP,[PRIM_SIZE,lvPanelSize,PRIM_POS_LOCAL,lvPanelPosOff,PRIM_COLOR,1,<1,1,1>,0.0]);
    llSetLinkPrimitiveParamsFast(giPANELVARDATA,[PRIM_SIZE,cvSizeMin,PRIM_POS_LOCAL,ZERO_VECTOR,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]);
    llSetLinkPrimitiveParamsFast(giPANELVARWIND,[PRIM_SIZE,cvSizeMin,PRIM_POS_LOCAL,ZERO_VECTOR,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]);
    llSetLinkPrimitiveParamsFast(giPANELVARWAV,[PRIM_SIZE,cvSizeMin,PRIM_POS_LOCAL,ZERO_VECTOR,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]);
    llSetLinkPrimitiveParamsFast(giPANELVARCUR,[PRIM_SIZE,cvSizeMin,PRIM_POS_LOCAL,ZERO_VECTOR,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]);
    if(piMode>0) llSetLinkPrimitiveParamsFast(liP,[PRIM_POS_LOCAL,lvPanelPosOn,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);  
    llSetLinkPrimitiveParamsFast(giROOT,[PRIM_SIZE,lvHudSize]);
}

panels(integer piPanel, integer piHudSize)
{
    if(piPanel==1){  //panelbase
        if(piHudSize==1) llSetLinkPrimitiveParamsFast(giPANELBASE,[PRIM_POS_LOCAL,cvPOSPANELONS,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]); 
        else llSetLinkPrimitiveParamsFast(giPANELBASE,[PRIM_POS_LOCAL,cvPOSPANELONG,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]); 
    }else if(piPanel==2){  //panel waves
        if(piHudSize==1) llSetLinkPrimitiveParamsFast(giPANELWAVES,[PRIM_POS_LOCAL,cvPOSPANELONS3,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]); 
        else llSetLinkPrimitiveParamsFast(giPANELWAVES,[PRIM_POS_LOCAL,cvPOSPANELONG3,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]); 
    }else if(piPanel==3){  //panel currents
        if(piHudSize==1) llSetLinkPrimitiveParamsFast(giPANELCURRENT,[PRIM_POS_LOCAL,cvPOSPANELONS3,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]); 
        else llSetLinkPrimitiveParamsFast(giPANELCURRENT,[PRIM_POS_LOCAL,cvPOSPANELONG3,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]); 
    }else if(piPanel==4){   //panel other
        if(piHudSize==1) llSetLinkPrimitiveParamsFast(giPANELOTHER,[PRIM_POS_LOCAL,cvPOSPANELONS,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]); 
        else llSetLinkPrimitiveParamsFast(giPANELOTHER,[PRIM_POS_LOCAL,cvPOSPANELONG,PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]); 
    }else if(piPanel==5){   //panel area
        llSetLinkAlpha(giPANELAREA,1.0,ALL_SIDES);
        if(piHudSize==1) llSetLinkPrimitiveParamsFast(giPANELAREA,[PRIM_POS_LOCAL,cvPOSPANELONS,PRIM_COLOR,1,<1,1,1>,1.0]); 
        else llSetLinkPrimitiveParamsFast(giPANELAREA,[PRIM_POS_LOCAL,cvPOSPANELONG,PRIM_COLOR,1,<1,1,1>,1.0]);
    }else if(piPanel==6){   //panel circle
        llSetLinkAlpha(giPANELCIRCLE,1.0,ALL_SIDES);
        if(piHudSize==1) llSetLinkPrimitiveParamsFast(giPANELCIRCLE,[PRIM_POS_LOCAL,cvPOSPANELONS,PRIM_COLOR,1,<1,1,1>,1.0]); 
        else llSetLinkPrimitiveParamsFast(giPANELCIRCLE,[PRIM_POS_LOCAL,cvPOSPANELONG,PRIM_COLOR,1,<1,1,1>,1.0]);
    }else if(piPanel==7){   //panel map
        llSetLinkAlpha(giPANELMAP,1.0,ALL_SIDES);
        if(piHudSize==1) llSetLinkPrimitiveParamsFast(giPANELMAP,[PRIM_POS_LOCAL,cvPOSPANELONS,PRIM_COLOR,1,<1,1,1>,1.0]); 
        else llSetLinkPrimitiveParamsFast(giPANELMAP,[PRIM_POS_LOCAL,cvPOSPANELONG,PRIM_COLOR,1,<1,1,1>,1.0]);
    }

    if(piPanel!=1) llSetLinkPrimitiveParamsFast(giPANELBASE,[PRIM_POS_LOCAL,cvPOSPANELOFF,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]); 
    if(piPanel!=2) llSetLinkPrimitiveParamsFast(giPANELWAVES,[PRIM_POS_LOCAL,cvPOSPANELOFF,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]); 
    if(piPanel!=3) llSetLinkPrimitiveParamsFast(giPANELCURRENT,[PRIM_POS_LOCAL,cvPOSPANELOFF,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]); 
    if(piPanel!=4) llSetLinkPrimitiveParamsFast(giPANELOTHER,[PRIM_POS_LOCAL,cvPOSPANELOFF,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]); 
    if(piPanel!=5) llSetLinkPrimitiveParamsFast(giPANELAREA,[PRIM_POS_LOCAL,cvPOSPANELOFF,PRIM_COLOR,1,<1,1,1>,0.0]); 
    if(piPanel!=6) llSetLinkPrimitiveParamsFast(giPANELCIRCLE,[PRIM_POS_LOCAL,cvPOSPANELOFF,PRIM_COLOR,1,<1,1,1>,0.0]); 
    if(piPanel!=7) llSetLinkPrimitiveParamsFast(giPANELMAP,[PRIM_POS_LOCAL,cvPOSPANELOFF,PRIM_COLOR,1,<1,1,1>,0.0]); 
    llSetLinkPrimitiveParamsFast(giPANELVARDATA,[PRIM_POS_LOCAL,cvPOSPANELOFF,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]);
    llSetLinkPrimitiveParamsFast(giPANELVARWIND,[PRIM_POS_LOCAL,cvPOSPANELOFF,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]);
    llSetLinkPrimitiveParamsFast(giPANELVARWAV,[PRIM_POS_LOCAL,cvPOSPANELOFF,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]);
    llSetLinkPrimitiveParamsFast(giPANELVARCUR,[PRIM_POS_LOCAL,cvPOSPANELOFF,PRIM_COLOR,ALL_SIDES,<1,1,1>,0.0]);
    llSetLinkPrimitiveParamsFast(giVARTEXT, [PRIM_TEXT, "", <0.10,0.10,0.10>, 0.0,PRIM_POS_LOCAL,ZERO_VECTOR]);        
    if(piPanel!=4) llSetLinkPrimitiveParamsFast(giTEXT,[PRIM_TEXT,"",<0.10,0.10,0.10>,0.0]);
}

setTouch0(key pkTarget, integer piFace, vector pvST)
{
    if(piFace==0){   //background
        if(pvST.x>crBUTB.x && pvST.y>crBUTB.y && pvST.x<crBUTT.z && pvST.y<crBUTT.s){   //buttons
            integer n=(integer)((pvST.x-crBUTB.x) / ((crBUTB.z-crBUTB.x)/5));
            if(pvST.y<=crBUTB.s){  //Bottom row
                if(n==0){     //finish button
                    giDelEvent=1;
                    dispMenu(1,pkTarget);  
                    return;
                }else if(n==1){  //print button
                    if(giPanel==5 || giPanel==6) llMessageLinked(LINK_THIS, 5000+giPanel, "print", pkTarget);
                    else llMessageLinked(LINK_THIS, 2910, "06", pkTarget);
                }else if(n==2) llMessageLinked(LINK_THIS,3003,(string)giPanel,pkTarget);  //restore button
                else if(n==3){ 
                    giLoadMode=0;
                    GenMenuLoad(0,pkTarget);  //load button
                }else if(n==4) dispMenu(0,pkTarget);  //menu button
                //else llMessageLinked(LINK_THIS, 2910, "0"+(string)(5+n),pkTarget);  //others buttons bottom row
            }else{    //up row
                if(n==3) llMessageLinked(LINK_THIS,3002,"",pkTarget);  //Default button
                else llMessageLinked(LINK_THIS, 2910, "0"+(string)n,pkTarget);  //send, ...  buttons
            }
            return;
        }
        integer liN=-1;
        if(llGetAttached()>0){
            if(pvST.x>crICO.x && pvST.y>crICO.y && pvST.x<crICO.z && pvST.y<crICO.s) liN=0;   //reduce icon
            if(pvST.x>crICG.x && pvST.y>crICG.y && pvST.x<crICG.z && pvST.y<crICG.s) liN=2;   //increase big
            if(pvST.x>crICP.x && pvST.y>crICP.y && pvST.x<crICP.z && pvST.y<crICP.s) liN=1;   //increase small
        }else{
            if(pvST.x>crICG.x && pvST.y>crICG.y && pvST.x<crICG.z && pvST.y<crICG.s) liN=2;   //increase big
        }
        if(liN>=0){
            hudSize(liN);
            llMessageLinked(LINK_THIS, 2000+liN, "icon", "");  //to GLW script
            llMessageLinked(LINK_THIS, 5000+liN, "icon", "");  //to Var script
            llMessageLinked(LINK_THIS, 6000+liN, "icon", "");  //to Var Menu script
            if(liN>0) giLastHudSize=liN;
        }
    }else if(piFace==1){  //tabs 
        integer liN=(integer)((pvST.x)/0.1428571);
        llSetLinkPrimitiveParamsFast(giROOT,[PRIM_COLOR,1,<1,1,1>,1.0,PRIM_TEXTURE,1,ckTEXTABS,<1.0,1.0,0.0>,<0,-0.0781*liN,0>,0.0]);  //change texture
        giPanel=liN+1;  //selec panel
        panels(giPanel,giLastHudSize);  //change panel
        llMessageLinked(LINK_THIS, 2910, "1"+(string)giPanel, pkTarget);   //update info in GLW script
        llMessageLinked(LINK_THIS, 5910, "1"+(string)giPanel, pkTarget);   //update info in Variations script
        llMessageLinked(LINK_THIS, 6910, "1"+(string)giPanel, pkTarget);   //update info in vars menu script
    }else if(piFace==2){   //start button
        llMessageLinked(LINK_THIS, 2910, "2", pkTarget);
    }else if(piFace==3){   //cast button
        llMessageLinked(LINK_THIS, 2910, "3", pkTarget);
    }else if(piFace>=4){   //sim, shout, whisper buttons
        if(pvST.y>0.99) llMessageLinked(LINK_THIS, 2910, (string)piFace+"1", pkTarget);
        else llMessageLinked(LINK_THIS, 2910, (string)piFace+"0", pkTarget);
    } 
}

integer keyboard(vector pvST)
{
    float cx;
    float cy;
    integer x=0;
    integer y=0;
    integer n=0;
    float IncX=(crKB.z-crKB.x)/3;
    float IncY=(crKB.s-crKB.y)/4;
    for(y=1;y<5;y++){
        cy=crKB.y+(IncY*y);
        for(x=1;x<4;x++){
            cx=crKB.x+(IncX*x);
            if(pvST.x<cx && pvST.y<cy && n==0){ 
                n=(y-1)*3+x;
            }
        }
    }
    if(n==2) n=0;
    else if(n==1){ 
        if(pvST.y<crKB.y+IncY/2) n=-2;
        else n=-1;
    }else if(n==3) n=-3;
    else n=n-3;
    return n;
}

touchNumber(vector pvST, rotation prCoord, integer piCols, integer piRows, string psNumbers, integer piChars, integer piCode, string psField)
{
    integer n;
    if(piCols>1){
        n=(integer)((pvST.x-prCoord.x) / ((prCoord.z-prCoord.x)/piCols));
        if(piRows>1){ 
            if(pvST.y-prCoord.y < (prCoord.s-prCoord.y)/2) n+=piCols;
        }
        n=(integer)llGetSubString(psNumbers,n*piChars,n*piChars+piChars-2);
        llMessageLinked(LINK_THIS,piCode,(string)n,psField);
    }else{
        n=piRows-(integer)((pvST.y-prCoord.y) / ((prCoord.s-prCoord.y)/piRows))-1;
        n=(integer)llGetSubString(psNumbers,n*piChars,n*piChars+piChars-2);
        llMessageLinked(LINK_THIS,piCode,(string)n,psField);
    }
}

setTouch1(key pkTarget, integer piFace, vector pvST)
{
    if(piFace==0){
        if(pvST.x>crKB.x && pvST.y>crKB.y && pvST.x<crKB.z && pvST.y<crKB.s){   //teclado 
            llMessageLinked(LINK_THIS,2981,(string)keyboard(pvST),pkTarget); 
            return;
        }
        if(pvST.x>crP1ROSE.x && pvST.y>crP1ROSE.y && pvST.x<crP1ROSE.z && pvST.y<crP1ROSE.s){   //rose
            float cx;
            float cy;
            integer x=0;
            integer y=0;
            integer n=0;
            float IncX=(crP1ROSE.z-crP1ROSE.x)/3;
            float IncY=(crP1ROSE.s-crP1ROSE.y)/3;
            cx=pvST.x-crP1ROSE.x;
            cy=pvST.y-crP1ROSE.y;
            x=(integer)(cx/IncX);
            y=(integer)(cy/IncY);
            n=y*3+x;
            n=(integer)llGetSubString("225,180,135,270,000,090,315,000,045",n*4,n*4+2);
            llMessageLinked(LINK_THIS,2901,(string)n,"1");   //to GLW panel 1 field 1 direction 
            return;
        }
        if(pvST.x>crP1VEL.x && pvST.y>crP1VEL.y && pvST.x<crP1VEL.z && pvST.y<crP1VEL.s){   //velo
            //touchNumber(pvST,cvP1VEL0,cvP1VEL1,3,2,"08,11,15,18,21,25",3,2901,"2");
            touchNumber(pvST,crP1VEL,3,2,"08,11,15,18,21,25",3,2901,"2");
        }else if(pvST.x>crP1GUS.x && pvST.y>crP1GUS.y && pvST.x<crP1GUS.z && pvST.y<crP1GUS.s){   //gusts
            touchNumber(pvST,crP1GUS,4,1,"00,10,25,50",3,2901,"3");
        }else if(pvST.x>crP1SHIFT.x && pvST.y>crP1SHIFT.y && pvST.x<crP1SHIFT.z && pvST.y<crP1SHIFT.s){   //shift
            touchNumber(pvST,crP1SHIFT,4,1,"00,10,20,30",3,2901,"4");
        }  
        if(pvST.x>crP1PER.x && pvST.y>crP1PER.y && pvST.x<crP1PER.z && pvST.y<crP1PER.s){   //velo
            touchNumber(pvST,crP1PER,2,2,"030,060,090,120",4,2901,"5");
        } 
    }else if(piFace>=1 && piFace<=5){   //fields
        llMessageLinked(LINK_THIS,2911,(string)piFace,pkTarget);
    }  
         
}

setTouch2(key pkTarget, integer piFace, vector pvST) 
{
    if(piFace==0){   //background
        if(pvST.x>crKB.x && pvST.y>crKB.y && pvST.x<crKB.z && pvST.y<crKB.s){   //teclado
            llMessageLinked(LINK_THIS,2981,(string)keyboard(pvST),pkTarget); 
        }else if(pvST.x>crP2HEIGHT.x && pvST.y>crP2HEIGHT.y && pvST.x<crP2HEIGHT.z && pvST.y<crP2HEIGHT.s){   //Height
            touchNumber(pvST,crP2HEIGHT,6,2,"00,05,10,15,20,25,30,35,40,45,50,25",3,2902,"1");
        }else if(pvST.x>crP2SPEED.x && pvST.y>crP2SPEED.y && pvST.x<crP2SPEED.z && pvST.y<crP2SPEED.s){   //Speed
            touchNumber(pvST,crP2SPEED,3,2,"03,05,08,10,12,15",3,2902,"2");
        }else if(pvST.x>crP2LENGTH.x && pvST.y>crP2LENGTH.y && pvST.x<crP2LENGTH.z && pvST.y<crP2LENGTH.s){   //LENGTH
            touchNumber(pvST,crP2LENGTH,3,1,"010,050,100",4,2902,"3");
        }else if(pvST.x>crP2VHEIGHT.x && pvST.y>crP2VHEIGHT.y && pvST.x<crP2VHEIGHT.z && pvST.y<crP2VHEIGHT.s){   //varHeight
            touchNumber(pvST,crP2VHEIGHT,4,1,"00,10,20,30",3,2902,"4");
        }else if(pvST.x>crP2VLENGTH.x && pvST.y>crP2VLENGTH.y && pvST.x<crP2VLENGTH.z && pvST.y<crP2VLENGTH.s){   //varLENGTH
            touchNumber(pvST,crP2VLENGTH,4,1,"00,10,20,30",3,2902,"5");
        }
    }else if(piFace==6){   //effects
        if(pvST.y>0.06424) llMessageLinked(LINK_THIS,2902,"0","6");
        else llMessageLinked(LINK_THIS,2902,"1","6");
    }else if(piFace>=1 && piFace<=5){   //fields
        llMessageLinked(LINK_THIS,2912,(string)piFace,pkTarget);
    }
}

setTouch3(key pkTarget, integer piFace, vector pvST)  //panel currents
{
    if(piFace==0){   //background
        if(pvST.x>crKB.x && pvST.y>crKB.y && pvST.x<crKB.z && pvST.y<crKB.s){   //teclado
            llMessageLinked(LINK_THIS,2981,(string)keyboard(pvST),pkTarget); 
            return;
        }else if(pvST.x>crP3SPEED.x && pvST.y>crP3SPEED.y && pvST.x<crP3SPEED.z && pvST.y<crP3SPEED.s){   //speed
            touchNumber(pvST,crP3SPEED,4,2,"00,10,20,30,40,50,60,30",3,2903,"1");
        }else if(pvST.x>crP3ROSE.x && pvST.y>crP3ROSE.y && pvST.x<crP3ROSE.z && pvST.y<crP3ROSE.s){   //wind rose
            float cx;
            float cy;
            integer x=0;
            integer y=0;
            integer n=0;
            float IncX=(crP3ROSE.z-crP3ROSE.x)/3;
            float IncY=(crP3ROSE.s-crP3ROSE.y)/3;
            cx=pvST.x-crP3ROSE.x;
            cy=pvST.y-crP3ROSE.y;
            x=(integer)(cx/IncX);
            y=(integer)(cy/IncY);
            n=y*3+x;
            n=(integer)llGetSubString("225,180,135,270,000,090,315,000,045",n*4,n*4+2);
            llMessageLinked(LINK_THIS,2903,(string)n,"2");   //to GLW panel 3 field 2 direction 
        }
    }else if(piFace>=1 && piFace<=2){   //fields
        llMessageLinked(LINK_THIS,2913,(string)piFace,pkTarget);
    }
}

setTouch4(key pkTarget, integer piFace, vector pvST)  //panel others
{
    
    if(pvST.x>crP4BTEXTS.x && pvST.y>crP4BTEXTS.y && pvST.x<crP4BTEXTS.z && pvST.y<crP4BTEXTS.s){   //texts buttons
        integer liPosX;
        string lsText;
        giField=-1;
        if(pvST.x-crP4BTEXTS.x>(crP4BTEXTS.z-crP4BTEXTS.x)/2){
            liPosX=1;
        }
        if(pvST.y-crP4BTEXTS.y>(crP4BTEXTS.s-crP4BTEXTS.y)/2){
            if(liPosX){  //event key
                giField=14;
                lsText="Event Key:";
            }else{ //event name
                giField=11;
                lsText="Event Name:";
            }
        }else{
            if(liPosX){  //extra 2
                giField=13;
                lsText="Extra 2:";
            }else{  //extra 1
                giField=12;
                lsText="Extra 1:";
            }
        }
        if(giField>0){
            giListenHandle2 = llListen( giInputChannel, "", "", "");     
            llTextBox(pkTarget, lsText, giInputChannel);
        }
    }else if(pvST.x>crP4BDEPTH.x && pvST.y>crP4BDEPTH.y && pvST.x<crP4BDEPTH.z && pvST.y<crP4BDEPTH.s){   //depth button
        llMessageLinked(LINK_THIS,2904,(string)setWaterDepth(),"10");    
    }else if(pvST.x>crP4DEPTH.x && pvST.y>crP4DEPTH.y && pvST.x<crP4DEPTH.z && pvST.y<crP4DEPTH.s){   //water depth options
         touchNumber(pvST,crP4DEPTH,7,2,"-1,00,05,06,07,08,09,10,11,12,13,14,15,20",3,2904,"1");   //-1 auto  0 disabled
    }else if(pvST.x>crP4MODE.x && pvST.y>crP4MODE.y && pvST.x<crP4MODE.z && pvST.y<crP4MODE.s){   //sail mode
         touchNumber(pvST,crP4MODE,3,1,"0,1,2",2,2904,"2");
    }else if(pvST.x>crP4UPDPOS.x && pvST.y>crP4UPDPOS.y && pvST.x<crP4UPDPOS.z && pvST.y<crP4UPDPOS.s){   //update boat position
         touchNumber(pvST,crP4UPDPOS,1,7,"00,05,10,15,20,30,60",3,2904,"3");
    }   
}

integer setWaterDepth() {
    float lfGroundHeight = llGround(ZERO_VECTOR);
    float lfWaterHeight = llWater(ZERO_VECTOR);
    integer li=5;
    if(lfWaterHeight>lfGroundHeight){
        li=(integer)(lfWaterHeight-lfGroundHeight+0.5);
        if(li<5) li=5;
    }
    return li;
}

fsay(key pkTarget, string tex)
{
    if(llGetAttached()==0){ 
        if(llGetAgentSize(pkTarget)==ZERO_VECTOR) llInstantMessage(pkTarget,tex);
        else llRegionSayTo(pkTarget,0,tex); 
    }else llOwnerSay(tex);
}

default
{
    state_entry()
    {
        swdbg=(integer)llLinksetDataRead("ISDsetini");        
        //getLinkNums====================>
        integer i;
        integer linkcount=llGetNumberOfPrims();
        string str;
        for (i=1;i<=linkcount;++i) {
            str=llGetLinkName(i);
            if (str=="panelbase") giPANELBASE=i;
            else if (str=="panelwaves") giPANELWAVES=i;
            else if (str=="panelcurrent") giPANELCURRENT=i;
            else if (str=="panelother") giPANELOTHER=i;
            else if (str=="panelcircle") giPANELCIRCLE=i;
            else if (str=="panelarea") giPANELAREA=i;
            else if (str=="panelmap") giPANELMAP=i;
            else if (str=="text") giTEXT=i;
            else if (str=="icon") giICON=i;
            else if (str=="panelvardata") giPANELVARDATA=i;
            else if (str=="panelvarwind") giPANELVARWIND=i;
            else if (str=="panelvarwave") giPANELVARWAV=i;
            else if (str=="panelvarcur") giPANELVARCUR=i;
            else if (str=="vartext") giVARTEXT=i;
        }
        //<==========================getLinkNums
        
        giDialogChannel = -1 - (integer)("0x" + llGetSubString( (string)llGetKey(), -7, -1) );
        giInputChannel = giDialogChannel-100;
        giRecovChannel = giDialogChannel-101;
        notecardCount();
        if(swdbg) llOwnerSay(llGetScriptName()+": "+(string)llGetFreeMemory());
    }
    
    link_message(integer piSender_num, integer piNum, string psStr, key pkTarget)
    {
        if(piNum>=4000 && piNum<5000){
            if(psStr=="inicio"){  //From GLW
                llSetLinkPrimitiveParamsFast(LINK_SET,[PRIM_COLOR,ALL_SIDES,<1,1,1>,1.0]);
                llSetLinkPrimitiveParamsFast(giROOT,[PRIM_TEXTURE,1,ckTEXTABS,<1.0,1.0,0.0>,ZERO_VECTOR,0.0]); //tabs panel base
                llSetLinkPrimitiveParamsFast(giROOT,[PRIM_COLOR,5,<0,1,0>,1.0]);  //shout on
                llSetLinkPrimitiveParamsFast(giVARTEXT,[PRIM_TEXT,"",<0.10,0.10,0.10>,0.0,PRIM_POS_LOCAL,ZERO_VECTOR]);
                giPanel=1;
                giLastHudSize=2;
                hudSize(giLastHudSize);                
            }else if(psStr=="cast"){  //From AUX
                giCast=piNum-4000;  //broadcast is on or off
            }else if(psStr=="admins"){  //From AUX load admin list
                gaAdmins=llCSV2List((string)pkTarget);  //save admins list
            }else if(psStr=="loadusb"){  //from Var Menu script for load usb note
                giLoadMode=1;
                GenMenuLoad(0,pkTarget); 
            }else if(psStr=="recovid"){  //From setter. Recovery. ask for the id or key of the event to retrieve 
                giListenHandle2 = llListen(giRecovChannel, "", "", "");     
                llTextBox(llGetOwner(), "Enter the #Id or the key of the event to retrieve", giRecovChannel);
            }
        }
    }    
    
    listen(integer piChannel, string psName, key pkId, string psMessage)
    {
        if(piChannel==giDialogChannel){
            llSetTimerEvent(0.0);
            llListenRemove(giListenHandle);
            giTimerMenu=-1;
            if (psMessage == "<<"){
                GenMenuLoad(-1,pkId);
            }else if (psMessage == ">>"){
                GenMenuLoad(1,pkId);
            }else if (psMessage == "Last"){
                GenMenuLoad(2,pkId);
            }else if (psMessage == "-"){ 
                GenMenuLoad(9,pkId);
            }else if (psMessage == "Close Menu"){ 
            }else if (psMessage == "Reset"){ 
                fsay(pkId, "Resetting...");
                llMessageLinked(LINK_THIS, 2000, "reset", "");  //to GLW script
            //}else if (psMessage == "Scan"){ 
            //    llMessageLinked(LINK_THIS, 1900, "scan", "");  //to GLW script
            }else if (psMessage == "Write Note"){
                llMessageLinked(LINK_THIS, 2000, "write", pkId); 
            }else if (psMessage == "Recovery"){
                llMessageLinked(LINK_THIS, 1900, "recovery", pkId); 
            }else if (psMessage == "Lock"){
                if(llListFindList(gaAdmins,[(string)pkId])<0){ 
                    fsay(pkId, "This Hud can only be locked by an Administrator");
                    return;
                }
                fsay(pkId,"GLW Hud is locked");
                giIsLock=1;
                llMessageLinked(LINK_THIS, 6001, "lock", "");  //to var menu
            }else if (psMessage == "Unlock"){
                fsay(pkId,"GLW Hud is unlocked");
                giIsLock=0;
                llMessageLinked(LINK_THIS, 6000, "lock", "");  //to var menu
            }else if(giDelEvent==1){ 
                if (psMessage == "[Yes]") llMessageLinked(LINK_THIS, 2910, "05","");  //Finish Menu
            }else{
                string lsItemName = llGetInventoryName(INVENTORY_NOTECARD, (integer)psMessage);  
                if(giLoadMode==1){
                    if(llGetSubString(lsItemName,0,0)!="~") llMessageLinked(LINK_THIS,6000,"loadusb",lsItemName);  //load item name, To VarMenu
                }else{
                    if(llGetSubString(lsItemName,0,0)!="~") llMessageLinked(LINK_THIS,3001,lsItemName,pkId);  //load item name, To Aux
                }
            }    
            giDelEvent=0; 
        }else if(piChannel==giInputChannel){
            psMessage=llStringTrim(psMessage, STRING_TRIM);
            if(psMessage!=""){ 
                llMessageLinked(LINK_THIS, 2904, psMessage, (string)giField);
            }
            giField=-1;
        }else if(piChannel==giRecovChannel){
            psMessage=llStringTrim(psMessage, STRING_TRIM);
            if(psMessage!=""){ 
                llMessageLinked(LINK_THIS, 1900, "recovid", psMessage);
            }
        }
    }
    
    touch_start(integer total_number)
    {
        key lkTarget=llDetectedKey(0);
        integer liLinkPanel=llDetectedLinkNumber(0);
        integer liFace=llDetectedTouchFace(0);
        vector lvST=llDetectedTouchST(0);
        //llOwnerSay("*** "+(string)liFace+"   "+(string)lvST);
        if(giIsLock){
            if(llListFindList(gaAdmins,[(string)lkTarget])<0){ 
                fsay(lkTarget, "This Hud is locked by an Administrator");
                return;
            }
        }
        
        if(giCast){    //is blowing
            integer sw=0;
            if(liLinkPanel==giROOT){  //panel background
                if(liFace==0){   //background
                    if(lvST.x<0.329 || lvST.y>crBUTT.s) sw=1; //not is send,restore,load,menu buttons continue
                    if(lvST.x>0.61 && lvST.y>crBUTB.s) sw=1; //is scan button
                }else if(liFace>0){   //is cast,start button or tabs  continue
                    sw=1;
                }
            }else if(liLinkPanel==giICON){  //icon
                sw=1;
            }else if(liLinkPanel==giPANELAREA || liLinkPanel==giPANELCIRCLE || liLinkPanel==giPANELMAP || liLinkPanel==giPANELVARDATA || liLinkPanel==giPANELVARWIND || liLinkPanel==giPANELVARWAV || liLinkPanel==giPANELVARCUR){  
                sw=1;
                return;
            }
            if(sw==0){
                fsay(lkTarget,"The setter is broadcasting. Press Cast button before continuing");
                return;
            }
        }
        if(liLinkPanel==giROOT) setTouch0(lkTarget,liFace,lvST);    //panel background
        else if(liLinkPanel==giPANELBASE) setTouch1(lkTarget,liFace,lvST); //panel base
        else if(liLinkPanel==giPANELWAVES) setTouch2(lkTarget,liFace,lvST); //panel waves
        else if(liLinkPanel==giPANELCURRENT) setTouch3(lkTarget,liFace,lvST); //panel currents
        else if(liLinkPanel==giPANELOTHER) setTouch4(lkTarget,liFace,lvST); //panel others    //llMessageLinked(LINK_THIS,4903,(string)ST,k);
        else if(liLinkPanel==giICON){ //push icon hud
            if(llGetAttached()>0){
                hudSize(giLastHudSize);
                llMessageLinked(LINK_THIS, 2000+giLastHudSize, "icon", "");  //to GLW script
                llMessageLinked(LINK_THIS, 5000+giLastHudSize, "icon", "");  //to Var script  panel 5 and 6
                llMessageLinked(LINK_THIS, 6000+giLastHudSize, "icon", "");  //to Var menu script panel 7
            }
        }
    }    
    
    timer()
    {
        if(giTimerMenu>0) giTimerMenu--;
        else{
            llListenRemove(giListenHandle);
            giTimerMenu=-1;
            llSetTimerEvent(0.0);
            giDelEvent=0; 
        }
    }    
}











