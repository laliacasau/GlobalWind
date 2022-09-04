<?php header("content-type: text/plain; charset=utf-8"); ?>
<?php
// Mind that some headers are not included because they're either useless or unreliable. X-Secondlife-Local-Position 
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

require '../../glwdb.php';

$idEvents=(integer)$data;
if ($idEvents == 0) {
    die("KOError id of event");
}

//load data to send
$sWind="0";
$sql="SELECT wind from glwModif WHERE idEvents=".$idEvents;
$result = $conn->query($sql);
if($result){
    foreach($result as $field=>$value){
        $sWind=$value['wind'];
    }
}
if(substr($sWind,0,1)=="0"){
    die("OK,0,-1");
}
//repeat send base wind data to boats if changed

//call polling function
$return="KOpolling not started";
$data2Send=substr($sWind,1);
$pollMode=1; //modif boat data
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

$conn->close();

?>


























