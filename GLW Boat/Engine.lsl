//GLW 1.1 Engine Script 13Sep2022 LaliaCasau
//This script is based on the "Elementary Sail Boat Script" by Dora Gustafson 2017
//Modified by LaliaCasau 2022..
//
//VARIABLE NAMING
//I am using the Azn Min (itoibo) system with some variation, which uses two letters to describe the scope and data type of each variable.
//The first letter is the scope: g-global l-local c-constant p-parameter
//The second letter is the data type: i-integer f-float s-string k-key v-vector r-rotation a-array(list)   
//
//OTHERS
//To find what relates the Engine Script to the Receiver Script, find the following text: "<================== glw"
//To find the last modifications, find the following text: "v1.11" or "v1.2"
//

//=========>CONSTANTS
integer MSGTYPE_GLWPARAMS=70001;  //receive glw params
integer MSGTYPE_RESET=70003;
integer MSGTYPE_SAILING=70004;
integer MSGTYPE_MOORED=70005;
integer MSGTYPE_BOATPARAMS=70006;  //Boat params for shadow wind
integer MSGTYPE_GLWINICIO=70007;
integer MSGTYPE_WINDINFO=70008;
integer MSGTYPE_RECOVERY=70009;
integer MSGTYPE_MYWIND=70010;  //mywind/cruising mode, personal wind
integer MSGTYPE_GLWIND=70011;  //glwind mode, for cruises
integer MSGTYPE_RACING=70012;  //racing mode, for races
integer MSGTYPE_WORLDWIND=70013;  //world wind mode, to sailing

string gsSoundSail="glw_dboat_sail";
string gsSoundWaveUp="glw_dboat_waveup";
string gsSoundWaveDown="glw_dboat_wavedown";
string gsSoundRaise="glw_dboat_raise";
string gsSoundLower="glw_dboat_lower";

//general constants
float  cfThreeDEG = 3;         //degrees that the sail moves when pressing the arrows.  Then convert to radians
float  cfOneDEG = 1;           //degrees that the sail moves when pressing the PgUp pgDown.  Then convert to radians  
float  cfTime = 4.0;           //default settimerevent
vector cvBlue = <0.0, 0.455, 0.851>;
vector cvGreen = <0.18, 0.8, 0.251>;
vector cvYellow = <1.0, 0.863, 0.0>;
vector cvRed = <1.0, 0.255, 0.212>;
float  cfFloatLevel=-0.15;   //0.0;
integer ciPeriod=120;
float  cfPosZ=20.06340;
float  cfKt2Ms=0.514444;
string csMsgChangeWind="To take the GLW wind you have to be in personal wind mode, type 'mywind' or 'cruising'";

//boat constants
integer sailArea=25;  //for shadow wind may not be zero;
string  boatLength2Bow="1.5"; //for shadow wind
string  boatLength2Stern="2.1"; //for shadow wind
float  cfHeelFactor = .1;
vector cvRudderRot=<0.00000, 330.00000, 0.00000>;    //rudder rest rotation
vector cvWakePos=<0.77819,0,-0.07165>;

//sail constants
float  cfSailFactor = 1.25;   //4.0;
float  cfMaxSail = 67;         //degrees of maximum opening of the sail  Then convert to radians 
float  cfMinSail = 10;         //degrees of minimum close of the sail  Then convert to radians 
vector cvMainPosOpen=<-0.32976, 0.0, 3.41302>;       //main open position
vector cvMainPosClose=<-0.0449,0.0,1.24924>;         //main close position
vector cvMainSizeOpen=<4.63353, 0.60999, 4.33824>;   //main open size
vector cvMainSizeClose=<4.63353, 0.01000, 0.01000>;  //main close size
vector cvMainRotOpen=<0.0, 352.5, 0.0>;              //main open rest rotation
vector cvMainRotClose=ZERO_VECTOR;                  //main closed rest rotation
vector cvJibPos=<0.45718, 0.0, 2.32585>;             //jib position
vector cvJibSizeOpen=<3.25069, 0.52274, 3.52543>;    //jib open size
vector cvJibSizeClose=<0.01000, 0.01000, 3.52543>;   //jib close size
vector cvJibRot=<0.0, 337.5, 0.0>;                   //jib rest rotation
vector cvBoomRot=<0.00000, 352.00000, 0.00000>;      //boom rest rotation

//current constants
float cfCurrentFactorX=0.5;
float cfCurrentFactorY=0.5;

//wave constants
float cfWaveHoverMax=0.05; //max visual wave height meters
float cfWaveMaxHeelX=200;   //50.0; //max visual wave heel degrees
float cfWaveMaxHeelY=200;  //10.0; //max visual wave pitch degrees
float cfWaveHeelAt1MeterHeight=11.0;  //degrees wave heel for 1 meter wave height.
float cfWaveSpeedClimbFactor=0.8;   //speed reduction factor when climb a wave.   0.5=half   2.0=double 
                               //1.0=reduce 50% at 7 meters height wave for snipe (4.3m length), a larger boat the factor will be smaller 
float cfWaveSpeedDownFactor=0.8;   //speed increase factor when go down a wave.   0.5=half   2.0=double  
                               //1.0=reduce 50% at 7 meters height wave for snipe (4.3m length), a larger boat the factor will be smaller 
float cfWaveSteerFactor=0.5;  //Steer factor when climb or descent a wave   
//<=========END CONSTANTS                            

//LINKS NUMBERS
integer giCREW;
integer giTEXTHUD;
integer giMAIN;
integer giJIB;
integer giRUDDER;
integer giBOOM;
integer giWAKE;


//GLW PARAMS  parameters sent by GLW Receiver
//One time for start, update and recovery event
string  gsEventName;
string  gsGlwDirectorName;
string  gsGlwExtra1;        
string  gsGlwExtra2;

//each second
integer giWindDir=0;
integer giWindSpeed=15; 
integer giCurrentDir;  
float   gfCurrentSpeed;  
float   gfWaveHeight;  
float   gfWaveHeightMax;
integer giWaveEffects;    //0-none  1-wave steer effect  2-wave speed effect  3-both
integer giWindBend;       //shadow wind effect

//GLOBAL VARIABLES
key     gkHelm;
integer giHelmLink;
integer giChannel;
integer giListenHandle;
integer giWindMode;      //0-mywind/cruising   1-glw     2-racing 
integer giNumOfPrims;
vector  gvWindVector=<.0,9.0,.0>;  //wind from north, 9 m/s 
float   gfSailAngle;
string  gsAnim;
string  gsAnimBase;
integer giSailSide;   //-1 port    1 Stb  
float   gfSeaLevel;
float   gfExtraHeight;
integer giSailMode;  //0-moored  1-sailing
integer giSteeringDir;
float   gfRudderSteerEffect_z;
integer giHud;  //0-normal  1-extended1  2-extended2
float gfCtrlTimer; //Control event local var for SetTimerEvent
integer giInvert; //0-tiller    1-rudder    //<==== v1.11  invert command and mouselook
integer giCrr=CONTROL_ROT_RIGHT;        //<==== v1.11  invert command and mouselook
integer giCrl=CONTROL_ROT_LEFT;        //<==== v1.11  invert command and mouselook
integer giCmr=CONTROL_RIGHT;            //<==== v1.11  invert command and mouselook
integer giCml=CONTROL_LEFT;             //<==== v1.11  invert command and mouselook
integer giVCrr;    //<==== v1.11  invert command and mouselook
integer giVCrl;     //<==== v1.11  invert command and mouselook
integer giVCtl;    //<==== v1.11  invert command and mouselook
integer giHudsChannel;   //<================== glw v1.2 Boat communication channel with hud. Receiver creates it and sends it to the engine

//TIMER VARS
//GLOBAL TIMERS VARS
//timer global boat vars
rotation grBoatRot;
vector gvHeading;
vector gvLeft;
vector gvVelocity;         //vector boat velocity m/s
float gfSpeed;             //boat speed in m/s 
vector gvAw;               //vector Aparent Wind  radians
vector gvNAw;              //Normalized vector Aparent Wind radians
vector gvAxs;              //up or down axis to turn sail around
float gfAwAngle;           //apparent wind, local angle [0;PI] radians
float gfRWA;               //Real Wind Angle radians
integer giHead;            //heading degrees
rotation grSailRot;
float gfSetsail;           //final value of the angle of rotation of the sail radians
vector gvSailnormal;       //value of the vector normal to the sail in global coordinates
vector gvAction;           //value of the action of the wind on the boat 
integer giSwhead;
integer giHeadobj;
integer giSound;
integer giSoundOld;
float gfSoundWind=5.0158;

