<?php header("content-type: text/plain; charset=utf-8"); ?>
<?php
//GLW Update Event from Wind Setter

$headers    = apache_request_headers();
$objectgrid = $headers["X-Secondlife-Shard"];
$objectname = $headers["X-Secondlife-Object-Name"];
$objectkey  = $headers["X-Secondlife-Object-Key"];
$objectpos  = $headers["X-Secondlife-Local-Position"];
$ownerkey   = $headers["X-Secondlife-Owner-Key"];
$ownername  = $headers["X-Secondlife-Owner-Name"];
$regiondata = $headers["X-Secondlife-Region"];
$regiontmp  = explode ("(",$regiondata);            // cut cords off
$regionname = substr($regiontmp[0],0,-1);           // cut last space from simname
$regiontmp  = explode (")",$regiontmp[1]);
$regionpos  = $regiontmp[0];

$data       = file_get_contents("php://input");
$listas     = explode("##",$data);
$control    = $listas[0];              //control data
$wind      = explode(",",$listas[1]);  //wind data
require '../../glwdb.php';

$idEvents=(integer)$wind[0];
if ($idEvents == 0) {
    die("KOError id of event");
}

$nt=count($wind);
$sqlvalues="";
if($nt<22) die("KOError parameters number ");

$sqlvalues="wndDir=".$wind[1].",".
    "wndSpeed=".$wind[2].",".
    "wndGusts=".$wind[3].",".
    "wndShifts=".$wind[4].",".
    "wndPeriod=".$wind[5].",".

    "wavSpeed=".$wind[6].",".
    "wavHeightVariance=".$wind[7].",".
    "wavLengthVariance=".$wind[8].",".
    "wavHeight=".$wind[9].",".
    "wavLength=".$wind[10].",".
    "wavEffects=".$wind[11].",".

    "crtDir=".$wind[12].",".
    "crtSpeed=".$wind[13].",".

    "sailMode=".$wind[14].",".
    "eventName='".$wind[15]."',".
    "eventKey='".$wind[16]."',".
    "extra1='".$wind[17]."',".
    "extra2='".$wind[18]."',".
    "waterDepth=".$wind[19].",".
    "updBoatPos=".$wind[20].",".
    "wavesType='".$wind[21]."',".
    "systemMode=".$wind[22];

//update event data
$sql="UPDATE glwEvents SET ".$sqlvalues." WHERE id=".$idEvents;
if($conn->query($sql)) {
}else{
    die("KOError: " . $sql . "\n" . $conn->error);
}
//add modif register
$sWind="0";
if(substr($control,0,1)=="1") $sWind="1".$listas[1];
$sql="INSERT INTO glwModif (idEvents,data,wind) VALUES ($idEvents,'$data','$sWind')";
if($conn->query($sql)) {
}else{
    die("KOError save modif: " . $sql . "\n" . $conn->error);
}

//save Areas Items if changed
if(substr($control,1,1)=="1"){
    $sqldel = "DELETE FROM glwVariations WHERE idEvents=".$idEvents." and type=1";   //type=1 Areas
    $conn->query($sqldel);
    if($listas[2]!=""){    //Areas
        $vars = explode("$$",$listas[2]);
        $nt=sizeof($vars);
        for($i=0;$i<$nt;$i++){
            $parts=explode(":",$vars[$i]);    
            $cols=explode(",",$parts[0]);   //active,sim1,corner1x,corner1y,sim2,corner2x,corner2y,margin 
            $windvar=wind2Boat($wind,$parts[1]);
            //coords are sim coords values
            $sql = "INSERT INTO glwVariations (idEvents,type,coord1X,coord1Y,coord2X,coord2Y,margin,overlap,itemData,windData,wind2Boat) 
                VALUES ($idEvents,1,$cols[2]/256,$cols[3]/256,$cols[5]/256,$cols[6]/256,$cols[7],$cols[8],'$parts[0]','$parts[1]','$windvar')";
            if ($conn->query($sql) === TRUE) {
            }else{ 
                print "Error1: " . $sql . "<br>" . $conn->error;
            }
        }
    }
}

