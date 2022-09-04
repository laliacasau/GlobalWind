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

$nt=count($cols);
if($nt!=2) die("KOError parameters number");

$idBoat=(integer)$cols[0];
$urlBoat=$cols[1];
if ($idBoat == 0) {
    die("KOError id of boat");
}else if ($urlBoat == "") {
    die("KOError boat url");
}

$boatSimX=(integer)($regionpos[0]/256);
$boatSimY=(integer)($regionpos[1]/256);
$boatpostmp=substr($objectpos,1,-2);
$boatposcoord=explode(",",$boatpostmp);
$boatX=(integer)($boatposcoord[0]+0.5);
$boatY=(integer)($boatposcoord[1]+0.5);

$regionname=str_replace("'","''",$regionname);
$sql="UPDATE glwBoats SET boatUrl='$urlBoat',boatSimName='$regionname',boatSimX=$boatSimX,boatSimY=$boatSimY,
        boatX=$boatX,boatY=$boatY WHERE id=$idBoat";
if($conn->query($sql)) {
    //return sims data
    $retType=array(0,0,0,0,0,0,0,0,0);
    $retData=array();
    /*
    //select 9 sims around boat position with local variations
    $sql = "SELECT map.mapSimX,map.mapSimY,map.type,map.simValues,vars.wind2Boat FROM glwEventsMap map ".
            "INNER JOIN glwVariations vars ON map.idVars = vars.id ".
            "WHERE map.idEvents=".$idEvents." and ".
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
        
    echo "OK#".$ret;    
    
}else{
    die("KOError requestSimData: " . $sql . "\n" . $conn->error);
}
//echo "OK#000000000";

$conn->close();
?>


