//timer global sail vars
float gfSailSpeedEffect_x;
float gfSailHeelEffect_x;

//timer global currents vars
float   gfCurrentSpeedEffect_x;
float   gfCurrentSpeedEffect_y;

//timer global waves vars
integer giWaveSign;
float gfWaveHeightPrev;
integer giSwSound;   //0 no sound   1 sail sound    2 up wave    3 down wave
integer giSwSoundOld;
float gfWaveHeelBoatY;     //pitch applied to the boat 
float gfWaveHeelBoatX;     //heel applied to the boat 
float gfWaveSpeedEffect_x;
float gfWaveSteerEffect_z;

//timer local boat vars
vector gvTemp;             //temporal var vector
float gfTotalHeelX;     //=heel for sails + heel for waves    radians
float gfMovZ;
vector gvAngular_motor;
vector gvLinear_motor;
string gsTextHud;
vector gvColor;            //color hud
string gsHudSymbol;     //color symbol
float gfBurstrate;
float gfBurstspeed;
string gsSymbol;
string gsWindMode; 

float gfEfiSail;
float gfAngle;
float gfSignSailWind;

//timer local currents vars
float gfCurrentAngle;  //angle between heading and current direction
vector gvCurrentVec;  ////current velocity

//timer local waves vars
float gfWaveHeightx1;
float gfWaveHeelMaxX;
float gfWaveHeelMaxY;
float gfwaveHeelMax;
string gsWaveBoatPosSymbol;    //Hud Symbol up or down wave / or \
string gsWaveBoatHeelSymbol;   //Hud Symbol inclination wave / or \
float gfWaveBoatPos;       //height of the boat in the wave 
float gfWaveSpeedEffectX;
float gfSteerEffect;
float gfWaveHeelX;
float gfWaveHeelY;

getLinkNums() 
{
    integer liI;
    integer liLinkCount=llGetNumberOfPrims();
    string lsStr;
    for (liI=1;liI<=liLinkCount;++liI) {
        lsStr=llGetLinkName(liI);
        if (lsStr=="crew") giCREW=liI;
        else if (lsStr=="texthud") giTEXTHUD=liI;
        else if (lsStr=="main") giMAIN=liI;
        else if (lsStr=="jib") giJIB=liI;
        else if (lsStr=="rudder") giRUDDER=liI;
        else if (lsStr=="boom") giBOOM=liI;
        else if (lsStr=="wake") giWAKE=liI;
    }
}

vehicle_params()
{ 
    llSetVehicleType(VEHICLE_TYPE_BOAT);
    llSetVehicleFlags(VEHICLE_FLAG_HOVER_GLOBAL_HEIGHT);
    llSetVehicleFloatParam(VEHICLE_BANKING_EFFICIENCY, 0.0 );
    llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_TIMESCALE, 0.75); // 0.75 default 4
    llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, 0); // default 0.5
    llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_TIMESCALE, 0); // default 3
    llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, 0); // default 0.5   <==== currents poner a 0
    llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, 0); // default 5
    //llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, 0.5); // default 0.5
    //llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_TIMESCALE, 3); // default 3
    //llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, 0.5); // default 0.5
    //llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, 5); // default 5
    llSetVehicleFloatParam(VEHICLE_HOVER_HEIGHT,llWater(ZERO_VECTOR)+cfFloatLevel);
    llSetVehicleFloatParam(VEHICLE_HOVER_EFFICIENCY,2.0);
    llSetVehicleFloatParam(VEHICLE_HOVER_TIMESCALE,1.0);
}

raise()
{
    vehicle_params();
    llSetLinkPrimitiveParamsFast(giMAIN,[PRIM_SIZE,cvMainSizeOpen,PRIM_POS_LOCAL,cvMainPosOpen,
        PRIM_ROT_LOCAL,llEuler2Rot(cvMainRotOpen*DEG_TO_RAD),PRIM_COLOR,2,<1.0,1.0,1.0>,1.0]);
    llSetLinkPrimitiveParamsFast(giJIB,[PRIM_SIZE,cvJibSizeOpen,PRIM_COLOR,2,<1.0,1.0,1.0>,1.0]);
    llSetStatus( STATUS_PHYSICS | STATUS_BLOCK_GRAB | STATUS_BLOCK_GRAB_OBJECT, TRUE);     //*****
    llMessageLinked(LINK_THIS, MSGTYPE_SAILING, "glw", "");                  //<================== glw sailing mode
    gfSailAngle=cfMinSail;
    giSailMode=1;
    llPlaySound(gsSoundRaise,1.0);
    //init timer vars
    giSailSide=0;
    gfCurrentSpeedEffect_x=0.0;
    gfCurrentSpeedEffect_y=0.0;
    gfWaveHeight=0.0;
    gfWaveHeightMax=0.0;
    llSetTimerEvent(2.0);  //start timer
    //llSetTimerEvent(0.05);  //start timer
}

moor(integer pi)
{
    llSetTimerEvent(0.0);
    //llSetVehicleFloatParam (VEHICLE_HOVER_HEIGHT, gfSeaLevel+cfFloatLevel);
    llSetStatus( STATUS_PHYSICS | STATUS_BLOCK_GRAB | STATUS_BLOCK_GRAB_OBJECT, FALSE);
    llSetVehicleType(VEHICLE_TYPE_NONE);
    giSailMode=0;
    llLinkParticleSystem(giWAKE,[]);
    mooredPos();  
    list la=llGetPrimitiveParams([PRIM_ROT_LOCAL,PRIM_POSITION]);
    vector lvVec=llRot2Euler((rotation)llList2String(la,0));
    vector lvPos=(vector)llList2String(la,1);
    lvPos.z=cfPosZ;
    llSetLinkPrimitiveParamsFast(LINK_ROOT,[PRIM_ROT_LOCAL,llEuler2Rot(<0,0,lvVec.z>),PRIM_POSITION,lvPos]); 
    llMessageLinked(LINK_THIS, MSGTYPE_MOORED, "glw", "");                  //<================== glw moored mode               
    llSetLinkPrimitiveParamsFast(giTEXTHUD,[PRIM_TEXT,"",<1,1,1>,0.0]);
    if(pi==1) llPlaySound(gsSoundLower,1.0);
    else llStopSound();
    giSwSound=giSwSoundOld=0;
}

mooredPos()
{
    llSetLinkPrimitiveParamsFast(giMAIN,[PRIM_SIZE,cvMainSizeClose,PRIM_POS_LOCAL,cvMainPosClose,
        PRIM_ROT_LOCAL,llEuler2Rot(cvMainRotClose*DEG_TO_RAD),PRIM_COLOR,ALL_SIDES,<1.0,1.0,1.0>,0.0]);
    llSetLinkPrimitiveParamsFast(giJIB,[PRIM_SIZE,cvJibSizeClose,PRIM_POS_LOCAL,cvJibPos,
        PRIM_ROT_LOCAL,llEuler2Rot(cvJibRot*DEG_TO_RAD),PRIM_COLOR,ALL_SIDES,<1.0,1.0,1.0>,0.0]);
    llSetLinkPrimitiveParamsFast(giRUDDER,[PRIM_ROT_LOCAL,llEuler2Rot(cvRudderRot*DEG_TO_RAD)]);
    llSetLinkPrimitiveParamsFast(giBOOM,[PRIM_ROT_LOCAL,llEuler2Rot(cvBoomRot*DEG_TO_RAD)]);
}

vector angle2Vector(integer piAngle, integer piVel)
{
    while(piAngle>180) piAngle-=360;
    return(<llSin(piAngle*DEG_TO_RAD),llCos(piAngle*DEG_TO_RAD),0.0>*piVel*cfKt2Ms);
}

