key gkCrew;
string gsAnim;
integer giCrewLink;
integer giNumOfPrims;
integer giCREW;

getLinkNums() 
{
    integer liI;
    integer liLinkCount=llGetNumberOfPrims();
    string lsStr;
    for (liI=1;liI<=liLinkCount;++liI) {
        lsStr=llGetLinkName(liI);
        if (lsStr=="crew") giCREW=liI;
    }
}

sitCrew()
{
    key lkAvi = llAvatarOnLinkSitTarget(giCREW);
    if(lkAvi){
        if(gkCrew){ 
            return;
        }else{
            if(lkAvi!=llGetOwner()){
                gkCrew=lkAvi;
                giCrewLink=llGetNumberOfPrims();
                llSetLinkPrimitiveParamsFast(giCrewLink,[PRIM_POS_LOCAL,<-0.7, 0.0, 1.17>]);
                gsAnim="crewPort";
                llRequestPermissions(gkCrew, PERMISSION_TRIGGER_ANIMATION | PERMISSION_CONTROL_CAMERA);
            }
        }
    }else{
        if(gkCrew){
            gkCrew="";
            giCrewLink=0;
        }
    }
}

default
{
    state_entry()
    {
        giNumOfPrims=llGetObjectPrimCount(llGetKey());
        getLinkNums();
        if(llGetNumberOfPrims()>giNumOfPrims){
            sitCrew();
        }
        //llOwnerSay("Ready "+llGetScriptName()+" "+(string)llGetFreeMemory());
    }

    changed(integer piChange)
    {
        if (piChange & CHANGED_LINK){
            sitCrew();
        }
    } 
    
    run_time_permissions(integer perm)
    {
        if ( perm & PERMISSION_TRIGGER_ANIMATION ) {
            list laAnims=llGetAnimationList(gkCrew);    
            integer liN=llGetListLength(laAnims);
            integer liI; 
            if(llGetAgentSize(gkCrew)){   ´
                for(liI=0;liI<liN;liI++){
                    if((key)llList2String(laAnims,liI)) llStopAnimation(llList2String(laAnims,liI));
                }
            }   
            llStartAnimation(gsAnim);            
        }
        if ( perm & PERMISSION_CONTROL_CAMERA ) { 
            llClearCameraParams(); // reset camera to default
            list laParams=[CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
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
                ];
            llSetCameraParams(laParams);        
        }
    }       
    
    link_message(integer piSender_num, integer piNum, string psMsg, key pkId)    
    {
        if(psMsg=="crewport"){
            if(llGetPermissions() & PERMISSION_TRIGGER_ANIMATION){
                if(gkCrew==llGetLinkKey(giNumOfPrims+1)) giCrewLink=giNumOfPrims+1;
                else if(gkCrew==llGetLinkKey(giNumOfPrims+2)) giCrewLink=giNumOfPrims+2;
                else giCrewLink=0;
                if(giCrewLink>0) llSetLinkPrimitiveParamsFast(giCrewLink,[PRIM_POS_LOCAL,<-0.7, 0.0, 1.17>]);
                llStopAnimation(gsAnim); 
                gsAnim="crewPort";
                llStartAnimation(gsAnim);
            }
        }else if(psMsg=="crewstb"){
            if(llGetPermissions() & PERMISSION_TRIGGER_ANIMATION){ 
                if(gkCrew==llGetLinkKey(giNumOfPrims+1)) giCrewLink=giNumOfPrims+1;
                else if(gkCrew==llGetLinkKey(giNumOfPrims+2)) giCrewLink=giNumOfPrims+2;
                else giCrewLink=0;
                if(giCrewLink>0) llSetLinkPrimitiveParamsFast(giCrewLink,[PRIM_POS_LOCAL,<-0.7, 0.0, 1.17>]);
                llStopAnimation(gsAnim); 
                gsAnim="crewStb";
                llStartAnimation(gsAnim); 
            }
        }
    }    
}
