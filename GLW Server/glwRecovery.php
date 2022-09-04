<?php header("content-type: text/plain; charset=utf-8"); ?>
<?php
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
//$cols       = explode(",",$data);

require '../../glwdb.php';

$idEvents=0;
$windMode=0;
$idBoat=0;

$sql = "SELECT id,idEvents,windMode FROM glwBoats WHERE boatOwner='".$data."' ORDER BY updTime DESC";
$result = $conn->query($sql);
$numRows=$result->num_rows;
if ($numRows == 0) {
    $conn->close();
    die("OK1The owner of the boat has not been found in any event");
} else {
    foreach($result as $field=>$value){
        $idBoat=$value['id'];
        $idEvents=$value['idEvents'];
        $windMode=$value['windMode'];
    }
}

$sql = "SELECT * FROM glwEvents WHERE id=".$idEvents;
$result = $conn->query($sql);
$numRows=$result->num_rows;
if ($numRows == 0) {
    $conn->close();
    die("OK2The event you were subscribed to was not found");
} else {
    $s="";
    foreach($result as $field=>$value){
        $s=$value['directorKey'].",".$value['eventNum'].",".$idEvents.",".$value['server'].",".$value['directorName'].",".
            $value['wndDir'].",".$value['wndSpeed'].",".$value['wndGusts'].",".$value['wndShifts'].",".$value['wndPeriod'].",".
            $value['wavSpeed'].",".$value['wavHeightVariance'].",".$value['wavLengthVariance'].",".$value['wavHeight'].",".
            $value['wavLength'].",".$value['wavEffects'].",".$value['crtDir'].",".$value['crtSpeed'].",".
            $value['sailMode'].",".$value['eventName'].",".$value['extra1'].",".$value['extra2'].",".
            $value['waterDepth'].",".$value['updBoatPos'].",".$value['wavesType'].",".$value['systemMode'].",".$idBoat;
    }
    echo "OK0".$windMode.",".$s;
}
$conn->close();
?>