inicio(integer piMode)
{
    llSetLinkPrimitiveParamsFast(giTEXTHUD,[PRIM_TEXT,"",<1,1,1>,1.0]);
    //==>Start Initial Position
    gfSeaLevel=llWater(ZERO_VECTOR);
    vector lvPos=llGetPos();
    vector lvRot=llRot2Euler(llGetRot());
    llSetRot(llEuler2Rot(<0,0,lvRot.z>));
    //if over water, set boat height to sealevel;
    if (llGround(ZERO_VECTOR)<= gfSeaLevel) {
        lvPos.z=gfSeaLevel+cfFloatLevel+0.2;
        while (llVecDist(llGetPos(),lvPos)>.001) llSetPos(lvPos);
    }
    llSetLinkPrimitiveParamsFast(giWAKE,[PRIM_ROT_LOCAL,ZERO_ROTATION,PRIM_POS_LOCAL,cvWakePos]);
    //<==End Initial Position 
    moor(0); 
    giWindMode=0;  //for personal wind
    llMessageLinked(LINK_THIS, MSGTYPE_MYWIND, "glw", "");    //<================== glw personal wind mode
    gfSailAngle=cfMinSail;
    if(piMode==0){   //from state_entry
        integer n=llGetNumberOfPrims()-llGetObjectPrimCount(llGetKey());
        if(n>0) sitHelm();   //sit helm
        if(n>1) llMessageLinked(LINK_THIS,0,"crewport","");    //sit crew
        llMessageLinked(LINK_THIS, MSGTYPE_BOATPARAMS, "glw", (string)sailArea+","+boatLength2Bow+","+boatLength2Stern+",1");    //<================== glw update boat parameters for shadow wind + switch send params to hud    
    
    }
    giSwSound=giSwSoundOld=0;
    llOwnerSay("The boat is ready");
}

integer lslAngle2RealAngle(integer lslAngle) {
    integer realAngle= (lslAngle-90)*-1;
    while(realAngle>=360) realAngle-=360;
    while(realAngle<0) realAngle+=360;
    return realAngle;
}

sitHelm()
{
    key lkAvi=llAvatarOnLinkSitTarget(LINK_ROOT);
    if(lkAvi){
        if(gkHelm){ 
            return;
        }else{
            if(lkAvi==llGetOwner()){
                gkHelm=lkAvi;
                giHelmLink=llGetNumberOfPrims();
                llSetLinkPrimitiveParamsFast(giHelmLink,[PRIM_POS_LOCAL,<-1.6, 0.3, 0.25>]);
                gsAnimBase="helmPort";
                gsAnim=gsAnimBase;
                llRequestPermissions(gkHelm, PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION | PERMISSION_CONTROL_CAMERA);
            }else{
                llSay(0,"Only the owner can handle the boat");
            }
        }
    }else{
        if(gkHelm){
            llSetTimerEvent(0.0);
            llReleaseControls();
            llListenRemove(giListenHandle);
            moor(0);
            gkHelm=""; 
            giHelmLink=0;
        }
    }
}

putCamera()
{
    llClearCameraParams(); // reset camera to default
    llSetCameraParams([CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
            CAMERA_BEHINDNESS_ANGLE, 0.0, // (0 to 180) degrees
            CAMERA_BEHINDNESS_LAG, 0.0, // (0 to 3) seconds
            CAMERA_DISTANCE, 5.0, // ( 0.5 to 10) meters
            //CAMERA_FOCUS, <0,0,0>, // region relative position
            CAMERA_FOCUS_LAG, 0.05, // 0.05 , // (0 to 3) seconds
            CAMERA_FOCUS_LOCKED, FALSE, // (TRUE or FALSE)
            CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
            CAMERA_PITCH, 10.0, // (-45 to 80) degrees
            //CAMERA_POSITION, <0,0,0>, // region relative position
            CAMERA_POSITION_LAG, 0.0, // (0 to 3) seconds
            CAMERA_POSITION_LOCKED, FALSE, // (TRUE or FALSE)
            CAMERA_POSITION_THRESHOLD, 0.0 // (0 to 4) meters 
        ]);
}

