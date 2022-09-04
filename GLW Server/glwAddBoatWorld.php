<?php header("content-type: text/plain; charset=utf-8"); ?>
<?php
// Mind that some headers are not included because they're either useless or unreliable. X-Secondlife-Local-Position 
// apache headers
$headers    = apache_request_headers();
$objectgrid = $headers["X-SecondLife-Shard"];
$objectname = $headers["X-SecondLife-Object-Name"];
$objectkey  = $headers["X-SecondLife-Object-Key"];
$objectpos  = $headers["X-SecondLife-Local-Position"];
$ownerkey   = $headers["X-SecondLife-Owner-Key"];
$ownername  = $headers["X-SecondLife-Owner-Name"];
$regiondata = $headers["X-SecondLife-Region"];
$regiontmp  = explode ("(",$regiondata);        // cut cords off
$regionpos  = explode (")",$regiontmp[1]);
$regionpos  = explode (",",$regionpos[0]);
$regionname = substr($regiontmp[0],0,-1);       // cut last space from simname

$data       = file_get_contents("php://input");
$cols       = explode(",",$data);

require '../../glwdb.php';

$baseWind="";
$sql = "SELECT baseWind FROM glwWorldBase WHERE code=1";
$result = $conn->query($sql);
$numRows=$result->num_rows;
if ($numRows > 0) {
    foreach($result as $row){
        $baseWind=$row['baseWind'];
    }
} else {
    $conn->close();
    die("KOAddBoatWorld Error: " . $sql . "<br>" . $conn->error);
}

$sql = "DELETE FROM glwBoats WHERE idEvents=0 AND boatOwner='".$ownerkey."'";
$conn->query($sql);

$boatSimX=(integer)($regionpos[0]/256);
$boatSimY=(integer)($regionpos[1]/256);
$boatpostmp=substr($objectpos,1,-2);
$boatposcoord=explode(",",$boatpostmp);
$boatX=(integer)($boatposcoord[0]+0.5);
$boatY=(integer)($boatposcoord[1]+0.5);
$posResident=strpos($ownername," Resident");
if($posResident>0) $ownerName=substr($ownername,0,$posResident);
else $ownerName=$ownername;

$regionname=str_replace("'","''",$regionname);
$sql = "INSERT INTO glwBoats (idEvents,boatOwner,boatUrl,boatSimName,boatSimX,boatSimY,boatX,boatY,ownerName,boatKey,windMode)
            VALUES (0,'$ownerkey','$cols[0]','$regionname',$boatSimX,$boatSimY,$boatX,$boatY,'$ownerName','$cols[1]',$cols[2])";
if ($conn->query($sql) === TRUE) {
    $idBoats = $conn->insert_id;
    
    //return sims data
    $retType=array(0,0,0,0,0,0,0,0,0);
    $retData=array();
    /*
    //select 9 sims around boat position with local variations
    $sql = "SELECT map.mapSimX,map.mapSimY,map.type,map.simValues,vars.wind2Boat FROM glwWorldMap map ".
            "INNER JOIN glwWorldVars vars ON map.idVars = vars.id ".
            "WHERE ".
            "map.mapSimX>=".(string)($boatSimX-1)." and map.mapSimX<=".(string)($boatSimX+1)." and ".
            "map.mapSimY>=".(string)($boatSimY-1)." and map.mapSimY<=".(string)($boatSimY+1)." ". 
            "ORDER BY map.mapSimY,map.mapSimX";
    $result = $conn->query($sql);
    if($result){
        $totalVars=$result->num_rows;
        if($totalVars>0){
            $nData=0;
            foreach($result as $row){
                $nSim=$row['mapSimY']-($boatSimY-1);
                $nSim=$nSim*3+($row['mapSimX']-($boatSimX-1));
                if($nSim>=0 && $nSim<9){
                    $nData++;
                    $retType[$nSim]=$nData;
                    $retData[$nData-1]=$row['type'].",".$row['simValues'].":".$row['wind2Boat'];
                }
            }
        }
    }
     */
    $ret=implode("",$retType)."#";
    if($nData>0) $ret.=implode("$",$retData);
    
    print "OK,".$idBoats."#".$baseWind."#".$ret;
} else {
    print "KOAddBoat Error3: " . $sql . "\n" . $conn->error;
}
$conn->close();

?>