//save Circles Items if changed
if(substr($control,2,1)=="1"){
    $sqldel = "DELETE FROM glwVariations WHERE idEvents=".$idEvents." and type=2)";  //type=2 Circles
    $conn->query($sqldel);
    if($listas[3]!=""){   //Circles
        $vars = explode("$$",$listas[3]);
        $nt=sizeof($vars);
        for($i=0;$i<$nt;$i++){
            $parts=explode(":",$vars[$i]);    
            $cols=explode(",",$parts[0]);  //active,sim1,global1x,global1y,sim2,global2x,global2y,radius,margin
            $simX=(integer)($cols[2]/256); //coord sim x
            $localX=$cols[2]-($simX*256);  //local pos x
            $simY=(integer)($cols[3]/256);  //coord sim y
            $localY=$cols[3]-($simY*256);  //local pos y
            $radius=$cols[7];
            $margin=$cols[8];
            $overlap=$cols[9];
            if($margin>$radius-5) $margin=$radius-5;
            $windvar=wind2Boat($wind,$parts[1]);

            $sql = "INSERT INTO glwVariations (idEvents,type,coord1X,coord1Y,coord2X,coord2Y,radius,margin,overlap,itemData,windData,wind2Boat) 
                VALUES ($idEvents,2,$simX,$simY,$localX,$localY,$radius,$margin,$overlap,'$parts[0]','$parts[1]','$windvar')";
            if ($conn->query($sql) === TRUE) {
            }else print "Error2: " . $sql . "<br>" . $conn->error;
        }
    }
}

//create the variation map
if(substr($control,1,2)!="00"){    // there are variations

    //delete variations map
    $sqldel = "DELETE FROM glwEventsMap WHERE idEvents=".$idEvents;
    $conn->query($sqldel);                    

    if($listas[2]!="" || $listas[3]!=""){    //the lists of areas or circles are not empty
        //create sims map
        $sql = "SELECT id,type,coord1X,coord1Y,coord2X,coord2Y,radius,margin,overlap FROM glwVariations ".
                "WHERE idEvents=".$idEvents." ORDER BY overlap,type,id";
        $result = $conn->query($sql);
        if($result){
            $totalVars=$result->num_rows;
            if($totalVars>0){
                foreach($result as $field=>$value){
                    if($value['type']==1){
                        addAreaSims($conn,$idEvents,$value['id'],$value['coord1X'],$value['coord1Y'],$value['coord2X'],$value['coord2Y'],$value['margin'],$value['overlap']);
                    }else{
                        //addCirclesSims(conn, idevent, id,centerposX,centerposY,radius,margin,overlap)
                        addCirclesSims($conn,$idEvents,$value['id'],256*$value['coord1X']+$value['coord2X'],256*$value['coord1Y']+$value['coord2Y'],$value['radius'],$value['margin'],$value['overlap']);
                    }
                }
            }
        }

        //delete duplicate sims registers map
        $sql = "SELECT id,mapSimX,mapSimY FROM glwEventsMap ".
                "WHERE idEvents=".$idEvents." ORDER BY mapSimX DESC, mapSimY DESC, overlap DESC, type DESC, id DESC";
        $result = $conn->query($sql);
        if($result){
            $totalVars=$result->num_rows;
            if($totalVars>0){
                $varX=0;
                $varY=0;
                $vid=0;
                foreach($result as $field=>$value){
                    if($value['mapSimX']==$varX && $value['mapSimY']==$varY){
                        $vid=$value['id'];
                        $sqldel = "DELETE FROM glwEventsMap WHERE id=".$vid;
                        $conn->query($sqldel);                    
                    }else{
                        $varX=$value['mapSimX'];
                        $varY=$value['mapSimY'];
                    }
                }
            }
        }
    }
}

//send base wind data to boats if changed
if(substr($control,0,1)=="1"){
    //set ifModif=1 all boats event
    $sql="UPDATE glwBoats SET ifModif=1 WHERE idEvents=".$idEvents;
    if($conn->query($sql)) {
    }else{
        die("KOError reset modif: " . $sql . "\n" . $conn->error);
    }
    //preparing data
    $boatdata="";
    for($i=0;$i<=21;$i++){
        if($i!=16){
            $boatdata.=$wind[$i].",";
        }
    }
    $boatdata.=$wind[22];
    
    //call polling function
    $return="KOpolling not started";
    $data2Send=$boatdata;
    $pollMode=1; //modif boat data  1-update   2-scan
    $pollclave="glwUpdData";  //key modif boat data

    //callback function for each boat OK
    function fcallback($pdata,$pconn){
        if(substr($pdata,0,2)=="OK"){
            $idBoat=substr($pdata,2);
            $sql="UPDATE glwBoats SET ifModif=2 WHERE id=".$idBoat;
            $pconn->query($sql);
        }
    }

    //need $idEvents, $data2Send, $pollMode, $conn
    //return $pollreturn
    require 'glwPollBoats.php';

    //result polling function
    if(isset($pollreturn)){
        $return=$pollreturn;
    }
    echo $return;
}else{
    echo "OK,0,-1";
}
$conn->close();



