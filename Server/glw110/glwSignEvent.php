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


$idEvents=(integer)$cols[0];
$idCounter=(integer)$cols[1];
if ($idEvents == 0) {
    die("KOError id of event");
}

$regionname=str_replace("'","''",$regionname);
$sqlvalues="setterSimName='$regionname',counter=$idCounter";

//update event data
$sql="UPDATE glwEvents SET ".$sqlvalues." WHERE id=".$idEvents;
if($conn->query($sql)) {
}else{
    die("KOError: " . $sql . "\n" . $conn->error);
}
echo "OK".$idEvents;
$conn->close();
?>


