default
{
    state_entry()
    {
        llResetOtherScript("Crew");
        llMessageLinked(LINK_THIS, MSGTYPE_RESET, "glw", "");           //<================== glw. Reset "GLW Receiver" script
        llSetStatus( STATUS_PHYSICS | STATUS_BLOCK_GRAB | STATUS_BLOCK_GRAB_OBJECT, FALSE);
        giNumOfPrims=llGetObjectPrimCount(llGetKey());
        cfThreeDEG = cfThreeDEG*DEG_TO_RAD;    //converts deg to radians
        cfOneDEG = cfOneDEG*DEG_TO_RAD;    //converts deg to radians
        cfMaxSail = cfMaxSail*DEG_TO_RAD;  //converts deg to radians
        cfMinSail = cfMinSail*DEG_TO_RAD;  //converts deg to radians
        integer liI;
        for(liI=1;liI<=giNumOfPrims;liI++) llLinkSitTarget(liI,ZERO_VECTOR,ZERO_ROTATION);   
        getLinkNums();
        llLinkSitTarget(LINK_ROOT,<-1.6, 0.0, 0.25>,ZERO_ROTATION);    //set sittarget for helm
        if(giCREW>0) llLinkSitTarget(giCREW,<-1.2, 0.0, 0.25>,ZERO_ROTATION);   //set sittarget for crew 
        giChannel=0;
        inicio(0);
        llOwnerSay("Ready "+llGetScriptName()+" "+(string)llGetFreeMemory()); 
    }
    
    on_rez( integer p){ 
        inicio(1);
    }
    
    touch_start(integer num_detected)
    {
        string lsWindMode;
        if(gkHelm){
            if(giWindMode==0) lsWindMode="Personal Wind=>";
            else if(giWindMode==1) lsWindMode="Cruise Wind=>";
            else if(giWindMode==2) lsWindMode="Race Wind=>";
            lsWindMode+=" DIR: "+(string)giWindDir+"º SPD: "+(string)giWindSpeed+"kt";
        }else{
            lsWindMode="Moored";
        }
        llInstantMessage(llDetectedKey(0), llGetDisplayName(llGetOwner())+": "+lsWindMode);
    }    
    
    listen(integer piChannel, string psName, key pkId, string psMsg)
    {
        if(giSailMode==1 && llGetSubString(psMsg,0,4)=="sheet") {
            float lfDeg=(integer)llGetSubString(psMsg,5,-1)*DEG_TO_RAD;
            if(lfDeg>0){
                if(gfSailAngle+lfDeg < cfMaxSail) gfSailAngle+=lfDeg;
                else gfSailAngle=cfMaxSail;
            }else if(lfDeg<0){
                if(gfSailAngle+lfDeg > cfMinSail) gfSailAngle += lfDeg;
                else gfSailAngle=cfMinSail;
            }
            llSetTimerEvent( 0.05);
        }else if (psMsg=="raise") raise();
        else if (psMsg=="moor") moor(1);
        else if (psMsg=="mywind" || psMsg=="cruising"){ 
            giWindMode=0;  //for personal wind
            gfWaveHeightMax=0.0;
            gfCurrentSpeed=0.0;
            llMessageLinked(LINK_THIS, MSGTYPE_MYWIND, "glw", ""); //<================== glw personal wind mode
        }else if(llGetSubString(psMsg,0,2)=="glw"){        //<==== v1.12 The glw command can take a parameter exam: glw tyccruise 
            if(giWindMode==0){
                giWindMode=1;   //for cruise
                llMessageLinked(LINK_THIS, MSGTYPE_GLWIND, "glw", psMsg); //<================== glw glw wind mode for cruise. v1.12 add psMsg parameter
            }else{
                llOwnerSay(csMsgChangeWind);
            }
        }else if(llGetSubString(psMsg,0,5)=="racing"){      //<==== v1.12 The racing command can take a parameter exam: racing b22race  
            if(giWindMode==0){
                giWindMode=2;  //for race
                llMessageLinked(LINK_THIS, MSGTYPE_RACING, "glw", psMsg); //<================== glw race wind mode for racing. v1.12 add psMsg parameter
            }else{
                llOwnerSay(csMsgChangeWind);
            }
        }else if (psMsg=="worldwind"){
            if(giWindMode==0){
                giWindMode=3;  //for world wind, to sailing
                llMessageLinked(LINK_THIS, MSGTYPE_WORLDWIND, "glw", ""); //<================== glw world wind mode NO IMPLEMENTED
            }else{
                llOwnerSay(csMsgChangeWind);
            }
        }else if (psMsg=="hud"){ 
            if(giHud==2) giHud=0;
            else giHud++;
        }else if(llGetSubString(psMsg,0,7)=="channel "){ 
            giChannel=(integer)llGetSubString(psMsg,7,-1);
            if(gkHelm){ 
                llListenRemove(giListenHandle);
                giListenHandle=llListen(giChannel, "", gkHelm, "");
            }
            llOwnerSay("Your channel is: "+(string)giChannel);
        }else if(psMsg=="cam"){ 
            if(llGetPermissions() & PERMISSION_CONTROL_CAMERA) putCamera();
            else llOwnerSay("You do not have permissions to reset the camera");
        }else if(psMsg=="recovery"){ 
            llMessageLinked(LINK_THIS, MSGTYPE_RECOVERY, "glw", ""); //<================== glw recovery command to recover the wind after a crash
        }else if(psMsg=="windinfo"){ 
            llMessageLinked(LINK_THIS, MSGTYPE_WINDINFO, "glw", ""); //<================== glw info command to print settings in chat
        }else if(psMsg=="boatreset"){ 
            llResetScript();
        }else if(psMsg=="help"){ 
            llOwnerSay("Boat commands:\nmoor\nraise\nwinddir n\nwindspeed n\nglw\nracing\nmywind/cruising\nworldwind\ncam\nhud\nchannel\nrecovery\nwindinfo\nsheet n\nboatreset\nhelp\ninvert");
        }else if(psMsg=="invert"){        //<==== v1.11  invert command and mouselook
            giInvert=!giInvert;
            if(giInvert){
                giCrr=CONTROL_ROT_LEFT;
                giCrl=CONTROL_ROT_RIGHT;
                giCmr=CONTROL_LEFT;
                giCml=CONTROL_RIGHT; 
            }else{
                giCrr=CONTROL_ROT_RIGHT;
                giCrl=CONTROL_ROT_LEFT;
                giCmr=CONTROL_RIGHT;
                giCml=CONTROL_LEFT; 
            }
        }else if(giWindMode==0){
            if (llGetSubString(psMsg,0,6)=="winddir") {  //personal wind direction
                integer liN=(integer)llGetSubString(psMsg,7,-1);
                if (liN>=0 || liN<=359) { 
                    giWindDir=liN;      
                    gvWindVector=angle2Vector(giWindDir,giWindSpeed); 
                } 
            }else if (llGetSubString(psMsg,0,8)=="windspeed") {  //personal wind speed
                integer liN=(integer)llGetSubString(psMsg,9,-1);
                if(liN>=5 || liN<=30) {     
                    giWindSpeed=liN;      
                    gvWindVector=angle2Vector(giWindDir,giWindSpeed); 
                    gfSoundWind=giWindSpeed*cfKt2Ms*0.7;   //----->the boat maximum speed m/s. Is 65% of the wind speed (depending on the boat)
                } 
            }
        }
    } 
    
    link_message(integer sender_num, integer num, string str, key id) 
    {
        if(str=="glw"){                                //<================== glw. identifies the messages sent by GLW Receive
            if(num==MSGTYPE_GLWPARAMS) {                           //<================== glw. You receive the glw wind parameters every second
                //llOwnerSay("wind data: "+(string)id);
                list laParams=llCSV2List((string)id);
                giWindDir=(integer)llList2String(laParams,0);   //degrees
                giWindSpeed=(integer)llList2String(laParams,1);  //kt
                giCurrentDir=(integer)llList2String(laParams,2);  //degrees
                gfCurrentSpeed=(float)llList2String(laParams,3);  //kt
                gfWaveHeight=(float)llList2String(laParams,4);    //meters
                gfWaveHeightMax=(float)llList2String(laParams,5);  //meters
                giWaveEffects=(integer)llList2String(laParams,6);  //0-no effects  1-steer effect  2-speed effect  3-speed & steer effects
                giWindBend=(integer)llList2String(laParams,7);      //shadow effect
                
                //llOwnerSay("from receive "+(string)id);
                
                gvWindVector=angle2Vector(giWindDir,giWindSpeed);   //calc wind vector
                if(gfWaveHeightMax>0) gfExtraHeight=gfWaveHeight*cfWaveHoverMax/gfWaveHeightMax;  //calc hover height produced by the waves
                else gfExtraHeight=0.0;
                
                gfSoundWind=giWindSpeed*cfKt2Ms*0.7;   //----->the boat maximum speed m/s. Is 65% of the wind speed (depending on the boat)
    
            }else if(num==MSGTYPE_GLWINICIO) {               //<================== glw. You receive it when wind are started, updated or recovery
                list laParams=llCSV2List((string)id);
                integer liType=(integer)llList2String(laParams,0);   //0-started  1-recovery  2-updated
                gsEventName=llList2String(laParams,1);
                gsGlwDirectorName=llList2String(laParams,2);
                gsGlwExtra1=llList2String(laParams,3);
                gsGlwExtra2=llList2String(laParams,4);
                if(liType==1) giWindMode=(integer)llList2String(laParams,5);  //for recovery save windMode
                giHudsChannel=llList2Integer(laParams,6);     //<================== glw v1.2 Receive Hud's Channel from Script Receiver
            }
        }
    }            
    
    changed(integer piChange)
    {
        if (piChange & CHANGED_LINK){
            sitHelm();
        }
    }
    
    run_time_permissions(integer perm)
    {
        if ( perm & PERMISSION_TRIGGER_ANIMATION ) {
            list laAnims=llGetAnimationList(gkHelm);    
            integer liN=llGetListLength(laAnims);
            integer liI; 
            if(llGetAgentSize(gkHelm)){   ´
                for(liI=0;liI<liN;liI++){
                    if((key)llList2String(laAnims,liI)) llStopAnimation(llList2String(laAnims,liI));
                }
            }   
            giListenHandle=llListen(giChannel, "", gkHelm, "");
            llStartAnimation(gsAnim);            
        }
        if ( perm & PERMISSION_TAKE_CONTROLS ) { 
            llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_UP | CONTROL_DOWN | CONTROL_ROT_RIGHT | CONTROL_ROT_LEFT | CONTROL_LEFT | CONTROL_RIGHT, TRUE, FALSE);
        }
        if ( perm & PERMISSION_CONTROL_CAMERA ) { 
            putCamera();
        }
    }
    
    control(key id, integer level, integer edge)
    {
        if(giSailMode==0) return;
        
        if(edge & level & (CONTROL_FWD | CONTROL_BACK | CONTROL_UP | CONTROL_DOWN)){
            if(edge & level & CONTROL_FWD){
                if(gfSailAngle+cfThreeDEG < cfMaxSail) gfSailAngle+=cfThreeDEG;
                else gfSailAngle=cfMaxSail;
            }else if(edge & level & CONTROL_BACK){
                if(gfSailAngle-cfThreeDEG > cfMinSail) gfSailAngle-=cfThreeDEG;
                else gfSailAngle=cfMinSail;
            }else if(edge & level & CONTROL_UP){
                if(gfSailAngle+cfOneDEG < cfMaxSail) gfSailAngle+=cfOneDEG;
                else gfSailAngle=cfMaxSail;
            }else if(edge & level & CONTROL_DOWN){
                if(gfSailAngle-cfOneDEG > cfMinSail) gfSailAngle-=cfOneDEG;
                else gfSailAngle=cfMinSail;
            }
            llSetTimerEvent(0.05);
            return;
        }
        
        if (!(llGetAgentInfo(gkHelm) & AGENT_MOUSELOOK)){    //it's not in mouselook //<==== v1.11  invert command and mouselook
            giVCtl=CONTROL_ROT_RIGHT | CONTROL_ROT_LEFT;
            giVCrr=giCrr;     //<==== v1.11  invert command and mouselook
            giVCrl=giCrl;    //<==== v1.11  invert command and mouselook
        }else{
            giVCtl=CONTROL_RIGHT | CONTROL_LEFT;  //it is in mouselook  //<==== v1.11  invert command and mouselook
            giVCrr=giCmr;    //<==== v1.11  invert command and mouselook
            giVCrl=giCml;    //<==== v1.11  invert command and mouselook
        }

        if(edge & giVCtl){  //left or right keys helm. raise and leave state swstate>1
            gfCtrlTimer=0.05;
            if(edge & level & giVCrr) {    //right    //<==== v1.11  invert command and mouselook
                gfRudderSteerEffect_z=0.8;
                giSteeringDir=1;
                llStopAnimation(gsAnim);
                gsAnim=gsAnimBase+"-R";
                llStartAnimation(gsAnim);
                llSetLinkPrimitiveParamsFast(giRUDDER,[PRIM_ROT_LOCAL, llEuler2Rot(<0,330,-21>*DEG_TO_RAD)]);
                llSetVehicleVectorParam  (VEHICLE_LINEAR_FRICTION_TIMESCALE,<100.0,0.05,0.5>);
            } else if(edge & level & giVCrl) {  //left      //<==== v1.11  invert command and mouselook
                gfRudderSteerEffect_z=-0.8;
                giSteeringDir=-1;
                llStopAnimation(gsAnim);
                gsAnim=gsAnimBase+"-L";
                llStartAnimation(gsAnim);
                llSetLinkPrimitiveParamsFast(giRUDDER,[PRIM_ROT_LOCAL, llEuler2Rot(<0,330,21>*DEG_TO_RAD)]);
                llSetVehicleVectorParam  (VEHICLE_LINEAR_FRICTION_TIMESCALE,<100.0,0.05,0.5>);
            } else if(edge & giVCtl) {   //up arrow key
                gfRudderSteerEffect_z=0.0;
                giSteeringDir=0;
                llStopAnimation(gsAnim);
                gsAnim=gsAnimBase;
                llStartAnimation(gsAnim);
                llSetLinkPrimitiveParamsFast(giRUDDER,[PRIM_ROT_LOCAL, llEuler2Rot(<0,330,0>*DEG_TO_RAD)]);
                llSetVehicleVectorParam  (VEHICLE_LINEAR_FRICTION_TIMESCALE,<100.0,100.0,0.5>);
                gvAngular_motor.z=gfRudderSteerEffect_z;
                llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, gvAngular_motor);  //stops turning
                gfCtrlTimer=1.0;  //wait for it to finish spinning
            }
            llSetTimerEvent(gfCtrlTimer);
        }
    }
    
    timer()
    {
        if (llGetStatus(STATUS_PHYSICS)) {
            llSetTimerEvent(0.0);  //stop timer
            // vector capture
            grBoatRot = llGetRot();
            gvHeading = llRot2Fwd(grBoatRot);
            gvLeft = llRot2Left(grBoatRot);
            gvVelocity = llGetVel();
            //gfSpeed = llVecMag(gvVelocity);
            gvAw = gvWindVector + gvVelocity;    //apparent wind
            gvAw.z = 0.0;
            gvNAw = llVecNorm(gvAw);
            gvAxs = gvHeading%gvNAw;             //up or down axis to turn sail around
            gfAwAngle = llAcos(gvHeading*gvNAw); //apparent wind, local angle [0;PI] radians
            
            //gfSailAngle=gfAwAngle/2;  //*****
            
            gfRWA=llAcos(gvHeading*llVecNorm(gvWindVector)); //real wind angle, local angle [0;PI] radians
            
            //shadow wind affects the angle of the apparent wind
            if(giWindBend>0) { 
                if(gfAwAngle>0) gfAwAngle-=giWindBend*DEG_TO_RAD;
                else gfAwAngle+=giWindBend*DEG_TO_RAD;
            }
    
            //======>SETTING SAIL AND SAILORS
            if(gfAwAngle>gfSailAngle) gfSetsail=gfSailAngle;
            else gfSetsail=gfAwAngle;
            grSailRot = llAxisAngle2Rot(<.0,.0,gvAxs.z>,gfSetsail);
            gvSailnormal = llRot2Left(grSailRot)*grBoatRot;     //Global
            if((grSailRot.z<0.0 && giSailSide<0) || (grSailRot.z>0.0 && giSailSide>0)){  //the sail is on the ok side
                llSetLinkPrimitiveParamsFast( giMAIN, [PRIM_ROT_LOCAL, grSailRot*llEuler2Rot(cvMainRotOpen*DEG_TO_RAD)]);   //set main
                llSetLinkPrimitiveParamsFast( giJIB, [PRIM_ROT_LOCAL, grSailRot*llEuler2Rot(cvJibRot*DEG_TO_RAD)]);         //set jib
            }else if(grSailRot.z<0.0) {   //change sails side
                giSailSide=-1;   //starboard
                llSetLinkPrimitiveParamsFast( giMAIN, [PRIM_ROT_LOCAL, grSailRot*llEuler2Rot(cvMainRotOpen*DEG_TO_RAD),
                    PRIM_COLOR,1,<1.0,1.0,1.0>,1.0,PRIM_COLOR,2,<1.0,1.0,1.0>,0.0]);
                llSetLinkPrimitiveParamsFast( giJIB, [PRIM_ROT_LOCAL, grSailRot*llEuler2Rot(cvJibRot*DEG_TO_RAD),
                    PRIM_COLOR,1,<1.0,1.0,1.0>,1.0,PRIM_COLOR,2,<1.0,1.0,1.0>,0.0]);
                //change sailors side
                llMessageLinked(LINK_THIS,0,"crewstb","");   //change Crew, message to crew script
                //   detect helm link
                if(gkHelm==llGetLinkKey(giNumOfPrims+1)) giHelmLink=giNumOfPrims+1;
                else if(gkHelm==llGetLinkKey(giNumOfPrims+2)) giHelmLink=giNumOfPrims+2;
                else giHelmLink=0;
                if(giHelmLink>0) llSetLinkPrimitiveParamsFast(giHelmLink,[PRIM_POS_LOCAL,<-1.6, -0.3, 0.25>]);
                gsAnimBase="helmStb";
                llStopAnimation(gsAnim);
                gsAnim=gsAnimBase;
                llStartAnimation(gsAnim);
            }else if(grSailRot.z>0.0) {  //change the sail side
                giSailSide=1;  //port
                llSetLinkPrimitiveParamsFast( giMAIN, [PRIM_ROT_LOCAL, grSailRot*llEuler2Rot(cvMainRotOpen*DEG_TO_RAD),
                    PRIM_COLOR,1,<1.0,1.0,1.0>,0.0,PRIM_COLOR,2,<1.0,1.0,1.0>,1.0]);
                llSetLinkPrimitiveParamsFast( giJIB, [PRIM_ROT_LOCAL, grSailRot*llEuler2Rot(cvJibRot*DEG_TO_RAD),
                    PRIM_COLOR,1,<1.0,1.0,1.0>,0.0,PRIM_COLOR,2,<1.0,1.0,1.0>,1.0]);
                //change sailors side
                llMessageLinked(LINK_THIS,0,"crewport","");    
                if(gkHelm==llGetLinkKey(giNumOfPrims+1)) giHelmLink=giNumOfPrims+1;
                else if(gkHelm==llGetLinkKey(giNumOfPrims+2)) giHelmLink=giNumOfPrims+2;
                else giHelmLink=0;
                if(giHelmLink>0) llSetLinkPrimitiveParamsFast(giHelmLink,[PRIM_POS_LOCAL,<-1.6, 0.3, 0.25>]);
                gsAnimBase="helmPort";
                llStopAnimation(gsAnim);
                gsAnim=gsAnimBase;
                llStartAnimation(gsAnim);
            }
            llSetLinkPrimitiveParamsFast(giBOOM,[PRIM_ROT_LOCAL, grSailRot*llEuler2Rot(cvBoomRot*DEG_TO_RAD)]);   //set boom
            
            //calc sails speed and heel effects
            if(llFabs(gvSailnormal*gvNAw)>=cfMinSail){
                if(gvAxs.z<0) gvAction=llVecMag(gvAw)*gvSailnormal;
                else gvAction=-llVecMag(gvAw)*gvSailnormal;   

                //eficience calc
                if(gfSailAngle==0){ 
                    gfEfiSail=0;
                }else{ 
                    if(gfAwAngle>2.61799){   //tailwind  >150º
                        gfAngle=gfSetsail+PI_BY_TWO;  //angle optimum wind perpendicular to the sail
                        gfEfiSail=(gfAngle-llFabs(gfAwAngle-gfAngle))/gfAngle;  //sail eficience
                    //}else if(AwAngle>=MAXSAIL*2 && AwAngle<=MAXSAIL+PI_BY_TWO && setsail==MAXSAIL){  //viento entre 94 y 135 grados
                    //    efiSail=1.0;
                    }else if(llFabs(gfSetsail-gfAwAngle)<0.087){  //5º
                        gfEfiSail=0.0;
                    }else{   //viento menor de 94 grados
                        gfAngle=(gfAwAngle*RAD_TO_DEG)/2;  //optimum sail angle
                        gfSignSailWind=(gfSetsail*RAD_TO_DEG)-gfAngle; 
                        if(llFabs(gfSignSailWind)<1.0) gfSignSailWind=0.0;    
                        gfEfiSail=(gfAngle-llFabs(gfSignSailWind))/gfAngle;  //sail eficience
                        if(gfEfiSail<0) gfEfiSail=0;  
                        else if(gfAwAngle<0.52){  //wind <30º
                            gfEfiSail=gfEfiSail*(gfAwAngle/0.52);
                        }else if(gfEfiSail>0.96){    //max eficience
                            if(gfAngle<30) gfEfiSail=1.0;   //si angulo optimo <30 y dif <0.04 efi=1 
                            else if(gfEfiSail>0.98) gfEfiSail=1.0;  //si angulo >=30 y dif<0.02 efi=1
                        }
                    }
                }
                
            }else{ 
                gvAction=ZERO_VECTOR;
            }
            
            gfSailSpeedEffect_x = cfSailFactor*gvAction*gvHeading*gfEfiSail;   //sail speed effect 
            gfSailHeelEffect_x = -cfHeelFactor*gvAction*gvLeft*gfEfiSail;          //sail heel effect
            giHead=llRound(llAtan2(gvHeading.x,gvHeading.y)*RAD_TO_DEG);  //global heading in degrees
            if(giHead<0) giHead+=360;
            else if(giHead>359) giHead-=360;
            //<====== SETTING SAIL AND SAILORS
            
            float lfPara=0.5*llPow((llFabs(gfAwAngle)-PI_BY_TWO),2);
            if(gfAwAngle>PI_BY_TWO) lfPara=-lfPara-lfPara*2.0*((gfAwAngle-PI_BY_TWO)/PI_BY_TWO);
            else lfPara+=lfPara*4.0*(gfAwAngle/PI_BY_TWO);
            
           //llOwnerSay("******************** fuerza "+(string)llVecMag(gvAw)+"  "+
           //    "AWA: "+(string)llRound(gfAwAngle*RAD_TO_DEG)+"º  Sheet: "+(string)llRound(gfSailAngle*RAD_TO_DEG)+"º Speed: "+llGetSubString((string)(llVecMag(llGetVel())/cfKt2Ms),0,3)+"kt  effect "+(string)gfSailSpeedEffect_x+"   efici "+(string)gfEfiSail);


            //===>CALC CURRENTS AND WATERSPEED
            //input vars gfCurrentSpeed, giCurrenDir, giHead
            //output vars gfCurrentSpeedEffect_x, gfCurrentSpeedEffect_y
            //local vars gfCurrentAngle, gvCurrentVec
            if(gfCurrentSpeed!=0.0) {
                gfCurrentAngle=(giHead-giCurrentDir+180)*DEG_TO_RAD;  //angle between heading and current direction
                gfCurrentSpeedEffect_x=llCos(gfCurrentAngle)*gfCurrentSpeed*cfKt2Ms*cfCurrentFactorX; //x-axis boat current speed
                gfCurrentSpeedEffect_y=llSin(gfCurrentAngle)*gfCurrentSpeed*cfKt2Ms*cfCurrentFactorY; //y-axis boat current speed

                //calc waterspeed
                gvCurrentVec=<llCos(giCurrentDir*DEG_TO_RAD),llSin(giCurrentDir*DEG_TO_RAD),0> * gfCurrentSpeed*cfKt2Ms; //current velocity
            }else{
                gfCurrentSpeedEffect_x=gfCurrentSpeedEffect_y=0;
            }
            //<===CALC CURRENTS AND WATERSPEED

            //===>CALC WAVES
            //constants: cfWaveHeelAt1MeterHeight, cfWaveMaxHeelX, cfWaveMaxHeelY
            //input vars: gfWaveHeightMax, gfWaveHeight, gfRWA, gfWaveHeightPrev, giWaveSign, giSwSound, gfAwAngle
            //output vars: gfWaveHeelX, gfWaveHeelY, gfWaveHeightPrev, giWaveSign, giSwSound, gfWaveHeelBoatY, gsWaveBoatPosSymbol
            //temporal vars: gfWaveHeightx1, gfWaveHeelMaxX, gfWaveHeelMaxY, gfwaveHeelMax, gfWaveBoatPos
            if(gfWaveHeightMax>0.0){
                gfWaveHeightx1=gfWaveHeight/gfWaveHeightMax;  //1 up, -1 down, 0 middle    0,1,0,-1,0,...   unit value of wave height
                gfWaveBoatPos=llSin(llAcos(gfWaveHeightx1));   //0-flat up or down  1-max heel in the wave middle
                gfwaveHeelMax = gfWaveHeightMax*cfWaveHeelAt1MeterHeight;  //max heel degrees
                //heel>
                gfWaveHeelMaxX = gfwaveHeelMax*llSin(gfRWA);   //max heel depending on relative real wind direction. 90 max heel wave through degrees
                gfWaveHeelX=gfWaveHeelMaxX*gfWaveBoatPos;  //heel depending of the height of the boat in the wave  degrees
                //<
                //pich>
                gfWaveHeelMaxY = llFabs(gfwaveHeelMax*llCos(gfRWA)); //max pich depending on relative real wind direction. 0/180º max pich degrees
                gfWaveHeelY=gfWaveHeelMaxY*gfWaveBoatPos;  //pich depending on wave height  degrees
                //<
                if(gfWaveHeightx1<gfWaveHeightPrev){  //the boat descend the wave 
                    gfWaveBoatPos=-gfWaveBoatPos;       //negative
                    gfWaveHeelY=-gfWaveHeelY;           //pitch
                    gfWaveHeelX=-gfWaveHeelX;
                    giWaveSign=-1;           //heel
                    giSwSound=3;  //wave down
                }else if(gfWaveHeightx1>gfWaveHeightPrev){  //the boat climb the wave
                    giWaveSign=1;
                    giSwSound=2;   //wave up
                }else if(giWaveSign==-1){  
                    gfWaveBoatPos=-gfWaveBoatPos;       //negative
                    gfWaveHeelY=-gfWaveHeelY;           //pitch
                    gfWaveHeelX=-gfWaveHeelX;
                }                
                gfWaveHeightPrev=gfWaveHeightx1;

                if(gfWaveHeelMaxY>cfWaveMaxHeelY) gfWaveHeelBoatY=-gfWaveHeelY*cfWaveMaxHeelY/gfWaveHeelMaxY;  //pich weighting
                else gfWaveHeelBoatY=-gfWaveHeelY;
                if(llFabs(gfAwAngle)>120*DEG_TO_RAD) gfWaveHeelBoatY=gfWaveHeelBoatY*0.8;  // reduce the visual wave pitch effect a little when going downwind 

                if(gfWaveHeelMaxX>cfWaveMaxHeelX) gfWaveHeelBoatX=gfWaveHeelX*cfWaveMaxHeelX/gfWaveHeelMaxX;  //heel weighting
                else gfWaveHeelBoatX=gfWaveHeelX;

                //WAVE SPEED EFFECT
                //the wave reduce or increase the speed effect of the wind by a percentage
                //gfWaveHeightMax  is the max wave height of the water to the crest, i.e. the middle of the wave 
                //constants: cfWaveSpeedClimbFactor, , cfWaveSpeedDownFactor
                //input vars: giWaveEffects, gfWaveBoatPos, gfSailSpeedEffect_x, gfWaveHeight, gfWaveHeightMax, gfRWA
                //output vars: gfWaveSpeedEffect_x
                //temporal vars: gfWaveSpeedEffectX
                if(giWaveEffects>=2){  //speed effect active
                    if(llFabs(gfWaveBoatPos)<0.3){ 
                        gfWaveSpeedEffect_x=0.0;
                    }else if(gfWaveBoatPos>0){   //climb the wave
                        //when the boat is rising to 7 meters in height, the speed is reduced by 50%. 0.5/7=0.072
                        //gfWaveHeight range = -gfWaveHeightMax to gfWaveHeightMax
                        //(gfWaveHeightMax+gfWaveHeight) = 0 to gfWaveHeightMax*2  from the valley to the ridge
                        gfWaveSpeedEffectX=-(gfSailSpeedEffect_x*(gfWaveHeightMax+gfWaveHeight)*0.072*cfWaveSpeedClimbFactor);
                        //This effect increases if the boat is going with or against the REAL wind and is reduced to 0 when the boat is across the wind.
                        gfWaveSpeedEffect_x=gfWaveSpeedEffectX*llFabs(llCos(gfRWA));  //llFabs(llCos(gfRWA)) = 0 for 0,180º and 1 for 90º
                    }else if(gfWaveBoatPos<0){ //descend the wave 
                        //when the boat has descended a wave of 7 meters its speed increases by 50%. 7*0.072=0.5
                        //3*gfWaveHeightMax-gfWaveHeight = 0 to gfWaveHeightMax*2  from the ridge to the valley
                        gfWaveSpeedEffectX=gfSailSpeedEffect_x*(3*gfWaveHeightMax-gfWaveHeight)*0.072*cfWaveSpeedDownFactor;
                        //This effect increases if the boat is going with or against the REAL wind and is reduced to 0 when the boat is across the wind.
                        gfWaveSpeedEffect_x=gfWaveSpeedEffectX*llFabs(llCos(gfRWA));  //
                    }
                }else{
                    gfWaveSpeedEffect_x=0;
                }
                //END WAVE SPEED EFFECT



                //WAVE STEER EFFECT
                //When the boat goes up or down a wave it tends to cross to the direction of the wave
                //The effect is most pronounced in the middle of the wave when the boat has maximum pitch.
                //constants: cfWaveSteerFactor
                //input vars: giWaveEffects, gfWaveBoatPos, gfWaveHeightMax, gfRWA
                //output vars: gfWaveSteerEffect_z
                //temporal vars: gfSteerEffect
                if(giWaveEffects==1 || giWaveEffects==3){  //steer effect active
                    if(llFabs(gfWaveBoatPos)<0.3){ //boat is flat
                        gfSteerEffect=0.0;  //When the boat is flat the effect is 0
                    }else{   //climb or descent the wave
                        //The effect depends on the height of the wave, in the middle of the slope the greater effect
                        //gfWaveBoatPos  is the position of the boat in the wave 0-down/up 1-middle 0-up/down
                        //llCos(gfRWA) //This effect increases if the boat is going with or against the REAL wind and is reduced to 0 when the boat is across the wind.
                        gfSteerEffect = gfWaveHeightMax/7 * llFabs(gfWaveBoatPos) * llCos(gfRWA) * cfWaveSteerFactor;
                    }

                    //puts the appropriate sign depending on tack port or starboard
                    if(gvAxs.z>0) gfWaveSteerEffect_z=-gfSteerEffect;
                    else gfWaveSteerEffect_z=gfSteerEffect;
                }else{
                    gfWaveSteerEffect_z=0;
                }
                //END WAVE STEER EFFECT

                //HUD SYMBOLS                    
                if(gfWaveBoatPos>0.3) gsWaveBoatPosSymbol="/";
                else if(gfWaveBoatPos<-0.3) gsWaveBoatPosSymbol="\\";
                else gsWaveBoatPosSymbol="-";
    
                if(gfWaveBoatPos>0.3) gsWaveBoatHeelSymbol="/";
                else if(gfWaveBoatPos<-0.3) gsWaveBoatHeelSymbol="\\";
                else gsWaveBoatHeelSymbol="-";
                //END HUD SYMBOLS
            }else{
                gfWaveHeelX=gfWaveHeelY=gfWaveSpeedEffect_x=gfWaveSteerEffect_z=gfWaveHeelBoatY=gfWaveHeelBoatX=0.0;
                gsWaveBoatPosSymbol=gsWaveBoatHeelSymbol="";
                giSwSound=1; //sail
            }
            //<===CALC WAVES

            // boat wave height
            llSetVehicleFloatParam (VEHICLE_HOVER_HEIGHT, gfSeaLevel+cfFloatLevel+gfExtraHeight);

            // boat heel
            gfTotalHeelX=gfSailHeelEffect_x-gfWaveHeelBoatX*DEG_TO_RAD;
            
            //regularization of the course due to deviation due to heel and pitch
            if(gfTotalHeelX!=0 && gfWaveHeelBoatY!=0){   //when the boat is pitching and rolling we have to correct the course  
                if(gfRudderSteerEffect_z+gfWaveSteerEffect_z==0){   //if there is no change of direction produced by the rudder or the waves...
                    if(giHeadobj==-1) giHeadobj=giHead;   //after a change of course save the target heading
                    else if(giSwhead==0){    //while the head is not stabilized
                        if(giHeadobj==giHead) giSwhead=1;   //activate regularization
                        else giHeadobj=giHead;   //update target heading
                    }
                    if(giSwhead){ 
                        gfMovZ=1.5*(giHead-giHeadobj)*DEG_TO_RAD;  //if active, calc regularization Z rotation
                        if(llFabs(gfMovZ)>0.06981) gfMovZ=0;                 //<==================== added in version 1.0Beta9b
                    }
                }else{
                    giHeadobj=-1; //init stable head
                    gfMovZ=0;
                    giSwhead=0;
                }
            }else{
                gfMovZ=0;
            }
            
            // boat angular motion
            gvAngular_motor=<gfTotalHeelX,gfWaveHeelBoatY*DEG_TO_RAD,gfRudderSteerEffect_z+gfWaveSteerEffect_z+gfMovZ>;  
            llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, gvAngular_motor);
            
            //llOwnerSay("***** "+(string)gfSailSpeedEffect_x+"   "+(string)gfCurrentSpeedEffect_x+"   "+(string)gfWaveSpeedEffect_x);
            
            // boat speed
            gvLinear_motor=<gfSailSpeedEffect_x+gfCurrentSpeedEffect_x+gfWaveSpeedEffect_x,gfCurrentSpeedEffect_y,0.0>;
            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, gvLinear_motor);
            
            // optional signal color
            if(gfSailAngle < 0.435*gfAwAngle){ 
                gvColor=cvBlue;
                gsHudSymbol="<>";
            }else if(gfSailAngle < 0.565*gfAwAngle){
                gvColor=cvGreen;
                gsHudSymbol="==";
            }else if(gfSailAngle < 0.825*gfAwAngle){ 
                gvColor=cvYellow;
                gsHudSymbol="><";
            }else{ 
                gvColor=cvRed;
                gsHudSymbol=">><<";
            }
            
            if(giWindMode==0) gsWindMode="Personal ";
            else if(giWindMode==1) gsWindMode="Cruise ";
            else if(giWindMode==2) gsWindMode="Race ";            
            
            gfSpeed=llVecMag(llGetVel());    //boat speed in m/s
            if(gfSpeed<=0.514444) giSound=-1;   //1kt in m/s
            else if(gfSpeed<=1.54333) giSound=0; //3kt in m/s
            else{  
                //sections vel in %  1kt-3kt, 3kt-60%, 60%-85%, 85%-100%
                //gfSoundWind 70% wind speed
                if(gfSpeed<gfSoundWind*0.6) giSound=1;
                else if(gfSpeed<gfSoundWind*0.85) giSound=2;
                else giSound=3;  
            }

            if(giSwSound!=giSwSoundOld || giSound!=giSoundOld){
                //if(giSwSound==3) llOwnerSay("sound: waves down   level: "+(string)giSound+"    vel: "+(string)(gfSpeed/cfKt2Ms)+"/"+(string)(gfSoundWind/cfKt2Ms));
                //else llOwnerSay("sound: sailing   level: "+(string)giSound+"    vel: "+(string)(gfSpeed/cfKt2Ms)+"/"+(string)(gfSoundWind/cfKt2Ms));
                if(giSound==-1) llStopSound();
                else if(giSwSound==0) llLoopSound(gsSoundSail+(string)giSound, 1.0);
                else if(giSwSound==1) llLoopSound(gsSoundSail+(string)giSound, 1.0);
                else if(giSwSound==2) llLoopSound(gsSoundSail+(string)giSound, 1.0);
                else if(giSwSound==3) llLoopSound(gsSoundWaveDown+(string)giSound, 1.0);
                giSwSoundOld=giSwSound;
                giSoundOld=giSound;
            }

            if(giHud>0){
                string lsSymbol;
                if(gfWaveHeelX>0) gsSymbol="-";
                else gsSymbol="+";
                gsTextHud="Heading: "+(string)giHead+"º  "+gsWindMode+" Wind=> Dir: "+(string)giWindDir+"º Speed: "+(string)giWindSpeed+"kt\n"+
                    "RWA: "+(string)llRound(gfRWA*RAD_TO_DEG)+"º  "+gsHudSymbol+" AWA: "+(string)llRound(gfAwAngle*RAD_TO_DEG)+"º"+
                        "  Sheet: "+(string)llRound(gfSailAngle*RAD_TO_DEG)+"º  Shadow dir:"+(string)giWindBend+"º\n"+
                    "Vel: "+llGetSubString((string)(gfSpeed/cfKt2Ms),0,3)+"kt  Push=> Wind: "+llGetSubString((string)(llFabs(gfSailSpeedEffect_x)/cfKt2Ms),0,3)+"kt"+
                        "  Current: "+llGetSubString((string)(gfCurrentSpeedEffect_x/cfKt2Ms),0,3)+"kt"+
                        "  Waves: "+llGetSubString((string)(gfWaveSpeedEffect_x/cfKt2Ms),0,3)+"kt\n";
                if(giHud==1){
                    gsTextHud+="Heel: "+(string)llRound(gfTotalHeelX*RAD_TO_DEG)+"="+(string)llRound(gfSailHeelEffect_x*RAD_TO_DEG)+gsSymbol+(string)llAbs(llRound(gfWaveHeelX))+"º "+gsWaveBoatHeelSymbol+
                        "  Pitch: "+llGetSubString((string)gfWaveHeelY,0,3)+" "+gsWaveBoatPosSymbol+
                        "  Drift: "+llGetSubString((string)(gfCurrentSpeedEffect_y/cfKt2Ms),0,3)+"kt"+
                    //"  WaveSteer: "+llGetSubString((string)(gfRudderSteerEffect_z*RAD_TO_DEG),0,3)+"+"+llGetSubString((string)(gfWaveSteerEffect_z*RAD_TO_DEG),0,3)+"º"; 
                        "  WaveSteer: "+llGetSubString((string)(gfWaveSteerEffect_z*RAD_TO_DEG),0,3)+"º ";
                }else{
                    gsTextHud+="Waves=> MaxH: "+llGetSubString((string)(gfWaveHeightMax*2),0,3)+"m Height: "+
                        llGetSubString((string)(gfWaveHeight+gfWaveHeightMax),0,3)+"m  Depth: "+(string)(llWater(ZERO_VECTOR)-llGround(ZERO_VECTOR))+
                        "\nTurn: "+llGetSubString((string)(gfRudderSteerEffect_z*RAD_TO_DEG),0,3)+"º ";
                        
                }
            }else{
                gsTextHud="Heading: "+(string)giHead+"º  Vel: "+llGetSubString((string)(gfSpeed/cfKt2Ms),0,3)+"kt\n"+
                    gsWindMode+" Wind=> Dir: "+(string)giWindDir+"º Speed: "+(string)giWindSpeed+"kt\n"+
                    gsHudSymbol+" AWA: "+(string)llRound(gfAwAngle*RAD_TO_DEG)+"º  Sheet: "+(string)llRound(gfSailAngle*RAD_TO_DEG)+"º "+
                    "  Factor: "+llGetSubString((string)(gfAwAngle/gfSailAngle),0,2);
                if(giWindMode>0 && gfWaveHeightMax>0.0) gsTextHud+="    Wave: "+gsWaveBoatPosSymbol;
            }
            llSetLinkPrimitiveParamsFast(giTEXTHUD,[PRIM_TEXT,gsTextHud,gvColor,1.0]);
            
            // optional particles
            gfBurstrate = 5.0/(20.0*gfSpeed+1.0);
            gfBurstspeed = 0.3*gfSpeed;
            gvTemp=llRot2Euler(ZERO_ROTATION/grBoatRot);
            gvTemp.z=0;
            gvTemp.y-=25;
            llSetLinkPrimitiveParamsFast(giWAKE,[PRIM_ROT_LOCAL,llEuler2Rot(gvTemp)*ZERO_ROTATION,PRIM_POS_LOCAL,<cvWakePos.x,cvWakePos.y,cvWakePos.z-gfExtraHeight>]);   
                     
            llLinkParticleSystem(giWAKE, [
                PSYS_PART_FLAGS , 0
                | PSYS_PART_INTERP_COLOR_MASK       //Colors fade from start to end
                | PSYS_PART_INTERP_SCALE_MASK       //Scale fades from beginning to end
                ,
                PSYS_SRC_PATTERN,            PSYS_SRC_PATTERN_ANGLE_CONE
                ,PSYS_SRC_TEXTURE,           ""                 //UUID of the desired particle texture, or inventory name
                ,PSYS_SRC_MAX_AGE,           0.0                //Time, in seconds, for particles to be emitted. 0 = forever
                ,PSYS_PART_MAX_AGE,          10.0               //Lifetime, in seconds, that a particle lasts
                ,PSYS_SRC_BURST_RATE,        gfBurstrate          //How long, in seconds, between each emission
                ,PSYS_SRC_BURST_PART_COUNT,  100                //Number of particles per emission
                ,PSYS_SRC_BURST_RADIUS,      .05                //Radius of emission
                ,PSYS_SRC_BURST_SPEED_MIN,   gfBurstspeed         //Minimum speed of an emitted particle
                ,PSYS_SRC_BURST_SPEED_MAX,   gfBurstspeed*1.1     //Maximum speed of an emitted particle
                ,PSYS_SRC_ACCEL,             <.0,.0,-.1>        //Acceleration of particles each second
                ,PSYS_PART_START_COLOR,      <1.0,1.0,1.0>      //Starting RGB color
                ,PSYS_PART_END_COLOR,        <0.3,0.4,0.5>      //Ending RGB color, if INTERP_COLOR_MASK is on
                ,PSYS_PART_START_ALPHA,      1.0                //Starting transparency, 1 is opaque, 0 is transparent.
                ,PSYS_PART_END_ALPHA,        0.0                //Ending transparency
                ,PSYS_PART_START_SCALE,      <0.8,0.10,0.0>     //Starting particle size
                ,PSYS_PART_END_SCALE,        <1.5,0.05,0.0>     //Ending particle size, if INTERP_SCALE_MASK is on
                ,PSYS_SRC_ANGLE_BEGIN,       1.62               //Inner angle for ANGLE patterns
                ,PSYS_SRC_ANGLE_END,         1.62               //Outer angle for ANGLE patterns
                ,PSYS_SRC_OMEGA,             <0.0,0.0,0.0>      //Rotation of ANGLE patterns, similar to llTargetOmega()
                ]);
                
            //start timer
            if(gfWaveHeightMax>0) llSetTimerEvent(1.0);
            else llSetTimerEvent(cfTime);
        } else {
            llLinkParticleSystem(giWAKE,[]);
            llSetTimerEvent( 0.0);
        }
    }
}