function addAreaSims($pConn,$pIdEvents,$pId,$pSim1X,$pSim1Y,$pSim2X,$pSim2Y,$pMargin,$pOverlap)
{
    $Sim1X=$pSim1X;
    $Sim1Y=$pSim1Y;
    $Sim2X=$pSim2X;
    $Sim2Y=$pSim2Y;
    if($pSim1X>$pSim2X || $pSim1Y>$pSim2Y){
        if($pSim2X<$pSim1X){
            $Sim1X=$pSim2X;
            $Sim2X=$pSim1X;
        }
        if($pSim2Y<$pSim1Y){
            $Sim1Y=$pSim2Y;
            $Sim2Y=$pSim1Y;
        }
    }
    for($y=$Sim1Y; $y<=$Sim2Y; $y++){
        for($x=$Sim1X; $x<=$Sim2X; $x++){
            $margins="";
            if($y==$Sim2Y) $margins.=(string)$pMargin.",";  //up margin
            else $margins.="0,";
            if($x==$Sim2X) $margins.=(string)$pMargin.",";  //left margin
            else $margins.="0,";
            if($y==$Sim1Y) $margins.=(string)$pMargin.",";  //bottom margin
            else $margins.="0,";
            if($x==$Sim1X) $margins.=(string)$pMargin;  //right margin
            else $margins.="0";
            if($margins=="0,0,0,0") $type=10;
            else $type=11;
            $margins.=",".$pOverlap;
            $sql = "INSERT INTO glwEventsMap (idEvents,idVars,mapSimX,mapSimY,type,simValues) 
                VALUES ($pIdEvents,$pId,$x,$y,$type,'$margins')";
            if ($pConn->query($sql) === TRUE) {
            }else print "Error3: " . $sql . "<br>" . $pConn->error;
        }
    }
}

function addCirclesSims($pConn,$pIdEvents,$pId,$pGlobalX,$pGlobalY,$pRadius,$pMargin,$pOverlap)
{
    $vx1=$pGlobalX-$pRadius;   //Global SW sim x
    $vy1=$pGlobalY-$pRadius;   //Global SW sim y
    $vx2=$pGlobalX+$pRadius;   //Global NE sim x
    $vy2=$pGlobalY+$pRadius;   //Global NE sim x

    $vx1=(integer)($vx1/256)*256;  //corner SW sim x
    $vy1=(integer)($vy1/256)*256;  //corner SW sim y
    $vx2=(integer)($vx2/256)*256;  //corner NE sim x
    $vy2=(integer)($vy2/256)*256;  //corner NE sim y
    
    //walk all sims within the detected area
    for($y=$vy1; $y<=$vy2; $y+=256){
        for($x=$vx1; $x<=$vx2; $x+=256){
            //for each sim find the distances of each vertex
            $dsw=sqrt(pow($pGlobalX-$x,2)+pow($pGlobalY-$y,2)); //SW corner distance to center
            $dse=sqrt(pow($pGlobalX-($x+256),2)+pow($pGlobalY-$y,2)); //SE corner distance to center
            $dnw=sqrt(pow($pGlobalX-$x,2)+pow($pGlobalY-($y+256),2));  //NW corner distance to center
            $dne=sqrt(pow($pGlobalX-($x+256),2)+pow($pGlobalY-($y+256),2)); //NE corner distance to center
            
            $sw=1; //is on the circunference
            if($dsw<$pRadius && $dse<$pRadius && $dnw<$pRadius && $dne<$pRadius) $sw=0;  //is inside the circumference
            else if($dsw>$pRadius && $dse>$pRadius && $dnw>$pRadius && $dne>$pRadius) $sw=2;   //is outside the circumference
            
            if($sw==0){     //if it is inside the circle, do the margins in the internal sim affect it?
                $internRadius=$pRadius-$pMargin;
                if($dsw<$internRadius && $dse<$internRadius && $dnw<$internRadius && $dne<$internRadius) $sw=0;  //is inside the margins
                else $sw=1; //is affected by the margin
            }else if($pRadius<182){  //possible internal sim radius 
                if($sw==2){ //check that it is not the sim where the center is
                    if((integer)($pGlobalX/256)==(integer)($x/256) && (integer)($pGlobalY/256)==(integer)($y/256)){ //is the center sim
                        $sw=1;
                    }else{
                        //if The center of the center sides distance to center < radius
                        if(sqrt(pow($pGlobalX-$x,2)+pow($pGlobalY-($y+128),2))<$pRadius) $sw=1; //east side
                        else if(sqrt(pow($pGlobalX-($x+128),2)+pow($pGlobalY-($y+256),2))<$pRadius) $sw=1; //north side
                        else if(sqrt(pow($pGlobalX-($x+256),2)+pow($pGlobalY-($y+128),2))<$pRadius) $sw=1; //west side
                        else if(sqrt(pow($pGlobalX-($x+128),2)+pow($pGlobalY-$y,2))<$pRadius) $sw=1; //south side
                    }
                }
            }
            
            if($sw<2){
                $sql = "INSERT INTO glwEventsMap (idEvents,idVars,mapSimX,mapSimY,type,simValues) 
                    VALUES ($pIdEvents,$pId,".(string)((integer)($x/256)).",".(string)((integer)($y/256)).",".(string)(20+$sw).",'$pGlobalX,$pGlobalY,$pRadius,$pMargin,$pOverlap')";
                if ($pConn->query($sql) === TRUE) {
                }else print "Error4: " . $sql . "<br>" . $pConn->error;
            }
            //echo "for $x $y $sw $dsw $dse $dnw $dne \n";
            //echo "for $x $y $sw $dist \n";
        }
    }
}

function wind2Boat($pWindData,$pWindVars)   //updates the base wind with local variations
{
    //$pWindData=      //base wind
        //wndDir,wndSpeed,wndGusts,wndShifts,wndPeriod,
        //wavSpeed,wavHeightVariance,wavLengthVariance,wavHeight,wavLength,effects
        //crtDir,crtSpeed,
        //sailMode,eventName,extra1,extra2,waterDepth,updBoatPos,wavesType,systemMode)
    //$pWindVars=      //variations wind   only the elements that have changed
        //wndDir,wndSpeed,wndGusts,wndShifts,wndPeriod,
        //wavHeight,wavSpeed,wavLength,wavHeightVariance,wavLengthVariance,steerEffect,speedEffect
        //crtSpeed,crtDir,waterDepth 
    //return=      //sort windvars and fill them with the wind base
        //wndDir,wndSpeed,wndGusts,wndShifts,wndPeriod,
        //wavSpeed,wavHeightVariance,wavLengthVariance,wavHeight,wavLength,effects
        //crtDir,crtSpeed,waterDepth 

    $windvar=explode(",",$pWindVars); 
    $windvar=array_map('trim', $windvar);
    $res=array();
    $nt=sizeof($windvar);
    if($nt>0){
        if($windvar[0]=="") $res[]=$pWindData[1]; //wind direction
        else $res[]=$windvar[0];
        if($windvar[1]=="") $res[]=$pWindData[2]; //wind speed
        else $res[]=$windvar[1];
        if($windvar[2]=="") $res[]=$pWindData[3]; //wind gusts
        else $res[]=$windvar[2];
        if($windvar[3]=="") $res[]=$pWindData[4]; //wind shifts
        else $res[]=$windvar[3];
        if($windvar[4]=="") $res[]=$pWindData[5]; //wind period
        else $res[]=$windvar[4];

        if($windvar[6]=="") $res[]=$pWindData[6]; //wave speed
        else $res[]=$windvar[6];
        if($windvar[8]=="") $res[]=$pWindData[7]; //wave height variance
        else $res[]=$windvar[8];
        if($windvar[9]=="") $res[]=$pWindData[8]; //wave length variance
        else $res[]=$windvar[9];
        if($windvar[5]=="") $res[]=$pWindData[9]; //wave height
        else $res[]=$windvar[5];
        if($windvar[7]=="") $res[]=$pWindData[10]; //wave length
        else $res[]=$windvar[7];
        //wav effects
        $steer="0";
        $speed="0";
        if($pWindData[11]=="1" || $pWindData[11]=="3") $steer="1";
        if($pWindData[11]=="2" || $pWindData[11]=="3") $speed="1";
        if($windvar[10]!="") $steer=$windvar[10];
        if($windvar[11]!="") $speed=$windvar[11];
        $res[]=(string)((integer)$speed*2+(integer)$steer);

        if($windvar[13]=="") $res[]=$pWindData[12]; //current dir
        else $res[]=$windvar[13];
        if($windvar[12]=="") $res[]=$pWindData[13]; //current speed
        else $res[]=$windvar[12];
        if($windvar[14]=="") $res[]=$pWindData[19]; //water depth
        else $res[]=$windvar[14];
        
        return implode(",",$res);
    }else{
        return "";
    }
}
?>


























